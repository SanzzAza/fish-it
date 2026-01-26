--[[
    ═══════════════════════════════════════════════════════
    🎣 FISCH AUTO - CLEAN & FOCUSED
    HANYA AUTO FISHING - GAK ADA YANG LAIN!
    ═══════════════════════════════════════════════════════
]]

print("════════════════════════════════════════")
print("🎣 LOADING FISCH AUTO...")
print("════════════════════════════════════════")

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Backpack = Player:WaitForChild("Backpack")

-- ════════════════════════════════════════════════════════
-- CONFIG
-- ════════════════════════════════════════════════════════
local Config = {
    Enabled = false,  -- Toggle ON/OFF
    
    CastDelay = 3,       -- Delay antar cast (detik)
    ReelDelay = 0.5,     -- Delay sebelum reel (detik)
    
    ShowDebug = true,
}

-- ════════════════════════════════════════════════════════
-- STATS
-- ════════════════════════════════════════════════════════
local Stats = {
    Fish = 0,
    Casts = 0,
    StartTime = tick(),
    Status = "Idle",
}

-- ════════════════════════════════════════════════════════
-- DEBUG
-- ════════════════════════════════════════════════════════
local function Log(...)
    if Config.ShowDebug then
        print("🎣", ...)
    end
end

-- ════════════════════════════════════════════════════════
-- ANTI-AFK (MINIMAL - GAK BIKIN GERAK!)
-- ════════════════════════════════════════════════════════
local VU = game:GetService("VirtualUser")
Player.Idled:Connect(function()
    VU:CaptureController()
    VU:ClickButton2(Vector2.new())
end)

-- ════════════════════════════════════════════════════════
-- FIND FISHING REMOTES (SPECIFIC ONLY!)
-- ════════════════════════════════════════════════════════
local Remotes = {
    Cast = nil,
    Reel = nil,
}

local function FindRemotes()
    Log("Looking for fishing remotes...")
    
    for _, remote in pairs(RS:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            
            -- Cast remote (very specific)
            if name == "cast" or name == "requestcast" then
                Remotes.Cast = remote
                Log("✅ Found Cast:", remote:GetFullName())
            end
            
            -- Reel remote (very specific)
            if name == "reel" or name == "reelfinished" or name == "catch" then
                Remotes.Reel = remote
                Log("✅ Found Reel:", remote:GetFullName())
            end
        end
    end
end

FindRemotes()

-- ════════════════════════════════════════════════════════
-- ROD FUNCTIONS
-- ════════════════════════════════════════════════════════
local function GetRod()
    -- Check equipped first
    if Player.Character then
        for _, item in pairs(Player.Character:GetChildren()) do
            if item:IsA("Tool") and item.Name:lower():find("rod") then
                return item
            end
        end
    end
    
    -- Check backpack
    for _, item in pairs(Backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name:lower():find("rod") then
            return item
        end
    end
    
    return nil
end

local function EquipRod()
    local rod = GetRod()
    if not rod then
        Log("❌ No rod found!")
        return false
    end
    
    if rod.Parent == Backpack then
        Player.Character.Humanoid:EquipTool(rod)
        task.wait(0.5)
        Log("Equipped rod")
        return true
    end
    
    return rod.Parent == Player.Character
end

-- ════════════════════════════════════════════════════════
-- UI DETECTION (CLEAN!)
-- ════════════════════════════════════════════════════════
local function HasReelUI()
    -- Cari UI yang muncul saat fishing
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            -- Cari frame reel/safezone
            for _, child in pairs(gui:GetDescendants()) do
                if child:IsA("Frame") and child.Visible then
                    local name = child.Name:lower()
                    -- Cek nama spesifik untuk reel UI
                    if name == "reel" or name == "safezone" or name == "bar" then
                        return true, child
                    end
                end
            end
        end
    end
    return false, nil
end

-- ════════════════════════════════════════════════════════
-- FISHING ACTIONS (CLEAN - NO SPAM!)
-- ════════════════════════════════════════════════════════
local IsFishing = false

local function Cast()
    if IsFishing then return end
    
    Stats.Status = "Casting..."
    
    if not EquipRod() then
        Stats.Status = "No Rod!"
        return
    end
    
    Stats.Casts = Stats.Casts + 1
    Log("🎣 Casting... (#" .. Stats.Casts .. ")")
    
    -- Method 1: Fire remote (if found)
    if Remotes.Cast then
        local success = pcall(function()
            Remotes.Cast:FireServer()
        end)
        if success then
            Log("✅ Cast remote fired")
        end
    else
        -- Method 2: Activate rod tool (SAFE - gak bikin gerak!)
        local rod = GetRod()
        if rod and rod.Parent == Player.Character then
            rod:Activate()
            Log("✅ Rod activated")
        end
    end
    
    IsFishing = true
    Stats.Status = "Waiting for fish..."
end

local ReelLock = false

local function Reel()
    if ReelLock then return end
    ReelLock = true
    
    Stats.Status = "Reeling..."
    Log("🎣 Reeling...")
    
    task.wait(Config.ReelDelay)
    
    -- HANYA PAKAI REMOTE (gak ada spam key/click!)
    if Remotes.Reel then
        local success = pcall(function()
            Remotes.Reel:FireServer()
        end)
        
        if success then
            Stats.Fish = Stats.Fish + 1
            Log("✅ Fish caught! Total: " .. Stats.Fish)
        else
            Log("❌ Reel failed")
        end
    else
        Log("⚠️ No reel remote found")
    end
    
    task.wait(1)
    IsFishing = false
    ReelLock = false
    Stats.Status = "Ready"
end

-- ════════════════════════════════════════════════════════
-- MAIN LOOP (SIMPLE & CLEAN!)
-- ════════════════════════════════════════════════════════
local LastCast = 0

task.spawn(function()
    Log("🚀 Auto fishing loop started")
    
    while task.wait(0.5) do
        if not Config.Enabled then
            Stats.Status = "Stopped"
            continue
        end
        
        -- Check for reel UI
        local hasUI, ui = HasReelUI()
        
        if hasUI and IsFishing then
            -- Ada UI reel = ikan nyangkut!
            Reel()
        elseif not IsFishing and tick() - LastCast >= Config.CastDelay then
            -- Gak ada UI dan udah lewat delay = cast lagi
            Cast()
            LastCast = tick()
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- GUI (SIMPLE!)
-- ════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FischGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.02, 0, 0.3, 0)
Main.Size = UDim2.new(0, 280, 0, 200)
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Main

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "🎣 FISCH AUTO"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local TitleCover = Instance.new("Frame")
TitleCover.Parent = Title
TitleCover.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
TitleCover.BorderSizePixel = 0
TitleCover.Position = UDim2.new(0, 0, 0.7, 0)
TitleCover.Size = UDim2.new(1, 0, 0.3, 0)

-- Stats
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = Main
StatsLabel.BackgroundTransparency = 1
StatsLabel.Position = UDim2.new(0, 10, 0, 50)
StatsLabel.Size = UDim2.new(1, -20, 0, 60)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Status: Idle"
StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsLabel.TextSize = 13
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Update stats
task.spawn(function()
    while task.wait(0.5) do
        if StatsLabel.Parent then
            local runtime = tick() - Stats.StartTime
            local mins = math.floor(runtime / 60)
            local secs = math.floor(runtime % 60)
            
            StatsLabel.Text = string.format(
                "Status: %s\n\n🐟 Fish: %d | 🎣 Casts: %d\n⏱️ Time: %02d:%02d",
                Stats.Status,
                Stats.Fish,
                Stats.Casts,
                mins,
                secs
            )
        end
    end
end)

-- Toggle Button
local Toggle = Instance.new("TextButton")
Toggle.Parent = Main
Toggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Toggle.BorderSizePixel = 0
Toggle.Position = UDim2.new(0, 10, 0, 120)
Toggle.Size = UDim2.new(1, -20, 0, 40)
Toggle.Font = Enum.Font.GothamBold
Toggle.Text = "▶️ START"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.TextSize = 16

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = Toggle

Toggle.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        Toggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        Toggle.Text = "⏸️ STOP"
        Log("✅ AUTO FISHING ON")
    else
        Toggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        Toggle.Text = "▶️ START"
        IsFishing = false
        ReelLock = false
        Log("⏹️ AUTO FISHING OFF")
    end
end)

-- Close Button
local Close = Instance.new("TextButton")
Close.Parent = Main
Close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0, 10, 0, 165)
Close.Size = UDim2.new(1, -20, 0, 25)
Close.Font = Enum.Font.Gotham
Close.Text = "❌ Close"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 12

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = Close

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    Config.Enabled = false
end)

-- Toggle GUI visibility
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
    end
end)

-- ════════════════════════════════════════════════════════
-- DONE!
-- ════════════════════════════════════════════════════════
print("════════════════════════════════════════")
print("✅ FISCH AUTO LOADED!")
print("════════════════════════════════════════")
print("📖 HOW TO USE:")
print("  1. Click 'START' button")
print("  2. Wait for auto fishing!")
print("  3. Click 'STOP' to pause")
print("")
print("⌨️  Press DELETE to hide/show")
print("════════════════════════════════════════")

Log("Ready! Press START to begin fishing")
