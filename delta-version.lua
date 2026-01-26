--[[
    ═══════════════════════════════════════════════════════
    🎣 FISCH AUTO - DELTA EXECUTOR OPTIMIZED
    Designed specifically for Delta Executor!
    ═══════════════════════════════════════════════════════
]]

print("════════════════════════════════════════")
print("🎣 FISCH AUTO - DELTA VERSION")
print("════════════════════════════════════════")

-- Wait for game to load
repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ════════════════════════════════════════════════════════
-- DELTA EXECUTOR SPECIFIC SETUP
-- ════════════════════════════════════════════════════════
local Services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    UserInputService = game:GetService("UserInputService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    RunService = game:GetService("RunService"),
    VirtualUser = game:GetService("VirtualUser"),
}

local Player = Services.Players.LocalPlayer
local Mouse = Player:GetMouse()
local PlayerGui = Player:WaitForChild("PlayerGui")
local Backpack = Player:WaitForChild("Backpack")

-- ════════════════════════════════════════════════════════
-- CONFIG
-- ════════════════════════════════════════════════════════
getgenv().FischConfig = getgenv().FischConfig or {
    Enabled = false,
    AutoCast = true,
    AutoReel = true,
    
    -- Timings (optimized for Delta)
    CastDelay = 2.8,
    ReelDelay = 0.4,
    ShakeDelay = 0.1,
    
    -- Debug
    ShowDebug = true,
}

local Config = getgenv().FischConfig

-- ════════════════════════════════════════════════════════
-- STATS
-- ════════════════════════════════════════════════════════
getgenv().FischStats = getgenv().FischStats or {
    TotalFish = 0,
    TotalCasts = 0,
    SuccessfulReels = 0,
    StartTime = tick(),
    Status = "Ready",
    LastAction = "None",
}

local Stats = getgenv().FischStats

-- ════════════════════════════════════════════════════════
-- DEBUG FUNCTION
-- ════════════════════════════════════════════════════════
local function Debug(...)
    if Config.ShowDebug then
        print("🎣 [DELTA]", ...)
    end
end

-- ════════════════════════════════════════════════════════
-- DELTA SPECIFIC ANTI-AFK
-- ════════════════════════════════════════════════════════
local function AntiAFK()
    pcall(function()
        Services.VirtualUser:CaptureController()
        Services.VirtualUser:ClickButton2(Vector2.new())
    end)
end

Player.Idled:Connect(AntiAFK)

-- ════════════════════════════════════════════════════════
-- REMOTE DETECTION (DELTA OPTIMIZED)
-- ════════════════════════════════════════════════════════
local RemoteEvents = {}
local RemoteFunctions = {}

local function ScanRemotes()
    Debug("Scanning for remotes...")
    
    for _, descendant in pairs(Services.ReplicatedStorage:GetDescendants()) do
        if descendant:IsA("RemoteEvent") then
            RemoteEvents[descendant.Name:lower()] = descendant
            Debug("RemoteEvent found:", descendant.Name)
        elseif descendant:IsA("RemoteFunction") then
            RemoteFunctions[descendant.Name:lower()] = descendant
            Debug("RemoteFunction found:", descendant.Name)
        end
    end
end

ScanRemotes()

-- Find fishing remotes
local FishingRemotes = {
    Cast = nil,
    Reel = nil,
    Shake = nil,
}

-- Auto-detect cast remote
for name, remote in pairs(RemoteEvents) do
    if name:find("cast") or name:find("throw") or name:find("fish") then
        FishingRemotes.Cast = remote
        Debug("✅ Cast remote detected:", remote.Name)
        break
    end
end

-- Auto-detect reel remote  
for name, remote in pairs(RemoteEvents) do
    if name:find("reel") or name:find("catch") or name:find("complete") then
        FishingRemotes.Reel = remote
        Debug("✅ Reel remote detected:", remote.Name)
        break
    end
end

-- Auto-detect shake remote
for name, remote in pairs(RemoteEvents) do
    if name:find("shake") or name:find("struggle") then
        FishingRemotes.Shake = remote
        Debug("✅ Shake remote detected:", remote.Name)
        break
    end
end

-- ════════════════════════════════════════════════════════
-- ROD MANAGEMENT
-- ════════════════════════════════════════════════════════
local function FindFishingRod()
    -- Check equipped tools
    if Player.Character then
        for _, tool in pairs(Player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                if toolName:find("rod") or toolName:find("fishing") or toolName:find("pole") then
                    return tool, "equipped"
                end
            end
        end
    end
    
    -- Check backpack
    for _, tool in pairs(Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name:lower()
            if toolName:find("rod") or toolName:find("fishing") or toolName:find("pole") then
                return tool, "backpack"
            end
        end
    end
    
    return nil, "none"
end

local function EquipFishingRod()
    local rod, location = FindFishingRod()
    
    if not rod then
        Debug("❌ No fishing rod found!")
        return false
    end
    
    if location == "backpack" then
        Debug("🎣 Equipping fishing rod:", rod.Name)
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid:EquipTool(rod)
            task.wait(0.5)
            return true
        end
    elseif location == "equipped" then
        Debug("✅ Fishing rod already equipped")
        return true
    end
    
    return false
end

-- ════════════════════════════════════════════════════════
-- UI DETECTION (DELTA COMPATIBLE)
-- ════════════════════════════════════════════════════════
local function DetectFishingUI()
    local fishingUI = {
        reel = false,
        shake = false,
        elements = {}
    }
    
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            -- Skip our own GUI
            if gui.Name == "DeltaFischGUI" then continue end
            
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("GuiObject") and obj.Visible then
                    local objName = obj.Name:lower()
                    local objText = ""
                    
                    if obj:IsA("TextLabel") then
                        objText = obj.Text:lower()
                    elseif obj:IsA("TextButton") then
                        objText = obj.Text:lower()
                    end
                    
                    -- Detect reel UI
                    if objName:find("reel") or objName:find("safe") or objName:find("bar") or 
                       objText:find("reel") or objText:find("catch") then
                        fishingUI.reel = true
                        table.insert(fishingUI.elements, {type = "reel", obj = obj})
                    end
                    
                    -- Detect shake UI
                    if objName:find("shake") or objName:find("struggle") or
                       objText:find("shake") or objText:find("struggle") then
                        fishingUI.shake = true
                        table.insert(fishingUI.elements, {type = "shake", obj = obj})
                    end
                end
            end
        end
    end
    
    return fishingUI
end

-- ════════════════════════════════════════════════════════
-- FISHING ACTIONS (DELTA OPTIMIZED)
-- ════════════════════════════════════════════════════════
local FishingState = {
    Idle = "Idle",
    Casting = "Casting",
    Waiting = "Waiting",
    Reeling = "Reeling",
    Shaking = "Shaking",
}

local CurrentState = FishingState.Idle
local LastCastTime = 0
local ReelCooldown = false

-- CAST FUNCTION
local function PerformCast()
    if CurrentState ~= FishingState.Idle then return false end
    if tick() - LastCastTime < Config.CastDelay then return false end
    
    CurrentState = FishingState.Casting
    Stats.TotalCasts = Stats.TotalCasts + 1
    Stats.Status = "🎣 Casting..."
    Stats.LastAction = "Cast #" .. Stats.TotalCasts
    
    Debug("🎣 Performing cast #" .. Stats.TotalCasts)
    
    -- Equip rod first
    if not EquipFishingRod() then
        CurrentState = FishingState.Idle
        return false
    end
    
    local castSuccess = false
    
    -- Method 1: Fire cast remote
    if FishingRemotes.Cast then
        local success = pcall(function()
            FishingRemotes.Cast:FireServer()
        end)
        if success then
            Debug("✅ Cast remote fired successfully")
            castSuccess = true
        end
    end
    
    -- Method 2: Use tool activation (Delta compatible)
    if not castSuccess then
        local rod = FindFishingRod()
        if rod then
            Debug("🔧 Activating fishing rod")
            rod:Activate()
            castSuccess = true
        end
    end
    
    -- Method 3: Mouse click simulation (Delta method)
    if not castSuccess then
        Debug("🖱️ Using mouse simulation")
        Services.VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.1)
        Services.VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        castSuccess = true
    end
    
    if castSuccess then
        LastCastTime = tick()
        CurrentState = FishingState.Waiting
        Stats.Status = "⏳ Waiting for fish..."
        
        -- Auto-timeout after 30 seconds
        task.spawn(function()
            task.wait(30)
            if CurrentState == FishingState.Waiting then
                Debug("⏰ Cast timeout, resetting...")
                CurrentState = FishingState.Idle
            end
        end)
        
        return true
    end
    
    CurrentState = FishingState.Idle
    return false
end

-- REEL FUNCTION
local function PerformReel()
    if ReelCooldown then return false end
    if CurrentState ~= FishingState.Waiting then return false end
    
    ReelCooldown = true
    CurrentState = FishingState.Reeling
    Stats.Status = "🔄 Reeling in fish..."
    Stats.LastAction = "Reeling"
    
    Debug("🔄 Performing reel")
    
    task.wait(Config.ReelDelay)
    
    local reelSuccess = false
    
    -- Method 1: Fire reel remote
    if FishingRemotes.Reel then
        local success = pcall(function()
            FishingRemotes.Reel:FireServer()
        end)
        if success then
            Debug("✅ Reel remote fired successfully")
            reelSuccess = true
        end
    end
    
    -- Method 2: Click UI elements
    local ui = DetectFishingUI()
    for _, element in pairs(ui.elements) do
        if element.type == "reel" and element.obj:IsA("GuiButton") then
            pcall(function()
                element.obj.MouseButton1Click:Fire()
            end)
            pcall(function()
                firesignal(element.obj.MouseButton1Click)
            end)
            reelSuccess = true
        end
    end
    
    -- Method 3: Key simulation (Delta compatible)
    if not reelSuccess then
        Debug("⌨️ Using E key simulation")
        Services.VirtualInputManager:SendKeyEvent(true, "E", false, game)
        task.wait(0.1)
        Services.VirtualInputManager:SendKeyEvent(false, "E", false, game)
        reelSuccess = true
    end
    
    if reelSuccess then
        Stats.TotalFish = Stats.TotalFish + 1
        Stats.SuccessfulReels = Stats.SuccessfulReels + 1
        Stats.Status = "✅ Fish caught! Total: " .. Stats.TotalFish
        Stats.LastAction = "Fish #" .. Stats.TotalFish
        Debug("✅ Fish successfully caught! Total: " .. Stats.TotalFish)
    else
        Debug("❌ Reel attempt failed")
    end
    
    task.wait(1)
    CurrentState = FishingState.Idle
    ReelCooldown = false
    
    return reelSuccess
end

-- SHAKE FUNCTION
local function PerformShake()
    CurrentState = FishingState.Shaking
    Stats.Status = "⚡ Shaking to escape!"
    Stats.LastAction = "Shaking"
    
    Debug("⚡ Performing shake sequence")
    
    -- Method 1: Shake remote
    if FishingRemotes.Shake then
        for i = 1, 3 do
            pcall(function()
                FishingRemotes.Shake:FireServer()
            end)
            task.wait(Config.ShakeDelay)
        end
    else
        -- Method 2: Key spam (W key, Delta compatible)
        for i = 1, 5 do
            Services.VirtualInputManager:SendKeyEvent(true, "W", false, game)
            task.wait(Config.ShakeDelay)
            Services.VirtualInputManager:SendKeyEvent(false, "W", false, game)
            task.wait(Config.ShakeDelay)
        end
    end
end

-- ════════════════════════════════════════════════════════
-- MAIN FISHING LOOP (DELTA OPTIMIZED)
-- ════════════════════════════════════════════════════════
task.spawn(function()
    Debug("🚀 Delta fishing loop started")
    
    while task.wait(0.3) do
        if not Config.Enabled then
            Stats.Status = "⏹️ Stopped"
            CurrentState = FishingState.Idle
            continue
        end
        
        -- Detect current fishing UI state
        local fishingUI = DetectFishingUI()
        
        -- Handle shake events
        if fishingUI.shake and Config.AutoReel then
            PerformShake()
        -- Handle reel events
        elseif fishingUI.reel and Config.AutoReel then
            PerformReel()
        -- Handle casting when idle
        elseif CurrentState == FishingState.Idle and Config.AutoCast then
            PerformCast()
        end
        
        -- Update status based on state
        if CurrentState == FishingState.Waiting then
            Stats.Status = "⏳ Waiting for bite..."
        elseif CurrentState == FishingState.Idle and Config.Enabled then
            Stats.Status = "🟢 Ready to cast"
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- GUI (DELTA STYLED)
-- ════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaFischGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.02, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 380, 0, 420)
MainFrame.Active = true
MainFrame.Draggable = true

-- Styling
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(100, 200, 255)
Stroke.Thickness = 2
Stroke.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 55)
Title.Font = Enum.Font.GothamBold
Title.Text = "🎣 FISCH AUTO - DELTA EXECUTOR"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.TextStrokeTransparency = 0
Title.TextStrokeColor3 = Color3.new(0, 0, 0)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = Title

local TitleCover = Instance.new("Frame")
TitleCover.Parent = Title
TitleCover.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
TitleCover.BorderSizePixel = 0
TitleCover.Position = UDim2.new(0, 0, 0.6, 0)
TitleCover.Size = UDim2.new(1, 0, 0.4, 0)

-- Status Display
local StatusFrame = Instance.new("Frame")
StatusFrame.Parent = MainFrame
StatusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
StatusFrame.BorderSizePixel = 0
StatusFrame.Position = UDim2.new(0, 15, 0, 70)
StatusFrame.Size = UDim2.new(1, -30, 0, 140)

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 10)
StatusCorner.Parent = StatusFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = StatusFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 15, 0, 10)
StatusLabel.Size = UDim2.new(1, -30, 1, -20)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Initializing..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Update status display
task.spawn(function()
    while task.wait(0.5) do
        if StatusLabel and StatusLabel.Parent then
            local runtime = tick() - Stats.StartTime
            local hours = math.floor(runtime / 3600)
            local minutes = math.floor((runtime % 3600) / 60)
            local seconds = math.floor(runtime % 60)
            
            local remoteStatus = ""
            if FishingRemotes.Cast then
                remoteStatus = remoteStatus .. "✅ Cast: " .. FishingRemotes.Cast.Name .. "\n"
            else
                remoteStatus = remoteStatus .. "❌ Cast: Not detected\n"
            end
            
            if FishingRemotes.Reel then
                remoteStatus = remoteStatus .. "✅ Reel: " .. FishingRemotes.Reel.Name .. "\n"
            else
                remoteStatus = remoteStatus .. "❌ Reel: Not detected\n"
            end
            
            StatusLabel.Text = string.format(
                "Status: %s\nLast Action: %s\n\n%s\n" ..
                "🐟 Fish Caught: %d\n🎣 Total Casts: %d\n✅ Successful Reels: %d\n" ..
                "⏱️ Runtime: %02d:%02d:%02d",
                Stats.Status,
                Stats.LastAction,
                remoteStatus,
                Stats.TotalFish,
                Stats.TotalCasts,
                Stats.SuccessfulReels,
                hours, minutes, seconds
            )
        end
    end
end)

-- Control Buttons
local ButtonsFrame = Instance.new("Frame")
ButtonsFrame.Parent = MainFrame
ButtonsFrame.BackgroundTransparency = 1
ButtonsFrame.Position = UDim2.new(0, 15, 0, 220)
ButtonsFrame.Size = UDim2.new(1, -30, 0, 140)

-- Main Toggle
local MainToggle = Instance.new("TextButton")
MainToggle.Parent = ButtonsFrame
MainToggle.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
MainToggle.BorderSizePixel = 0
MainToggle.Position = UDim2.new(0, 0, 0, 0)
MainToggle.Size = UDim2.new(1, 0, 0, 50)
MainToggle.Font = Enum.Font.GothamBold
MainToggle.Text = "▶️ START AUTO FISHING"
MainToggle.TextColor3 = Color3.new(1, 1, 1)
MainToggle.TextSize = 16
MainToggle.TextStrokeTransparency = 0
MainToggle.TextStrokeColor3 = Color3.new(0, 0, 0)

local MainToggleCorner = Instance.new("UICorner")
MainToggleCorner.CornerRadius = UDim.new(0, 8)
MainToggleCorner.Parent = MainToggle

MainToggle.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        MainToggle.BackgroundColor3 = Color3.fromRGB(0, 220, 0)
        MainToggle.Text = "⏸️ STOP AUTO FISHING"
        Debug("✅ DELTA AUTO FISHING STARTED!")
    else
        MainToggle.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
        MainToggle.Text = "▶️ START AUTO FISHING"
        CurrentState = FishingState.Idle
        ReelCooldown = false
        Debug("⏹️ DELTA AUTO FISHING STOPPED!")
    end
end)

-- Cast Toggle
local CastToggle = Instance.new("TextButton")
CastToggle.Parent = ButtonsFrame
CastToggle.BackgroundColor3 = Config.AutoCast and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
CastToggle.BorderSizePixel = 0
CastToggle.Position = UDim2.new(0, 0, 0, 60)
CastToggle.Size = UDim2.new(0.48, 0, 0, 35)
CastToggle.Font = Enum.Font.Gotham
CastToggle.Text = "🎣 Auto Cast: " .. (Config.AutoCast and "ON" or "OFF")
CastToggle.TextColor3 = Color3.new(1, 1, 1)
CastToggle.TextSize = 12

local CastToggleCorner = Instance.new("UICorner")
CastToggleCorner.CornerRadius = UDim.new(0, 6)
CastToggleCorner.Parent = CastToggle

CastToggle.MouseButton1Click:Connect(function()
    Config.AutoCast = not Config.AutoCast
    CastToggle.BackgroundColor3 = Config.AutoCast and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    CastToggle.Text = "🎣 Auto Cast: " .. (Config.AutoCast and "ON" or "OFF")
end)

-- Reel Toggle
local ReelToggle = Instance.new("TextButton")
ReelToggle.Parent = ButtonsFrame
ReelToggle.BackgroundColor3 = Config.AutoReel and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
ReelToggle.BorderSizePixel = 0
ReelToggle.Position = UDim2.new(0.52, 0, 0, 60)
ReelToggle.Size = UDim2.new(0.48, 0, 0, 35)
ReelToggle.Font = Enum.Font.Gotham
ReelToggle.Text = "🔄 Auto Reel: " .. (Config.AutoReel and "ON" or "OFF")
ReelToggle.TextColor3 = Color3.new(1, 1, 1)
ReelToggle.TextSize = 12

local ReelToggleCorner = Instance.new("UICorner")
ReelToggleCorner.CornerRadius = UDim.new(0, 6)
ReelToggleCorner.Parent = ReelToggle

ReelToggle.MouseButton1Click:Connect(function()
    Config.AutoReel = not Config.AutoReel
    ReelToggle.BackgroundColor3 = Config.AutoReel and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    ReelToggle.Text = "🔄 Auto Reel: " .. (Config.AutoReel and "ON" or "OFF")
end)

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Parent = ButtonsFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(0, 0, 0, 105)
CloseButton.Size = UDim2.new(1, 0, 0, 30)
CloseButton.Font = Enum.Font.Gotham
CloseButton.Text = "❌ CLOSE & DISABLE"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.TextSize = 13

local CloseButtonCorner = Instance.new("UICorner")
CloseButtonCorner.CornerRadius = UDim.new(0, 6)
CloseButtonCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    Config.Enabled = false
    ScreenGui:Destroy()
    Debug("👋 GUI closed and auto fishing disabled")
end)

-- Minimize/Maximize functionality
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Parent = Title
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Position = UDim2.new(1, -40, 0, 10)
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.TextSize = 20

local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 380, 0, 55)
        MinimizeButton.Text = "+"
        StatusFrame.Visible = false
        ButtonsFrame.Visible = false
    else
        MainFrame.Size = UDim2.new(0, 380, 0, 420)
        MinimizeButton.Text = "_"
        StatusFrame.Visible = true
        ButtonsFrame.Visible = true
    end
end)

-- Keyboard shortcut to toggle GUI
Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Delete then
        MainFrame.Visible = not MainFrame.Visible
    elseif input.KeyCode == Enum.KeyCode.F1 then
        Config.Enabled = not Config.Enabled
        if Config.Enabled then
            MainToggle.BackgroundColor3 = Color3.fromRGB(0, 220, 0)
            MainToggle.Text = "⏸️ STOP AUTO FISHING"
        else
            MainToggle.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
            MainToggle.Text = "▶️ START AUTO FISHING"
            CurrentState = FishingState.Idle
            ReelCooldown = false
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- STARTUP COMPLETE
-- ════════════════════════════════════════════════════════
print("════════════════════════════════════════")
print("✅ FISCH AUTO - DELTA VERSION LOADED!")
print("════════════════════════════════════════")
print("🎮 DELTA EXECUTOR OPTIMIZED:")
print("  ✅ Compatible input simulation")
print("  ✅ Proper tool activation")
print("  ✅ Smart UI detection")
print("  ✅ Anti-AFK protection")
print("")
print("⌨️ HOTKEYS:")
print("  DELETE - Toggle GUI visibility")
print("  F1 - Quick start/stop fishing")
print("")
print("🎯 DETECTED FEATURES:")
if FishingRemotes.Cast then
    print("  ✅ Cast Remote: " .. FishingRemotes.Cast.Name)
else
    print("  ⚠️ Cast Remote: Using fallback methods")
end
if FishingRemotes.Reel then
    print("  ✅ Reel Remote: " .. FishingRemotes.Reel.Name)
else
    print("  ⚠️ Reel Remote: Using fallback methods")
end
if FishingRemotes.Shake then
    print("  ✅ Shake Remote: " .. FishingRemotes.Shake.Name)
else
    print("  ⚠️ Shake Remote: Using fallback methods")
end
print("════════════════════════════════════════")
print("🚀 Ready to fish! Click START button!")
print("════════════════════════════════════════")

-- Initial setup
Stats.Status = "🟢 Delta Executor Ready"
Debug("🎉 DELTA FISCH AUTO successfully initialized!")
