--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - SPAM REEL + AUTO SELL (MINIMIZE!)
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
local IsMinimized = false

-- ════════════════════════════════════════════════════════
-- RESET STATE FUNCTION
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

local function SellAllFish()
    if IsSelling then return false end
    IsSelling = true
    
    print("💰 SELLING ALL FISH...")
    
    local success = false
    
    local fischRemoteNames = {
        "SellFish", "SellAllFish", "Sell", "SellAll",
        "sellfish", "sellall", "QuickSell", "InstaSell",
        "SellInventory", "SellCatch", "SellCatches",
    }
    
    for _, remoteName in pairs(fischRemoteNames) do
        local remote = RS:FindFirstChild(remoteName, true)
        if remote then
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
    
    if success then
        Stats.TotalSold = Stats.TotalSold + Stats.FishSinceLastSell
        print(string.format("💰 SOLD! Total: %d fish", Stats.TotalSold))
        Stats.FishSinceLastSell = 0
    end
    
    task.wait(1)
    
    IsSelling = false
    IsFishing = false
    IsReeling = false
    LastCast = 0
    
    print("🔄 Continuing fishing...")
    task.wait(0.5)
    EquipRod()
    
    return success
end

local function CheckAndSell()
    if not Config.AutoSell then return end
    if IsSelling then return end
    
    if Stats.FishSinceLastSell >= Config.SellThreshold then
        print(string.format("💰 Reached %d fish! Selling...", Config.SellThreshold))
        IsFishing = false
        IsReeling = false
        task.wait(0.5)
        SellAllFish()
        task.wait(0.5)
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
    if IsFishing or IsReeling or IsSelling then return end
    if tick() - LastCast < 1.5 then return end
    
    Stats.Casts = Stats.Casts + 1
    print("🎣 Casting #" .. Stats.Casts)
    
    EquipRod()
    
    local rod = GetRod()
    if rod then rod:Activate() end
    
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    IsFishing = true
    LastCast = tick()
    
    task.delay(20, function()
        if IsFishing and not IsReeling and not IsSelling then 
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
    
    local startTime = tick()
    local clickCount = 0
    
    ReelThread = task.spawn(function()
        while IsReeling and Config.Enabled and not IsSelling do
            local hasUI = HasReelUI()
            
            if not hasUI then break end
            
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            
            clickCount = clickCount + 1
            Stats.Clicks = Stats.Clicks + 1
            
            task.wait(Config.ClickSpeed)
            
            if tick() - startTime > 30 then break end
        end
        
        Stats.Fish = Stats.Fish + 1
        Stats.FishSinceLastSell = Stats.FishSinceLastSell + 1
        print(string.format("✅ Fish #%d! [%d/%d]", Stats.Fish, Stats.FishSinceLastSell, Config.SellThreshold))
        
        IsReeling = false
        IsFishing = false
        LastCast = 0
        
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
        if Config.Enabled and IsFishing and not IsReeling and not IsSelling then
            local hasUI = HasReelUI()
            if hasUI then StartSpamReel() end
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
-- GUI REFERENCES
-- ════════════════════════════════════════════════════════
local MainToggle, Glow, SellToggleButton, Main, ContentFrame, MinimizeButton, MiniBar

-- ════════════════════════════════════════════════════════
-- TOGGLE FUNCTIONS
-- ════════════════════════════════════════════════════════
local function UpdateButtonVisuals()
    if not MainToggle then return end
    
    if Config.Enabled then
        MainToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        MainToggle.Text = "⚡ STOP FISHING"
        if Glow then Glow.Color = Color3.fromRGB(0, 255, 0) end
    else
        MainToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        MainToggle.Text = "🎣 START FISHING"
        if Glow then Glow.Color = Color3.fromRGB(255, 0, 255) end
    end
end

local function ToggleScript()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
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
        else
            SellToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            SellToggleButton.Text = "💰 Auto Sell: OFF"
        end
    end
end

-- ════════════════════════════════════════════════════════
-- MINIMIZE FUNCTION
-- ════════════════════════════════════════════════════════
local function ToggleMinimize()
    IsMinimized = not IsMinimized
    
    if IsMinimized then
        -- MINIMIZE - Tampilkan bar kecil
        ContentFrame.Visible = false
        Main.Size = UDim2.new(0, 200, 0, 40)
        MinimizeButton.Text = "+"
        MiniBar.Visible = true
    else
        -- MAXIMIZE - Tampilkan full GUI
        ContentFrame.Visible = true
        Main.Size = UDim2.new(0, 320, 0, 320)
        MinimizeButton.Text = "−"
        MiniBar.Visible = false
    end
end

-- ════════════════════════════════════════════════════════
-- MAIN LOOP
-- ════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.3)
        if Config.Enabled and not IsFishing and not IsReeling and not IsSelling then
            DoCast()
        end
    end
end)

-- STATE MONITOR
task.spawn(function()
    while true do
        task.wait(5)
        if Config.Enabled and not IsSelling then
            local hasUI = HasReelUI()
            if not hasUI and not IsReeling and IsFishing then
                if tick() - LastCast > 15 then
                    print("⚠️ Stuck! Resetting...")
                    ResetState()
                end
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- GUI
-- ════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FischSpamGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- MAIN FRAME
Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0, 10, 0.5, -160)
Main.Size = UDim2.new(0, 320, 0, 320)
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(255, 0, 255)
Glow.Thickness = 2
Glow.Parent = Main

-- TITLE BAR
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = Main
TitleBar.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 40)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Parent = TitleBar
TitleFix.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
TitleFix.BorderSizePixel = 0
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "🎣 FISCH AUTO"
TitleText.TextColor3 = Color3.new(1, 1, 1)
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- MINIMIZE BUTTON
MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "Minimize"
MinimizeButton.Parent = TitleBar
MinimizeButton.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Position = UDim2.new(1, -35, 0, 5)
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "−"
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.TextSize = 20

local MinBtnCorner = Instance.new("UICorner")
MinBtnCorner.CornerRadius = UDim.new(0, 8)
MinBtnCorner.Parent = MinimizeButton

MinimizeButton.MouseButton1Click:Connect(ToggleMinimize)

-- MINI STATUS BAR (Saat Minimize)
MiniBar = Instance.new("TextLabel")
MiniBar.Name = "MiniBar"
MiniBar.Parent = Main
MiniBar.BackgroundTransparency = 1
MiniBar.Position = UDim2.new(0, 10, 0, 40)
MiniBar.Size = UDim2.new(1, -50, 0, 0)
MiniBar.Font = Enum.Font.GothamBold
MiniBar.Text = "🔴 OFF"
MiniBar.TextColor3 = Color3.new(1, 1, 1)
MiniBar.TextSize = 12
MiniBar.TextXAlignment = Enum.TextXAlignment.Left
MiniBar.Visible = false

-- CONTENT FRAME (Yang bisa di-minimize)
ContentFrame = Instance.new("Frame")
ContentFrame.Name = "Content"
ContentFrame.Parent = Main
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 0, 0, 45)
ContentFrame.Size = UDim2.new(1, 0, 1, -45)

-- STATS LABEL
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = ContentFrame
StatsLabel.BackgroundTransparency = 1
StatsLabel.Position = UDim2.new(0, 15, 0, 5)
StatsLabel.Size = UDim2.new(1, -30, 0, 85)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Ready to fish!"
StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsLabel.TextSize = 11
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Stats updater
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            local status = Config.Enabled and "⚡ ACTIVE" or "🔴 OFF"
            local action = "Idle"
            
            if Config.Enabled then
                if IsSelling then action = "💰 SELLING!"
                elseif IsReeling then action = "⚡ REELING!"
                elseif IsFishing then action = "⏳ Waiting..."
                else action = "🎣 Casting..." end
            end
            
            local sellStatus = Config.AutoSell and 
                string.format("✅ [%d/%d]", Stats.FishSinceLastSell, Config.SellThreshold) or "❌ OFF"
            
            StatsLabel.Text = string.format(
                "%s | %s\n\n🐟 Fish: %d | 🎣 Casts: %d\n🖱️ Clicks: %d | 💰 Sold: %d\n📦 Auto Sell: %s",
                status, action,
                Stats.Fish, Stats.Casts,
                Stats.Clicks, Stats.TotalSold,
                sellStatus
            )
            
            -- Update mini bar
            MiniBar.Text = string.format("%s | 🐟%d | 💰%d", status, Stats.Fish, Stats.TotalSold)
            if Config.Enabled then
                MiniBar.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                MiniBar.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end)
    end
end)

-- SPEED LABEL
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = ContentFrame
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0, 15, 0, 95)
SpeedLabel.Size = UDim2.new(1, -30, 0, 15)
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.Text = "⚡ ULTRA FAST | Auto-Recovery: ON"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
SpeedLabel.TextSize = 9
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

-- AUTO SELL TOGGLE
SellToggleButton = Instance.new("TextButton")
SellToggleButton.Parent = ContentFrame
SellToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
SellToggleButton.BorderSizePixel = 0
SellToggleButton.Position = UDim2.new(0, 15, 0, 115)
SellToggleButton.Size = UDim2.new(1, -30, 0, 30)
SellToggleButton.Font = Enum.Font.GothamBold
SellToggleButton.Text = "💰 Auto Sell: ON (5 Fish)"
SellToggleButton.TextColor3 = Color3.new(1, 1, 1)
SellToggleButton.TextSize = 11

local SellBtnCorner = Instance.new("UICorner")
SellBtnCorner.CornerRadius = UDim.new(0, 8)
SellBtnCorner.Parent = SellToggleButton

SellToggleButton.MouseButton1Click:Connect(ToggleAutoSell)

-- SELL NOW & RESET BUTTONS
local SellNowButton = Instance.new("TextButton")
SellNowButton.Parent = ContentFrame
SellNowButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
SellNowButton.BorderSizePixel = 0
SellNowButton.Position = UDim2.new(0, 15, 0, 150)
SellNowButton.Size = UDim2.new(0.5, -20, 0, 28)
SellNowButton.Font = Enum.Font.GothamBold
SellNowButton.Text = "💰 SELL NOW"
SellNowButton.TextColor3 = Color3.new(1, 1, 1)
SellNowButton.TextSize = 10

local SellNowCorner = Instance.new("UICorner")
SellNowCorner.CornerRadius = UDim.new(0, 8)
SellNowCorner.Parent = SellNowButton

SellNowButton.MouseButton1Click:Connect(function()
    if not IsSelling then task.spawn(SellAllFish) end
end)

local ResetButton = Instance.new("TextButton")
ResetButton.Parent = ContentFrame
ResetButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ResetButton.BorderSizePixel = 0
ResetButton.Position = UDim2.new(0.5, 5, 0, 150)
ResetButton.Size = UDim2.new(0.5, -20, 0, 28)
ResetButton.Font = Enum.Font.GothamBold
ResetButton.Text = "🔄 RESET"
ResetButton.TextColor3 = Color3.new(1, 1, 1)
ResetButton.TextSize = 10

local ResetCorner = Instance.new("UICorner")
ResetCorner.CornerRadius = UDim.new(0, 8)
ResetCorner.Parent = ResetButton

ResetButton.MouseButton1Click:Connect(ResetState)

-- MAIN TOGGLE BUTTON
MainToggle = Instance.new("TextButton")
MainToggle.Parent = ContentFrame
MainToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
MainToggle.BorderSizePixel = 0
MainToggle.Position = UDim2.new(0, 15, 0, 185)
MainToggle.Size = UDim2.new(1, -30, 0, 40)
MainToggle.Font = Enum.Font.GothamBold
MainToggle.Text = "🎣 START FISHING"
MainToggle.TextColor3 = Color3.new(1, 1, 1)
MainToggle.TextSize = 14

local MainToggleCorner = Instance.new("UICorner")
MainToggleCorner.CornerRadius = UDim.new(0, 10)
MainToggleCorner.Parent = MainToggle

MainToggle.MouseButton1Click:Connect(ToggleScript)

-- KEYBIND INFO
local KeybindInfo = Instance.new("TextLabel")
KeybindInfo.Parent = ContentFrame
KeybindInfo.BackgroundTransparency = 1
KeybindInfo.Position = UDim2.new(0, 15, 0, 230)
KeybindInfo.Size = UDim2.new(1, -30, 0, 40)
KeybindInfo.Font = Enum.Font.Gotham
KeybindInfo.Text = "DEL=Hide | F6=Toggle | F7=AutoSell | F8=Sell | F9=Reset"
KeybindInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
KeybindInfo.TextSize = 9
KeybindInfo.TextWrapped = true

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
        if not IsSelling then task.spawn(SellAllFish) end
    elseif input.KeyCode == Enum.KeyCode.F9 then
        ResetState()
    elseif input.KeyCode == Enum.KeyCode.M then
        ToggleMinimize()
    end
end)

print("════════════════════════════════════════")
print("✅ FISCH AUTO LOADED!")
print("════════════════════════════════════════")
print("🎮 KEYBINDS:")
print("  DEL = Hide/Show")
print("  F6 = Start/Stop")
print("  F7 = Auto Sell Toggle")
print("  F8 = Sell Now")
print("  F9 = Reset State")
print("  M = Minimize/Maximize")
print("════════════════════════════════════════")
