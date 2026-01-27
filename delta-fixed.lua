--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - SPAM REEL + AUTO SELL
    CLICK TERUS SAMPAI IKAN MASUK!
    AUTO SELL SETELAH 5 IKAN!
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
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Backpack = Player:WaitForChild("Backpack")

-- ════════════════════════════════════════════════════════
-- CONFIG
-- ════════════════════════════════════════════════════════
local Config = {
    Enabled = false,
    AutoSell = true,
    SellThreshold = 5,
    ClickSpeed = 0.03,
}

local Stats = {
    Fish = 0,
    FishSinceLastSell = 0,
    Casts = 0,
    Clicks = 0,
    TotalSold = 0,
}

-- ════════════════════════════════════════════════════════
-- STATE
-- ════════════════════════════════════════════════════════
local IsFishing = false
local IsReeling = false
local IsSelling = false
local LastCast = 0

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
-- AUTO SELL FUNCTIONS
-- ════════════════════════════════════════════════════════
local function FindSellRemote()
    local possibleNames = {
        "SellFish", "SellAll", "Sell", "SellAllFish",
        "sellfish", "sellall", "sell",
        "SellItem", "SellItems", "QuickSell"
    }
    
    -- Cari di ReplicatedStorage
    for _, name in pairs(possibleNames) do
        local remote = RS:FindFirstChild(name, true)
        if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            return remote
        end
    end
    
    -- Cari di Remotes folder
    local remotesFolder = RS:FindFirstChild("Remotes") or RS:FindFirstChild("Events") or RS:FindFirstChild("Network")
    if remotesFolder then
        for _, name in pairs(possibleNames) do
            local remote = remotesFolder:FindFirstChild(name)
            if remote then
                return remote
            end
        end
        
        -- Cari yang mengandung "sell"
        for _, remote in pairs(remotesFolder:GetDescendants()) do
            if (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                if remote.Name:lower():find("sell") then
                    return remote
                end
            end
        end
    end
    
    -- Cari semua remote yang mengandung "sell"
    for _, remote in pairs(RS:GetDescendants()) do
        if (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            if remote.Name:lower():find("sell") then
                return remote
            end
        end
    end
    
    return nil
end

local function FindSellNPC()
    local workspace = game:GetService("Workspace")
    local possibleNames = {
        "Sell", "SellNPC", "FishSeller", "Merchant",
        "Shop", "Store", "Vendor", "SellArea"
    }
    
    -- Cari NPC
    for _, name in pairs(possibleNames) do
        local npc = workspace:FindFirstChild(name, true)
        if npc then
            return npc
        end
    end
    
    -- Cari model yang mengandung "sell"
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            if obj.Name:lower():find("sell") then
                return obj
            end
        end
    end
    
    return nil
end

local function FindSellProximityPrompt()
    local workspace = game:GetService("Workspace")
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local name = obj.Name:lower()
            local parentName = obj.Parent and obj.Parent.Name:lower() or ""
            local actionText = obj.ActionText and obj.ActionText:lower() or ""
            
            if name:find("sell") or parentName:find("sell") or actionText:find("sell") then
                return obj
            end
        end
    end
    
    return nil
end

local function TeleportToSellArea()
    local sellNPC = FindSellNPC()
    if sellNPC and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local targetPos
        
        if sellNPC:IsA("Model") and sellNPC:FindFirstChild("HumanoidRootPart") then
            targetPos = sellNPC.HumanoidRootPart.Position
        elseif sellNPC:IsA("Model") and sellNPC.PrimaryPart then
            targetPos = sellNPC.PrimaryPart.Position
        elseif sellNPC:IsA("BasePart") then
            targetPos = sellNPC.Position
        elseif sellNPC:IsA("Model") then
            local part = sellNPC:FindFirstChildWhichIsA("BasePart")
            if part then
                targetPos = part.Position
            end
        end
        
        if targetPos then
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 5))
            return true
        end
    end
    return false
end

local function DoSell()
    if IsSelling then return false end
    IsSelling = true
    
    print("💰 Starting Auto Sell...")
    
    local success = false
    
    -- Method 1: Cari dan fire RemoteEvent/RemoteFunction
    local sellRemote = FindSellRemote()
    if sellRemote then
        print("💰 Found sell remote: " .. sellRemote.Name)
        
        pcall(function()
            if sellRemote:IsA("RemoteEvent") then
                sellRemote:FireServer()
                sellRemote:FireServer("all")
                sellRemote:FireServer("All")
                sellRemote:FireServer(true)
            elseif sellRemote:IsA("RemoteFunction") then
                sellRemote:InvokeServer()
                sellRemote:InvokeServer("all")
            end
        end)
        
        success = true
        task.wait(0.5)
    end
    
    -- Method 2: Cari ProximityPrompt sell
    local sellPrompt = FindSellProximityPrompt()
    if sellPrompt then
        print("💰 Found sell prompt: " .. sellPrompt.Name)
        
        -- Teleport ke prompt jika perlu
        if sellPrompt.Parent and sellPrompt.Parent:IsA("BasePart") then
            local promptPos = sellPrompt.Parent.Position
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (Player.Character.HumanoidRootPart.Position - promptPos).Magnitude
                if distance > sellPrompt.MaxActivationDistance then
                    Player.Character.HumanoidRootPart.CFrame = CFrame.new(promptPos + Vector3.new(0, 3, 3))
                    task.wait(0.5)
                end
            end
        end
        
        pcall(function()
            fireproximityprompt(sellPrompt)
        end)
        
        success = true
        task.wait(0.5)
    end
    
    -- Method 3: Cari tombol sell di GUI
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    local name = obj.Name:lower()
                    local text = ""
                    if obj:IsA("TextButton") then
                        text = obj.Text:lower()
                    end
                    
                    if name:find("sell") or text:find("sell") then
                        print("💰 Found sell button: " .. obj.Name)
                        pcall(function()
                            -- Simulate click
                            for _, conn in pairs(getconnections(obj.MouseButton1Click)) do
                                conn:Fire()
                            end
                        end)
                        success = true
                        task.wait(0.3)
                    end
                end
            end
        end
    end
    
    -- Method 4: Teleport ke NPC dan interact
    if not success then
        if TeleportToSellArea() then
            print("💰 Teleported to sell area")
            task.wait(1)
            
            -- Coba trigger ProximityPrompt terdekat
            local sellPrompt2 = FindSellProximityPrompt()
            if sellPrompt2 then
                pcall(function()
                    fireproximityprompt(sellPrompt2)
                end)
                success = true
            end
            
            task.wait(0.5)
        end
    end
    
    -- Method 5: Fire semua remote yang ada "sell"
    if not success then
        print("💰 Trying all sell remotes...")
        for _, remote in pairs(RS:GetDescendants()) do
            if remote:IsA("RemoteEvent") and remote.Name:lower():find("sell") then
                pcall(function()
                    remote:FireServer()
                    remote:FireServer("all")
                end)
                success = true
            end
        end
    end
    
    if success then
        Stats.TotalSold = Stats.TotalSold + Stats.FishSinceLastSell
        print(string.format("💰 SOLD! Total fish sold: %d", Stats.TotalSold))
        Stats.FishSinceLastSell = 0
    else
        print("⚠️ Could not find sell method - please sell manually or check game")
    end
    
    IsSelling = false
    task.wait(1)
    
    return success
end

local function CheckAndSell()
    if not Config.AutoSell then return end
    if IsSelling then return end
    
    if Stats.FishSinceLastSell >= Config.SellThreshold then
        print(string.format("💰 Reached %d fish! Auto selling...", Config.SellThreshold))
        
        -- Stop fishing sementara
        local wasEnabled = Config.Enabled
        IsFishing = false
        IsReeling = false
        
        task.wait(0.5)
        
        DoSell()
        
        task.wait(1)
    end
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
-- SPAM REEL (CLICK TERUS!)
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
        Stats.FishSinceLastSell = Stats.FishSinceLastSell + 1
        print(string.format("✅ Fish #%d! (%d clicks, %dms) [%d/%d to sell]", 
            Stats.Fish, clickCount, duration, Stats.FishSinceLastSell, Config.SellThreshold))
        
        IsReeling = false
        IsFishing = false
        
        -- Check auto sell
        task.spawn(function()
            task.wait(0.5)
            CheckAndSell()
        end)
        
        task.wait(1)
    end)
end

local function StopSpamReel()
    IsReeling = false
    ReelThread = nil
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
-- TOGGLE FUNCTION
-- ════════════════════════════════════════════════════════
local ToggleButton, Glow, SellToggleButton

local function ToggleScript()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.Text = "⚡ STOP SPAM"
        Glow.Color = Color3.fromRGB(0, 255, 0)
        StartReelDetection()
        print("✅ SPAM MODE ON!")
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = "🔴 START SPAM"
        Glow.Color = Color3.fromRGB(255, 0, 255)
        StopReelDetection()
        StopSpamReel()
        IsFishing = false
        print("❌ STOPPED!")
    end
end

local function ToggleAutoSell()
    Config.AutoSell = not Config.AutoSell
    
    if Config.AutoSell then
        SellToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        SellToggleButton.Text = "💰 Auto Sell: ON (5 Fish)"
        print("✅ Auto Sell ON!")
    else
        SellToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        SellToggleButton.Text = "💰 Auto Sell: OFF"
        print("❌ Auto Sell OFF!")
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
print("Creating GUI...")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FischSpamGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success = pcall(function()
    ScreenGui.Parent = PlayerGui
end)

if not success then
    warn("Failed to parent GUI, retrying...")
    task.wait(1)
    ScreenGui.Parent = PlayerGui
end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.35, 0, 0.25, 0)
Main.Size = UDim2.new(0, 320, 0, 290)
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 15)
Corner.Parent = Main

Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(255, 0, 255)
Glow.Thickness = 3
Glow.Parent = Main

local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡ SPAM REEL + AUTO SELL"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = Title

local TitleFix = Instance.new("Frame")
TitleFix.Parent = Title
TitleFix.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
TitleFix.BorderSizePixel = 0
TitleFix.Position = UDim2.new(0, 0, 0.6, 0)
TitleFix.Size = UDim2.new(1, 0, 0.4, 0)

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = Main
StatsLabel.BackgroundTransparency = 1
StatsLabel.Position = UDim2.new(0, 15, 0, 55)
StatsLabel.Size = UDim2.new(1, -30, 0, 90)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Ready to spam!"
StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsLabel.TextSize = 12
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            local status = Config.Enabled and "⚡ SPAM MODE!" or "🔴 STOPPED"
            local currentAction = ""
            
            if Config.Enabled then
                if IsSelling then
                    currentAction = "💰💰💰 SELLING! 💰💰💰"
                elseif IsReeling then
                    currentAction = "⚡⚡⚡ SPAMMING! ⚡⚡⚡"
                elseif IsFishing then
                    currentAction = "⏳ Waiting bite..."
                else
                    currentAction = "🎣 Casting..."
                end
            end
            
            local sellStatus = Config.AutoSell and 
                string.format("✅ ON [%d/%d]", Stats.FishSinceLastSell, Config.SellThreshold) or 
                "❌ OFF"
            
            StatsLabel.Text = string.format(
                "%s\n%s\n\n🐟 Fish: %d | 🎣 Casts: %d\n🖱️ Clicks: %d | 💰 Sold: %d\n📦 Auto Sell: %s",
                status,
                currentAction,
                Stats.Fish,
                Stats.Casts,
                Stats.Clicks,
                Stats.TotalSold,
                sellStatus
            )
        end)
    end
end)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = Main
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0, 15, 0, 150)
SpeedLabel.Size = UDim2.new(1, -30, 0, 20)
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.Text = "⚡ Speed: ULTRA FAST"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
SpeedLabel.TextSize = 12
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

-- SELL TOGGLE BUTTON
SellToggleButton = Instance.new("TextButton")
SellToggleButton.Parent = Main
SellToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
SellToggleButton.BorderSizePixel = 0
SellToggleButton.Position = UDim2.new(0, 15, 0, 175)
SellToggleButton.Size = UDim2.new(1, -30, 0, 35)
SellToggleButton.Font = Enum.Font.GothamBold
SellToggleButton.Text = "💰 Auto Sell: ON (5 Fish)"
SellToggleButton.TextColor3 = Color3.new(1, 1, 1)
SellToggleButton.TextSize = 13

local SellButtonCorner = Instance.new("UICorner")
SellButtonCorner.CornerRadius = UDim.new(0, 10)
SellButtonCorner.Parent = SellToggleButton

SellToggleButton.MouseButton1Click:Connect(ToggleAutoSell)

-- MANUAL SELL BUTTON
local ManualSellButton = Instance.new("TextButton")
ManualSellButton.Parent = Main
ManualSellButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
ManualSellButton.BorderSizePixel = 0
ManualSellButton.Position = UDim2.new(0, 15, 0, 215)
ManualSellButton.Size = UDim2.new(0.45, -10, 0, 30)
ManualSellButton.Font = Enum.Font.GothamBold
ManualSellButton.Text = "💰 SELL NOW"
ManualSellButton.TextColor3 = Color3.new(1, 1, 1)
ManualSellButton.TextSize = 11

local ManualSellCorner = Instance.new("UICorner")
ManualSellCorner.CornerRadius = UDim.new(0, 8)
ManualSellCorner.Parent = ManualSellButton

ManualSellButton.MouseButton1Click:Connect(function()
    if not IsSelling then
        task.spawn(function()
            DoSell()
        end)
    end
end)

-- START/STOP BUTTON
ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Main
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0.5, 5, 0, 215)
ToggleButton.Size = UDim2.new(0.5, -20, 0, 30)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "🔴 START"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = 11

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(ToggleScript)

-- MAIN TOGGLE BUTTON (BESAR)
local MainToggle = Instance.new("TextButton")
MainToggle.Parent = Main
MainToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
MainToggle.BorderSizePixel = 0
MainToggle.Position = UDim2.new(0, 15, 0, 250)
MainToggle.Size = UDim2.new(1, -30, 0, 30)
MainToggle.Font = Enum.Font.GothamBold
MainToggle.Text = "🎣 START FISHING"
MainToggle.TextColor3 = Color3.new(1, 1, 1)
MainToggle.TextSize = 13

local MainToggleCorner = Instance.new("UICorner")
MainToggleCorner.CornerRadius = UDim.new(0, 8)
MainToggleCorner.Parent = MainToggle

MainToggle.MouseButton1Click:Connect(function()
    ToggleScript()
    if Config.Enabled then
        MainToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        MainToggle.Text = "⚡ STOP FISHING"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.Text = "⚡ STOP"
    else
        MainToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        MainToggle.Text = "🎣 START FISHING"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = "🔴 START"
    end
end)

-- ════════════════════════════════════════════════════════
-- KEYBINDS
-- ════════════════════════════════════════════════════════
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
        print("GUI Toggled:", Main.Visible)
    elseif input.KeyCode == Enum.KeyCode.F6 then
        ToggleScript()
        if Config.Enabled then
            MainToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            MainToggle.Text = "⚡ STOP FISHING"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            ToggleButton.Text = "⚡ STOP"
        else
            MainToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            MainToggle.Text = "🎣 START FISHING"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            ToggleButton.Text = "🔴 START"
        end
    elseif input.KeyCode == Enum.KeyCode.F7 then
        ToggleAutoSell()
    elseif input.KeyCode == Enum.KeyCode.F8 then
        if not IsSelling then
            task.spawn(function()
                DoSell()
            end)
        end
    end
end)

print("════════════════════════════════════════")
print("✅ GUI CREATED!")
print("✅ SPAM REEL + AUTO SELL LOADED!")
print("════════════════════════════════════════")
print("🎮 Controls:")
print("  DELETE = Hide/Show GUI")
print("  F6 = Toggle Fishing ON/OFF")
print("  F7 = Toggle Auto Sell ON/OFF")
print("  F8 = Manual Sell Now")
print("════════════════════════════════════════")
print("⚡ CLICK START BUTTON TO BEGIN!")
print("💰 Auto Sell after 5 fish!")
print("════════════════════════════════════════")

task.wait(1)
if Main.Visible then
    print("✅ GUI is visible on screen!")
else
    warn("⚠️ GUI might be hidden!")
end
