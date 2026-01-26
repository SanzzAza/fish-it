--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - FIXED FISH COUNTER!
    DEBUG MODE + PROPER DETECTION!
    ════════════════════════════════════════════════════════
]]

print("🎣 LOADING FIXED FISH COUNTER VERSION...")

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
    ClickSpeed = 0.03,
    AutoSell = true,
    SellInterval = 5,
    DebugMode = true, -- ENABLE DEBUG!
}

local Stats = {
    Fish = 0,
    Casts = 0,
    Clicks = 0,
    Sells = 0,
}

-- ════════════════════════════════════════════════════════
-- WAYPOINTS
-- ════════════════════════════════════════════════════════
local Waypoints = {
    Merchant = _G.MerchantPos,
    Fishing = _G.FishingPos,
}

-- ════════════════════════════════════════════════════════
-- STATE
-- ════════════════════════════════════════════════════════
local IsFishing = false
local IsReeling = false
local IsSelling = false
local LastCast = 0
local LastFishCount = 0 -- Track inventory changes!

-- ════════════════════════════════════════════════════════
-- DEBUG PRINT
-- ════════════════════════════════════════════════════════
local function DebugPrint(...)
    if Config.DebugMode then
        print("[DEBUG]", ...)
    end
end

-- ════════════════════════════════════════════════════════
-- CHARACTER
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
    if not hrp then return false end
    
    hrp.CFrame = cframe
    task.wait(0.5)
    return true
end

-- ════════════════════════════════════════════════════════
-- AUTO SELL
-- ════════════════════════════════════════════════════════
local function AutoSell()
    if IsSelling then return end
    IsSelling = true
    
    print("════════════════════════════════════════")
    print("💰 AUTO SELL TRIGGERED!")
    print("Fish count:", Stats.Fish)
    print("════════════════════════════════════════")
    
    if not Waypoints.Merchant then
        warn("❌ Merchant position not set!")
        IsSelling = false
        return
    end
    
    if not Waypoints.Fishing then
        local hrp = GetHRP()
        if hrp then
            Waypoints.Fishing = hrp.CFrame
        end
    end
    
    print("📍 TP to merchant...")
    TeleportTo(Waypoints.Merchant)
    task.wait(1)
    
    print("💰 Selling...")
    for i = 1, 20 do
        VIM:SendKeyEvent(true, "E", false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, "E", false, game)
        task.wait(0.1)
    end
    
    for i = 1, 15 do
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        task.wait(0.1)
    end
    
    task.wait(2)
    Stats.Sells = Stats.Sells + 1
    
    print("✅ Sell #" .. Stats.Sells)
    
    if Waypoints.Fishing then
        print("📍 Returning...")
        TeleportTo(Waypoints.Fishing)
        task.wait(1)
    end
    
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
-- IMPROVED UI DETECTION (WITH DEBUG!)
-- ════════════════════════════════════════════════════════
local LastUIState = false

local function HasReelUI()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "FischManualGUI" then
            
            -- Method 1: Direct find
            local reel = gui:FindFirstChild("reel", true)
            if reel and reel:IsA("GuiObject") and reel.Visible then
                if not LastUIState then
                    DebugPrint("UI Found (Method 1):", gui.Name, "→", reel.Name)
                    LastUIState = true
                end
                return true
            end
            
            -- Method 2: Deep scan
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("GuiObject") and obj.Visible then
                    local name = obj.Name:lower()
                    if name == "reel" or name == "safezone" or name == "bar" or 
                       name == "reelbar" or name == "fishingbar" or name == "progress" or
                       name == "playerbar" or name:find("reel") then
                        if not LastUIState then
                            DebugPrint("UI Found (Method 2):", gui.Name, "→", obj.Name)
                            LastUIState = true
                        end
                        return true
                    end
                end
            end
        end
    end
    
    if LastUIState then
        DebugPrint("UI DISAPPEARED!")
        LastUIState = false
    end
    
    return false
end

-- ════════════════════════════════════════════════════════
-- ALTERNATIVE: DETECT FISH BY INVENTORY CHANGE!
-- ════════════════════════════════════════════════════════
local function CountFishInInventory()
    local count = 0
    
    -- Method 1: Check backpack for fish items
    for _, item in pairs(Backpack:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            -- Common fish item patterns
            if not name:find("rod") and not name:find("bait") then
                -- Ini mungkin ikan
                count = count + 1
            end
        end
    end
    
    return count
end

-- ════════════════════════════════════════════════════════
-- CAST
-- ════════════════════════════════════════════════════════
local function DoCast()
    if IsFishing or IsReeling or IsSelling or tick() - LastCast < 2 then return end
    
    Stats.Casts = Stats.Casts + 1
    DebugPrint("🎣 Casting #" .. Stats.Casts)
    
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
            DebugPrint("⏰ Cast timeout")
            IsFishing = false 
        end
    end)
end

-- ════════════════════════════════════════════════════════
-- SPAM REEL (FIXED COUNTER!)
-- ════════════════════════════════════════════════════════
local ReelThread = nil

local function StartSpamReel()
    if IsReeling then return end
    IsReeling = true
    
    DebugPrint("⚡ REEL START!")
    
    local startTime = tick()
    local clickCount = 0
    local hadUI = true
    
    ReelThread = task.spawn(function()
        while IsReeling and Config.Enabled do
            local hasUI = HasReelUI()
            
            if not hasUI and hadUI then
                DebugPrint("✅ UI GONE = Fish caught!")
                break
            end
            
            hadUI = hasUI
            
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            
            clickCount = clickCount + 1
            Stats.Clicks = Stats.Clicks + 1
            
            task.wait(Config.ClickSpeed)
            
            if tick() - startTime > 30 then 
                DebugPrint("⏰ Reel timeout")
                break 
            end
        end
        
        -- INCREMENT FISH!
        Stats.Fish = Stats.Fish + 1
        
        local duration = math.floor((tick() - startTime) * 1000)
        print("════════════════════════════════════════")
        print(string.format("🐟 FISH #%d CAUGHT! (%dms, %d clicks)", Stats.Fish, duration, clickCount))
        print("════════════════════════════════════════")
        
        IsReeling = false
        IsFishing = false
        
        -- CHECK SELL (WITH DEBUG!)
        local remaining = Stats.Fish % Config.SellInterval
        DebugPrint("Fish count:", Stats.Fish)
        DebugPrint("Sell interval:", Config.SellInterval)
        DebugPrint("Remaining until sell:", Config.SellInterval - remaining)
        
        if Config.AutoSell and (Stats.Fish % Config.SellInterval == 0) then
            print("💰💰💰 5 FISH REACHED! SELLING NOW! 💰💰💰")
            task.wait(1)
            task.spawn(AutoSell)
        else
            print("Next sell in:", Config.SellInterval - remaining, "fish")
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
                DebugPrint("🎯 REEL UI DETECTED! Starting spam...")
                StartSpamReel()
            end
        end
    end)
    
    print("✅ Detection active (60 FPS)")
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
Main.Size = UDim2.new(0, 360, 0, 360)
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
Title.Text = "🐛 DEBUG MODE - FISH COUNTER"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 15

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
StatsLabel.Size = UDim2.new(1, -30, 0, 110)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Starting..."
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
                elseif IsReeling then action = "⚡ SPAMMING!"
                elseif IsFishing then action = "⏳ Waiting..."
                else action = "🎣 Casting..." end
            end
            
            local nextSell = Config.SellInterval - (Stats.Fish % Config.SellInterval)
            if nextSell == 0 then nextSell = Config.SellInterval end
            
            local merchantStatus = Waypoints.Merchant and "✅" or "❌"
            local fishingStatus = Waypoints.Fishing and "✅" or "❌"
            
            local hasUI = HasReelUI()
            
            StatsLabel.Text = string.format(
                "%s | %s\n\n🐟 FISH: %d/%d (Next sell: %d)\n🎣 Casts: %d | 💰 Sells: %d\n🖱️ Clicks: %d\n\n%s Merchant | %s Fishing\n🎯 Reel UI: %s",
                status, action, Stats.Fish, Config.SellInterval, nextSell,
                Stats.Casts, Stats.Sells, Stats.Clicks,
                merchantStatus, fishingStatus,
                hasUI and "VISIBLE" or "Hidden"
            )
        end)
    end
end)

-- Waypoint Buttons
local SetMerchant = Instance.new("TextButton")
SetMerchant.Parent = Main
SetMerchant.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
SetMerchant.BorderSizePixel = 0
SetMerchant.Position = UDim2.new(0, 15, 0, 180)
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
        print("✅ MERCHANT SAVED:", Waypoints.Merchant)
        SetMerchant.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        SetMerchant.Text = "✅ SAVED"
        task.wait(1)
        SetMerchant.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        SetMerchant.Text = "📍 SET MERCHANT"
    end
end)

local SetFishing = Instance.new("TextButton")
SetFishing.Parent = Main
SetFishing.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SetFishing.BorderSizePixel = 0
SetFishing.Position = UDim2.new(0.52, 0, 0, 180)
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
        print("✅ FISHING SAVED:", Waypoints.Fishing)
        SetFishing.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        SetFishing.Text = "✅ SAVED"
        task.wait(1)
        SetFishing.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        SetFishing.Text = "🎣 SET FISHING"
    end
end)

-- Debug Toggle
local DebugToggle = Instance.new("TextButton")
DebugToggle.Parent = Main
DebugToggle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
DebugToggle.BorderSizePixel = 0
DebugToggle.Position = UDim2.new(0, 15, 0, 225)
DebugToggle.Size = UDim2.new(1, -30, 0, 25)
DebugToggle.Font = Enum.Font.GothamBold
DebugToggle.Text = "🐛 DEBUG: ON (Check Console)"
DebugToggle.TextColor3 = Color3.new(1, 1, 1)
DebugToggle.TextSize = 11

Instance.new("UICorner", DebugToggle).CornerRadius = UDim.new(0, 6)

DebugToggle.MouseButton1Click:Connect(function()
    Config.DebugMode = not Config.DebugMode
    if Config.DebugMode then
        DebugToggle.Text = "🐛 DEBUG: ON (Check Console)"
    else
        DebugToggle.Text = "🐛 DEBUG: OFF"
    end
end)

-- Auto Sell Toggle
local SellToggle = Instance.new("TextButton")
SellToggle.Parent = Main
SellToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
SellToggle.BorderSizePixel = 0
SellToggle.Position = UDim2.new(0, 15, 0, 260)
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
ManualSell.Position = UDim2.new(0, 15, 0, 305)
ManualSell.Size = UDim2.new(0.48, -10, 0, 20)
ManualSell.Font = Enum.Font.GothamBold
ManualSell.Text = "🔧 SELL NOW"
ManualSell.TextColor3 = Color3.new(1, 1, 1)
ManualSell.TextSize = 11

Instance.new("UICorner", ManualSell).CornerRadius = UDim.new(0, 6)

ManualSell.MouseButton1Click:Connect(function()
    if not IsSelling then task.spawn(AutoSell) end
end)

-- Reset Counter
local ResetButton = Instance.new("TextButton")
ResetButton.Parent = Main
ResetButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ResetButton.BorderSizePixel = 0
ResetButton.Position = UDim2.new(0.52, 0, 0, 305)
ResetButton.Size = UDim2.new(0.48, -15, 0, 20)
ResetButton.Font = Enum.Font.GothamBold
ResetButton.Text = "🔄 RESET COUNT"
ResetButton.TextColor3 = Color3.new(1, 1, 1)
ResetButton.TextSize = 11

Instance.new("UICorner", ResetButton).CornerRadius = UDim.new(0, 6)

ResetButton.MouseButton1Click:Connect(function()
    Stats.Fish = 0
    print("🔄 Fish counter reset to 0")
end)

-- Main Toggle
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Main
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0, 15, 0, 330)
ToggleButton.Size = UDim2.new(1, -30, 0, 20)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "🔴 START"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = 14

Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)

ToggleButton.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        if not Waypoints.Merchant then
            warn("⚠️ SET MERCHANT FIRST!")
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
        
        print("════════════════════════════════════════")
        print("✅ STARTED WITH DEBUG MODE!")
        print("Watch console for [DEBUG] messages")
        print("════════════════════════════════════════")
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = "🔴 START"
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
    elseif input.KeyCode == Enum.KeyCode.F9 then
        Stats.Fish = 0
        print("🔄 Fish reset!")
    end
end)

print("════════════════════════════════════════")
print("🐛 DEBUG MODE ENABLED!")
print("════════════════════════════════════════")
print("Watch console for:")
print("  [DEBUG] UI Found = Reel detected")
print("  [DEBUG] UI DISAPPEARED = Fish caught")
print("  🐟 FISH #X CAUGHT! = Counter update")
print("════════════════════════════════════════")
print("🎮 F6=Toggle | F7=Sell | F9=Reset Count")
print("════════════════════════════════════════")
