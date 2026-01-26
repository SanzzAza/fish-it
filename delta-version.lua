--[[
    ═══════════════════════════════════════════════════════
    🎣 FISCH AUTO - TRUE FULL AUTO
    Klik ON = Auto Fishing! Gak perlu apa-apa lagi!
    ═══════════════════════════════════════════════════════
]]

print("════════════════════════════════════════")
print("🎣 LOADING FISCH FULL AUTO...")
print("════════════════════════════════════════")

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Backpack = Player:WaitForChild("Backpack")

-- ════════════════════════════════════════════════════════
-- CONFIG
-- ════════════════════════════════════════════════════════
local Config = {
    -- MAIN TOGGLE
    Enabled = false,  -- Ini yang di-control sama button ON/OFF
    
    -- SETTINGS
    CastDelay = 2.5,      -- Delay antar cast (detik)
    ReelDelay = 0.4,      -- Delay sebelum reel (detik)
    ShakeSpeed = 0.05,    -- Speed spam shake
    
    -- SAFETY
    MaxReelAttempts = 3,  -- Max reel attempt per fish
    Timeout = 45,         -- Max waktu fishing (detik)
    
    -- DEBUG
    ShowDebug = true,
}

-- ════════════════════════════════════════════════════════
-- STATS
-- ════════════════════════════════════════════════════════
local Stats = {
    TotalFish = 0,
    TotalCasts = 0,
    Successful = 0,
    Failed = 0,
    StartTime = tick(),
    Status = "Idle",
}

-- ════════════════════════════════════════════════════════
-- STATE MACHINE
-- ════════════════════════════════════════════════════════
local State = {
    IDLE = "🟢 Ready",
    CASTING = "🎣 Casting...",
    WAITING = "⏳ Waiting for fish...",
    REELING = "🔄 Reeling...",
    SHAKING = "⚡ Shaking...",
    ERROR = "❌ Error",
}

local CurrentState = State.IDLE

local function SetState(newState)
    CurrentState = newState
    Stats.Status = newState
end

-- ════════════════════════════════════════════════════════
-- DEBUG
-- ════════════════════════════════════════════════════════
local function Log(...)
    if Config.ShowDebug then
        print("🎣 [FISCH]", ...)
    end
end

-- ════════════════════════════════════════════════════════
-- ANTI-AFK
-- ════════════════════════════════════════════════════════
Player.Idled:Connect(function()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.1)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end)

-- ════════════════════════════════════════════════════════
-- REMOTE FINDER
-- ════════════════════════════════════════════════════════
local Remotes = {
    Cast = nil,
    Reel = nil,
    Shake = nil,
}

local function ScanRemotes()
    Log("Scanning for fishing remotes...")
    
    for _, remote in pairs(RS:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local name = remote.Name:lower()
            
            -- Cast remote
            if (name:match("cast") or name:match("throw")) and not Remotes.Cast then
                Remotes.Cast = remote
                Log("✅ Cast Remote:", remote.Name)
            end
            
            -- Reel remote
            if (name:match("reel") or name:match("catch")) and not Remotes.Reel then
                Remotes.Reel = remote
                Log("✅ Reel Remote:", remote.Name)
            end
            
            -- Shake remote
            if name:match("shake") and not Remotes.Shake then
                Remotes.Shake = remote
                Log("✅ Shake Remote:", remote.Name)
            end
        end
    end
end

ScanRemotes()

-- ════════════════════════════════════════════════════════
-- ROD FUNCTIONS
-- ════════════════════════════════════════════════════════
local function GetRod()
    local char = Player.Character
    if not char then return nil end
    
    -- Check equipped
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") and (item.Name:lower():find("rod") or item.Name:lower():find("fishing")) then
            return item
        end
    end
    
    -- Check backpack
    for _, item in pairs(Backpack:GetChildren()) do
        if item:IsA("Tool") and (item.Name:lower():find("rod") or item.Name:lower():find("fishing")) then
            return item
        end
    end
    
    return nil
end

local function EquipRod()
    local rod = GetRod()
    if not rod then
        Log("❌ No fishing rod found!")
        return false
    end
    
    if rod.Parent == Backpack then
        local char = Player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:EquipTool(rod)
            task.wait(0.5)
            Log("✅ Rod equipped:", rod.Name)
            return true
        end
    elseif rod.Parent == Player.Character then
        Log("✅ Rod already equipped")
        return true
    end
    
    return false
end

-- ════════════════════════════════════════════════════════
-- UI DETECTION
-- ════════════════════════════════════════════════════════
local FishingUI = {
    Reel = nil,
    Shake = nil,
    Progress = nil,
}

local function FindFishingUI()
    -- Reset
    FishingUI.Reel = nil
    FishingUI.Shake = nil
    
    for _, ui in pairs(PlayerGui:GetDescendants()) do
        if not ui:IsA("GuiObject") then continue end
        
        local name = ui.Name:lower()
        
        -- Reel UI (biasanya ada "reel", "safezone", "bar")
        if ui.Visible and (name == "reel" or name == "safezone" or name == "playerbar") then
            FishingUI.Reel = ui
            Log("🎯 Found Reel UI:", ui.Name)
        end
        
        -- Shake UI
        if ui.Visible and (name == "shake" or name:match("button")) then
            FishingUI.Shake = ui
            Log("⚡ Found Shake UI:", ui.Name)
        end
    end
    
    return FishingUI.Reel ~= nil or FishingUI.Shake ~= nil
end

-- ════════════════════════════════════════════════════════
-- FISHING ACTIONS
-- ════════════════════════════════════════════════════════
local function Cast()
    if not EquipRod() then
        return false
    end
    
    SetState(State.CASTING)
    Stats.TotalCasts = Stats.TotalCasts + 1
    
    Log("🎣 Casting... (#" .. Stats.TotalCasts .. ")")
    
    -- Method 1: Remote
    if Remotes.Cast then
        pcall(function()
            Remotes.Cast:FireServer()
        end)
    end
    
    -- Method 2: Tool activation
    local rod = GetRod()
    if rod and rod.Parent == Player.Character then
        rod:Activate()
    end
    
    -- Method 3: Mouse click (fallback)
    task.wait(0.2)
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.1)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    task.wait(0.5)
    SetState(State.WAITING)
    
    return true
end

local ReelDebounce = false

local function Reel()
    if ReelDebounce then return false end
    ReelDebounce = true
    
    SetState(State.REELING)
    Log("🔄 Reeling fish...")
    
    task.wait(Config.ReelDelay)
    
    local success = false
    local attempts = 0
    
    while attempts < Config.MaxReelAttempts do
        attempts = attempts + 1
        
        -- Method 1: Remote
        if Remotes.Reel then
            local s = pcall(function()
                Remotes.Reel:FireServer(100)
            end)
            if s then success = true end
        end
        
        -- Method 2: Click on reel button
        if FishingUI.Reel then
            for _, btn in pairs(FishingUI.Reel:GetDescendants()) do
                if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                    pcall(function()
                        firesignal(btn.MouseButton1Click)
                    end)
                    success = true
                end
            end
        end
        
        -- Method 3: Key press (E)
        VIM:SendKeyEvent(true, "E", false, game)
        task.wait(0.1)
        VIM:SendKeyEvent(false, "E", false, game)
        
        task.wait(0.3)
        
        -- Check if UI disappeared (fish caught)
        FindFishingUI()
        if not FishingUI.Reel then
            success = true
            break
        end
    end
    
    if success then
        Stats.TotalFish = Stats.TotalFish + 1
        Stats.Successful = Stats.Successful + 1
        Log("✅ Fish caught! Total: " .. Stats.TotalFish)
    else
        Stats.Failed = Stats.Failed + 1
        Log("❌ Reel failed")
    end
    
    task.wait(1)
    ReelDebounce = false
    SetState(State.IDLE)
    
    return success
end

local function Shake()
    SetState(State.SHAKING)
    Log("⚡ Shaking...")
    
    -- Method 1: Remote
    if Remotes.Shake then
        for i = 1, 5 do
            pcall(function()
                Remotes.Shake:FireServer()
            end)
            task.wait(Config.ShakeSpeed)
        end
    end
    
    -- Method 2: Key spam (W or Space)
    for i = 1, 10 do
        VIM:SendKeyEvent(true, "W", false, game)
        task.wait(Config.ShakeSpeed)
        VIM:SendKeyEvent(false, "W", false, game)
        task.wait(Config.ShakeSpeed)
    end
    
    -- Method 3: Click spam
    for i = 1, 5 do
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(Config.ShakeSpeed)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        task.wait(Config.ShakeSpeed)
    end
end

-- ════════════════════════════════════════════════════════
-- MAIN AUTO FISHING LOOP
-- ════════════════════════════════════════════════════════
local LastCastTime = 0
local FishingStartTime = 0

task.spawn(function()
    Log("🚀 Main loop started!")
    
    while task.wait(0.5) do
        if not Config.Enabled then
            SetState(State.IDLE)
            continue
        end
        
        -- Safety timeout
        if FishingStartTime > 0 and tick() - FishingStartTime > Config.Timeout then
            Log("⏱️ Timeout - resetting...")
            SetState(State.IDLE)
            FishingStartTime = 0
            ReelDebounce = false
        end
        
        -- Check for fishing UI
        local hasUI = FindFishingUI()
        
        if hasUI then
            FishingStartTime = FishingStartTime == 0 and tick() or FishingStartTime
            
            -- Handle shake
            if FishingUI.Shake then
                Shake()
            end
            
            -- Handle reel
            if FishingUI.Reel then
                Reel()
                FishingStartTime = 0
            end
        else
            -- No UI = idle, ready to cast
            if CurrentState ~= State.CASTING and tick() - LastCastTime >= Config.CastDelay then
                if Cast() then
                    LastCastTime = tick()
                    FishingStartTime = tick()
                end
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- GUI
-- ════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FischAutoGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Active = true
MainFrame.Draggable = true

-- Corner rounding
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 45)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleCover = Instance.new("Frame")
TitleCover.Parent = TitleBar
TitleCover.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
TitleCover.BorderSizePixel = 0
TitleCover.Position = UDim2.new(0, 0, 0.6, 0)
TitleCover.Size = UDim2.new(1, 0, 0.4, 0)

local Title = Instance.new("TextLabel")
Title.Parent = TitleBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "🎣 FISCH FULL AUTO"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18

-- Status display
local StatusFrame = Instance.new("Frame")
StatusFrame.Parent = MainFrame
StatusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
StatusFrame.BorderSizePixel = 0
StatusFrame.Position = UDim2.new(0, 10, 0, 55)
StatusFrame.Size = UDim2.new(1, -20, 0, 100)

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = StatusFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 10, 0, 5)
StatusLabel.Size = UDim2.new(1, -20, 1, -10)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.Text = "Status: Idle"

-- Update status
task.spawn(function()
    while task.wait(0.5) do
        if StatusLabel and StatusLabel.Parent then
            local runtime = tick() - Stats.StartTime
            local minutes = math.floor(runtime / 60)
            local seconds = math.floor(runtime % 60)
            
            StatusLabel.Text = string.format(
                "Status: %s\n\n" ..
                "🐟 Fish Caught: %d\n" ..
                "🎣 Total Casts: %d\n" ..
                "✅ Success: %d | ❌ Failed: %d\n" ..
                "⏱️ Runtime: %02d:%02d",
                Stats.Status,
                Stats.TotalFish,
                Stats.TotalCasts,
                Stats.Successful,
                Stats.Failed,
                minutes,
                seconds
            )
        end
    end
end)

-- Main toggle button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0, 10, 0, 165)
ToggleButton.Size = UDim2.new(1, -20, 0, 60)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "▶️ START AUTO FISHING"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = 16

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        ToggleButton.Text = "⏸️ STOP AUTO FISHING"
        Log("✅ AUTO FISHING STARTED!")
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        ToggleButton.Text = "▶️ START AUTO FISHING"
        Log("⏹️ AUTO FISHING STOPPED")
    end
end)

-- Settings
local yPos = 235

local function CreateSetting(name, key, min, max, step)
    local Frame = Instance.new("Frame")
    Frame.Parent = MainFrame
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.new(0, 10, 0, yPos)
    Frame.Size = UDim2.new(1, -20, 0, 35)
    
    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 6)
    FrameCorner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Parent = Frame
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Position = UDim2.new(0.5, 0, 0, 0)
    ValueLabel.Size = UDim2.new(0.5, -10, 1, 0)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Text = tostring(Config[key])
    ValueLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
    ValueLabel.TextSize = 12
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    yPos = yPos + 40
end

CreateSetting("Cast Delay:", "CastDelay", 1, 5, 0.5)
CreateSetting("Reel Delay:", "ReelDelay", 0.1, 2, 0.1)
CreateSetting("Timeout:", "Timeout", 10, 60, 5)

-- Close button
local CloseButton = Instance.new("TextButton")
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(0, 10, 1, -45)
CloseButton.Size = UDim2.new(1, -20, 0, 35)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "❌ CLOSE"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.TextSize = 14

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    Config.Enabled = false
end)

-- Toggle GUI with DELETE key
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Delete then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ════════════════════════════════════════════════════════
-- STARTUP
-- ════════════════════════════════════════════════════════
print("════════════════════════════════════════")
print("✅ FISCH FULL AUTO LOADED!")
print("════════════════════════════════════════")
print("📋 INSTRUCTIONS:")
print("  1️⃣  Click 'START AUTO FISHING'")
print("  2️⃣  Watch it work!")
print("  3️⃣  Click 'STOP' to pause")
print("")
print("⌨️  Press DELETE to show/hide GUI")
print("════════════════════════════════════════")

Log("Script ready! Press START to begin")
