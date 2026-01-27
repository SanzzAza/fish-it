--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - SPAM REEL + AUTO SELL (FIXED!)
    AUTO LANJUT MANCING SETELAH SELL!
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
-- RESET STATE FUNCTION (NEW!)
-- ════════════════════════════════════════════════════════
local function ResetState()
    IsFishing = false
    IsReeling = false
    IsSelling = false
    LastCast = 0
    print("🔄 State reset - Ready to fish!")
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
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid:EquipTool(rod)
            task.wait(0.3)
            return true
        end
    end
    return rod ~= nil
end

-- ════════════════════════════════════════════════════════
-- FISCH SELL SYSTEM
-- ════════════════════════════════════════════════════════

local function DebugRemotes()
    print("═══════ DEBUG REMOTES ═══════")
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            print("📡 " .. obj.ClassName .. ": " .. obj:GetFullName())
        end
    end
    print("═════════════════════════════")
end

local function GetNetworkFolder()
    local possiblePaths = {
        RS:FindFirstChild("Network"),
        RS:FindFirstChild("Remotes"),
        RS:FindFirstChild("Events"),
        RS:FindFirstChild("RemoteEvents"),
        RS:FindFirstChild("Comm"),
    }
    
    for _, folder in pairs(possiblePaths) do
        if folder then
            return folder
        end
    end
    
    return RS
end

local function FindAllSellRemotes()
    local sellRemotes = {}
    local keywords = {"sell", "shop", "vendor", "merchant", "trade", "exchange"}
    
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            for _, keyword in pairs(keywords) do
                if name:find(keyword) then
                    table.insert(sellRemotes, obj)
                    break
                end
            end
        end
    end
    
    return sellRemotes
end

-- MAIN SELL FUNCTION
local function SellAllFish()
    if IsSelling then return false end
    IsSelling = true
    
    -- SIMPAN STATE SEBELUM SELL
    local wasEnabled = Config.Enabled
    
    print("💰 ═══════════════════════════════════")
    print("💰 SELLING ALL FISH...")
    print("💰 ═══════════════════════════════════")
    
    local success = false
    
    -- METHOD 1: Fisch specific remotes
    local fischRemoteNames = {
        "SellFish", "SellAllFish", "Sell", "SellAll",
        "sellfish", "sellall", "QuickSell", "InstaSell",
        "SellInventory", "SellCatch", "SellCatches",
    }
    
    for _, remoteName in pairs(fischRemoteNames) do
        local remote = RS:FindFirstChild(remoteName, true)
        if remote then
            print("💰 Found: " .. remote:GetFullName())
            
            pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer()
                    task.wait(0.1)
                    remote:FireServer("All")
                    task.wait(0.1)
                    remote:FireServer("all")
                    task.wait(0.1)
                    remote:FireServer(true)
                elseif remote:IsA("RemoteFunction") then
                    remote:InvokeServer()
                    task.wait(0.1)
                    remote:InvokeServer("All")
                end
            end)
            
            success = true
            task.wait(0.2)
        end
    end
    
    -- METHOD 2: Network folder
    local networkFolder = GetNetworkFolder()
    if networkFolder and networkFolder ~= RS then
        for _, obj in pairs(networkFolder:GetDescendants()) do
            if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and obj.Name:lower():find("sell") then
                pcall(function()
                    if obj:IsA("RemoteEvent") then
                        obj:FireServer()
                        obj:FireServer("All")
                        obj:FireServer(true)
                    else
                        obj:InvokeServer()
                        obj:InvokeServer("All")
                    end
                end)
                success = true
                task.wait(0.2)
            end
        end
    end
    
    -- METHOD 3: All sell remotes
    local allSellRemotes = FindAllSellRemotes()
    if #allSellRemotes > 0 then
        for _, remote in pairs(allSellRemotes) do
            pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer()
                    remote:FireServer("All")
                    remote:FireServer("all")
                    remote:FireServer(true)
                elseif remote:IsA("RemoteFunction") then
                    pcall(function() remote:InvokeServer() end)
                    pcall(function() remote:InvokeServer("All") end)
                end
            end)
            success = true
            task.wait(0.1)
        end
    end
    
    -- METHOD 4: ProximityPrompt
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local name = obj.Name:lower()
            local parentName = obj.Parent and obj.Parent.Name:lower() or ""
            local actionText = obj.ActionText and obj.ActionText:lower() or ""
            
            if name:find("sell") or parentName:find("sell") or actionText:find("sell") then
                if obj.Parent and obj.Parent:IsA("BasePart") then
                    local promptPos = obj.Parent.Position
                    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                        Player.Character.HumanoidRootPart.CFrame = CFrame.new(promptPos + Vector3.new(0, 3, 3))
                        task.wait(0.5)
                    end
                end
                
                pcall(function()
                    if fireproximityprompt then
                        fireproximityprompt(obj)
                    end
                end)
                
                success = true
                task.wait(0.5)
            end
        end
    end
    
    -- METHOD 5: GUI Buttons
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "FischSpamGUI" then
            for _, obj in pairs(gui:GetDescendants()) do
                if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Visible then
                    local name = obj.Name:lower()
                    local text = obj:IsA("TextButton") and obj.Text:lower() or ""
                    
                    if name:find("sell") or text:find("sell") then
                        pcall(function()
                            if getconnections then
                                for _, conn in pairs(getconnections(obj.MouseButton1Click)) do
                                    conn:Fire()
                                end
                            end
                        end)
                        
                        success = true
                        task.wait(0.3)
                        
                        -- Click confirm/all buttons
                        for _, btn in pairs(gui:GetDescendants()) do
                            if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                                local btnName = btn.Name:lower()
                                local btnText = btn:IsA("TextButton") and btn.Text:lower() or ""
                                
                                if btnName:find("all") or btnText:find("all") or
                                   btnName:find("confirm") or btnText:find("confirm") then
                                    pcall(function()
                                        if getconnections then
                                            for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
                                                conn:Fire()
                                            end
                                        end
                                    end)
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- HASIL
    if success then
        Stats.TotalSold = Stats.TotalSold + Stats.FishSinceLastSell
        print("💰 ═══════════════════════════════════")
        print(string.format("💰 SOLD! Total: %d fish", Stats.TotalSold))
        print("💰 ═══════════════════════════════════")
        Stats.FishSinceLastSell = 0
    else
        print("⚠️ Could not find sell method!")
    end
    
    -- ═══════════════════════════════════════════════════
    -- FIXED: RESET STATE DAN LANJUT MANCING!
    -- ═══════════════════════════════════════════════════
    task.wait(1)
    
    IsSelling = false
    IsFishing = false
    IsReeling = false
    LastCast = 0  -- Reset LastCast biar bisa cast langsung
    
    print("🔄 State reset - Continuing fishing...")
    
    -- Re-equip rod setelah sell
    task.wait(0.5)
    EquipRod()
    
    return success
end

local function CheckAndSell()
    if not Config.AutoSell then return end
    if IsSelling then return end
    
    if Stats.FishSinceLastSell >= Config.SellThreshold then
        print(string.format("💰 Reached %d fish! Selling...", Config.SellThreshold))
        
        -- Stop fishing sementara
        IsFishing = false
        IsReeling = false
        
        task.wait(0.5)
        
        -- Sell
        SellAllFish()
        
        -- FIXED: Pastikan bisa lanjut mancing
        task.wait(0.5)
        print("🎣 Resuming fishing...")
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
-- CAST (FIXED!)
-- ════════════════════════════════════════════════════════
local function DoCast()
    -- FIXED: Tambah pengecekan IsSelling
    if IsFishing or IsReeling or IsSelling then 
        return 
    end
    
    -- FIXED: Kurangi delay antar cast
    if tick() - LastCast < 1.5 then 
        return 
    end
    
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
    
    -- Timeout protection
    task.delay(20, function()
        if IsFishing and not IsReeling and not IsSelling then 
            print("⏰ Cast timeout - resetting...")
            IsFishing = false 
            LastCast = 0
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
        while IsReeling and Config.Enabled and not IsSelling do
            local hasUI = HasReelUI()
            
            if not hasUI then
                print("✅ UI gone! Fish caught!")
                break
            end
            
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            
            clickCount = clickCount + 1
            Stats.Clicks = Stats.Clicks + 1
            
            task.wait(Config.ClickSpeed)
            
            if tick() - startTime > 30 then
                print("⏰ Reel timeout!")
                break
            end
        end
        
        local duration = math.floor((tick() - startTime) * 1000)
        Stats.Fish = Stats.Fish + 1
        Stats.FishSinceLastSell = Stats.FishSinceLastSell + 1
        print(string.format("✅ Fish #%d! [%d/%d to sell]", 
            Stats.Fish, Stats.FishSinceLastSell, Config.SellThreshold))
        
        -- FIXED: Reset state dengan benar
        IsReeling = false
        IsFishing = false
        LastCast = 0  -- Biar bisa cast lagi segera
        
        -- Check auto sell
        task.wait(0.3)
        if Config.Enabled and not IsSelling then
            CheckAndSell()
        end
    end)
end

local function StopSpamReel()
    IsReeling = false
    ReelThread = nil
end

-- ════════════════════════════════════════════════════════
-- DETECTION
-- ════════════════════════════════════════════════════════
local ReelDetection = nil

local function StartReelDetection()
    if ReelDetection then return end
    
    ReelDetection = RunService.RenderStepped:Connect(function()
        -- FIXED: Cek semua kondisi
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
-- TOGGLE FUNCTIONS
-- ════════════════════════════════════════════════════════
local ToggleButton, Glow, SellToggleButton, MainToggle

local function UpdateButtonVisuals()
    if Config.Enabled then
        if MainToggle then
            MainToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            MainToggle.Text = "⚡ STOP FISHING"
        end
        if Glow then
            Glow.Color = Color3.fromRGB(0, 255, 0)
        end
    else
        if MainToggle then
            MainToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            MainToggle.Text = "🎣 START FISHING"
        end
        if Glow then
            Glow.Color = Color3.fromRGB(255, 0, 255)
        end
    end
end

local function ToggleScript()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        -- Reset semua state saat start
        ResetState()
        StartReelDetection()
        print("✅ FISHING STARTED!")
    else
        StopReelDetection()
        StopSpamReel()
        ResetState()
        print("❌ FISHING STOPPED!")
    end
    
    UpdateButtonVisuals()
end

local function ToggleAutoSell()
    Config.AutoSell = not Config.AutoSell
    
    if SellToggleButton then
        if Config.AutoSell then
            SellToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            SellToggleButton.Text = string.format("💰 Auto Sell: ON (%d Fish)", Config.SellThreshold)
            print("✅ Auto Sell ON!")
        else
            SellToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            SellToggleButton.Text = "💰 Auto Sell: OFF"
            print("❌ Auto Sell OFF!")
        end
    end
end

-- ════════════════════════════════════════════════════════
-- MAIN LOOP (FIXED!)
-- ════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.3)  -- Lebih cepat check
        
        -- FIXED: Kondisi yang lebih jelas
        if Config.Enabled then
            if not IsFishing and not IsReeling and not IsSelling then
                DoCast()
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- STATE MONITOR (NEW! - Auto Recovery)
-- ════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(5)
        
        -- Auto recovery jika stuck
        if Config.Enabled and not IsSelling then
            local hasUI = HasReelUI()
            
            -- Jika enabled tapi tidak ada aktivitas selama 10 detik
            if not hasUI and not IsReeling and IsFishing then
                if tick() - LastCast > 15 then
                    print("⚠️ Stuck detected! Resetting...")
                    ResetState()
                end
            end
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
    task.wait(1)
    ScreenGui.Parent = PlayerGui
end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.35, 0, 0.2, 0)
Main.Size = UDim2.new(0, 320, 0, 320)
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
Title.Text = "🎣 FISCH AUTO + SELL ALL"
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
StatsLabel.Size = UDim2.new(1, -30, 0, 100)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Ready to fish!"
StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsLabel.TextSize = 12
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Stats updater
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            local status = Config.Enabled and "⚡ ACTIVE" or "🔴 STOPPED"
            local currentAction = "Idle"
            
            if Config.Enabled then
                if IsSelling then
                    currentAction = "💰💰 SELLING! 💰💰"
                elseif IsReeling then
                    currentAction = "⚡⚡ REELING! ⚡⚡"
                elseif IsFishing then
                    currentAction = "⏳ Waiting for bite..."
                else
                    currentAction = "🎣 Casting..."
                end
            end
            
            local sellStatus = Config.AutoSell and 
                string.format("✅ [%d/%d]", Stats.FishSinceLastSell, Config.SellThreshold) or "❌ OFF"
            
            StatsLabel.Text = string.format(
                "%s | %s\n\n🐟 Fish: %d | 🎣 Casts: %d\n🖱️ Clicks: %d | 💰 Sold: %d\n📦 Auto Sell: %s\n\n⚡ State: %s | %s | %s",
                status, currentAction,
                Stats.Fish, Stats.Casts,
                Stats.Clicks, Stats.TotalSold,
                sellStatus,
                IsFishing and "Fishing" or "-",
                IsReeling and "Reeling" or "-",
                IsSelling and "Selling" or "-"
            )
        end)
    end
end)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = Main
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0, 15, 0, 160)
SpeedLabel.Size = UDim2.new(1, -30, 0, 20)
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.Text = "⚡ Speed: ULTRA FAST | Auto-Recovery: ON"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
SpeedLabel.TextSize = 10
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

-- AUTO SELL TOGGLE
SellToggleButton = Instance.new("TextButton")
SellToggleButton.Parent = Main
SellToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
SellToggleButton.BorderSizePixel = 0
SellToggleButton.Position = UDim2.new(0, 15, 0, 185)
SellToggleButton.Size = UDim2.new(1, -30, 0, 32)
SellToggleButton.Font = Enum.Font.GothamBold
SellToggleButton.Text = "💰 Auto Sell: ON (5 Fish)"
SellToggleButton.TextColor3 = Color3.new(1, 1, 1)
SellToggleButton.TextSize = 12

local SellButtonCorner = Instance.new("UICorner")
SellButtonCorner.CornerRadius = UDim.new(0, 8)
SellButtonCorner.Parent = SellToggleButton

SellToggleButton.MouseButton1Click:Connect(ToggleAutoSell)

-- SELL NOW BUTTON
local SellNowButton = Instance.new("TextButton")
SellNowButton.Parent = Main
SellNowButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
SellNowButton.BorderSizePixel = 0
SellNowButton.Position = UDim2.new(0, 15, 0, 222)
SellNowButton.Size = UDim2.new(0.5, -20, 0, 32)
SellNowButton.Font = Enum.Font.GothamBold
SellNowButton.Text = "💰 SELL NOW"
SellNowButton.TextColor3 = Color3.new(1, 1, 1)
SellNowButton.TextSize = 11

local SellNowCorner = Instance.new("UICorner")
SellNowCorner.CornerRadius = UDim.new(0, 8)
SellNowCorner.Parent = SellNowButton

SellNowButton.MouseButton1Click:Connect(function()
    if not IsSelling then
        task.spawn(SellAllFish)
    end
end)

-- RESET BUTTON (NEW!)
local ResetButton = Instance.new("TextButton")
ResetButton.Parent = Main
ResetButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ResetButton.BorderSizePixel = 0
ResetButton.Position = UDim2.new(0.5, 5, 0, 222)
ResetButton.Size = UDim2.new(0.5, -20, 0, 32)
ResetButton.Font = Enum.Font.GothamBold
ResetButton.Text = "🔄 RESET STATE"
ResetButton.TextColor3 = Color3.new(1, 1, 1)
ResetButton.TextSize = 11

local ResetCorner = Instance.new("UICorner")
ResetCorner.CornerRadius = UDim.new(0, 8)
ResetCorner.Parent = ResetButton

ResetButton.MouseButton1Click:Connect(function()
    ResetState()
    print("🔄 Manual state reset!")
end)

-- MAIN START/STOP BUTTON
MainToggle = Instance.new("TextButton")
MainToggle.Parent = Main
MainToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
MainToggle.BorderSizePixel = 0
MainToggle.Position = UDim2.new(0, 15, 0, 260)
MainToggle.Size = UDim2.new(1, -30, 0, 45)
MainToggle.Font = Enum.Font.GothamBold
MainToggle.Text = "🎣 START FISHING"
MainToggle.TextColor3 = Color3.new(1, 1, 1)
MainToggle.TextSize = 16

local MainToggleCorner = Instance.new("UICorner")
MainToggleCorner.CornerRadius = UDim.new(0, 10)
MainToggleCorner.Parent = MainToggle

MainToggle.MouseButton1Click:Connect(ToggleScript)

-- ════════════════════════════════════════════════════════
-- KEYBINDS
-- ════════════════════════════════════════════════════════
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
    elseif input.KeyCode == Enum.KeyCode.F6 then
        ToggleScript()
    elseif input.KeyCode == Enum.KeyCode.F7 then
        ToggleAutoSell()
    elseif input.KeyCode == Enum.KeyCode.F8 then
        if not IsSelling then
            task.spawn(SellAllFish)
        end
    elseif input.KeyCode == Enum.KeyCode.F9 then
        ResetState()
        print("🔄 State reset via F9!")
    end
end)

print("════════════════════════════════════════")
print("✅ FISCH AUTO + SELL ALL LOADED!")
print("════════════════════════════════════════")
print("🎮 KEYBINDS:")
print("  DELETE = Hide/Show GUI")
print("  F6 = Start/Stop Fishing")
print("  F7 = Toggle Auto Sell")
print("  F8 = Sell All Now")
print("  F9 = Reset State (if stuck)")
print("════════════════════════════════════════")
print("✅ Auto-Recovery: ON")
print("✅ Will continue fishing after sell!")
print("════════════════════════════════════════")
