--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - LIGHTNING FAST REEL! 
    INSTANT REEL - NO DELAY!
    ════════════════════════════════════════════════════════
]]

print("⚡ LOADING LIGHTNING FISCH AUTO...")

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
    FastReels = 0,
}

-- ════════════════════════════════════════════════════════
-- ANTI-AFK
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
        task.wait(0.2)
        return true
    end
    return rod ~= nil
end

-- ════════════════════════════════════════════════════════
-- ULTRA FAST UI DETECTION!
-- ════════════════════════════════════════════════════════
local function HasReelUI()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "LightningFischGUI" then
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("GuiObject") and obj.Visible then
                    local name = obj.Name:lower()
                    
                    -- INSTANT DETECTION!
                    if name == "reel" or name == "safezone" or name == "bar" or 
                       name == "reelbar" or name == "fishingbar" or name == "progress" or
                       name:find("reel") or name:find("safe") or name:find("fish") or
                       name:find("catch") or name:find("hook") then
                        return true, obj
                    end
                    
                    -- Check parent too
                    if obj.Parent then
                        local parentName = obj.Parent.Name:lower()
                        if parentName:find("reel") or parentName:find("fish") or parentName:find("catch") then
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
-- FISHING ACTIONS
-- ════════════════════════════════════════════════════════
local IsFishing = false
local LastCast = 0

-- CAST (SAME)
local function DoCast()
    if IsFishing or tick() - LastCast < 2 then return end
    
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
    
    task.delay(12, function()
        if IsFishing then 
            IsFishing = false 
        end
    end)
end

-- LIGHTNING FAST REEL! ⚡⚡⚡
local ReelActive = false

local function DoLightningReel()
    if ReelActive then return end
    ReelActive = true
    
    Stats.FastReels = Stats.FastReels + 1
    print("⚡ LIGHTNING REEL #" .. Stats.FastReels)
    
    -- NO DELAY! INSTANT ACTION!
    
    -- SPAM MULTIPLE METHODS INSTANTLY!
    task.spawn(function()
        -- METHOD 1: Remote spam (3x FAST!)
        if ReelRemote then
            for i = 1, 3 do
                pcall(function() ReelRemote:FireServer() end)
                task.wait(0.01) -- SUPER FAST!
            end
        end
    end)
    
    task.spawn(function()
        -- METHOD 2: E key spam (5x FAST!)
        for i = 1, 5 do
            VIM:SendKeyEvent(true, "E", false, game)
            task.wait(0.01)
            VIM:SendKeyEvent(false, "E", false, game)
            task.wait(0.01)
        end
    end)
    
    task.spawn(function()
        -- METHOD 3: Mouse spam (3x FAST!)
        for i = 1, 3 do
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            task.wait(0.01)
        end
    end)
    
    Stats.Fish = Stats.Fish + 1
    print("⚡ LIGHTNING FISH #" .. Stats.Fish)
    
    -- INSTANT RESET! (was 0.5s, now 0.1s!)
    task.wait(0.1)
    IsFishing = false
    ReelActive = false
end

-- ════════════════════════════════════════════════════════
-- LIGHTNING FAST MAIN LOOP! ⚡
-- ════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(0.05) do  -- ULTRA FAST CHECK! (was 0.2s, now 0.05s!)
        if Config.Enabled then
            local hasUI, uiObj = HasReelUI()
            
            if hasUI and IsFishing and not ReelActive then
                print("⚡ INSTANT UI DETECTED!")
                DoLightningReel()
            elseif not IsFishing then
                DoCast()
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- ADDITIONAL AGGRESSIVE REEL DETECTION!
-- ════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(0.03) do  -- EVEN FASTER BACKUP CHECK!
        if Config.Enabled and IsFishing and not ReelActive then
            -- BACKUP DETECTION METHOD!
            for _, gui in pairs(PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Enabled then
                    -- Look for ANY visible frame when fishing!
                    for _, obj in pairs(gui:GetDescendants()) do
                        if obj:IsA("Frame") and obj.Visible and obj.Size.Y.Scale > 0.01 then
                            local name = obj.Name:lower()
                            if name:len() > 2 then -- Any meaningful frame
                                -- AGGRESSIVE REEL!
                                DoLightningReel()
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- GUI
-- ════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LightningFischGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.4, 0, 0.3, 0)
Main.Size = UDim2.new(0, 320, 0, 220)
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 15)
Corner.Parent = Main

-- Lightning effect!
local Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(255, 255, 0)
Glow.Thickness = 4
Glow.Parent = Main

-- Animate glow
task.spawn(function()
    while task.wait(0.1) do
        if Glow and Glow.Parent then
            Glow.Color = Color3.fromHSV(tick() % 1, 1, 1)
        end
    end
end)

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡ LIGHTNING FAST REEL"
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.TextSize = 18

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = Title

local TitleFix = Instance.new("Frame")
TitleFix.Parent = Title
TitleFix.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
TitleFix.BorderSizePixel = 0
TitleFix.Position = UDim2.new(0, 0, 0.6, 0)
TitleFix.Size = UDim2.new(1, 0, 0.4, 0)

-- Stats
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = Main
StatsLabel.BackgroundTransparency = 1
StatsLabel.Position = UDim2.new(0, 20, 0, 60)
StatsLabel.Size = UDim2.new(1, -40, 0, 80)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Lightning Ready!"
StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsLabel.TextSize = 13
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Update stats (FAST!)
task.spawn(function()
    while task.wait(0.2) do
        if StatsLabel.Parent then
            local status = Config.Enabled and "⚡ LIGHTNING MODE!" or "🔴 STOPPED"
            local hasUI = HasReelUI()
            local currentAction = ""
            
            if Config.Enabled then
                if ReelActive then
                    currentAction = "⚡ LIGHTNING REEL!"
                elseif hasUI then
                    currentAction = "🎯 UI DETECTED!"
                elseif IsFishing then
                    currentAction = "⏳ Waiting..."
                else
                    currentAction = "🎣 Casting..."
                end
            end
            
            StatsLabel.Text = string.format(
                "%s\n%s\n\n⚡ Lightning Reels: %d\n🐟 Fish: %d | 🎣 Casts: %d\n\nSpeed: 0.05s loops!",
                status,
                currentAction,
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
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0, 20, 0, 150)
ToggleButton.Size = UDim2.new(1, -40, 0, 50)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "🔴 OFF - CLICK FOR LIGHTNING!"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = 15

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        ToggleButton.Text = "⚡ LIGHTNING MODE ON!"
        Glow.Color = Color3.fromRGB(255, 255, 0)
        print("⚡ LIGHTNING FAST FISHING ACTIVATED!")
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.Text = "🔴 OFF - CLICK FOR LIGHTNING!"
        Glow.Color = Color3.fromRGB(255, 0, 0)
        IsFishing = false
        ReelActive = false
        print("❌ LIGHTNING MODE STOPPED!")
    end
end)

-- Hide with DELETE
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
    end
end)

print("════════════════════════════════════════")
print("⚡ LIGHTNING FISCH AUTO LOADED!")
print("════════════════════════════════════════")
print("🚀 LIGHTNING SPEED FEATURES:")
print("  ⚡ 0.05s loop (was 0.2s)")
print("  ⚡ 0.01s action delays") 
print("  ⚡ 0.1s reel reset (was 0.5s)")
print("  ⚡ Parallel reel methods")
print("  ⚡ Backup detection loop (0.03s)")
print("  ⚡ Aggressive UI detection")
print("════════════════════════════════════════")
print("⚡ READY FOR LIGHTNING SPEED FISHING!")
print("════════════════════════════════════════")
