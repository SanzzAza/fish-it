--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - REEL FIXED! 
    CEPAT + GAK LOMPAT!
    ════════════════════════════════════════════════════════
]]

print("🎣 LOADING FIXED FISCH AUTO...")

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
-- ANTI-AFK (SOFT - GAK BIKIN LOMPAT!)
-- ════════════════════════════════════════════════════════
Player.Idled:Connect(function()
    pcall(function()
        game:GetService("VirtualUser"):CaptureController()
    end)
end)

-- ════════════════════════════════════════════════════════
-- FIND REMOTES (AUTO!)
-- ════════════════════════════════════════════════════════
local CastRemote = nil
local ReelRemote = nil

for _, remote in pairs(RS:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        local name = remote.Name:lower()
        
        if not CastRemote and (name:find("cast") or name:find("fish") or name:find("throw")) then
            CastRemote = remote
            print("✅ Cast Remote:", remote.Name)
        end
        
        if not ReelRemote and (name:find("reel") or name:find("catch") or name:find("complete")) then
            ReelRemote = remote
            print("✅ Reel Remote:", remote.Name)
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
-- FASTER UI DETECTION!
-- ════════════════════════════════════════════════════════
local function HasReelUI()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "FixedFischGUI" then
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("GuiObject") and obj.Visible then
                    local name = obj.Name:lower()
                    local className = obj.ClassName
                    
                    -- MULTIPLE DETECTION METHODS!
                    if name == "reel" or name == "safezone" or name == "bar" or 
                       name == "reelbar" or name == "fishingbar" or name == "progress" or
                       name:find("reel") or name:find("safe") or name:find("fish") then
                        return true, obj
                    end
                    
                    -- Check parent names too
                    if obj.Parent then
                        local parentName = obj.Parent.Name:lower()
                        if parentName:find("reel") or parentName:find("fish") then
                            return true, obj
                        end
                    end
                end
            end
        end
    end
    return false, nil
end

-- ════════════════════════════════════════════════════════
-- FISHING ACTIONS (FIXED!)
-- ════════════════════════════════════════════════════════
local IsFishing = false
local LastCast = 0
local ReelCooldown = false

-- CAST (SAME AS BEFORE)
local function DoCast()
    if IsFishing or tick() - LastCast < 2.5 then return end
    
    Stats.Casts = Stats.Casts + 1
    print("🎣 Casting #" .. Stats.Casts)
    
    EquipRod()
    
    -- Remote first
    if CastRemote then
        pcall(function() CastRemote:FireServer() end)
    end
    
    -- Tool activate (GUARANTEED!)
    local rod = GetRod()
    if rod then
        rod:Activate()
    end
    
    -- Mouse click backup
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.1)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    IsFishing = true
    LastCast = tick()
    
    -- Auto reset
    task.delay(15, function()
        if IsFishing then 
            IsFishing = false 
            print("⏰ Cast timeout reset")
        end
    end)
end

-- REEL (FIXED - NO JUMP!)
local function DoReel()
    if ReelCooldown then return end
    ReelCooldown = true
    
    print("🔄 FAST REEL!")
    
    -- SHORTER DELAY!
    task.wait(0.1)
    
    -- METHOD 1: Remote (PRIORITY!)
    if ReelRemote then
        local success = pcall(function() 
            ReelRemote:FireServer() 
        end)
        if success then
            print("✅ Reel remote fired!")
        end
    end
    
    -- METHOD 2: E key ONLY (GAK ADA SPACE = GAK LOMPAT!)
    for i = 1, 3 do
        VIM:SendKeyEvent(true, "E", false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, "E", false, game)
        task.wait(0.05)
    end
    
    -- METHOD 3: Mouse click (SHORT BURST!)
    for i = 1, 2 do
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        task.wait(0.05)
    end
    
    Stats.Fish = Stats.Fish + 1
    print("✅ Fish #" .. Stats.Fish)
    
    -- SHORTER COOLDOWN!
    task.wait(0.5)
    IsFishing = false
    ReelCooldown = false
end

-- ════════════════════════════════════════════════════════
-- FASTER MAIN LOOP!
-- ════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(0.2) do  -- FASTER CHECK! (was 0.5)
        if Config.Enabled then
            local hasUI, uiObj = HasReelUI()
            
            if hasUI and IsFishing then
                print("🎯 UI detected! Reeling...")
                DoReel()
            elseif not IsFishing then
                DoCast()
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- GUI (SAME)
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

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Font = Enum.Font.GothamBold
Title.Text = "🎣 FISCH AUTO - FIXED!"
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

-- Stats
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = Main
StatsLabel.BackgroundTransparency = 1
StatsLabel.Position = UDim2.new(0, 20, 0, 60)
StatsLabel.Size = UDim2.new(1, -40, 0, 60)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Fixed & Ready!"
StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsLabel.TextSize = 14
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Update stats
task.spawn(function()
    while task.wait(0.5) do
        if StatsLabel.Parent then
            local status = Config.Enabled and "🟢 FAST FISHING!" or "🔴 STOPPED"
            local hasUI = HasReelUI()
            local currentAction = ""
            
            if Config.Enabled then
                if hasUI then
                    currentAction = "🔄 Reeling..."
                elseif IsFishing then
                    currentAction = "⏳ Waiting..."
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

-- BIG BUTTON
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Main
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0, 20, 0, 130)
ToggleButton.Size = UDim2.new(1, -40, 0, 50)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "🔴 OFF - CLICK TO START"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = 16

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.Text = "🟢 ON - FAST FISHING!"
        Glow.Color = Color3.fromRGB(0, 255, 0)
        print("✅ FAST AUTO FISHING STARTED!")
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = "🔴 OFF - CLICK TO START"
        Glow.Color = Color3.fromRGB(255, 0, 0)
        IsFishing = false
        ReelCooldown = false
        print("❌ AUTO FISHING STOPPED!")
    end
end)

-- Hide with DELETE
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
    end
end)

print("════════════════════════════════════════")
print("✅ FIXED FISCH AUTO LOADED!")
print("════════════════════════════════════════")
print("🔧 FIXES:")
print("  ✅ FASTER reel detection (0.2s)")
print("  ✅ NO Space key (no jumping!)")
print("  ✅ SHORTER reel delay (0.1s)")
print("  ✅ Multiple UI detection methods")
print("  ✅ Better timing system")
print("════════════════════════════════════════")
print("🎣 Cast works ✅ | Reel fixed ✅")
print("════════════════════════════════════════")
