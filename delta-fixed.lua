--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - Inventory Sell + Compact GUI
    ════════════════════════════════════════════════════════
]]

print("🎣 Loading...")

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
}

local Stats = {
    Fish = 0,
    Casts = 0,
    Sells = 0,
}

local Waypoints = {
    Merchant = _G.MerchantPos,
    Fishing = _G.FishingPos,
}

local IsFishing = false
local IsReeling = false
local IsSelling = false
local LastCast = 0

-- ════════════════════════════════════════════════════════
-- UTILITY
-- ════════════════════════════════════════════════════════
local function GetHRP()
    return Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
end

Player.Idled:Connect(function()
    pcall(function()
        game:GetService("VirtualUser"):CaptureController()
    end)
end)

-- ════════════════════════════════════════════════════════
-- TELEPORT
-- ════════════════════════════════════════════════════════
local function TeleportTo(cframe)
    local hrp = GetHRP()
    if hrp then
        hrp.CFrame = cframe
        task.wait(0.5)
        return true
    end
    return false
end

-- ════════════════════════════════════════════════════════
-- IMPROVED SELL - DENGAN INVENTORY INTERACTION!
-- ════════════════════════════════════════════════════════
local function OpenInventory()
    -- Method 1: Tekan I atau Tab (common inventory keys)
    for _, key in pairs({"I", "Tab", "B"}) do
        VIM:SendKeyEvent(true, key, false, game)
        task.wait(0.1)
        VIM:SendKeyEvent(false, key, false, game)
        task.wait(0.3)
    end
end

local function ClickSellAll()
    -- Cari button "Sell All" atau sejenisnya di GUI
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") then
            local text = gui.Text:lower()
            if text:find("sell") or text:find("jual") then
                print("💰 Found sell button:", gui.Text)
                
                -- Simulate click
                for i = 1, 3 do
                    firesignal(gui.MouseButton1Click)
                    task.wait(0.2)
                end
                
                return true
            end
        end
    end
    return false
end

local function AutoSell()
    if IsSelling then return end
    IsSelling = true
    
    print("💰 Starting sell...")
    
    if not Waypoints.Merchant then
        warn("❌ Set merchant first!")
        IsSelling = false
        return
    end
    
    if not Waypoints.Fishing then
        local hrp = GetHRP()
        if hrp then Waypoints.Fishing = hrp.CFrame end
    end
    
    -- TP to merchant
    print("📍 TP to merchant...")
    TeleportTo(Waypoints.Merchant)
    task.wait(1.5)
    
    -- Method 1: Open inventory
    print("💰 Opening inventory...")
    OpenInventory()
    task.wait(1)
    
    -- Method 2: Click sell button in GUI
    if ClickSellAll() then
        print("✅ Clicked sell button!")
        task.wait(2)
    else
        -- Fallback: Spam E and Click
        print("💰 Spamming E + Click...")
        
        for i = 1, 25 do
            VIM:SendKeyEvent(true, "E", false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, "E", false, game)
            task.wait(0.05)
        end
        
        task.wait(0.5)
        
        for i = 1, 20 do
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.05)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            task.wait(0.05)
        end
    end
    
    -- Method 3: Try remotes
    for _, remote in pairs(RS:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            if name:find("sell") or name:find("apprai") then
                pcall(function()
                    remote:FireServer()
                    remote:FireServer("all")
                end)
            end
        end
    end
    
    task.wait(2)
    Stats.Sells = Stats.Sells + 1
    print("✅ Sell #" .. Stats.Sells)
    
    -- Return
    if Waypoints.Fishing then
        print("📍 Returning...")
        TeleportTo(Waypoints.Fishing)
        task.wait(1)
    end
    
    IsSelling = false
end

-- ════════════════════════════════════════════════════════
-- FISHING FUNCTIONS
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

local function HasReelUI()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "CompactFischGUI" then
            local reel = gui:FindFirstChild("reel", true)
            if reel and reel:IsA("GuiObject") and reel.Visible then
                return true
            end
            
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("GuiObject") and obj.Visible then
                    local name = obj.Name:lower()
                    if name == "reel" or name:find("reel") or name == "safezone" or name == "bar" then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function DoCast()
    if IsFishing or IsReeling or IsSelling or tick() - LastCast < 2 then return end
    
    Stats.Casts = Stats.Casts + 1
    EquipRod()
    
    local rod = GetRod()
    if rod then rod:Activate() end
    
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    IsFishing = true
    LastCast = tick()
    
    task.delay(20, function()
        if IsFishing and not IsReeling then IsFishing = false end
    end)
end

local ReelThread = nil

local function StartSpamReel()
    if IsReeling then return end
    IsReeling = true
    
    ReelThread = task.spawn(function()
        local startTime = tick()
        
        while IsReeling and Config.Enabled do
            if not HasReelUI() then break end
            
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            task.wait(Config.ClickSpeed)
            
            if tick() - startTime > 30 then break end
        end
        
        Stats.Fish = Stats.Fish + 1
        print("🐟 Fish #" .. Stats.Fish)
        
        IsReeling = false
        IsFishing = false
        
        if Config.AutoSell and (Stats.Fish % Config.SellInterval == 0) then
            print("💰 Selling...")
            task.wait(1)
            task.spawn(AutoSell)
        else
            task.wait(1)
        end
    end)
end

local ReelDetection = nil

local function StartReelDetection()
    if ReelDetection then return end
    ReelDetection = RunService.RenderStepped:Connect(function()
        if Config.Enabled and IsFishing and not IsReeling and not IsSelling then
            if HasReelUI() then StartSpamReel() end
        end
    end)
end

local function StopReelDetection()
    if ReelDetection then
        ReelDetection:Disconnect()
        ReelDetection = nil
    end
end

task.spawn(function()
    while task.wait(0.5) do
        if Config.Enabled and not IsFishing and not IsReeling and not IsSelling then
            DoCast()
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- COMPACT GUI WITH MINIMIZE
-- ════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CompactFischGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.01, 0, 0.3, 0)
Main.Size = UDim2.new(0, 200, 0, 180)
Main.Active = true
Main.Draggable = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Glow = Instance.new("UIStroke", Main)
Glow.Color = Color3.fromRGB(0, 200, 255)
Glow.Thickness = 2

-- Header (clickable to minimize)
local Header = Instance.new("TextButton")
Header.Parent = Main
Header.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
Header.BorderSizePixel = 0
Header.Size = UDim2.new(1, 0, 0, 25)
Header.Font = Enum.Font.GothamBold
Header.Text = "🎣 FISCH AUTO [-]"
Header.TextColor3 = Color3.new(1, 1, 1)
Header.TextSize = 12

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local HeaderFix = Instance.new("Frame", Header)
HeaderFix.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
HeaderFix.BorderSizePixel = 0
HeaderFix.Position = UDim2.new(0, 0, 0.5, 0)
HeaderFix.Size = UDim2.new(1, 0, 0.5, 0)

-- Content (will be hidden when minimized)
local Content = Instance.new("Frame")
Content.Parent = Main
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 0, 0, 25)
Content.Size = UDim2.new(1, 0, 1, -25)

local Stats = Instance.new("TextLabel")
Stats.Parent = Content
Stats.BackgroundTransparency = 1
Stats.Position = UDim2.new(0, 10, 0, 5)
Stats.Size = UDim2.new(1, -20, 0, 60)
Stats.Font = Enum.Font.Gotham
Stats.Text = "Ready"
Stats.TextColor3 = Color3.new(1, 1, 1)
Stats.TextSize = 10
Stats.TextXAlignment = Enum.TextXAlignment.Left
Stats.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            local status = Config.Enabled and "🟢" or "🔴"
            local action = IsSelling and "💰Sell" or IsReeling and "⚡Reel" or IsFishing and "⏳Wait" or "🎣Cast"
            local nextSell = Config.SellInterval - (Stats.Fish % Config.SellInterval)
            if nextSell == 0 then nextSell = Config.SellInterval end
            
            Stats.Text = string.format(
                "%s %s\n🐟 %d/%d | 🎣 %d\n💰 Sells: %d",
                status, action,
                Stats.Fish, Config.SellInterval,
                Stats.Casts, Stats.Sells
            )
        end)
    end
end)

-- Buttons
local function CreateButton(text, pos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = Content
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Position = pos
    btn.Size = UDim2.new(1, -20, 0, 22)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 10
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local SetMerchantBtn = CreateButton("📍 Merchant", UDim2.new(0, 10, 0, 70), Color3.fromRGB(255, 100, 0), function()
    local hrp = GetHRP()
    if hrp then
        Waypoints.Merchant = hrp.CFrame
        _G.MerchantPos = hrp.CFrame
        print("✅ Merchant saved")
    end
end)

local SetFishingBtn = CreateButton("🎣 Fishing", UDim2.new(0, 10, 0, 95), Color3.fromRGB(0, 150, 255), function()
    local hrp = GetHRP()
    if hrp then
        Waypoints.Fishing = hrp.CFrame
        _G.FishingPos = hrp.CFrame
        print("✅ Fishing saved")
    end
end)

local SellBtn = CreateButton("💰 Sell Now", UDim2.new(0, 10, 0, 120), Color3.fromRGB(255, 165, 0), function()
    if not IsSelling then task.spawn(AutoSell) end
end)

local ToggleBtn = CreateButton("🔴 START", UDim2.new(0, 10, 0, 145), Color3.fromRGB(200, 0, 0), function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        if not Waypoints.Merchant then
            warn("⚠️ Set merchant first!")
            Config.Enabled = false
            return
        end
        
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        ToggleBtn.Text = "🟢 STOP"
        Glow.Color = Color3.fromRGB(0, 255, 0)
        StartReelDetection()
        
        if not Waypoints.Fishing then
            local hrp = GetHRP()
            if hrp then Waypoints.Fishing = hrp.CFrame end
        end
        
        print("✅ Started!")
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        ToggleBtn.Text = "🔴 START"
        Glow.Color = Color3.fromRGB(0, 200, 255)
        StopReelDetection()
        IsFishing = false
        IsReeling = false
        IsSelling = false
        print("❌ Stopped")
    end
end)

-- Minimize functionality
local isMinimized = false

Header.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        Main:TweenSize(UDim2.new(0, 200, 0, 25), "Out", "Quad", 0.3, true)
        Header.Text = "🎣 FISCH AUTO [+]"
        Content.Visible = false
    else
        Main:TweenSize(UDim2.new(0, 200, 0, 180), "Out", "Quad", 0.3, true)
        Header.Text = "🎣 FISCH AUTO [-]"
        Content.Visible = true
    end
end)

-- Keybinds
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
    elseif input.KeyCode == Enum.KeyCode.F6 then
        ToggleBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.F7 then
        if not IsSelling then task.spawn(AutoSell) end
    elseif input.KeyCode == Enum.KeyCode.F8 then
        Header.MouseButton1Click:Fire()
    end
end)

print("════════════════════════════════════════")
print("✅ COMPACT GUI LOADED!")
print("════════════════════════════════════════")
print("📦 Features:")
print("  ✅ Inventory-based sell")
print("  ✅ Minimizable GUI (click header)")
print("  ✅ Small & clean design")
print("════════════════════════════════════════")
print("🎮 Controls:")
print("  F6 = Toggle ON/OFF")
print("  F7 = Manual Sell")
print("  F8 = Minimize")
print("  DELETE = Hide/Show")
print("════════════════════════════════════════")
print("📍 Setup:")
print("  1. Go to merchant → Click 📍 Merchant")
print("  2. Go to fishing → Click 🎣 Fishing")
print("  3. Click START")
print("════════════════════════════════════════")
