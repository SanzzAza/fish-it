--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - SPAM REEL (FIXED!)
    CLICK TERUS SAMPAI IKAN MASUK!
    ════════════════════════════════════════════════════════
]]

print("🎣 LOADING SPAM REEL...")

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")  -- ✅ FIXED!
local VIM = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Backpack = Player:WaitForChild("Backpack")

-- ════════════════════════════════════════════════════════
-- CONFIG
-- ════════════════════════════════════════════════════════
local Config = {
    Enabled = false,
    ClickSpeed = 0.03,
}

local Stats = {
    Fish = 0,
    Casts = 0,
    Clicks = 0,
}

-- ════════════════════════════════════════════════════════
-- STATE
-- ════════════════════════════════════════════════════════
local IsFishing = false
local IsReeling = false
local LastCast = 0

-- ════════════════════════════════════════════════════════
-- ANTI-AFK
-- ════════════════════════════════════════════════════════
Player.Idled:Connect(function()
    pcall(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):Button1Down(Vector2.new())
    end)
end)

-- ════════════════════════════════════════════════════════
-- ROD FUNCTIONS
-- ════════════════════════════════════════════════════════
local function GetRod()
    if Player.Character then
        for _, tool in pairs(Player.Character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("rod") then
                return tool
            end
        end
    end
    
    for _, tool in pairs(Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("rod") then
            return tool
        end
    end
end

local function EquipRod()
    local rod = GetRod()
    if rod and rod.Parent == Backpack then
        Player.Character.Humanoid:EquipTool(rod)
        task.wait(0.3)
        return true
    end
    return rod ~= nil
end

-- ════════════════════════════════════════════════════════
-- UI DETECTION
-- ════════════════════════════════════════════════════════
local function HasReelUI()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "FischSpamGUI" then
            local reel = gui:FindFirstChild("reel", true)
            if reel and reel:IsA("GuiObject") and reel.Visible then
                return true, reel
            end
            
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("GuiObject") and obj.Visible then
                    local name = obj.Name:lower()
                    if name == "reel" or name == "safezone" or name == "bar" or 
                       name == "reelbar" or name == "fishingbar" or name == "progress" or
                       name == "playerbar" or name:find("reel") or name:find("safe") then
                        return true, obj
                    end
                end
            end
        end
    end
    return false, nil
end

-- ════════════════════════════════════════════════════════
-- CAST
-- ════════════════════════════════════════════════════════
local function DoCast()
    if IsFishing or IsReeling or tick() - LastCast < 2 then return end
    
    Stats.Casts = Stats.Casts + 1
    print("🎣 Casting #" .. Stats.Casts)
    
    EquipRod()
    
    local rod = GetRod()
    if rod then
        rod:Activate()
    end
    
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    IsFishing = true
    LastCast = tick()
    
    task.delay(20, function()
        if IsFishing and not IsReeling then 
            IsFishing = false 
        end
    end)
end

-- ════════════════════════════════════════════════════════
-- SPAM REEL (CLICK TERUS!)
-- ════════════════════════════════════════════════════════
local ReelThread = nil

local function StartSpamReel()
    if IsReeling then return end
    IsReeling = true
    
    print("⚡ SPAM STARTED!")
    
    local startTime = tick()
    local clickCount = 0
    
    ReelThread = task.spawn(function()
        while IsReeling and Config.Enabled do
            local hasUI = HasReelUI()
            
            if not hasUI then
                print("✅ UI hilang! Ikan masuk!")
                break
            end
            
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            
            clickCount = clickCount + 1
            Stats.Clicks = Stats.Clicks + 1
            
            task.wait(Config.ClickSpeed)
            
            if tick() - startTime > 30 then
                print("⏰ Timeout!")
                break
            end
        end
        
        local duration = math.floor((tick() - startTime) * 1000)
        Stats.Fish = Stats.Fish + 1
        print(string.format("✅ Fish #%d! (%d clicks, %dms)", Stats.Fish, clickCount, duration))
        
        IsReeling = false
        IsFishing = false
        task.wait(1)
    end)
end

local function StopSpamReel()
    IsReeling = false
    if ReelThread then
        task.cancel(ReelThread)
        ReelThread = nil
    end
end

-- ════════════════════════════════════════════════════════
-- DETECTION (60 FPS)
-- ════════════════════════════════════════════════════════
local ReelDetection = nil

local function StartReelDetection()
    if ReelDetection then return end
    
    ReelDetection = RunService.RenderStepped:Connect(function()
        if Config.Enabled and IsFishing and not IsReeling then
            local hasUI = HasReelUI()
            if hasUI then
                print("🎯 UI DETECTED!")
                StartSpamReel()
            end
        end
    end)
    print("✅ Detection active!")
end

local function StopReelDetection()
    if ReelDetection then
        ReelDetection:Disconnect()
        ReelDetection = nil
    end
    print("❌ Detection stopped!")
end

-- ════════════════════════════════════════════════════════
-- MAIN LOOP
-- ════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(0.5) do
        if Config.Enabled and not IsFishing and not IsReeling then
            DoCast()
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- GUI
-- ════════════════════════════════════════════════════════
print("Creating GUI...")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FischSpamGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- WAIT FOR PLAYERGUI READY
local success = pcall(function()
    ScreenGui.Parent = PlayerGui
end)

if not success then
    warn("Failed to parent GUI, retrying...")
    task.wait(1)
    ScreenGui.Parent = PlayerGui
end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.35, 0, 0.3, 0)
Main.Size = UDim2.new(0, 320, 0, 220)
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 15)
Corner.Parent = Main

local Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(255, 0, 255)
Glow.Thickness = 3
Glow.Parent = Main

local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡ SPAM REEL - NON STOP!"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 17

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = Title

local TitleFix = Instance.new("Frame")
TitleFix.Parent = Title
TitleFix.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
TitleFix.BorderSizePixel = 0
TitleFix.Position = UDim2.new(0, 0, 0.6, 0)
TitleFix.Size = UDim2.new(1, 0, 0.4, 0)

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = Main
StatsLabel.BackgroundTransparency = 1
StatsLabel.Position = UDim2.new(0, 15, 0, 60)
StatsLabel.Size = UDim2.new(1, -30, 0, 80)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Ready to spam!"
StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsLabel.TextSize = 13
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            local status = Config.Enabled and "⚡ SPAM MODE!" or "🔴 STOPPED"
            local currentAction = ""
            
            if Config.Enabled then
                if IsReeling then
                    currentAction = "⚡⚡⚡ SPAMMING! ⚡⚡⚡"
                elseif IsFishing then
                    currentAction = "⏳ Waiting bite..."
                else
                    currentAction = "🎣 Casting..."
                end
            end
            
            StatsLabel.Text = string.format(
                "%s\n%s\n\n🐟 Fish: %d | 🎣 Casts: %d\n🖱️ Clicks: %d",
                status,
                currentAction,
                Stats.Fish,
                Stats.Casts,
                Stats.Clicks
            )
        end)
    end
end)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = Main
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0, 15, 0, 145)
SpeedLabel.Size = UDim2.new(1, -30, 0, 20)
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.Text = "⚡ Speed: ULTRA FAST"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
SpeedLabel.TextSize = 12
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Main
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0, 15, 0, 170)
ToggleButton.Size = UDim2.new(1, -30, 0, 40)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "🔴 START SPAM"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = 15

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.Text = "⚡ STOP SPAM"
        Glow.Color = Color3.fromRGB(0, 255, 0)
        StartReelDetection()
        print("✅ SPAM MODE ON!")
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = "🔴 START SPAM"
        Glow.Color = Color3.fromRGB(255, 0, 255)
        StopReelDetection()
        StopSpamReel()
        IsFishing = false
        print("❌ STOPPED!")
    end
end)

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
        print("GUI Toggled:", Main.Visible)
    elseif input.KeyCode == Enum.KeyCode.F6 then
        ToggleButton.MouseButton1Click:Fire()
    end
end)

print("════════════════════════════════════════")
print("✅ GUI CREATED!")
print("✅ SPAM REEL LOADED!")
print("════════════════════════════════════════")
print("🎮 Controls:")
print("  DELETE = Hide/Show GUI")
print("  F6 = Toggle ON/OFF")
print("════════════════════════════════════════")
print("⚡ CLICK START BUTTON TO BEGIN!")
print("════════════════════════════════════════")

-- Check GUI visible
task.wait(1)
if Main.Visible then
    print("✅ GUI is visible on screen!")
else
    warn("⚠️ GUI might be hidden!")
end
