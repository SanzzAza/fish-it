--[[
    ════════════════════════════════════════════════════════
    ⚡ FISCH AUTO - EXTREME SPEED
    ZERO DELAY! MEGA SPAM! INSTANT EVERYTHING!
    ════════════════════════════════════════════════════════
]]

print("🔥 LOADING EXTREME SPEED FISCH...")

repeat task.wait() until game:IsLoaded()
task.wait(1)

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
    MegaReels = 0,
    TapsPerSecond = 0,
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
        task.wait(0.1) -- MINIMAL WAIT!
        return true
    end
    return rod ~= nil
end

-- ════════════════════════════════════════════════════════
-- MEGA SPEED UI DETECTION!
-- ════════════════════════════════════════════════════════
local function HasReelUI()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "ExtremeFischGUI" then
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("GuiObject") and obj.Visible then
                    local name = obj.Name:lower()
                    
                    -- INSTANT DETECTION - NO DELAY!
                    if name == "reel" or name == "safezone" or name == "bar" or 
                       name == "reelbar" or name == "fishingbar" or name == "progress" or
                       name:find("reel") or name:find("safe") or name:find("fish") or
                       name:find("catch") or name:find("hook") or name:find("mini") then
                        return true
                    end
                    
                    if obj.Parent then
                        local parentName = obj.Parent.Name:lower()
                        if parentName:find("reel") or parentName:find("fish") or 
                           parentName:find("catch") or parentName:find("mini") then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

-- ════════════════════════════════════════════════════════
-- FISHING ACTIONS
-- ════════════════════════════════════════════════════════
local IsFishing = false
local LastCast = 0

-- CAST
local function DoCast()
    if IsFishing or tick() - LastCast < 1.5 then return end
    
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
    
    -- INSTANT CLICK!
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    IsFishing = true
    LastCast = tick()
    
    task.delay(10, function()
        if IsFishing then IsFishing = false end
    end)
end

-- 🔥 EXTREME MEGA SPAM REEL! 🔥
local ReelActive = false

local function DoMegaSpamReel()
    if ReelActive then return end
    ReelActive = true
    
    Stats.MegaReels = Stats.MegaReels + 1
    print("🔥 MEGA SPAM REEL #" .. Stats.MegaReels)
    
    local tapCount = 0
    local startTime = tick()
    
    -- 🔥 METHOD 1: REMOTE MEGA SPAM (20x INSTANT!)
    if ReelRemote then
        task.spawn(function()
            for i = 1, 20 do
                pcall(function() 
                    ReelRemote:FireServer() 
                    tapCount = tapCount + 1
                end)
                -- NO WAIT! PURE SPAM!
            end
        end)
    end
    
    -- 🔥 METHOD 2: E KEY MEGA SPAM (30x INSTANT!)
    task.spawn(function()
        for i = 1, 30 do
            VIM:SendKeyEvent(true, "E", false, game)
            VIM:SendKeyEvent(false, "E", false, game)
            tapCount = tapCount + 1
            -- NO WAIT! PURE SPAM!
        end
    end)
    
    -- 🔥 METHOD 3: MOUSE MEGA SPAM (25x INSTANT!)
    task.spawn(function()
        for i = 1, 25 do
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            tapCount = tapCount + 1
            -- NO WAIT! PURE SPAM!
        end
    end)
    
    -- 🔥 METHOD 4: MEGA REMOTE SPAM (DIFFERENT ARGS!)
    if ReelRemote then
        task.spawn(function()
            for i = 1, 15 do
                pcall(function() ReelRemote:FireServer(true) end)
                pcall(function() ReelRemote:FireServer(100) end)
                pcall(function() ReelRemote:FireServer("complete") end)
                tapCount = tapCount + 3
                -- NO WAIT! PURE SPAM!
            end
        end)
    end
    
    Stats.Fish = Stats.Fish + 1
    
    -- Calculate TPS
    local endTime = tick()
    Stats.TapsPerSecond = math.floor(tapCount / (endTime - startTime))
    
    print("🔥 MEGA REEL COMPLETE! TPS: " .. Stats.TapsPerSecond)
    
    -- INSTANT RESET! NO COOLDOWN!
    IsFishing = false
    ReelActive = false
end

-- ════════════════════════════════════════════════════════
-- EXTREME SPEED LOOPS! 🚀
-- ════════════════════════════════════════════════════════

-- MAIN LOOP (HEARTBEAT = FASTEST POSSIBLE!)
RunService.Heartbeat:Connect(function()
    if Config.Enabled then
        local hasUI = HasReelUI()
        
        if hasUI and IsFishing and not ReelActive then
            print("🔥 INSTANT UI DETECTED!")
            DoMegaSpamReel()
        elseif not IsFishing then
            DoCast()
        end
    end
end)

-- BACKUP LOOP 1 (STEPPED = ALSO FAST!)
RunService.Stepped:Connect(function()
    if Config.Enabled and IsFishing and not ReelActive then
        if HasReelUI() then
            DoMegaSpamReel()
        end
    end
end)

-- BACKUP LOOP 2 (RENDERSTEPPED = RENDER SPEED!)
RunService.RenderStepped:Connect(function()
    if Config.Enabled and IsFishing and not ReelActive then
        if HasReelUI() then
            DoMegaSpamReel()
        end
    end
end)

-- BACKUP LOOP 3 (TASK SPAWN = CONTINUOUS!)
task.spawn(function()
    while true do
        if Config.Enabled and IsFishing and not ReelActive then
            if HasReelUI() then
                DoMegaSpamReel()
            end
        end
        -- INSTANT LOOP! NO WAIT!
    end
end)

-- ════════════════════════════════════════════════════════
-- GUI
-- ════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExtremeFischGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.4, 0, 0.3, 0)
Main.Size = UDim2.new(0, 350, 0, 240)
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 15)
Corner.Parent = Main

-- EXTREME GLOW EFFECT!
local Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(255, 0, 0)
Glow.Thickness = 5
Glow.Parent = Main

-- Animate extreme glow
task.spawn(function()
    while true do
        for i = 0, 360, 10 do
            if Glow and Glow.Parent then
                local hue = i / 360
                Glow.Color = Color3.fromHSV(hue, 1, 1)
                Glow.Thickness = 3 + math.sin(i) * 2
            end
            task.wait(0.02)
        end
    end
end)

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Font = Enum.Font.GothamBold
Title.Text = "🔥 EXTREME MEGA SPEED"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.TextStrokeTransparency = 0
Title.TextStrokeColor3 = Color3.new(0, 0, 0)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = Title

local TitleFix = Instance.new("Frame")
TitleFix.Parent = Title
TitleFix.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
TitleFix.BorderSizePixel = 0
TitleFix.Position = UDim2.new(0, 0, 0.6, 0)
TitleFix.Size = UDim2.new(1, 0, 0.4, 0)

-- Stats
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = Main
StatsLabel.BackgroundTransparency = 1
StatsLabel.Position = UDim2.new(0, 15, 0, 60)
StatsLabel.Size = UDim2.new(1, -30, 0, 100)
StatsLabel.Font = Enum.Font.GothamBold
StatsLabel.Text = "EXTREME SPEED READY!"
StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsLabel.TextSize = 12
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Update stats
RunService.Heartbeat:Connect(function()
    if StatsLabel.Parent then
        local status = Config.Enabled and "🔥 EXTREME MODE!" or "🔴 STOPPED"
        local hasUI = HasReelUI()
        local currentAction = ""
        
        if Config.Enabled then
            if ReelActive then
                currentAction = "🔥 MEGA SPAM ACTIVE!"
            elseif hasUI then
                currentAction = "🎯 UI DETECTED!"
            elseif IsFishing then
                currentAction = "⏳ Waiting..."
            else
                currentAction = "🎣 Casting..."
            end
        end
        
        StatsLabel.Text = string.format(
            "%s\n%s\n\n🔥 Mega Reels: %d\n🐟 Fish: %d | 🎣 Casts: %d\n⚡ Last TPS: %d\n\nSpeed: HEARTBEAT + 3 LOOPS!\nDelay: ZERO!",
            status,
            currentAction,
            Stats.MegaReels,
            Stats.Fish,
            Stats.Casts,
            Stats.TapsPerSecond
        )
    end
end)

-- BIG BUTTON
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Main
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0, 15, 0, 170)
ToggleButton.Size = UDim2.new(1, -30, 0, 50)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "🔴 OFF - CLICK FOR EXTREME!"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = 15
ToggleButton.TextStrokeTransparency = 0
ToggleButton.TextStrokeColor3 = Color3.new(0, 0, 0)

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        ToggleButton.Text = "🔥 EXTREME MODE ACTIVE!"
        print("🔥 EXTREME MEGA SPEED ACTIVATED!")
        print("⚡ Heartbeat + 3 backup loops running!")
        print("🚀 Zero delay mega spam enabled!")
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = "🔴 OFF - CLICK FOR EXTREME!"
        IsFishing = false
        ReelActive = false
        print("❌ EXTREME MODE STOPPED!")
    end
end)

-- Hide with DELETE
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
    end
end)

print("════════════════════════════════════════")
print("🔥 EXTREME MEGA SPEED FISCH LOADED!")
print("════════════════════════════════════════")
print("⚡ EXTREME FEATURES:")
print("  🚀 Heartbeat loop (fastest possible!)")
print("  🚀 3 backup detection loops")
print("  🚀 75+ actions per reel")
print("  🚀 ZERO delays")
print("  🚀 4 simultaneous spam methods")
print("  🚀 Multiple remote arguments")
print("  🚀 TPS counter")
print("════════════════════════════════════════")
print("🔥 READY FOR EXTREME SPEED!")
print("Warning: This is MAXIMUM SPEED!")
print("════════════════════════════════════════")
