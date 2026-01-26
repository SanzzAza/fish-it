--[[
    ═══════════════════════════════════════════════════════
    🎣 FISCH AUTO - ULTRA MINIMAL
    HANYA REMOTE - GAK ADA AKTIVASI LAIN!
    ═══════════════════════════════════════════════════════
]]

print("════════════════════════════════════════")
print("🎣 FISCH AUTO - MINIMAL MODE")
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

-- ════════════════════════════════════════════════════════
-- CONFIG
-- ════════════════════════════════════════════════════════
local Config = {
    Enabled = false,
    CastDelay = 3,
    ReelDelay = 0.5,
    ShowDebug = true,
}

local Stats = {
    Fish = 0,
    Casts = 0,
    StartTime = tick(),
    Status = "Idle",
}

local function Log(...)
    if Config.ShowDebug then
        print("🎣", ...)
    end
end

-- ════════════════════════════════════════════════════════
-- ANTI-AFK (PALING SOFT - GAK BIKIN GERAK!)
-- ════════════════════════════════════════════════════════
Player.Idled:Connect(function()
    -- Cuma capture controller, gak ada click/movement
    pcall(function()
        game:GetService("VirtualUser"):CaptureController()
    end)
end)

-- ════════════════════════════════════════════════════════
-- FIND REMOTES (PRINT SEMUA BIAR KITA TAU!)
-- ════════════════════════════════════════════════════════
local AllRemotes = {}

Log("Scanning remotes...")
for _, obj in pairs(RS:GetDescendants()) do
    if obj:IsA("RemoteEvent") then
        table.insert(AllRemotes, obj)
        Log("  Found:", obj.Name, "|", obj:GetFullName())
    end
end

Log("Total remotes found:", #AllRemotes)

-- ════════════════════════════════════════════════════════
-- UI DETECTION
-- ════════════════════════════════════════════════════════
local function CheckForReelUI()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("Frame") and obj.Visible then
                    local name = obj.Name:lower()
                    -- Deteksi nama spesifik aja
                    if name == "reel" or name == "safezone" then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- ════════════════════════════════════════════════════════
-- VARIABLES
-- ════════════════════════════════════════════════════════
local IsFishing = false
local CanReel = false
local LastCast = 0

-- ════════════════════════════════════════════════════════
-- MAIN LOOP (CUMA MONITOR UI!)
-- ════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(0.5) do
        if Config.Enabled then
            local hasReelUI = CheckForReelUI()
            
            if hasReelUI then
                CanReel = true
            else
                CanReel = false
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- MANUAL REMOTE SETUP (EDIT INI!)
-- ════════════════════════════════════════════════════════
-- Ganti dengan nama remote yang EXACT dari game!
local CastRemoteName = "cast"  -- ⬅️ EDIT INI!
local ReelRemoteName = "reel"  -- ⬅️ EDIT INI!

local CastRemote = nil
local ReelRemote = nil

-- Cari remote berdasarkan nama
for _, remote in pairs(AllRemotes) do
    if remote.Name:lower() == CastRemoteName:lower() then
        CastRemote = remote
        Log("✅ Cast remote set:", remote:GetFullName())
    end
    if remote.Name:lower() == ReelRemoteName:lower() then
        ReelRemote = remote
        Log("✅ Reel remote set:", remote:GetFullName())
    end
end

-- ════════════════════════════════════════════════════════
-- FISHING FUNCTIONS (REMOTE ONLY!)
-- ════════════════════════════════════════════════════════
local function Cast()
    if not CastRemote then
        Log("❌ Cast remote not found!")
        return false
    end
    
    Stats.Casts = Stats.Casts + 1
    Stats.Status = "Casting..."
    Log("🎣 Casting... (#" .. Stats.Casts .. ")")
    
    local success = pcall(function()
        CastRemote:FireServer()
    end)
    
    if success then
        IsFishing = true
        Stats.Status = "Waiting for fish..."
        return true
    else
        Log("❌ Cast failed")
        return false
    end
end

local function Reel()
    if not ReelRemote then
        Log("❌ Reel remote not found!")
        return false
    end
    
    Stats.Status = "Reeling..."
    Log("🎣 Reeling...")
    
    task.wait(Config.ReelDelay)
    
    local success = pcall(function()
        ReelRemote:FireServer()
    end)
    
    if success then
        Stats.Fish = Stats.Fish + 1
        Stats.Status = "Fish caught!"
        Log("✅ Fish caught! Total:", Stats.Fish)
        IsFishing = false
        return true
    else
        Log("❌ Reel failed")
        IsFishing = false
        return false
    end
end

-- ════════════════════════════════════════════════════════
-- AUTO LOOP
-- ════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(1) do
        if not Config.Enabled then
            Stats.Status = "Stopped"
            continue
        end
        
        -- Kalo ada UI reel dan lagi fishing
        if CanReel and IsFishing then
            Reel()
        -- Kalo gak fishing dan udah lewat delay
        elseif not IsFishing and tick() - LastCast >= Config.CastDelay then
            if Cast() then
                LastCast = tick()
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- GUI
-- ════════════════════════════════════════════════════════
local SG = Instance.new("ScreenGui")
SG.Name = "FischMinimalGUI"
SG.ResetOnSpawn = false
SG.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Parent = SG
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.4, 0, 0.3, 0)
Main.Size = UDim2.new(0, 320, 0, 280)
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Font = Enum.Font.GothamBold
Title.Text = "🎣 FISCH AUTO (MINIMAL)"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 17

local TCorner = Instance.new("UICorner")
TCorner.CornerRadius = UDim.new(0, 12)
TCorner.Parent = Title

local TCover = Instance.new("Frame")
TCover.Parent = Title
TCover.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
TCover.BorderSizePixel = 0
TCover.Position = UDim2.new(0, 0, 0.7, 0)
TCover.Size = UDim2.new(1, 0, 0.3, 0)

-- Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = Main
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 15, 0, 55)
StatusLabel.Size = UDim2.new(1, -30, 0, 80)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Update
task.spawn(function()
    while task.wait(0.5) do
        if StatusLabel and StatusLabel.Parent then
            local runtime = tick() - Stats.StartTime
            local m = math.floor(runtime / 60)
            local s = math.floor(runtime % 60)
            
            local remoteStatus = ""
            if CastRemote then
                remoteStatus = remoteStatus .. "✅ Cast\n"
            else
                remoteStatus = remoteStatus .. "❌ Cast\n"
            end
            if ReelRemote then
                remoteStatus = remoteStatus .. "✅ Reel\n"
            else
                remoteStatus = remoteStatus .. "❌ Reel\n"
            end
            
            StatusLabel.Text = string.format(
                "Status: %s\n\n" ..
                "Remotes:\n%s\n" ..
                "🐟 Fish: %d | 🎣 Casts: %d\n" ..
                "⏱️ Time: %02d:%02d",
                Stats.Status,
                remoteStatus,
                Stats.Fish,
                Stats.Casts,
                m, s
            )
        end
    end
end)

-- Toggle
local Toggle = Instance.new("TextButton")
Toggle.Parent = Main
Toggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Toggle.BorderSizePixel = 0
Toggle.Position = UDim2.new(0, 15, 0, 180)
Toggle.Size = UDim2.new(1, -30, 0, 45)
Toggle.Font = Enum.Font.GothamBold
Toggle.Text = "▶️ START AUTO FISH"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.TextSize = 15

local TgCorner = Instance.new("UICorner")
TgCorner.CornerRadius = UDim.new(0, 8)
TgCorner.Parent = Toggle

Toggle.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        Toggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        Toggle.Text = "⏸️ STOP AUTO FISH"
        Log("✅ Started")
    else
        Toggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        Toggle.Text = "▶️ START AUTO FISH"
        IsFishing = false
        Log("⏹️ Stopped")
    end
end)

-- Close
local Close = Instance.new("TextButton")
Close.Parent = Main
Close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0, 15, 0, 235)
Close.Size = UDim2.new(1, -30, 0, 30)
Close.Font = Enum.Font.Gotham
Close.Text = "❌ CLOSE"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 13

local CCorner = Instance.new("UICorner")
CCorner.CornerRadius = UDim.new(0, 6)
CCorner.Parent = Close

Close.MouseButton1Click:Connect(function()
    SG:Destroy()
    Config.Enabled = false
end)

-- Hide/Show
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
    end
end)

-- ════════════════════════════════════════════════════════
-- INFO
-- ════════════════════════════════════════════════════════
print("════════════════════════════════════════")
print("✅ MINIMAL MODE LOADED")
print("════════════════════════════════════════")
print("⚠️  IMPORTANT:")
print("  - Buka Console (F9)")
print("  - Liat daftar remotes")
print("  - Edit nama remote di script!")
print("════════════════════════════════════════")
print("🔧 Remote Names to Edit:")
print("  - Line 99: CastRemoteName")
print("  - Line 100: ReelRemoteName")
print("════════════════════════════════════════")

if not CastRemote or not ReelRemote then
    warn("⚠️ REMOTES NOT FOUND!")
    warn("Check console for remote list")
    warn("Edit script with correct names!")
end
