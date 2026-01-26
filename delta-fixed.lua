--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - MANUAL WAYPOINT SELL!
    SET POSISI MERCHANT & FISHING MANUAL!
    ════════════════════════════════════════════════════════
]]

print("🎣 LOADING MANUAL WAYPOINT VERSION...")

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
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Backpack = Player:WaitForChild("Backpack")

-- ════════════════════════════════════════════════════════
-- CONFIG
-- ════════════════════════════════════════════════════════
local Config = {
    Enabled = false,
    ClickSpeed = 0.03,
    AutoSell = true,
    SellInterval = 5, -- JUAL TIAP 5 IKAN
}

local Stats = {
    Fish = 0,
    Casts = 0,
    Clicks = 0,
    Sells = 0,
}

-- ════════════════════════════════════════════════════════
-- WAYPOINTS (MANUAL SET!)
-- ════════════════════════════════════════════════════════
local Waypoints = {
    Merchant = _G.MerchantPos, -- Set pakai command di atas!
    Fishing = _G.FishingPos,   -- Set pakai command di atas!
}

-- ════════════════════════════════════════════════════════
-- STATE
-- ════════════════════════════════════════════════════════
local IsFishing = false
local IsReeling = false
local IsSelling = false
local LastCast = 0

-- ════════════════════════════════════════════════════════
-- CHARACTER UPDATE
-- ════════════════════════════════════════════════════════
local function GetHRP()
    local char = Player.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

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
-- TELEPORT
-- ════════════════════════════════════════════════════════
local function TeleportTo(cframe)
    local hrp = GetHRP()
    if not hrp then 
        warn("No HRP!")
        return false
    end
    
    -- Method 1: Instant
    hrp.CFrame = cframe
    task.wait(0.3)
    
    -- Method 2: Tween backup
    local tween = TweenService:Create(hrp, TweenInfo.new(0.5), {CFrame = cframe})
    tween:Play()
    
    return true
end

-- ════════════════════════════════════════════════════════
-- AUTO SELL (MANUAL WAYPOINT!)
-- ════════════════════════════════════════════════════════
local function AutoSell()
    if IsSelling then return end
    IsSelling = true
    
    print("════════════════════════════════════════")
    print("💰 AUTO SELL STARTING...")
    print("════════════════════════════════════════")
    
    -- Check waypoint set
    if not Waypoints.Merchant then
        warn("❌ MERCHANT POSITION NOT SET!")
        warn("💡 Run this at merchant:")
        warn('_G.MerchantPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame')
        IsSelling = false
        return
    end
    
    -- Save current position jika belum set fishing spot
    if not Waypoints.Fishing then
        local hrp = GetHRP()
        if hrp then
            Waypoints.Fishing = hrp.CFrame
            print("📍 Auto-saved fishing position")
        end
    end
    
    -- TP to merchant
    print("📍 Teleporting to merchant...")
    if not TeleportTo(Waypoints.Merchant) then
        warn("❌ Teleport failed!")
        IsSelling = false
        return
    end
    
    task.wait(1)
    
    -- SPAM SELL!
    print("💰 Selling fish...")
    
    -- Method 1: E key spam
    for i = 1, 20 do
        VIM:SendKeyEvent(true, "E", false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, "E", false, game)
        task.wait(0.1)
    end
    
    -- Method 2: Click spam
    for i = 1, 15 do
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        task.wait(0.1)
    end
    
    -- Method 3: Try all possible remotes
    for _, remote in pairs(RS:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            if name:find("sell") or name:find("apprai") or name:find("merchant") then
                pcall(function()
                    remote:FireServer()
                    remote:FireServer("all")
                end)
            end
        end
    end
    
    task.wait(2)
    
    Stats.Sells = Stats.Sells + 1
    print("✅ Sell complete! (#" .. Stats.Sells .. ")")
    
    -- Return to fishing
    if Waypoints.Fishing then
        print("📍 Returning to fishing spot...")
        TeleportTo(Waypoints.Fishing)
        task.wait(1)
    end
    
    print("════════════════════════════════════════")
    print("✅ RESUMING FISHING...")
    print("════════════════════════════════════════")
    
    IsSelling = false
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
    end
end

-- ════════════════════════════════════════════════════════
-- UI DETECTION
-- ════════════════════════════════════════════════════════
local function HasReelUI()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "FischManualGUI" then
            local reel = gui:FindFirstChild("reel", true)
            if reel and reel:IsA("GuiObject") and reel.Visible then
                return true
            end
            
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("GuiObject") and obj.Visible then
                    local name = obj.Name:lower()
                    if name == "reel" or name == "safezone" or name == "bar" or 
                       name == "reelbar" or name:find("reel") then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- ════════════════════════════════════════════════════════
-- CAST
-- ════════════════════════════════════════════════════════
local function DoCast()
    if IsFishing or IsReeling or IsSelling or tick() - LastCast < 2 then return end
    
    Stats.Casts = Stats.Casts + 1
    print("🎣 Cast #" .. Stats.Casts)
    
    EquipRod()
    
    local rod = GetRod()
    if rod then rod:Activate() end
    
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
-- SPAM REEL
-- ════════════════════════════════════════════════════════
local ReelThread = nil

local function StartSpamReel()
    if IsReeling then return end
    IsReeling = true
    
    local startTime = tick()
    local clickCount = 0
    
    ReelThread = task.spawn(function()
        while IsReeling and Config.Enabled do
            if not HasReelUI() then
                break
            end
            
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            
            clickCount = clickCount + 1
            Stats.Clicks = Stats.Clicks + 1
            
            task.wait(Config.ClickSpeed)
            
            if tick() - startTime > 30 then break end
        end
        
        Stats.Fish = Stats.Fish + 1
        print(string.format("✅ Fish #%d! (%dms)", Stats.Fish, math.floor((tick()-startTime)*1000)))
        
        IsReeling = false
        IsFishing = false
        
        -- AUTO SELL CHECK - FIXED!
        print("📊 Fish count: " .. Stats.Fish .. "/" .. Config.SellInterval)
        
        if Config.AutoSell and (Stats.Fish % Config.SellInterval == 0) then
            print("💰💰💰 5 FISH REACHED! SELLING... 💰💰💰")
            task.wait(1)
            task.spawn(AutoSell) -- Spawn biar ga block
        else
            task.wait(1)
        end
    end)
end

-- ════════════════════════════════════════════════════════
-- DETECTION
-- ════════════════════════════════════════════════════════
local ReelDetection = nil

local function StartReelDetection()
    if ReelDetection then return end
    
    ReelDetection = RunService.RenderStepped:Connect(function()
        if Config.Enabled and IsFishing and not IsReeling and not IsSelling then
            if HasReelUI() then
                StartSpamReel()
            end
        end
    end)
end

local function StopReelDetection()
    if ReelDetection then
        ReelDetection:Disconnect()
        ReelDetection = nil
    end
end

-- ════════════════════════════════════════════════════════
-- MAIN LOOP
-- ════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(0.5) do
        if Config.Enabled and not IsFishing and not IsReeling and not IsSelling then
            DoCast()
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- GUI
-- ════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FischManualGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.35, 0, 0.2, 0)
Main.Size = UDim2.new(0, 350, 0, 340)
Main.Active = true
Main.Draggable = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)

local Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(0, 255, 255)
Glow.Thickness = 3
Glow.Parent = Main

local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Font = Enum.Font.GothamBold
Title.Text = "📍 MANUAL WAYPOINT SELL"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16

Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 15)

local TitleFix = Instance.new("Frame")
TitleFix.Parent = Title
TitleFix.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
TitleFix.BorderSizePixel = 0
TitleFix.Position = UDim2.new(0, 0, 0.6, 0)
TitleFix.Size = UDim2.new(1, 0, 0.4, 0)

-- Stats
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = Main
StatsLabel.BackgroundTransparency = 1
StatsLabel.Position = UDim2.new(0, 15, 0, 60)
StatsLabel.Size = UDim2.new(1, -30, 0, 90)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Setup waypoints first!"
StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsLabel.TextSize = 13
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            local status = Config.Enabled and "⚡ ACTIVE" or "🔴 STOPPED"
            local action = ""
            
            if Config.Enabled then
                if IsSelling then action = "💰 SELLING!"
                elseif IsReeling then action = "⚡ REELING!"
                elseif IsFishing then action = "⏳ Waiting..."
                else action = "🎣 Casting..." end
            end
            
            local nextSell = Config.SellInterval - (Stats.Fish % Config.SellInterval)
            if nextSell == 0 then nextSell = Config.SellInterval end
            
            local merchantStatus = Waypoints.Merchant and "✅" or "❌"
            local fishingStatus = Waypoints.Fishing and "✅" or "❌"
            
            StatsLabel.Text = string.format(
                "%s | %s\n\n🐟 Fish: %d | Next sell: %d\n🎣 Casts: %d | 💰 Sells: %d\n\n%s Merchant | %s Fishing Spot",
                status, action, Stats.Fish, nextSell, Stats.Casts, Stats.Sells,
                merchantStatus, fishingStatus
            )
        end)
    end
end)

-- Waypoint Buttons
local SetMerchant = Instance.new("TextButton")
SetMerchant.Parent = Main
SetMerchant.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
SetMerchant.BorderSizePixel = 0
SetMerchant.Position = UDim2.new(0, 15, 0, 160)
SetMerchant.Size = UDim2.new(0.48, -10, 0, 35)
SetMerchant.Font = Enum.Font.GothamBold
SetMerchant.Text = "📍 SET MERCHANT"
SetMerchant.TextColor3 = Color3.new(1, 1, 1)
SetMerchant.TextSize = 12

Instance.new("UICorner", SetMerchant).CornerRadius = UDim.new(0, 8)

SetMerchant.MouseButton1Click:Connect(function()
    local hrp = GetHRP()
    if hrp then
        Waypoints.Merchant = hrp.CFrame
        _G.MerchantPos = hrp.CFrame
        print("✅ MERCHANT POSITION SAVED!")
        print("Position:", Waypoints.Merchant)
        SetMerchant.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        SetMerchant.Text = "✅ MERCHANT SET"
        task.wait(1)
        SetMerchant.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        SetMerchant.Text = "📍 SET MERCHANT"
    end
end)

local SetFishing = Instance.new("TextButton")
SetFishing.Parent = Main
SetFishing.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SetFishing.BorderSizePixel = 0
SetFishing.Position = UDim2.new(0.52, 0, 0, 160)
SetFishing.Size = UDim2.new(0.48, -15, 0, 35)
SetFishing.Font = Enum.Font.GothamBold
SetFishing.Text = "🎣 SET FISHING"
SetFishing.TextColor3 = Color3.new(1, 1, 1)
SetFishing.TextSize = 12

Instance.new("UICorner", SetFishing).CornerRadius = UDim.new(0, 8)

SetFishing.MouseButton1Click:Connect(function()
    local hrp = GetHRP()
    if hrp then
        Waypoints.Fishing = hrp.CFrame
        _G.FishingPos = hrp.CFrame
        print("✅ FISHING POSITION SAVED!")
        print("Position:", Waypoints.Fishing)
        SetFishing.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        SetFishing.Text = "✅ FISHING SET"
        task.wait(1)
        SetFishing.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        SetFishing.Text = "🎣 SET FISHING"
    end
end)

-- Auto Sell Toggle
local SellToggle = Instance.new("TextButton")
SellToggle.Parent = Main
SellToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
SellToggle.BorderSizePixel = 0
SellToggle.Position = UDim2.new(0, 15, 0, 205)
SellToggle.Size = UDim2.new(1, -30, 0, 35)
SellToggle.Font = Enum.Font.GothamBold
SellToggle.Text = "💰 AUTO SELL: ON (5 FISH)"
SellToggle.TextColor3 = Color3.new(1, 1, 1)
SellToggle.TextSize = 13

Instance.new("UICorner", SellToggle).CornerRadius = UDim.new(0, 8)

SellToggle.MouseButton1Click:Connect(function()
    Config.AutoSell = not Config.AutoSell
    if Config.AutoSell then
        SellToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        SellToggle.Text = "💰 AUTO SELL: ON (5 FISH)"
    else
        SellToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        SellToggle.Text = "💰 AUTO SELL: OFF"
    end
end)

-- Manual Sell
local ManualSell = Instance.new("TextButton")
ManualSell.Parent = Main
ManualSell.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
ManualSell.BorderSizePixel = 0
ManualSell.Position = UDim2.new(0, 15, 0, 250)
ManualSell.Size = UDim2.new(1, -30, 0, 30)
ManualSell.Font = Enum.Font.GothamBold
ManualSell.Text = "🔧 MANUAL SELL NOW"
ManualSell.TextColor3 = Color3.new(1, 1, 1)
ManualSell.TextSize = 13

Instance.new("UICorner", ManualSell).CornerRadius = UDim.new(0, 8)

ManualSell.MouseButton1Click:Connect(function()
    if not IsSelling then
        task.spawn(AutoSell)
    end
end)

-- Main Toggle
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Main
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0, 15, 0, 290)
ToggleButton.Size = UDim2.new(1, -30, 0, 40)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "🔴 START FISHING"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = 15

Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 10)

ToggleButton.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        if not Waypoints.Merchant then
            warn("⚠️ SET MERCHANT POSITION FIRST!")
            Config.Enabled = false
            return
        end
        
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.Text = "⚡ STOP"
        Glow.Color = Color3.fromRGB(0, 255, 0)
        StartReelDetection()
        
        if not Waypoints.Fishing then
            local hrp = GetHRP()
            if hrp then
                Waypoints.Fishing = hrp.CFrame
                print("📍 Auto-set fishing spot")
            end
        end
        
        print("✅ STARTED!")
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = "🔴 START FISHING"
        Glow.Color = Color3.fromRGB(0, 255, 255)
        StopReelDetection()
        IsFishing = false
        IsReeling = false
        IsSelling = false
        print("❌ STOPPED!")
    end
end)

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
    elseif input.KeyCode == Enum.KeyCode.F6 then
        ToggleButton.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.F7 then
        if not IsSelling then task.spawn(AutoSell) end
    end
end)

print("════════════════════════════════════════")
print("✅ MANUAL WAYPOINT VERSION LOADED!")
print("════════════════════════════════════════")
print("📍 SETUP STEPS:")
print("  1. Go to MERCHANT")
print("  2. Click 'SET MERCHANT' button")
print("  3. Go to FISHING SPOT")
print("  4. Click 'SET FISHING' button")
print("  5. Click 'START FISHING'")
print("════════════════════════════════════════")
print("💰 Will auto sell every 5 fish!")
print("════════════════════════════════════════")
print("🎮 F6=Toggle | F7=Manual Sell | DEL=Hide")
print("════════════════════════════════════════")
