--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - FIXED REEL DETECTION
    ════════════════════════════════════════════════════════
]]

print("🎣 Loading fixed version...")

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
-- IMPROVED REEL UI DETECTION (MULTIPLE METHODS!)
-- ════════════════════════════════════════════════════════
local function HasReelUI()
    -- METHOD 1: Check for any new GUI that appears
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "CompactFischGUI" then
            
            -- A) Direct find "reel"
            local reel = gui:FindFirstChild("reel", true)
            if reel and reel.Visible then
                print("🎯 Reel found (method A):", reel.Name)
                return true
            end
            
            -- B) Find common fishing UI elements
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("GuiObject") and obj.Visible then
                    local name = obj.Name:lower()
                    
                    -- Common names in Fisch
                    if name == "reel" or name == "safezone" or name == "bar" or 
                       name == "reelbar" or name == "playerbar" or name == "fishbar" or
                       name == "progress" or name:find("reel") or name:find("safe") or
                       name:find("minigame") then
                        print("🎯 Reel found (method B):", obj.Name, "in", gui.Name)
                        return true
                    end
                    
                    -- Check for ImageLabel/Frame with specific size (common for minigames)
                    if (obj:IsA("Frame") or obj:IsA("ImageLabel")) and 
                       obj.AbsoluteSize.Y > 100 and obj.AbsoluteSize.Y < 600 then
                        
                        -- Check if it has children (bar, safezone, etc)
                        local hasBar = obj:FindFirstChild("bar", true) or 
                                      obj:FindFirstChild("playerbar", true) or
                                      obj:FindFirstChild("safezone", true)
                        
                        if hasBar then
                            print("🎯 Reel found (method C - structure):", obj.Name)
                            return true
                        end
                    end
                end
            end
        end
    end
    
    return false
end

-- METHOD 2: Check if a NEW GUI appeared (alternative detection)
local KnownGUIs = {}

local function DetectNewGUI()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "CompactFischGUI" then
            if not KnownGUIs[gui] then
                -- New GUI appeared!
                print("🆕 New GUI appeared:", gui.Name)
                
                -- Check if it's a reel GUI
                task.wait(0.1)
                if gui:FindFirstChildOfClass("Frame") or gui:FindFirstChildOfClass("ImageLabel") then
                    print("🎯 Likely reel GUI:", gui.Name)
                    KnownGUIs[gui] = true
                    return true
                end
                
                KnownGUIs[gui] = true
            end
        end
    end
    
    -- Clean up removed GUIs
    for gui in pairs(KnownGUIs) do
        if not gui.Parent then
            KnownGUIs[gui] = nil
        end
    end
    
    return false
end

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
-- AUTO SELL
-- ════════════════════════════════════════════════════════
local function AutoSell()
    if IsSelling then return end
    IsSelling = true
    
    print("💰 Selling...")
    
    if not Waypoints.Merchant then
        warn("❌ Set merchant!")
        IsSelling = false
        return
    end
    
    if not Waypoints.Fishing then
        local hrp = GetHRP()
        if hrp then Waypoints.Fishing = hrp.CFrame end
    end
    
    TeleportTo(Waypoints.Merchant)
    task.wait(1.5)
    
    -- Spam sell
    for i = 1, 25 do
        VIM:SendKeyEvent(true, "E", false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, "E", false, game)
        task.wait(0.08)
    end
    
    for i = 1, 20 do
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        task.wait(0.08)
    end
    
    task.wait(2)
    Stats.Sells = Stats.Sells + 1
    print("✅ Sell #" .. Stats.Sells)
    
    if Waypoints.Fishing then
        TeleportTo(Waypoints.Fishing)
        task.wait(1)
    end
    
    IsSelling = false
end

-- ════════════════════════════════════════════════════════
-- ROD
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
    
    task.delay(25, function()
        if IsFishing and not IsReeling then 
            print("⏰ Cast timeout, recasting...")
            IsFishing = false 
        end
    end)
end

-- ════════════════════════════════════════════════════════
-- SPAM REEL (IMPROVED!)
-- ════════════════════════════════════════════════════════
local ReelThread = nil

local function StartSpamReel()
    if IsReeling then return end
    IsReeling = true
    
    print("⚡⚡⚡ REEL STARTED! ⚡⚡⚡")
    
    ReelThread = task.spawn(function()
        local startTime = tick()
        local clicks = 0
        local hadUI = true
        
        while IsReeling and Config.Enabled do
            local hasUI = HasReelUI()
            
            -- If UI disappeared after being present = fish caught!
            if not hasUI and hadUI and tick() - startTime > 0.5 then
                print("✅ UI disappeared = Fish caught!")
                break
            end
            
            hadUI = hasUI or hadUI -- Keep track if we ever had UI
            
            -- Spam click
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            
            clicks = clicks + 1
            
            task.wait(Config.ClickSpeed)
            
            -- Timeout after 30s
            if tick() - startTime > 30 then 
                print("⏰ Reel timeout!")
                break 
            end
        end
        
        local duration = math.floor((tick() - startTime) * 1000)
        Stats.Fish = Stats.Fish + 1
        
        print("════════════════════════════════════════")
        print(string.format("🐟 FISH #%d! (%dms, %d clicks)", Stats.Fish, duration, clicks))
        print("════════════════════════════════════════")
        
        IsReeling = false
        IsFishing = false
        
        -- Check sell
        local nextSell = Config.SellInterval - (Stats.Fish % Config.SellInterval)
        if nextSell == 0 then nextSell = Config.SellInterval end
        
        print("Next sell in:", nextSell, "fish")
        
        if Config.AutoSell and (Stats.Fish % Config.SellInterval == 0) then
            print("💰💰💰 TIME TO SELL! 💰💰💰")
            task.wait(1)
            task.spawn(AutoSell)
        else
            task.wait(1)
        end
    end)
end

-- ════════════════════════════════════════════════════════
-- DETECTION (DUAL METHOD!)
-- ════════════════════════════════════════════════════════
local ReelDetection = nil

local function StartReelDetection()
    if ReelDetection then return end
    
    print("✅ Starting reel detection (60 FPS + GUI monitoring)...")
    
    ReelDetection = RunService.RenderStepped:Connect(function()
        if Config.Enabled and IsFishing and not IsReeling and not IsSelling then
            
            -- Method 1: Check UI
            if HasReelUI() then
                print("🎯 REEL UI DETECTED!")
                StartSpamReel()
                return
            end
            
            -- Method 2: New GUI appeared
            if DetectNewGUI() then
                print("🎯 NEW GUI DETECTED!")
                task.wait(0.2)
                StartSpamReel()
                return
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
-- GUI (COMPACT + MINIMIZABLE)
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

local Content = Instance.new("Frame")
Content.Parent = Main
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 0, 0, 25)
Content.Size = UDim2.new(1, 0, 1, -25)

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = Content
StatsLabel.BackgroundTransparency = 1
StatsLabel.Position = UDim2.new(0, 10, 0, 5)
StatsLabel.Size = UDim2.new(1, -20, 0, 60)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Ready"
StatsLabel.TextColor3 = Color3.new(1, 1, 1)
StatsLabel.TextSize = 10
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            local status = Config.Enabled and "🟢" or "🔴"
            local action = IsSelling and "💰Sell" or IsReeling and "⚡Reel" or IsFishing and "⏳Wait" or "🎣Cast"
            local nextSell = Config.SellInterval - (Stats.Fish % Config.SellInterval)
            if nextSell == 0 then nextSell = Config.SellInterval end
            
            local hasUI = HasReelUI() and "👁️" or "❌"
            
            StatsLabel.Text = string.format(
                "%s %s | UI:%s\n🐟 %d/%d | Next:%d\n🎣 %d | 💰 %d",
                status, action, hasUI,
                Stats.Fish, Config.SellInterval, nextSell,
                Stats.Casts, Stats.Sells
            )
        end)
    end
end)

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

CreateButton("📍 Merchant", UDim2.new(0, 10, 0, 70), Color3.fromRGB(255, 100, 0), function()
    local hrp = GetHRP()
    if hrp then
        Waypoints.Merchant = hrp.CFrame
        _G.MerchantPos = hrp.CFrame
        print("✅ Merchant saved")
    end
end)

CreateButton("🎣 Fishing", UDim2.new(0, 10, 0, 95), Color3.fromRGB(0, 150, 255), function()
    local hrp = GetHRP()
    if hrp then
        Waypoints.Fishing = hrp.CFrame
        _G.FishingPos = hrp.CFrame
        print("✅ Fishing saved")
    end
end)

CreateButton("💰 Sell Now", UDim2.new(0, 10, 0, 120), Color3.fromRGB(255, 165, 0), function()
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
        
        print("✅ Started! Watch for '🎯 REEL UI DETECTED!' messages")
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
print("✅ FIXED VERSION LOADED!")
print("════════════════════════════════════════")
print("🔧 Improvements:")
print("  ✅ Multiple UI detection methods")
print("  ✅ New GUI monitoring")
print("  ✅ Better timeout handling")
print("  ✅ Real-time UI indicator (👁️/❌)")
print("════════════════════════════════════════")
print("📺 Watch console for:")
print("  '🎯 REEL UI DETECTED!'")
print("  '🐟 FISH #X!'")
print("════════════════════════════════════════")
print("🎮 F6=Toggle | F7=Sell | F8=Minimize")
print("════════════════════════════════════════")
