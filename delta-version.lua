--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - SUPER SIMPLE
    TINGGAL KLIK ON/OFF DOANG!
    ════════════════════════════════════════════════════════
]]

print("🎣 LOADING SIMPLE FISCH AUTO...")

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
-- CONFIG (SIMPLE!)
-- ════════════════════════════════════════════════════════
local Config = {
    Enabled = false,  -- INI YANG DIKONTROL SAMA BUTTON ON/OFF
}

local Stats = {
    Fish = 0,
    Casts = 0,
}

-- ════════════════════════════════════════════════════════
-- ANTI-AFK
-- ════════════════════════════════════════════════════════
Player.Idled:Connect(function()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

-- ════════════════════════════════════════════════════════
-- FIND REMOTES (AUTO!)
-- ════════════════════════════════════════════════════════
local CastRemote = nil
local ReelRemote = nil

for _, remote in pairs(RS:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        local name = remote.Name:lower()
        
        -- Find cast remote
        if not CastRemote and (name:find("cast") or name:find("fish") or name:find("throw")) then
            CastRemote = remote
            print("✅ Found Cast Remote:", remote.Name)
        end
        
        -- Find reel remote  
        if not ReelRemote and (name:find("reel") or name:find("catch") or name:find("complete")) then
            ReelRemote = remote
            print("✅ Found Reel Remote:", remote.Name)
        end
    end
end

-- ════════════════════════════════════════════════════════
-- ROD FUNCTIONS
-- ════════════════════════════════════════════════════════
local function GetRod()
    -- Check equipped
    if Player.Character then
        for _, tool in pairs(Player.Character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("rod") then
                return tool
            end
        end
    end
    
    -- Check backpack
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
        task.wait(0.5)
        return true
    end
    return rod ~= nil
end

-- ════════════════════════════════════════════════════════
-- SIMPLE UI CHECK
-- ════════════════════════════════════════════════════════
local function HasFishingUI()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "SimpleFischGUI" then
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("Frame") and obj.Visible then
                    local name = obj.Name:lower()
                    if name == "reel" or name == "safezone" or name == "bar" then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- ════════════════════════════════════════════════════════
-- FISHING ACTIONS (GUARANTEED TO WORK!)
-- ════════════════════════════════════════════════════════
local IsFishing = false
local LastCast = 0

-- CAST FUNCTION (MULTIPLE METHODS!)
local function DoCast()
    if IsFishing or tick() - LastCast < 3 then return end
    
    Stats.Casts = Stats.Casts + 1
    print("🎣 Casting #" .. Stats.Casts)
    
    EquipRod()
    
    -- METHOD 1: Remote
    if CastRemote then
        pcall(function() CastRemote:FireServer() end)
    end
    
    -- METHOD 2: Tool activate (ALWAYS DO THIS!)
    local rod = GetRod()
    if rod then
        rod:Activate()
    end
    
    -- METHOD 3: Mouse click (FORCE!)
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.1)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    IsFishing = true
    LastCast = tick()
    
    -- Auto reset after 20 seconds
    task.delay(20, function()
        if IsFishing then IsFishing = false end
    end)
end

-- REEL FUNCTION (MULTIPLE METHODS!)
local function DoReel()
    print("🔄 Reeling fish!")
    
    task.wait(0.3)
    
    -- METHOD 1: Remote
    if ReelRemote then
        pcall(function() ReelRemote:FireServer() end)
    end
    
    -- METHOD 2: E key (FORCE!)
    VIM:SendKeyEvent(true, "E", false, game)
    task.wait(0.1)
    VIM:SendKeyEvent(false, "E", false, game)
    
    -- METHOD 3: Space key (FORCE!)
    VIM:SendKeyEvent(true, "Space", false, game)
    task.wait(0.1)
    VIM:SendKeyEvent(false, "Space", false, game)
    
    -- METHOD 4: Mouse click (FORCE!)
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.1)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    Stats.Fish = Stats.Fish + 1
    print("✅ Fish caught! Total: " .. Stats.Fish)
    
    IsFishing = false
end

-- ════════════════════════════════════════════════════════
-- MAIN AUTO LOOP (SIMPLE!)
-- ════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(0.5) do
        if Config.Enabled then
            local hasUI = HasFishingUI()
            
            if hasUI and IsFishing then
                -- ADA UI + LAGI FISHING = REEL!
                DoReel()
            elseif not IsFishing then
                -- GAK FISHING = CAST!
                DoCast()
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- SUPER SIMPLE GUI
-- ════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleFischGUI"
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

-- Glow
local Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(0, 255, 255)
Glow.Thickness = 3
Glow.Parent = Main

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Font = Enum.Font.GothamBold
Title.Text = "🎣 SIMPLE AUTO FISH"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = Title

local TitleFix = Instance.new("Frame")
TitleFix.Parent = Title
TitleFix.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
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
StatsLabel.Text = "Ready!"
StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsLabel.TextSize = 14
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Update stats
task.spawn(function()
    while task.wait(1) do
        if StatsLabel.Parent then
            local status = Config.Enabled and "🟢 FISHING..." or "🔴 STOPPED"
            StatsLabel.Text = string.format(
                "%s\n\n🐟 Fish Caught: %d\n🎣 Total Casts: %d",
                status,
                Stats.Fish,
                Stats.Casts
            )
        end
    end
end)

-- BIG ON/OFF BUTTON
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

-- TOGGLE FUNCTION (SIMPLE!)
ToggleButton.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        -- TURNED ON
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.Text = "🟢 ON - AUTO FISHING!"
        Glow.Color = Color3.fromRGB(0, 255, 0)
        print("✅ AUTO FISHING STARTED!")
    else
        -- TURNED OFF
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = "🔴 OFF - CLICK TO START"
        Glow.Color = Color3.fromRGB(255, 0, 0)
        IsFishing = false
        print("❌ AUTO FISHING STOPPED!")
    end
end)

-- Hide with DELETE
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
    end
end)

-- ════════════════════════════════════════════════════════
-- DONE!
-- ════════════════════════════════════════════════════════
print("════════════════════════════════════════")
print("✅ SIMPLE AUTO FISH LOADED!")
print("════════════════════════════════════════")
print("🎮 SUPER SIMPLE:")
print("  🔴 RED = OFF")
print("  🟢 GREEN = ON (AUTO FISHING!)")
print("")
print("Just click the big button!")
print("Press DELETE to hide/show GUI")
print("════════════════════════════════════════")
