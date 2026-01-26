--[[
    ═══════════════════════════════════════════════════════
    🎣 FISCH AUTO - FIXED VERSION
    By: SanzzAza (Original) | Fixed & Improved
    
    FIXES:
    ✅ Memory leak fixed (proper cleanup)
    ✅ Draggable fixed (custom implementation)
    ✅ Button click fixed (executor compatible)
    ✅ VirtualInputManager fallbacks
    ✅ Anti-detection improvements
    ✅ Better error handling
    ✅ Connection management
    ═══════════════════════════════════════════════════════
]]

-- ════════════════════════════════════════════════════════
-- CLEANUP OLD INSTANCE
-- ════════════════════════════════════════════════════════
if _G.FischAutoRunning then
    _G.FischAutoRunning = false
    task.wait(0.5)
end

if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("FischGUI") then
    game:GetService("Players").LocalPlayer.PlayerGui.FischGUI:Destroy()
end

print("════════════════════════════════════════")
print("🎣 FISCH AUTO - FIXED VERSION")
print("════════════════════════════════════════")

-- ════════════════════════════════════════════════════════
-- WAIT FOR GAME
-- ════════════════════════════════════════════════════════
repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- VirtualInputManager with safety check
local VIM
pcall(function()
    VIM = game:GetService("VirtualInputManager")
end)

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ════════════════════════════════════════════════════════
-- EXECUTOR COMPATIBILITY
-- ════════════════════════════════════════════════════════
local ExecutorName = "Unknown"
pcall(function()
    if identifyexecutor then
        ExecutorName = identifyexecutor()
    elseif getexecutorname then
        ExecutorName = getexecutorname()
    end
end)

local function FireSignal(signal)
    local success = false
    
    -- Method 1: firesignal
    if not success then
        pcall(function()
            if firesignal then
                firesignal(signal)
                success = true
            end
        end)
    end
    
    -- Method 2: syn.fire_signal (Synapse)
    if not success then
        pcall(function()
            if syn and syn.fire_signal then
                syn.fire_signal(signal)
                success = true
            end
        end)
    end
    
    -- Method 3: fluxus
    if not success then
        pcall(function()
            if getconnections then
                for _, conn in pairs(getconnections(signal)) do
                    if conn.Fire then
                        conn:Fire()
                        success = true
                    end
                end
            end
        end)
    end
    
    return success
end

local function SafeKeyPress(keyCode)
    -- Method 1: VirtualInputManager
    if VIM then
        pcall(function()
            VIM:SendKeyEvent(true, keyCode, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, keyCode, false, game)
        end)
    end
    
    -- Method 2: keypress/keyrelease
    pcall(function()
        if keypress and keyrelease then
            keypress(keyCode)
            task.wait(0.05)
            keyrelease(keyCode)
        end
    end)
end

local function SafeMouseClick()
    -- Method 1: VirtualInputManager
    if VIM then
        pcall(function()
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.05)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
    end
    
    -- Method 2: mouse1click
    pcall(function()
        if mouse1click then
            mouse1click()
        end
    end)
end

-- ════════════════════════════════════════════════════════
-- SCRIPT STATE MANAGEMENT
-- ════════════════════════════════════════════════════════
_G.FischAutoRunning = true

local Connections = {}
local Threads = {}

local function Connect(signal, func)
    local conn = signal:Connect(func)
    table.insert(Connections, conn)
    return conn
end

local function SpawnThread(func)
    local thread = task.spawn(func)
    table.insert(Threads, thread)
    return thread
end

local function Cleanup()
    print("🧹 Cleaning up...")
    _G.FischAutoRunning = false
    
    -- Disconnect all connections
    for _, conn in pairs(Connections) do
        pcall(function() 
            conn:Disconnect() 
        end)
    end
    Connections = {}
    
    -- Cancel all threads
    for _, thread in pairs(Threads) do
        pcall(function() 
            task.cancel(thread) 
        end)
    end
    Threads = {}
    
    print("✅ Cleanup complete!")
end

-- ════════════════════════════════════════════════════════
-- CONFIG
-- ════════════════════════════════════════════════════════
_G.FischConfig = _G.FischConfig or {
    Enabled = true,
    AutoCast = true,
    AutoReel = true,
    AutoShake = true,
    
    -- Timing (dengan randomization)
    ReelDelayMin = 0.2,
    ReelDelayMax = 0.5,
    CastDelayMin = 2.5,
    CastDelayMax = 4.0,
    
    -- Debug
    ShowDebug = true,
}

local Config = _G.FischConfig

_G.FischStats = {
    Fish = 0,
    Casts = 0,
    Reels = 0,
    Shakes = 0,
    Start = tick(),
}

local Stats = _G.FischStats

-- ════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ════════════════════════════════════════════════════════
local function RandomDelay(min, max)
    return min + math.random() * (max - min)
end

local function Debug(...)
    if Config.ShowDebug then
        print("🐛 [DEBUG]", ...)
    end
end

local function Log(...)
    print("🎣 [FISCH]", ...)
end

local function IsRunning()
    return _G.FischAutoRunning and Config.Enabled
end

-- ════════════════════════════════════════════════════════
-- FIND REMOTES (IMPROVED)
-- ════════════════════════════════════════════════════════
local AllRemotes = {}
local CategorizedRemotes = {
    Cast = {},
    Reel = {},
    Shake = {},
    Other = {}
}

local function ScanRemotes()
    AllRemotes = {}
    CategorizedRemotes = { Cast = {}, Reel = {}, Shake = {}, Other = {} }
    
    Debug("Scanning remotes...")
    
    for _, v in pairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            table.insert(AllRemotes, v)
            
            local name = v.Name:lower()
            if name:find("cast") or name:find("throw") or name:find("line") then
                table.insert(CategorizedRemotes.Cast, v)
            elseif name:find("reel") or name:find("catch") or name:find("finish") or name:find("pull") then
                table.insert(CategorizedRemotes.Reel, v)
            elseif name:find("shake") or name:find("struggle") or name:find("resist") then
                table.insert(CategorizedRemotes.Shake, v)
            else
                table.insert(CategorizedRemotes.Other, v)
            end
        end
    end
    
    Debug("Found", #AllRemotes, "total remotes")
    Debug("  Cast:", #CategorizedRemotes.Cast)
    Debug("  Reel:", #CategorizedRemotes.Reel)
    Debug("  Shake:", #CategorizedRemotes.Shake)
end

ScanRemotes()

-- ════════════════════════════════════════════════════════
-- ANTI-AFK
-- ════════════════════════════════════════════════════════
Connect(Player.Idled, function()
    pcall(function()
        local VU = game:GetService("VirtualUser")
        VU:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(0.1)
        VU:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
    Debug("Anti-AFK triggered")
end)

-- ════════════════════════════════════════════════════════
-- GUI CREATION
-- ════════════════════════════════════════════════════════
local SG = Instance.new("ScreenGui")
SG.Name = "FischGUI"
SG.Parent = PlayerGui
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = SG
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.02, 0, 0.3, 0)
Main.Size = UDim2.new(0, 320, 0, 360)
Main.ClipsDescendants = true

-- Corner
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Main

-- Stroke
local Stroke = Instance.new("UIStroke")
Stroke.Parent = Main
Stroke.Color = Color3.fromRGB(0, 170, 255)
Stroke.Thickness = 2

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Parent = Main
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.ZIndex = -1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)

-- ════════════════════════════════════════════════════════
-- CUSTOM DRAGGING (FIXED)
-- ════════════════════════════════════════════════════════
local Dragging = false
local DragInput
local DragStart
local StartPos

Connect(Main.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = Main.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

Connect(Main.InputChanged, function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or 
       input.UserInputType == Enum.UserInputType.Touch then
        DragInput = input
    end
end)

Connect(UIS.InputChanged, function(input)
    if input == DragInput and Dragging then
        local Delta = input.Position - DragStart
        Main.Position = UDim2.new(
            StartPos.X.Scale, 
            StartPos.X.Offset + Delta.X,
            StartPos.Y.Scale, 
            StartPos.Y.Offset + Delta.Y
        )
    end
end)

-- ════════════════════════════════════════════════════════
-- TITLE BAR
-- ════════════════════════════════════════════════════════
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = Main
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 45)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- Fix corner overlap
local TitleFix = Instance.new("Frame")
TitleFix.Parent = TitleBar
TitleFix.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
TitleFix.BorderSizePixel = 0
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)

local Title = Instance.new("TextLabel")
Title.Parent = TitleBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "🎣 FISCH AUTO - FIXED"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = TitleBar
MinBtn.BackgroundTransparency = 1
MinBtn.Position = UDim2.new(1, -40, 0, 0)
MinBtn.Size = UDim2.new(0, 40, 1, 0)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.TextSize = 24

local Minimized = false
local OriginalSize = Main.Size

Connect(MinBtn.MouseButton1Click, function()
    Minimized = not Minimized
    if Minimized then
        TweenService:Create(Main, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 320, 0, 45)
        }):Play()
        MinBtn.Text = "+"
    else
        TweenService:Create(Main, TweenInfo.new(0.3), {
            Size = OriginalSize
        }):Play()
        MinBtn.Text = "−"
    end
end)

-- ════════════════════════════════════════════════════════
-- CONTENT AREA
-- ════════════════════════════════════════════════════════
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Parent = Main
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 0, 0, 50)
Content.Size = UDim2.new(1, 0, 1, -55)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Parent = Content
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 8)

local ContentPadding = Instance.new("UIPadding")
ContentPadding.Parent = Content
ContentPadding.PaddingLeft = UDim.new(0, 10)
ContentPadding.PaddingRight = UDim.new(0, 10)
ContentPadding.PaddingTop = UDim.new(0, 5)
ContentPadding.PaddingBottom = UDim.new(0, 10)

-- ════════════════════════════════════════════════════════
-- INFO PANEL
-- ════════════════════════════════════════════════════════
local InfoPanel = Instance.new("Frame")
InfoPanel.Name = "InfoPanel"
InfoPanel.Parent = Content
InfoPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
InfoPanel.Size = UDim2.new(1, 0, 0, 70)
InfoPanel.LayoutOrder = 1

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 8)
InfoCorner.Parent = InfoPanel

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Name = "InfoLabel"
InfoLabel.Parent = InfoPanel
InfoLabel.BackgroundTransparency = 1
InfoLabel.Position = UDim2.new(0, 10, 0, 5)
InfoLabel.Size = UDim2.new(1, -20, 1, -10)
InfoLabel.Font = Enum.Font.RobotoMono
InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
InfoLabel.TextSize = 12
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.Text = "Loading..."

-- Update info loop
SpawnThread(function()
    while _G.FischAutoRunning do
        task.wait(0.5)
        if InfoLabel and InfoLabel.Parent then
            local elapsed = tick() - Stats.Start
            local hours = math.floor(elapsed / 3600)
            local mins = math.floor((elapsed % 3600) / 60)
            local secs = math.floor(elapsed % 60)
            
            InfoLabel.Text = string.format(
                "⏱️ Time: %02d:%02d:%02d\n🎣 Fish: %d | 🎯 Casts: %d\n🔄 Reels: %d | 💥 Shakes: %d\n📡 Remotes: %d | 💻 %s",
                hours, mins, secs,
                Stats.Fish,
                Stats.Casts,
                Stats.Reels,
                Stats.Shakes,
                #AllRemotes,
                ExecutorName
            )
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- TOGGLE BUTTON CREATOR
-- ════════════════════════════════════════════════════════
local LayoutOrder = 2

local function CreateToggle(name, configKey, icon)
    icon = icon or "⚡"
    
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name .. "Toggle"
    ToggleFrame.Parent = Content
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    ToggleFrame.LayoutOrder = LayoutOrder
    LayoutOrder = LayoutOrder + 1
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Parent = ToggleFrame
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.Text = icon .. " " .. name
    ToggleLabel.TextColor3 = Color3.new(1, 1, 1)
    ToggleLabel.TextSize = 14
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = ToggleFrame
    ToggleBtn.Position = UDim2.new(1, -70, 0.5, -12)
    ToggleBtn.Size = UDim2.new(0, 60, 0, 24)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 11
    ToggleBtn.Text = Config[configKey] and "ON" or "OFF"
    ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
    ToggleBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = ToggleBtn
    
    local function UpdateToggle()
        local enabled = Config[configKey]
        ToggleBtn.Text = enabled and "ON" or "OFF"
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(180, 50, 50)
        }):Play()
    end
    
    Connect(ToggleBtn.MouseButton1Click, function()
        Config[configKey] = not Config[configKey]
        UpdateToggle()
        Debug(name, "toggled:", Config[configKey])
    end)
    
    return ToggleFrame
end

-- Create toggles
CreateToggle("Master Enable", "Enabled", "🔌")
CreateToggle("Auto Cast", "AutoCast", "🎣")
CreateToggle("Auto Reel", "AutoReel", "🔄")
CreateToggle("Auto Shake", "AutoShake", "💥")
CreateToggle("Debug Mode", "ShowDebug", "🐛")

-- ════════════════════════════════════════════════════════
-- ACTION BUTTONS
-- ════════════════════════════════════════════════════════
local ButtonsFrame = Instance.new("Frame")
ButtonsFrame.Name = "Buttons"
ButtonsFrame.Parent = Content
ButtonsFrame.BackgroundTransparency = 1
ButtonsFrame.Size = UDim2.new(1, 0, 0, 35)
ButtonsFrame.LayoutOrder = 99

local ButtonsLayout = Instance.new("UIListLayout")
ButtonsLayout.Parent = ButtonsFrame
ButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
ButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ButtonsLayout.Padding = UDim.new(0, 10)

local function CreateButton(name, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = ButtonsFrame
    Btn.Size = UDim2.new(0, 90, 0, 30)
    Btn.BackgroundColor3 = color
    Btn.Font = Enum.Font.GothamBold
    Btn.Text = name
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.TextSize = 12
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn
    
    Connect(Btn.MouseButton1Click, callback)
    
    return Btn
end

CreateButton("Rescan", Color3.fromRGB(0, 140, 220), function()
    ScanRemotes()
    Log("Remotes rescanned:", #AllRemotes, "found")
end)

CreateButton("Reset Stats", Color3.fromRGB(180, 140, 0), function()
    Stats.Fish = 0
    Stats.Casts = 0
    Stats.Reels = 0
    Stats.Shakes = 0
    Stats.Start = tick()
    Log("Stats reset!")
end)

CreateButton("Close", Color3.fromRGB(180, 50, 50), function()
    Cleanup()
    SG:Destroy()
end)

-- ════════════════════════════════════════════════════════
-- TOGGLE GUI VISIBILITY
-- ════════════════════════════════════════════════════════
Connect(UIS.InputBegan, function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
    end
end)

Debug("GUI created!")

-- ════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ════════════════════════════════════════════════════════
local function GetChar()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRod()
    -- Check equipped
    local char = GetChar()
    if char then
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("Tool") then
                local name = v.Name:lower()
                if name:find("rod") or name:find("pole") or name:find("fish") then
                    return v
                end
            end
        end
    end
    
    -- Check backpack
    for _, v in pairs(Player.Backpack:GetChildren()) do
        if v:IsA("Tool") then
            local name = v.Name:lower()
            if name:find("rod") or name:find("pole") or name:find("fish") then
                return v
            end
        end
    end
    
    return nil
end

local function EquipRod()
    local rod = GetRod()
    if rod then
        if rod.Parent == Player.Backpack then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid:EquipTool(rod)
                task.wait(RandomDelay(0.2, 0.4))
                Debug("Rod equipped:", rod.Name)
                return true
            end
        elseif rod.Parent == GetChar() then
            return true -- Already equipped
        end
    end
    return false
end

local function IsRodEquipped()
    local char = GetChar()
    if char then
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("Tool") then
                local name = v.Name:lower()
                if name:find("rod") or name:find("pole") or name:find("fish") then
                    return true, v
                end
            end
        end
    end
    return false, nil
end

-- ════════════════════════════════════════════════════════
-- FISHING DETECTION
-- ════════════════════════════════════════════════════════
local IsFishing = false
local LastCast = 0
local LastReel = 0

local function DetectFishingUI()
    for _, ui in pairs(PlayerGui:GetDescendants()) do
        -- Skip our GUI
        if ui:IsDescendantOf(SG) then continue end
        
        local name = ui.Name:lower()
        local isVisible = false
        
        pcall(function()
            if ui:IsA("ScreenGui") then
                isVisible = ui.Enabled
            elseif ui:IsA("GuiObject") then
                isVisible = ui.Visible
            end
        end)
        
        if isVisible then
            -- Fishing minigame keywords
            if name:find("fish") or name:find("reel") or name:find("catch") or 
               name:find("minigame") or name:find("bobber") or name:find("bar") or
               name:find("progress") or name:find("meter") then
                return true, ui
            end
        end
    end
    return false, nil
end

local function DetectShakeUI()
    for _, ui in pairs(PlayerGui:GetDescendants()) do
        if ui:IsDescendantOf(SG) then continue end
        
        local name = ui.Name:lower()
        local isVisible = false
        
        pcall(function()
            if ui:IsA("GuiObject") then
                isVisible = ui.Visible
            end
        end)
        
        if isVisible then
            if name:find("shake") or name:find("struggle") or name:find("resist") or
               name:find("button") or name:find("tap") or name:find("click") then
                return true, ui
            end
        end
    end
    return false, nil
end

-- ════════════════════════════════════════════════════════
-- AUTO CAST SYSTEM
-- ════════════════════════════════════════════════════════
SpawnThread(function()
    Debug("Cast system started")
    
    while _G.FischAutoRunning do
        task.wait(0.5)
        
        if not IsRunning() or not Config.AutoCast then continue end
        if IsFishing then continue end
        
        local timeSinceCast = tick() - LastCast
        local castDelay = RandomDelay(Config.CastDelayMin, Config.CastDelayMax)
        
        if timeSinceCast >= castDelay then
            -- Equip rod first
            if not EquipRod() then
                Debug("No rod found!")
                task.wait(1)
                continue
            end
            
            local equipped, rod = IsRodEquipped()
            if not equipped then continue end
            
            Stats.Casts = Stats.Casts + 1
            Debug("═══ CAST #" .. Stats.Casts .. " ═══")
            
            local castSuccess = false
            
            -- Method 1: Fire cast remotes
            for _, remote in pairs(CategorizedRemotes.Cast) do
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer()
                        castSuccess = true
                        Debug("Fired cast remote:", remote.Name)
                    elseif remote:IsA("RemoteFunction") then
                        remote:InvokeServer()
                        castSuccess = true
                    end
                end)
            end
            
            -- Method 2: Activate tool
            if rod then
                pcall(function()
                    rod:Activate()
                    castSuccess = true
                    Debug("Activated tool:", rod.Name)
                end)
            end
            
            -- Method 3: Mouse click
            task.wait(0.1)
            SafeMouseClick()
            
            -- Method 4: Try E key
            task.wait(0.1)
            SafeKeyPress(Enum.KeyCode.E)
            
            IsFishing = true
            LastCast = tick()
            
            if castSuccess then
                Log("✅ Cast successful! (#" .. Stats.Casts .. ")")
            end
        end
    end
    
    Debug("Cast system stopped")
end)

-- ════════════════════════════════════════════════════════
-- AUTO REEL SYSTEM
-- ════════════════════════════════════════════════════════
SpawnThread(function()
    Debug("Reel system started")
    
    while _G.FischAutoRunning do
        task.wait(0.15)
        
        if not IsRunning() or not Config.AutoReel then continue end
        
        local detected, fishingUI = DetectFishingUI()
        
        if detected then
            -- Debounce
            if tick() - LastReel < 0.5 then continue end
            LastReel = tick()
            
            Stats.Reels = Stats.Reels + 1
            Debug("═══ REEL #" .. Stats.Reels .. " ═══")
            Debug("UI detected:", fishingUI and fishingUI.Name or "unknown")
            
            task.wait(RandomDelay(Config.ReelDelayMin, Config.ReelDelayMax))
            
            local reelSuccess = false
            
            -- Method 1: Fire reel remotes with various args
            for _, remote in pairs(CategorizedRemotes.Reel) do
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        -- Try different argument combinations
                        remote:FireServer()
                        remote:FireServer(100)
                        remote:FireServer(100, true)
                        remote:FireServer(1)
                        remote:FireServer(true)
                        reelSuccess = true
                        Debug("Fired reel remote:", remote.Name)
                    end
                end)
            end
            
            -- Method 2: Find and click buttons in the UI
            if fishingUI then
                for _, btn in pairs(fishingUI:GetDescendants()) do
                    if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                        Debug("Found button:", btn.Name)
                        
                        -- Try firing signals
                        pcall(function()
                            FireSignal(btn.MouseButton1Click)
                        end)
                        pcall(function()
                            FireSignal(btn.Activated)
                        end)
                        
                        reelSuccess = true
                    end
                end
            end
            
            -- Method 3: Key presses
            SafeKeyPress(Enum.KeyCode.E)
            task.wait(0.05)
            SafeKeyPress(Enum.KeyCode.Space)
            
            -- Method 4: Mouse clicks
            SafeMouseClick()
            
            if reelSuccess then
                Stats.Fish = Stats.Fish + 1
                IsFishing = false
                Log("🐟 Fish caught! Total:", Stats.Fish)
            end
        end
    end
    
    Debug("Reel system stopped")
end)

-- ════════════════════════════════════════════════════════
-- AUTO SHAKE SYSTEM
-- ════════════════════════════════════════════════════════
SpawnThread(function()
    Debug("Shake system started")
    
    while _G.FischAutoRunning do
        task.wait(0.1)
        
        if not IsRunning() or not Config.AutoShake then continue end
        
        local detected, shakeUI = DetectShakeUI()
        
        if detected then
            Stats.Shakes = Stats.Shakes + 1
            Debug("Shake detected! (#" .. Stats.Shakes .. ")")
            
            -- Method 1: Fire shake remotes
            for _, remote in pairs(CategorizedRemotes.Shake) do
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer()
                    end
                end)
            end
            
            -- Method 2: Click buttons
            if shakeUI then
                for _, btn in pairs(shakeUI:GetDescendants()) do
                    if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                        pcall(function() FireSignal(btn.MouseButton1Click) end)
                        pcall(function() FireSignal(btn.Activated) end)
                    end
                end
            end
            
            -- Method 3: Spam inputs
            for i = 1, 5 do
                SafeKeyPress(Enum.KeyCode.E)
                task.wait(0.02)
                SafeKeyPress(Enum.KeyCode.Space)
                task.wait(0.02)
                SafeMouseClick()
                task.wait(0.02)
            end
        end
    end
    
    Debug("Shake system stopped")
end)

-- ════════════════════════════════════════════════════════
-- SAFETY TIMEOUT
-- ════════════════════════════════════════════════════════
SpawnThread(function()
    while _G.FischAutoRunning do
        task.wait(15)
        
        if IsFishing and tick() - LastCast > 20 then
            Debug("⚠️ Timeout! Resetting fishing state...")
            IsFishing = false
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- STARTUP COMPLETE
-- ════════════════════════════════════════════════════════
print("════════════════════════════════════════")
print("✅ FISCH AUTO - FIXED VERSION LOADED!")
print("════════════════════════════════════════")
print("📊 Executor: " .. ExecutorName)
print("📡 Remotes: " .. #AllRemotes)
print("   Cast: " .. #CategorizedRemotes.Cast)
print("   Reel: " .. #CategorizedRemotes.Reel)
print("   Shake: " .. #CategorizedRemotes.Shake)
print("════════════════════════════════════════")
print("⌨️ Press DELETE or RIGHT CTRL to toggle GUI")
print("════════════════════════════════════════")

Log("Script loaded successfully!")
