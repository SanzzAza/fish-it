--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - ULTRA FAST REEL! 
    ════════════════════════════════════════════════════════
]]

print("🎣 LOADING ULTRA FAST FISCH AUTO...")

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
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
}

local Stats = {
    Fish = 0,
    Casts = 0,
}

-- ════════════════════════════════════════════════════════
-- STATE
-- ════════════════════════════════════════════════════════
local IsFishing = false
local IsReeling = false
local LastCast = 0
local ReelStartTime = 0

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
-- ULTRA FAST UI DETECTION! (OPTIMIZED!)
-- ════════════════════════════════════════════════════════
local CachedReelUI = nil
local LastUICheck = 0

local function HasReelUI()
    -- Cache untuk performa!
    local now = tick()
    if CachedReelUI and CachedReelUI.Parent and (now - LastUICheck) < 0.1 then
        return true, CachedReelUI
    end
    
    LastUICheck = now
    
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "FixedFischGUI" then
            -- Quick check di top level dulu
            local reel = gui:FindFirstChild("reel", true)
            if reel and reel:IsA("GuiObject") and reel.Visible then
                CachedReelUI = reel
                return true, reel
            end
            
            -- Deep scan
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("GuiObject") and obj.Visible then
                    local name = obj.Name:lower()
                    
                    -- Deteksi lebih spesifik
                    if name == "reel" or name == "safezone" or name == "bar" or 
                       name == "reelbar" or name == "fishingbar" or name == "progress" or
                       name == "playerbar" or name == "fish" or
                       name:find("reel") or name:find("safe") then
                        CachedReelUI = obj
                        return true, obj
                    end
                end
            end
        end
    end
    
    CachedReelUI = nil
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
            print("⏰ Cast timeout")
        end
    end)
end

-- ════════════════════════════════════════════════════════
-- ULTRA FAST REEL! (NO DELAY!)
-- ════════════════════════════════════════════════════════
local function DoReel()
    if IsReeling then return end
    IsReeling = true
    ReelStartTime = tick()
    
    print("⚡ INSTANT REEL!")
    
    -- NO DELAY! LANGSUNG ACTION!
    
    -- Method 1: Spam click (FASTEST!)
    for i = 1, 5 do
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.03)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        task.wait(0.02)
    end
    
    -- Method 2: E key spam
    for i = 1, 3 do
        VIM:SendKeyEvent(true, "E", false, game)
        task.wait(0.03)
        VIM:SendKeyEvent(false, "E", false, game)
        task.wait(0.02)
    end
    
    Stats.Fish = Stats.Fish + 1
    print("✅ Fish #" .. Stats.Fish .. " (took " .. math.floor((tick() - ReelStartTime) * 1000) .. "ms)")
    
    -- Short cooldown
    task.wait(0.3)
    IsReeling = false
    IsFishing = false
    CachedReelUI = nil
end

-- ════════════════════════════════════════════════════════
-- REAL-TIME DETECTION (RENDERSTEP = 60 FPS!)
-- ════════════════════════════════════════════════════════
local ReelConnection = nil

local function StartReelDetection()
    if ReelConnection then return end
    
    ReelConnection = RunService.RenderStepped:Connect(function()
        if Config.Enabled and IsFishing and not IsReeling then
            local hasUI, uiObj = HasReelUI()
            if hasUI then
                print("🎯 UI detected at " .. tick())
                DoReel()
            end
        end
    end)
    
    print("✅ RenderStepped detection active! (60 FPS)")
end

local function StopReelDetection()
    if ReelConnection then
        ReelConnection:Disconnect()
        ReelConnection = nil
        print("❌ RenderStepped detection stopped")
    end
end

-- ════════════════════════════════════════════════════════
-- MAIN LOOP (CASTING ONLY!)
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
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FixedFischGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.4, 0, 0.3, 0)
Main.Size = UDim2.new(0, 300, 0, 200)
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 15)
Corner.Parent = Main

local Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(0, 255, 255)
Glow.Thickness = 3
Glow.Parent = Main

local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Font = Enum.Font.GothamBold
Title.Text = "🎣 ULTRA FAST REEL!"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = Title

local TitleFix = Instance.new("Frame")
TitleFix.Parent = Title
TitleFix.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
TitleFix.BorderSizePixel = 0
TitleFix.Position = UDim2.new(0, 0, 0.6, 0)
TitleFix.Size = UDim2.new(1, 0, 0.4, 0)

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = Main
StatsLabel.BackgroundTransparency = 1
StatsLabel.Position = UDim2.new(0, 20, 0, 60)
StatsLabel.Size = UDim2.new(1, -40, 0, 60)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Ready!"
StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsLabel.TextSize = 14
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
    while task.wait(0.3) do
        if StatsLabel.Parent then
            local status = Config.Enabled and "⚡ ULTRA FAST!" or "🔴 STOPPED"
            local hasUI = HasReelUI()
            local currentAction = ""
            
            if Config.Enabled then
                if IsReeling then
                    currentAction = "⚡ Reeling..."
                elseif hasUI then
                    currentAction = "🎯 UI Found!"
                elseif IsFishing then
                    currentAction = "⏳ Waiting bite..."
                else
                    currentAction = "🎣 Casting..."
                end
            end
            
            StatsLabel.Text = string.format(
                "%s\n%s\n\n🐟 Fish: %d | 🎣 Casts: %d",
                status,
                currentAction,
                Stats.Fish,
                Stats.Casts
            )
        end
    end
end)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Main
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0, 20, 0, 130)
ToggleButton.Size = UDim2.new(1, -40, 0, 50)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "🔴 START ULTRA FAST"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = 16

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.Text = "⚡ STOP"
        Glow.Color = Color3.fromRGB(0, 255, 0)
        StartReelDetection()
        print("✅ ULTRA FAST MODE ACTIVATED!")
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = "🔴 START ULTRA FAST"
        Glow.Color = Color3.fromRGB(255, 0, 0)
        StopReelDetection()
        IsFishing = false
        IsReeling = false
        CachedReelUI = nil
        print("❌ STOPPED!")
    end
end)

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
    end
end)

print("════════════════════════════════════════")
print("✅ ULTRA FAST FISCH AUTO LOADED!")
print("════════════════════════════════════════")
print("⚡ IMPROVEMENTS:")
print("  ✅ RenderStepped (60 FPS detection!)")
print("  ✅ NO delay before reel")
print("  ✅ Cached UI detection")
print("  ✅ Spam click method")
print("  ✅ Shows reel time in MS")
print("════════════════════════════════════════")
print("🎣 Ready to fish ULTRA FAST!")
print("════════════════════════════════════════")
