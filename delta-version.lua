--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - OPTIMIZED SPEED
    Fast but won't crash your phone! 📱✅
    ════════════════════════════════════════════════════════
]]

print("📱 LOADING PHONE-FRIENDLY FISCH...")

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Backpack = Player:WaitForChild("Backpack")

-- ════════════════════════════════════════════════════════
-- CONFIG (PHONE OPTIMIZED!)
-- ════════════════════════════════════════════════════════
local Config = {
    Enabled = false,
}

local Stats = {
    Fish = 0,
    Casts = 0,
    FastReels = 0,
}

-- ════════════════════════════════════════════════════════
-- ANTI-AFK (LIGHT!)
-- ════════════════════════════════════════════════════════
Player.Idled:Connect(function()
    pcall(function()
        game:GetService("VirtualUser"):CaptureController()
    end)
end)

-- ════════════════════════════════════════════════════════
-- FIND REMOTES
-- ════════════════════════════════════════════════════════
local CastRemote = nil
local ReelRemote = nil

for _, remote in pairs(RS:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        local name = remote.Name:lower()
        
        if not CastRemote and (name:find("cast") or name:find("fish") or name:find("throw")) then
            CastRemote = remote
            print("✅ Cast:", remote.Name)
        end
        
        if not ReelRemote and (name:find("reel") or name:find("catch") or name:find("complete")) then
            ReelRemote = remote
            print("✅ Reel:", remote.Name)
        end
    end
end

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
-- SMART UI DETECTION (PHONE FRIENDLY!)
-- ════════════════════════════════════════════════════════
local function HasReelUI()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "OptimizedFischGUI" then
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("GuiObject") and obj.Visible then
                    local name = obj.Name:lower()
                    
                    -- Smart detection (gak terlalu agresif)
                    if name == "reel" or name == "safezone" or name == "bar" or 
                       name == "reelbar" or name == "fishingbar" then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- ════════════════════════════════════════════════════════
-- FISHING ACTIONS (OPTIMIZED!)
-- ════════════════════════════════════════════════════════
local IsFishing = false
local LastCast = 0
local ReelCooldown = false

-- CAST (NORMAL)
local function DoCast()
    if IsFishing or tick() - LastCast < 2.5 then return end
    
    Stats.Casts = Stats.Casts + 1
    print("🎣 Cast #" .. Stats.Casts)
    
    EquipRod()
    
    if CastRemote then
        pcall(function() CastRemote:FireServer() end)
    end
    
    local rod = GetRod()
    if rod then
        rod:Activate()
    end
    
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.1)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    IsFishing = true
    LastCast = tick()
    
    task.delay(15, function()
        if IsFishing then IsFishing = false end
    end)
end

-- FAST REEL (PHONE SAFE!)
local function DoFastReel()
    if ReelCooldown then return end
    ReelCooldown = true
    
    Stats.FastReels = Stats.FastReels + 1
    print("⚡ Fast Reel #" .. Stats.FastReels)
    
    -- CEPAT TAPI GAK SPAM BERLEBIHAN!
    
    -- Method 1: Remote (Priority!)
    if ReelRemote then
        for i = 1, 3 do -- Cuma 3x, bukan 20x!
            pcall(function() ReelRemote:FireServer() end)
            task.wait(0.02) -- Small delay buat phone
        end
    end
    
    -- Method 2: E key (Controlled!)
    for i = 1, 5 do -- Cuma 5x, bukan 30x!
        VIM:SendKeyEvent(true, "E", false, game)
        task.wait(0.02)
        VIM:SendKeyEvent(false, "E", false, game)
        task.wait(0.02)
    end
    
    -- Method 3: Mouse (Minimal!)
    for i = 1, 2 do -- Cuma 2x, bukan 25x!
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.03)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        task.wait(0.03)
    end
    
    Stats.Fish = Stats.Fish + 1
    print("✅ Fish #" .. Stats.Fish)
    
    -- Cooldown buat phone safety
    task.wait(0.2)
    IsFishing = false
    ReelCooldown = false
end

-- ════════════════════════════════════════════════════════
-- SINGLE OPTIMIZED LOOP (GAK MULTIPLE!)
-- ════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(0.1) do -- 0.1s = phone friendly!
        if Config.Enabled then
            local hasUI = HasReelUI()
            
            if hasUI and IsFishing and not ReelCooldown then
                DoFastReel()
            elseif not IsFishing then
                DoCast()
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- LIGHTWEIGHT GUI 📱
-- ════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OptimizedFischGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.4, 0, 0.3, 0)
Main.Size = UDim2.new(0, 280, 0, 180)
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

-- Simple glow (gak animated buat phone!)
local Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(0, 200, 100)
Glow.Thickness = 2
Glow.Parent = Main

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Font = Enum.Font.GothamBold
Title.Text = "📱 PHONE-FRIENDLY FISCH"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

local TitleFix = Instance.new("Frame")
TitleFix.Parent = Title
TitleFix.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
TitleFix.BorderSizePixel = 0
TitleFix.Position = UDim2.new(0, 0, 0.6, 0)
TitleFix.Size = UDim2.new(1, 0, 0.4, 0)

-- Stats (Simple update!)
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = Main
StatsLabel.BackgroundTransparency = 1
StatsLabel.Position = UDim2.new(0, 15, 0, 55)
StatsLabel.Size = UDim2.new(1, -30, 0, 60)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Phone Optimized!"
StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsLabel.TextSize = 13
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Update stats (every 2s buat save battery!)
task.spawn(function()
    while task.wait(2) do
        if StatsLabel.Parent then
            local status = Config.Enabled and "📱 Phone Mode ON!" or "🔴 Stopped"
            
            StatsLabel.Text = string.format(
                "%s\n\n⚡ Fast Reels: %d\n🐟 Fish: %d | 🎣 Casts: %d\n\n📱 Optimized for mobile!",
                status,
                Stats.FastReels,
                Stats.Fish,
                Stats.Casts
            )
        end
    end
end)

-- BIG BUTTON
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Main
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0, 15, 0, 125)
ToggleButton.Size = UDim2.new(1, -30, 0, 40)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "🔴 OFF - TAP TO START"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = 14

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 255, 70)
        ToggleButton.Text = "📱 PHONE MODE ON!"
        Glow.Color = Color3.fromRGB(0, 255, 0)
        print("📱 PHONE-FRIENDLY MODE ACTIVATED!")
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        ToggleButton.Text = "🔴 OFF - TAP TO START"
        Glow.Color = Color3.fromRGB(255, 0, 0)
        IsFishing = false
        ReelCooldown = false
        print("❌ PHONE MODE STOPPED!")
    end
end)

-- Hide with DELETE
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
    end
end)

print("════════════════════════════════════════")
print("📱 PHONE-FRIENDLY FISCH LOADED!")
print("════════════════════════════════════════")
print("📱 PHONE OPTIMIZATIONS:")
print("  ✅ Single loop (0.1s)")
print("  ✅ Limited actions (3+5+2 = 10 total)")
print("  ✅ Small delays (0.02-0.03s)")
print("  ✅ No multiple parallel loops")
print("  ✅ Simple GUI (no animations)")
print("  ✅ 2s stat updates (battery save)")
print("════════════════════════════════════════")
print("📱 FAST but won't freeze your phone!")
print("════════════════════════════════════════")
