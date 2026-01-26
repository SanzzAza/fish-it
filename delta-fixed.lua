--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - SPAM REEL + AUTO SELL!
    CLICK TERUS + JUAL OTOMATIS!
    ════════════════════════════════════════════════════════
]]

print("🎣 LOADING SPAM REEL + AUTO SELL...")

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
local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- ════════════════════════════════════════════════════════
-- CONFIG
-- ════════════════════════════════════════════════════════
local Config = {
    Enabled = false,
    ClickSpeed = 0.03,
    AutoSell = true,
    SellInterval = 20, -- Jual setiap 20 ikan
}

local Stats = {
    Fish = 0,
    Casts = 0,
    Clicks = 0,
    Sells = 0,
    Money = 0,
}

-- ════════════════════════════════════════════════════════
-- STATE
-- ════════════════════════════════════════════════════════
local IsFishing = false
local IsReeling = false
local IsSelling = false
local LastCast = 0
local OriginalPosition = nil

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
-- FIND NPC MERCHANT/APPRAISER
-- ════════════════════════════════════════════════════════
local function FindMerchant()
    -- Method 1: Cari di Workspace
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") then
            local name = npc.Name:lower()
            -- Nama NPC merchant di Fisch biasanya "Merchant", "Appraiser", "Shipwright", dll
            if name:find("merchant") or name:find("appraiser") or name:find("marc") then
                if npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head") then
                    print("✅ Found merchant:", npc.Name)
                    return npc
                end
            end
        end
    end
    
    -- Method 2: Cari ProximityPrompt (interact point)
    for _, prompt in pairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local name = prompt.Name:lower()
            if name:find("sell") or name:find("apprai") or name:find("merchant") then
                print("✅ Found sell prompt:", prompt.Name)
                return prompt.Parent
            end
        end
    end
    
    warn("❌ Merchant not found! (Mungkin nama NPC berbeda)")
    return nil
end

-- ════════════════════════════════════════════════════════
-- AUTO SELL FUNCTION
-- ════════════════════════════════════════════════════════
local function AutoSell()
    if IsSelling then return end
    IsSelling = true
    
    print("💰 Starting auto sell...")
    
    -- Save posisi awal
    if not OriginalPosition then
        OriginalPosition = HRP.CFrame
    end
    
    -- Cari merchant
    local merchant = FindMerchant()
    
    if not merchant then
        warn("❌ Can't find merchant! Skipping sell...")
        IsSelling = false
        return
    end
    
    -- Teleport ke merchant
    local merchantPos = merchant:FindFirstChild("HumanoidRootPart") or merchant:FindFirstChild("Head") or merchant.PrimaryPart
    
    if not merchantPos then
        warn("❌ Merchant has no position!")
        IsSelling = false
        return
    end
    
    print("📍 Teleporting to merchant...")
    
    -- Teleport (dengan offset biar ga di dalam NPC)
    local targetPos = merchantPos.CFrame * CFrame.new(0, 0, 5)
    HRP.CFrame = targetPos
    
    task.wait(0.5)
    
    -- Method 1: Cari ProximityPrompt
    local sellPrompt = nil
    for _, prompt in pairs(merchant:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            sellPrompt = prompt
            break
        end
    end
    
    if sellPrompt then
        print("💰 Using ProximityPrompt to sell...")
        fireproximityprompt(sellPrompt)
        task.wait(0.5)
        
        -- Spam E juga (backup)
        for i = 1, 5 do
            VIM:SendKeyEvent(true, "E", false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, "E", false, game)
            task.wait(0.1)
        end
    else
        -- Method 2: Spam E key (fallback)
        print("💰 Spamming E to sell...")
        for i = 1, 10 do
            VIM:SendKeyEvent(true, "E", false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, "E", false, game)
            task.wait(0.1)
        end
    end
    
    -- Method 3: Cari sell remote
    local sellRemote = nil
    for _, remote in pairs(RS:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local name = remote.Name:lower()
            if name:find("sell") or name:find("apprai") then
                sellRemote = remote
                break
            end
        end
    end
    
    if sellRemote then
        print("💰 Using sell remote...")
        pcall(function()
            if sellRemote:IsA("RemoteEvent") then
                sellRemote:FireServer()
            else
                sellRemote:InvokeServer()
            end
        end)
    end
    
    task.wait(1)
    
    Stats.Sells = Stats.Sells + 1
    print("✅ Sell attempt #" .. Stats.Sells)
    
    -- Balik ke posisi awal
    if OriginalPosition then
        print("📍 Returning to fishing spot...")
        HRP.CFrame = OriginalPosition
        task.wait(0.5)
    end
    
    IsSelling = false
    print("✅ Sell complete! Resuming fishing...")
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
-- UI DETECTION
-- ════════════════════════════════════════════════════════
local function HasReelUI()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "FischSpamGUI" then
            local reel = gui:FindFirstChild("reel", true)
            if reel and reel:IsA("GuiObject") and reel.Visible then
                return true, reel
            end
            
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("GuiObject") and obj.Visible then
                    local name = obj.Name:lower()
                    if name == "reel" or name == "safezone" or name == "bar" or 
                       name == "reelbar" or name == "fishingbar" or name == "progress" or
                       name == "playerbar" or name:find("reel") or name:find("safe") then
                        return true, obj
                    end
                end
            end
        end
    end
    return false, nil
end

-- ════════════════════════════════════════════════════════
-- CAST
-- ════════════════════════════════════════════════════════
local function DoCast()
    if IsFishing or IsReeling or IsSelling or tick() - LastCast < 2 then return end
    
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
    
    print("⚡ SPAM STARTED!")
    
    local startTime = tick()
    local clickCount = 0
    
    ReelThread = task.spawn(function()
        while IsReeling and Config.Enabled do
            local hasUI = HasReelUI()
            
            if not hasUI then
                print("✅ UI hilang! Ikan masuk!")
                break
            end
            
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            
            clickCount = clickCount + 1
            Stats.Clicks = Stats.Clicks + 1
            
            task.wait(Config.ClickSpeed)
            
            if tick() - startTime > 30 then
                print("⏰ Timeout!")
                break
            end
        end
        
        local duration = math.floor((tick() - startTime) * 1000)
        Stats.Fish = Stats.Fish + 1
        print(string.format("✅ Fish #%d! (%d clicks, %dms)", Stats.Fish, clickCount, duration))
        
        IsReeling = false
        IsFishing = false
        
        -- Auto sell check
        if Config.AutoSell and Stats.Fish % Config.SellInterval == 0 then
            print("💰 Time to sell! (Every " .. Config.SellInterval .. " fish)")
            task.wait(1)
            AutoSell()
        else
            task.wait(1)
        end
    end)
end

local function StopSpamReel()
    IsReeling = false
    if ReelThread then
        task.cancel(ReelThread)
        ReelThread = nil
    end
end

-- ════════════════════════════════════════════════════════
-- DETECTION (60 FPS)
-- ════════════════════════════════════════════════════════
local ReelDetection = nil

local function StartReelDetection()
    if ReelDetection then return end
    
    ReelDetection = RunService.RenderStepped:Connect(function()
        if Config.Enabled and IsFishing and not IsReeling and not IsSelling then
            local hasUI = HasReelUI()
            if hasUI then
                print("🎯 UI DETECTED!")
                StartSpamReel()
            end
        end
    end)
    print("✅ Detection active!")
end

local function StopReelDetection()
    if ReelDetection then
        ReelDetection:Disconnect()
        ReelDetection = nil
    end
    print("❌ Detection stopped!")
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
print("Creating GUI...")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FischSpamGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.35, 0, 0.25, 0)
Main.Size = UDim2.new(0, 340, 0, 280)
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 15)
Corner.Parent = Main

local Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(255, 215, 0)
Glow.Thickness = 3
Glow.Parent = Main

local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡💰 SPAM + AUTO SELL!"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 17

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = Title

local TitleFix = Instance.new("Frame")
TitleFix.Parent = Title
TitleFix.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
TitleFix.BorderSizePixel = 0
TitleFix.Position = UDim2.new(0, 0, 0.6, 0)
TitleFix.Size = UDim2.new(1, 0, 0.4, 0)

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = Main
StatsLabel.BackgroundTransparency = 1
StatsLabel.Position = UDim2.new(0, 15, 0, 60)
StatsLabel.Size = UDim2.new(1, -30, 0, 100)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Ready!"
StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsLabel.TextSize = 13
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            local status = Config.Enabled and "⚡ ACTIVE!" or "🔴 STOPPED"
            local currentAction = ""
            
            if Config.Enabled then
                if IsSelling then
                    currentAction = "💰💰 SELLING! 💰💰"
                elseif IsReeling then
                    currentAction = "⚡⚡⚡ SPAMMING! ⚡⚡⚡"
                elseif IsFishing then
                    currentAction = "⏳ Waiting bite..."
                else
                    currentAction = "🎣 Casting..."
                end
            end
            
            local nextSell = Config.SellInterval - (Stats.Fish % Config.SellInterval)
            
            StatsLabel.Text = string.format(
                "%s\n%s\n\n🐟 Fish: %d | 🎣 Casts: %d\n🖱️ Clicks: %d | 💰 Sells: %d\n\n📊 Next sell in: %d fish",
                status,
                currentAction,
                Stats.Fish,
                Stats.Casts,
                Stats.Clicks,
                Stats.Sells,
                nextSell
            )
        end)
    end
end)

-- Auto Sell Toggle
local SellToggle = Instance.new("TextButton")
SellToggle.Parent = Main
SellToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
SellToggle.BorderSizePixel = 0
SellToggle.Position = UDim2.new(0, 15, 0, 170)
SellToggle.Size = UDim2.new(1, -30, 0, 35)
SellToggle.Font = Enum.Font.GothamBold
SellToggle.Text = "💰 AUTO SELL: ON (Every 20 fish)"
SellToggle.TextColor3 = Color3.new(1, 1, 1)
SellToggle.TextSize = 13

local SellCorner = Instance.new("UICorner")
SellCorner.CornerRadius = UDim.new(0, 8)
SellCorner.Parent = SellToggle

SellToggle.MouseButton1Click:Connect(function()
    Config.AutoSell = not Config.AutoSell
    
    if Config.AutoSell then
        SellToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        SellToggle.Text = "💰 AUTO SELL: ON (Every " .. Config.SellInterval .. " fish)"
    else
        SellToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        SellToggle.Text = "💰 AUTO SELL: OFF"
    end
end)

-- Manual Sell Button
local ManualSell = Instance.new("TextButton")
ManualSell.Parent = Main
ManualSell.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
ManualSell.BorderSizePixel = 0
ManualSell.Position = UDim2.new(0, 15, 0, 210)
ManualSell.Size = UDim2.new(1, -30, 0, 25)
ManualSell.Font = Enum.Font.GothamBold
ManualSell.Text = "🔧 MANUAL SELL NOW"
ManualSell.TextColor3 = Color3.new(1, 1, 1)
ManualSell.TextSize = 12

local ManualCorner = Instance.new("UICorner")
ManualCorner.CornerRadius = UDim.new(0, 6)
ManualCorner.Parent = ManualSell

ManualSell.MouseButton1Click:Connect(function()
    if not IsSelling then
        print("🔧 Manual sell triggered!")
        task.spawn(AutoSell)
    else
        warn("Already selling!")
    end
end)

-- Main Toggle
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Main
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0, 15, 0, 240)
ToggleButton.Size = UDim2.new(1, -30, 0, 30)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "🔴 START"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = 15

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.Text = "⚡ STOP"
        Glow.Color = Color3.fromRGB(0, 255, 0)
        StartReelDetection()
        
        -- Save starting position
        OriginalPosition = HRP.CFrame
        
        print("✅ AUTO FISHING + SELLING STARTED!")
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = "🔴 START"
        Glow.Color = Color3.fromRGB(255, 215, 0)
        StopReelDetection()
        StopSpamReel()
        IsFishing = false
        IsSelling = false
        print("❌ STOPPED!")
    end
end)

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
        print("GUI Toggled:", Main.Visible)
    elseif input.KeyCode == Enum.KeyCode.F6 then
        ToggleButton.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.F7 then
        if not IsSelling then
            task.spawn(AutoSell)
        end
    end
end)

print("════════════════════════════════════════")
print("✅ AUTO SELL ADDED!")
print("════════════════════════════════════════")
print("💰 Features:")
print("  ✅ Auto sell every 20 fish")
print("  ✅ Teleport to merchant")
print("  ✅ Return to fishing spot")
print("  ✅ Manual sell button")
print("════════════════════════════════════════")
print("🎮 Controls:")
print("  DELETE = Hide/Show")
print("  F6 = Toggle ON/OFF")
print("  F7 = Manual Sell")
print("════════════════════════════════════════")
print("⚡💰 READY TO FISH & SELL!")
print("════════════════════════════════════════")
