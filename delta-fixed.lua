--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - BLATAN V1
    ════════════════════════════════════════════════════════
    Features:
    ✅ Auto Fish + Auto Reel
    ✅ Auto Sell (5 Fish)
    ✅ Delay Reels (Adjustable)
    ✅ Delay Fishing (Adjustable)
    ✅ Save Position (Auto Teleport)
    ✅ Hide Animation (No Fishing Animation)
    ✅ Minimize GUI
    ✅ Auto Recovery
    ════════════════════════════════════════════════════════
]]

print("🎣 LOADING FISCH AUTO - BLATAN V1...")

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
-- CONFIG (BLATAN V1)
-- ════════════════════════════════════════════════════════
local Config = {
    -- Main
    Enabled = false,
    AutoSell = true,
    SellThreshold = 5,
    
    -- BLATAN V1 Features
    DelayReels = 0.03,      -- Delay antara click saat reel (0.01 - 0.5)
    DelayFishing = 1.5,     -- Delay antara cast (0.5 - 5)
    
    -- Position
    SavedPosition = nil,    -- Posisi yang disimpan
    AutoTeleport = false,   -- Auto teleport ke posisi
    
    -- Animation
    HideAnimation = false,  -- Sembunyikan animasi mancing
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
local OriginalAnimations = {}

-- ════════════════════════════════════════════════════════
-- RESET STATE
-- ════════════════════════════════════════════════════════
local function ResetState()
    IsFishing = false
    IsReeling = false
    IsSelling = false
    LastCast = 0
    print("🔄 State reset!")
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
-- HIDE ANIMATION SYSTEM
-- ════════════════════════════════════════════════════════
local function GetAnimator()
    if Player.Character then
        local humanoid = Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            return humanoid:FindFirstChild("Animator")
        end
    end
    return nil
end

local function HideFishingAnimation()
    if not Config.HideAnimation then return end
    
    pcall(function()
        local animator = GetAnimator()
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                local name = track.Name:lower()
                if name:find("fish") or name:find("cast") or name:find("reel") or name:find("rod") then
                    track:Stop()
                    track:AdjustSpeed(0)
                end
            end
        end
        
        -- Hide rod mesh
        if Player.Character then
            for _, tool in pairs(Player.Character:GetChildren()) do
                if tool:IsA("Tool") and tool.Name:lower():find("rod") then
                    for _, part in pairs(tool:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Transparency = 1
                        end
                    end
                end
            end
        end
    end)
end

local function ShowFishingAnimation()
    pcall(function()
        -- Show rod mesh
        if Player.Character then
            for _, tool in pairs(Player.Character:GetChildren()) do
                if tool:IsA("Tool") and tool.Name:lower():find("rod") then
                    for _, part in pairs(tool:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Transparency = 0
                        end
                    end
                end
            end
        end
    end)
end

-- Animation hide loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if Config.Enabled and Config.HideAnimation then
            HideFishingAnimation()
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- POSITION SYSTEM
-- ════════════════════════════════════════════════════════
local function SavePosition()
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Config.SavedPosition = Player.Character.HumanoidRootPart.CFrame
        print("📍 Position saved!")
        return true
    end
    return false
end

local function TeleportToSavedPosition()
    if Config.SavedPosition and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = Config.SavedPosition
        print("📍 Teleported to saved position!")
        return true
    end
    return false
end

local function ClearPosition()
    Config.SavedPosition = nil
    Config.AutoTeleport = false
    print("📍 Position cleared!")
end

-- Auto teleport loop
task.spawn(function()
    while true do
        task.wait(1)
        if Config.Enabled and Config.AutoTeleport and Config.SavedPosition then
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local currentPos = Player.Character.HumanoidRootPart.Position
                local savedPos = Config.SavedPosition.Position
                local distance = (currentPos - savedPos).Magnitude
                
                if distance > 10 then
                    TeleportToSavedPosition()
                end
            end
        end
    end
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
-- SELL SYSTEM
-- ════════════════════════════════════════════════════════
local function GetNetworkFolder()
    local possiblePaths = {
        RS:FindFirstChild("Network"),
        RS:FindFirstChild("Remotes"),
        RS:FindFirstChild("Events"),
    }
    
    for _, folder in pairs(possiblePaths) do
        if folder then return folder end
    end
    return RS
end

local function FindAllSellRemotes()
    local sellRemotes = {}
    local keywords = {"sell", "shop", "vendor"}
    
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
    local remoteNames = {
        "SellFish", "SellAllFish", "Sell", "SellAll",
        "sellfish", "sellall", "QuickSell",
    }
    
    for _, remoteName in pairs(remoteNames) do
        local remote = RS:FindFirstChild(remoteName, true)
        if remote then
            pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer()
                    remote:FireServer("All")
                    remote:FireServer(true)
                else
                    remote:InvokeServer()
                    remote:InvokeServer("All")
                end
            end)
            success = true
            task.wait(0.1)
        end
    end
    
    local allSellRemotes = FindAllSellRemotes()
    for _, remote in pairs(allSellRemotes) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer()
                remote:FireServer("All")
            end
        end)
        success = true
        task.wait(0.1)
    end
    
    -- ProximityPrompt sell
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local name = obj.Name:lower()
            local parentName = obj.Parent and obj.Parent.Name:lower() or ""
            local actionText = obj.ActionText and obj.ActionText:lower() or ""
            
            if name:find("sell") or parentName:find("sell") or actionText:find("sell") then
                if obj.Parent and obj.Parent:IsA("BasePart") then
                    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                        Player.Character.HumanoidRootPart.CFrame = CFrame.new(obj.Parent.Position + Vector3.new(0, 3, 3))
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
    
    if success then
        Stats.TotalSold = Stats.TotalSold + Stats.FishSinceLastSell
        print(string.format("💰 SOLD %d fish! Total: %d", Stats.FishSinceLastSell, Stats.TotalSold))
        Stats.FishSinceLastSell = 0
    end
    
    task.wait(0.5)
    
    -- Teleport back to saved position
    if Config.SavedPosition then
        TeleportToSavedPosition()
        task.wait(0.3)
    end
    
    IsSelling = false
    IsFishing = false
    IsReeling = false
    LastCast = 0
    
    EquipRod()
    
    return success
end

local function CheckAndSell()
    if not Config.AutoSell then return end
    if IsSelling then return end
    
    if Stats.FishSinceLastSell >= Config.SellThreshold then
        print(string.format("💰 %d fish! Selling...", Config.SellThreshold))
        IsFishing = false
        IsReeling = false
        task.wait(0.3)
        SellAllFish()
    end
end

-- ════════════════════════════════════════════════════════
-- UI DETECTION
-- ════════════════════════════════════════════════════════
local function HasReelUI()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "FischBlatanGUI" then
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("GuiObject") and obj.Visible then
                    local name = obj.Name:lower()
                    if name == "reel" or name == "safezone" or name == "bar" or 
                       name == "reelbar" or name == "fishingbar" or name == "progress" or
                       name == "playerbar" or name:find("reel") or name:find("safe") then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- ════════════════════════════════════════════════════════
-- CAST (With Delay Fishing)
-- ════════════════════════════════════════════════════════
local function DoCast()
    if IsFishing or IsReeling or IsSelling then return end
    if tick() - LastCast < Config.DelayFishing then return end
    
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
        if IsFishing and not IsReeling and not IsSelling then 
            IsFishing = false 
            LastCast = 0
        end
    end)
end

-- ════════════════════════════════════════════════════════
-- SPAM REEL (With Delay Reels)
-- ════════════════════════════════════════════════════════
local function StartSpamReel()
    if IsReeling then return end
    IsReeling = true
    
    local startTime = tick()
    local clickCount = 0
    
    task.spawn(function()
        while IsReeling and Config.Enabled and not IsSelling do
            if not HasReelUI() then break end
            
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            
            clickCount = clickCount + 1
            Stats.Clicks = Stats.Clicks + 1
            
            task.wait(Config.DelayReels)  -- DELAY REELS
            
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

-- ════════════════════════════════════════════════════════
-- DETECTION
-- ════════════════════════════════════════════════════════
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

-- ════════════════════════════════════════════════════════
-- MAIN LOOP
-- ════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.2)
        if Config.Enabled and not IsFishing and not IsReeling and not IsSelling then
            DoCast()
        end
    end
end)

-- Auto Recovery
task.spawn(function()
    while true do
        task.wait(5)
        if Config.Enabled and not IsSelling and IsFishing and not IsReeling then
            if tick() - LastCast > 15 then
                print("⚠️ Stuck! Resetting...")
                ResetState()
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- GUI REFERENCES
-- ════════════════════════════════════════════════════════
local Main, ContentFrame, Glow, MainToggle
local SellToggleBtn, HideAnimBtn, AutoTPBtn
local DelayReelsSlider, DelayFishingSlider
local SavePosBtn, TeleportBtn, ClearPosBtn

-- ════════════════════════════════════════════════════════
-- TOGGLE FUNCTIONS
-- ════════════════════════════════════════════════════════
local function UpdateMainButton()
    if not MainToggle then return end
    if Config.Enabled then
        MainToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        MainToggle.Text = "⚡ STOP"
        if Glow then Glow.Color = Color3.fromRGB(0, 255, 0) end
    else
        MainToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        MainToggle.Text = "🎣 START"
        if Glow then Glow.Color = Color3.fromRGB(255, 0, 255) end
    end
end

local function ToggleScript()
    Config.Enabled = not Config.Enabled
    if Config.Enabled then
        ResetState()
        StartReelDetection()
        if Config.SavedPosition then TeleportToSavedPosition() end
        print("✅ STARTED!")
    else
        StopReelDetection()
        ResetState()
        if not Config.HideAnimation then ShowFishingAnimation() end
        print("❌ STOPPED!")
    end
    UpdateMainButton()
end

local function ToggleAutoSell()
    Config.AutoSell = not Config.AutoSell
    if SellToggleBtn then
        SellToggleBtn.BackgroundColor3 = Config.AutoSell and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 80)
        SellToggleBtn.Text = Config.AutoSell and "💰 Auto Sell: ON" or "💰 Auto Sell: OFF"
    end
end

local function ToggleHideAnimation()
    Config.HideAnimation = not Config.HideAnimation
    if HideAnimBtn then
        HideAnimBtn.BackgroundColor3 = Config.HideAnimation and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 80)
        HideAnimBtn.Text = Config.HideAnimation and "👻 Hide Anim: ON" or "👻 Hide Anim: OFF"
    end
    if not Config.HideAnimation then ShowFishingAnimation() end
end

local function ToggleAutoTeleport()
    Config.AutoTeleport = not Config.AutoTeleport
    if AutoTPBtn then
        AutoTPBtn.BackgroundColor3 = Config.AutoTeleport and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 80)
        AutoTPBtn.Text = Config.AutoTeleport and "📍 Auto TP: ON" or "📍 Auto TP: OFF"
    end
end

local function ToggleMinimize()
    IsMinimized = not IsMinimized
    if IsMinimized then
        ContentFrame.Visible = false
        Main.Size = UDim2.new(0, 220, 0, 45)
    else
        ContentFrame.Visible = true
        Main.Size = UDim2.new(0, 320, 0, 420)
    end
end

-- ════════════════════════════════════════════════════════
-- GUI BUILDER
-- ════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FischBlatanGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- MAIN FRAME
Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0, 10, 0.5, -210)
Main.Size = UDim2.new(0, 320, 0, 420)
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
TitleBar.Parent = Main
TitleBar.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
TitleBar.Size = UDim2.new(1, 0, 0, 45)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Parent = TitleBar
TitleFix.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
TitleFix.BorderSizePixel = 0
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.Size = UDim2.new(1, -80, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "🎣 BLATAN V1"
TitleText.TextColor3 = Color3.new(1, 1, 1)
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- MINIMIZE BUTTON
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = TitleBar
MinBtn.BackgroundColor3 = Color3.fromRGB(70, 0, 150)
MinBtn.Position = UDim2.new(1, -40, 0, 7)
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.TextSize = 20

local MinBtnCorner = Instance.new("UICorner")
MinBtnCorner.CornerRadius = UDim.new(0, 8)
MinBtnCorner.Parent = MinBtn

MinBtn.MouseButton1Click:Connect(ToggleMinimize)

-- MINI STATUS (When minimized)
local MiniStatus = Instance.new("TextLabel")
MiniStatus.Parent = TitleBar
MiniStatus.BackgroundTransparency = 1
MiniStatus.Position = UDim2.new(0, 100, 0, 0)
MiniStatus.Size = UDim2.new(1, -150, 1, 0)
MiniStatus.Font = Enum.Font.Gotham
MiniStatus.Text = ""
MiniStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
MiniStatus.TextSize = 10
MiniStatus.TextXAlignment = Enum.TextXAlignment.Right

-- CONTENT FRAME
ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "Content"
ContentFrame.Parent = Main
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 0, 0, 50)
ContentFrame.Size = UDim2.new(1, 0, 1, -50)
ContentFrame.ScrollBarThickness = 4
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 380)

-- HELPER: Create Button
local function CreateButton(parent, pos, size, text, color)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = color or Color3.fromRGB(80, 80, 80)
    btn.BorderSizePixel = 0
    btn.Position = pos
    btn.Size = size
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 11
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    return btn
end

-- HELPER: Create Label
local function CreateLabel(parent, pos, size, text, textSize)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.BackgroundTransparency = 1
    label.Position = pos
    label.Size = size
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = textSize or 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

-- HELPER: Create Slider
local function CreateSlider(parent, pos, name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundTransparency = 1
    frame.Position = pos
    frame.Size = UDim2.new(1, -30, 0, 40)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Font = Enum.Font.GothamBold
    label.Text = string.format("%s: %.2f", name, default)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = frame
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBg.Position = UDim2.new(0, 0, 0, 22)
    sliderBg.Size = UDim2.new(1, 0, 0, 14)
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 7)
    sliderCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderBg
    sliderFill.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 7)
    fillCorner.Parent = sliderFill
    
    local dragging = false
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = UIS:GetMouseLocation()
            local relX = pos.X - sliderBg.AbsolutePosition.X
            local percent = math.clamp(relX / sliderBg.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * percent
            
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = string.format("%s: %.2f", name, value)
            
            callback(value)
        end
    end)
    
    return frame, label, sliderFill
end

-- ════════════════════════════════════════════════════════
-- GUI CONTENT
-- ════════════════════════════════════════════════════════

-- STATS
local StatsLabel = CreateLabel(ContentFrame, UDim2.new(0, 15, 0, 5), UDim2.new(1, -30, 0, 55), "", 10)
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            local status = Config.Enabled and "⚡ ACTIVE" or "🔴 OFF"
            local action = "Idle"
            
            if Config.Enabled then
                if IsSelling then action = "💰 Selling"
                elseif IsReeling then action = "⚡ Reeling"
                elseif IsFishing then action = "⏳ Waiting"
                else action = "🎣 Casting" end
            end
            
            StatsLabel.Text = string.format(
                "%s | %s\n🐟 %d caught | 🎣 %d casts | 💰 %d sold\n📦 AutoSell: %s [%d/%d]",
                status, action,
                Stats.Fish, Stats.Casts, Stats.TotalSold,
                Config.AutoSell and "ON" or "OFF",
                Stats.FishSinceLastSell, Config.SellThreshold
            )
            
            MiniStatus.Text = string.format("🐟%d 💰%d", Stats.Fish, Stats.TotalSold)
        end)
    end
end)

-- SECTION: BLATAN V1
local Section1 = CreateLabel(ContentFrame, UDim2.new(0, 15, 0, 65), UDim2.new(1, -30, 0, 20), "━━━ BLATAN V1 ━━━", 10)
Section1.TextXAlignment = Enum.TextXAlignment.Center
Section1.TextColor3 = Color3.fromRGB(150, 0, 255)

-- Delay Reels Slider
local _, delayReelsLabel = CreateSlider(ContentFrame, UDim2.new(0, 15, 0, 90), "⚡ Delay Reels", 0.01, 0.5, Config.DelayReels, function(val)
    Config.DelayReels = val
end)

-- Delay Fishing Slider
local _, delayFishLabel = CreateSlider(ContentFrame, UDim2.new(0, 15, 0, 135), "🎣 Delay Fishing", 0.5, 5, Config.DelayFishing, function(val)
    Config.DelayFishing = val
end)

-- SECTION: FEATURES
local Section2 = CreateLabel(ContentFrame, UDim2.new(0, 15, 0, 185), UDim2.new(1, -30, 0, 20), "━━━ FEATURES ━━━", 10)
Section2.TextXAlignment = Enum.TextXAlignment.Center
Section2.TextColor3 = Color3.fromRGB(150, 0, 255)

-- Auto Sell Toggle
SellToggleBtn = CreateButton(ContentFrame, UDim2.new(0, 15, 0, 210), UDim2.new(0.5, -20, 0, 28), "💰 Auto Sell: ON", Color3.fromRGB(0, 200, 100))
SellToggleBtn.MouseButton1Click:Connect(ToggleAutoSell)

-- Hide Animation Toggle
HideAnimBtn = CreateButton(ContentFrame, UDim2.new(0.5, 5, 0, 210), UDim2.new(0.5, -20, 0, 28), "👻 Hide Anim: OFF", Color3.fromRGB(80, 80, 80))
HideAnimBtn.MouseButton1Click:Connect(ToggleHideAnimation)

-- SECTION: POSITION
local Section3 = CreateLabel(ContentFrame, UDim2.new(0, 15, 0, 248), UDim2.new(1, -30, 0, 20), "━━━ POSITION ━━━", 10)
Section3.TextXAlignment = Enum.TextXAlignment.Center
Section3.TextColor3 = Color3.fromRGB(150, 0, 255)

-- Save Position Button
SavePosBtn = CreateButton(ContentFrame, UDim2.new(0, 15, 0, 273), UDim2.new(0.33, -13, 0, 28), "📍 Save", Color3.fromRGB(0, 150, 255))
SavePosBtn.MouseButton1Click:Connect(function()
    if SavePosition() then
        SavePosBtn.Text = "📍 Saved!"
        task.delay(1, function() SavePosBtn.Text = "📍 Save" end)
    end
end)

-- Teleport Button
TeleportBtn = CreateButton(ContentFrame, UDim2.new(0.33, 2, 0, 273), UDim2.new(0.33, -4, 0, 28), "🚀 TP", Color3.fromRGB(255, 165, 0))
TeleportBtn.MouseButton1Click:Connect(function()
    if TeleportToSavedPosition() then
        TeleportBtn.Text = "🚀 Done!"
        task.delay(1, function() TeleportBtn.Text = "🚀 TP" end)
    else
        TeleportBtn.Text = "❌ No Pos"
        task.delay(1, function() TeleportBtn.Text = "🚀 TP" end)
    end
end)

-- Clear Position Button
ClearPosBtn = CreateButton(ContentFrame, UDim2.new(0.66, 2, 0, 273), UDim2.new(0.33, -13, 0, 28), "🗑️ Clear", Color3.fromRGB(255, 80, 80))
ClearPosBtn.MouseButton1Click:Connect(function()
    ClearPosition()
    ClearPosBtn.Text = "🗑️ Cleared!"
    task.delay(1, function() ClearPosBtn.Text = "🗑️ Clear" end)
end)

-- Auto Teleport Toggle
AutoTPBtn = CreateButton(ContentFrame, UDim2.new(0, 15, 0, 306), UDim2.new(1, -30, 0, 28), "📍 Auto TP: OFF", Color3.fromRGB(80, 80, 80))
AutoTPBtn.MouseButton1Click:Connect(ToggleAutoTeleport)

-- MAIN TOGGLE BUTTON
MainToggle = CreateButton(ContentFrame, UDim2.new(0, 15, 0, 345), UDim2.new(1, -30, 0, 45), "🎣 START", Color3.fromRGB(255, 0, 0))
MainToggle.TextSize = 16
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
        if not IsSelling then task.spawn(SellAllFish) end
    elseif input.KeyCode == Enum.KeyCode.F9 then
        ResetState()
    elseif input.KeyCode == Enum.KeyCode.M then
        ToggleMinimize()
    elseif input.KeyCode == Enum.KeyCode.P then
        SavePosition()
    elseif input.KeyCode == Enum.KeyCode.T then
        TeleportToSavedPosition()
    end
end)

print("════════════════════════════════════════")
print("✅ FISCH AUTO - BLATAN V1 LOADED!")
print("════════════════════════════════════════")
print("🎮 KEYBINDS:")
print("  DEL = Hide/Show GUI")
print("  F6 = Start/Stop")
print("  F7 = Toggle Auto Sell")
print("  F8 = Sell Now")
print("  F9 = Reset State")
print("  M = Minimize")
print("  P = Save Position")
print("  T = Teleport to Saved")
print("════════════════════════════════════════")
print("⚡ BLATAN V1 Features:")
print("  - Delay Reels (Adjustable)")
print("  - Delay Fishing (Adjustable)")
print("  - Save Position + Auto TP")
print("  - Hide Animation")
print("════════════════════════════════════════")
