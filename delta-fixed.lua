--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - BLATAN V1 (CLEAN GUI)
    ════════════════════════════════════════════════════════
]]

print("🎣 LOADING BLATAN V1...")

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
    AutoSell = true,
    SellThreshold = 5,
    DelayReels = 0.03,
    DelayFishing = 0.5,
    SavedPosition = nil,
    AutoTeleport = false,
    HideAnimation = false,
}

local Stats = { Fish = 0, FishSinceLastSell = 0, Casts = 0, TotalSold = 0 }
local IsFishing, IsReeling, IsSelling, LastCast = false, false, false, 0

-- ════════════════════════════════════════════════════════
-- CORE FUNCTIONS
-- ════════════════════════════════════════════════════════
local function ResetState()
    IsFishing, IsReeling, IsSelling, LastCast = false, false, false, 0
end

Player.Idled:Connect(function()
    pcall(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):Button1Down(Vector2.new())
    end)
end)

local function GetRod()
    if Player.Character then
        for _, t in pairs(Player.Character:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find("rod") then return t end
        end
    end
    for _, t in pairs(Backpack:GetChildren()) do
        if t:IsA("Tool") and t.Name:lower():find("rod") then return t end
    end
end

local function EquipRod()
    local rod = GetRod()
    if rod and rod.Parent == Backpack and Player.Character then
        Player.Character.Humanoid:EquipTool(rod)
        task.wait(0.2)
    end
end

local function SavePosition()
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Config.SavedPosition = Player.Character.HumanoidRootPart.CFrame
        return true
    end
end

local function TeleportToSaved()
    if Config.SavedPosition and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = Config.SavedPosition
    end
end

-- Hide Animation
task.spawn(function()
    while true do
        task.wait(0.1)
        if Config.Enabled and Config.HideAnimation and Player.Character then
            pcall(function()
                local hum = Player.Character:FindFirstChild("Humanoid")
                if hum then
                    local animator = hum:FindFirstChild("Animator")
                    if animator then
                        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                            if track.Name:lower():find("fish") or track.Name:lower():find("rod") then
                                track:Stop()
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Teleport
task.spawn(function()
    while true do
        task.wait(1)
        if Config.Enabled and Config.AutoTeleport and Config.SavedPosition then
            pcall(function()
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (Player.Character.HumanoidRootPart.Position - Config.SavedPosition.Position).Magnitude
                    if dist > 10 then TeleportToSaved() end
                end
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- SELL SYSTEM
-- ════════════════════════════════════════════════════════
local function SellAllFish()
    if IsSelling then return end
    IsSelling = true
    
    for _, name in pairs({"SellFish", "SellAllFish", "Sell", "SellAll"}) do
        local r = RS:FindFirstChild(name, true)
        if r then
            pcall(function()
                if r:IsA("RemoteEvent") then r:FireServer() r:FireServer("All") r:FireServer(true)
                else r:InvokeServer() end
            end)
            task.wait(0.1)
        end
    end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and (obj.Name:lower():find("sell") or (obj.ActionText and obj.ActionText:lower():find("sell"))) then
            pcall(function()
                if obj.Parent:IsA("BasePart") and Player.Character then
                    Player.Character.HumanoidRootPart.CFrame = CFrame.new(obj.Parent.Position + Vector3.new(0,3,3))
                    task.wait(0.3)
                    if fireproximityprompt then fireproximityprompt(obj) end
                end
            end)
            task.wait(0.3)
        end
    end
    
    Stats.TotalSold = Stats.TotalSold + Stats.FishSinceLastSell
    Stats.FishSinceLastSell = 0
    
    task.wait(0.5)
    if Config.SavedPosition then TeleportToSaved() end
    task.wait(0.3)
    
    IsSelling, IsFishing, IsReeling, LastCast = false, false, false, 0
    EquipRod()
end

local function CheckAndSell()
    if Config.AutoSell and Stats.FishSinceLastSell >= Config.SellThreshold then
        SellAllFish()
    end
end

-- ════════════════════════════════════════════════════════
-- FISHING SYSTEM
-- ════════════════════════════════════════════════════════
local function HasReelUI()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "BlatanV1" then
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("GuiObject") and obj.Visible then
                    local n = obj.Name:lower()
                    if n:find("reel") or n:find("safe") or n == "bar" or n == "progress" then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function DoCast()
    if IsFishing or IsReeling or IsSelling or tick() - LastCast < Config.DelayFishing then return end
    
    EquipRod()
    local rod = GetRod()
    if rod then rod:Activate() end
    
    VIM:SendMouseButtonEvent(0,0,0,true,game,0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(0,0,0,false,game,0)
    
    IsFishing, LastCast = true, tick()
    Stats.Casts = Stats.Casts + 1
    
    task.delay(20, function()
        if IsFishing and not IsReeling then IsFishing, LastCast = false, 0 end
    end)
end

local function StartReel()
    if IsReeling then return end
    IsReeling = true
    
    task.spawn(function()
        local start = tick()
        while IsReeling and Config.Enabled and not IsSelling do
            if not HasReelUI() then break end
            VIM:SendMouseButtonEvent(0,0,0,true,game,0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0,0,0,false,game,0)
            task.wait(Config.DelayReels)
            if tick() - start > 30 then break end
        end
        
        Stats.Fish = Stats.Fish + 1
        Stats.FishSinceLastSell = Stats.FishSinceLastSell + 1
        IsReeling, IsFishing, LastCast = false, false, 0
        
        task.wait(0.2)
        CheckAndSell()
    end)
end

-- Detection
local Detection = nil
local function StartDetection()
    if Detection then return end
    Detection = RunService.RenderStepped:Connect(function()
        if Config.Enabled and IsFishing and not IsReeling and not IsSelling and HasReelUI() then
            StartReel()
        end
    end)
end

local function StopDetection()
    if Detection then Detection:Disconnect() Detection = nil end
end

-- Main Loop
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
        if Config.Enabled and IsFishing and not IsReeling and tick() - LastCast > 15 then
            ResetState()
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- CLEAN GUI
-- ════════════════════════════════════════════════════════
local GUI = Instance.new("ScreenGui")
GUI.Name = "BlatanV1"
GUI.ResetOnSpawn = false
GUI.Parent = PlayerGui

-- Main Frame
local Main = Instance.new("Frame")
Main.Parent = GUI
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0, 10, 0.3, 0)
Main.Size = UDim2.new(0, 180, 0, 245)
Main.Active = true
Main.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(80, 80, 100)
Stroke.Thickness = 1
Stroke.Parent = Main

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
Title.Size = UDim2.new(1, 0, 0, 28)
Title.Font = Enum.Font.GothamBold
Title.Text = "Blatant V1 Features"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 11

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Toggle Button (Automatically)
local AutoBtn = Instance.new("TextButton")
AutoBtn.Parent = Main
AutoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
AutoBtn.Position = UDim2.new(0, 8, 0, 35)
AutoBtn.Size = UDim2.new(1, -16, 0, 24)
AutoBtn.Font = Enum.Font.Gotham
AutoBtn.Text = "Automatically"
AutoBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
AutoBtn.TextSize = 10

local AutoCorner = Instance.new("UICorner")
AutoCorner.CornerRadius = UDim.new(0, 6)
AutoCorner.Parent = AutoBtn

-- Delay Reel Section
local ReelLabel = Instance.new("TextLabel")
ReelLabel.Parent = Main
ReelLabel.BackgroundTransparency = 1
ReelLabel.Position = UDim2.new(0, 10, 0, 65)
ReelLabel.Size = UDim2.new(0.5, -10, 0, 16)
ReelLabel.Font = Enum.Font.Gotham
ReelLabel.Text = "Delay Reel"
ReelLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
ReelLabel.TextSize = 10
ReelLabel.TextXAlignment = Enum.TextXAlignment.Left

local ReelValue = Instance.new("TextLabel")
ReelValue.Parent = Main
ReelValue.BackgroundTransparency = 1
ReelValue.Position = UDim2.new(0.5, 0, 0, 65)
ReelValue.Size = UDim2.new(0.5, -10, 0, 16)
ReelValue.Font = Enum.Font.GothamBold
ReelValue.Text = string.format("%.2f", Config.DelayReels)
ReelValue.TextColor3 = Color3.new(1, 1, 1)
ReelValue.TextSize = 10
ReelValue.TextXAlignment = Enum.TextXAlignment.Right

local ReelSliderBg = Instance.new("Frame")
ReelSliderBg.Parent = Main
ReelSliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ReelSliderBg.Position = UDim2.new(0, 10, 0, 83)
ReelSliderBg.Size = UDim2.new(1, -20, 0, 6)

local ReelSliderCorner = Instance.new("UICorner")
ReelSliderCorner.CornerRadius = UDim.new(0, 3)
ReelSliderCorner.Parent = ReelSliderBg

local ReelSliderFill = Instance.new("Frame")
ReelSliderFill.Parent = ReelSliderBg
ReelSliderFill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
ReelSliderFill.Size = UDim2.new(Config.DelayReels / 0.5, 0, 1, 0)

local ReelFillCorner = Instance.new("UICorner")
ReelFillCorner.CornerRadius = UDim.new(0, 3)
ReelFillCorner.Parent = ReelSliderFill

-- Delay Fishing Section
local FishLabel = Instance.new("TextLabel")
FishLabel.Parent = Main
FishLabel.BackgroundTransparency = 1
FishLabel.Position = UDim2.new(0, 10, 0, 95)
FishLabel.Size = UDim2.new(0.5, -10, 0, 16)
FishLabel.Font = Enum.Font.Gotham
FishLabel.Text = "Delay Fishing"
FishLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
FishLabel.TextSize = 10
FishLabel.TextXAlignment = Enum.TextXAlignment.Left

local FishValue = Instance.new("TextLabel")
FishValue.Parent = Main
FishValue.BackgroundTransparency = 1
FishValue.Position = UDim2.new(0.5, 0, 0, 95)
FishValue.Size = UDim2.new(0.5, -10, 0, 16)
FishValue.Font = Enum.Font.GothamBold
FishValue.Text = string.format("%.1f", Config.DelayFishing)
FishValue.TextColor3 = Color3.new(1, 1, 1)
FishValue.TextSize = 10
FishValue.TextXAlignment = Enum.TextXAlignment.Right

local FishSliderBg = Instance.new("Frame")
FishSliderBg.Parent = Main
FishSliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
FishSliderBg.Position = UDim2.new(0, 10, 0, 113)
FishSliderBg.Size = UDim2.new(1, -20, 0, 6)

local FishSliderCorner = Instance.new("UICorner")
FishSliderCorner.CornerRadius = UDim.new(0, 3)
FishSliderCorner.Parent = FishSliderBg

local FishSliderFill = Instance.new("Frame")
FishSliderFill.Parent = FishSliderBg
FishSliderFill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
FishSliderFill.Size = UDim2.new(Config.DelayFishing / 5, 0, 1, 0)

local FishFillCorner = Instance.new("UICorner")
FishFillCorner.CornerRadius = UDim.new(0, 3)
FishFillCorner.Parent = FishSliderFill

-- Buttons Row 1 (Trading, Menu, Quest)
local function CreateSmallBtn(name, posX, posY)
    local btn = Instance.new("TextButton")
    btn.Parent = Main
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.Position = UDim2.new(0, posX, 0, posY)
    btn.Size = UDim2.new(0, 50, 0, 22)
    btn.Font = Enum.Font.Gotham
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.TextSize = 9
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    
    return btn
end

local TradingBtn = CreateSmallBtn("Trading", 10, 128)
local MenuBtn = CreateSmallBtn("Menu", 65, 128)
local QuestBtn = CreateSmallBtn("Quest", 120, 128)

-- Buttons Row 2 (Teleport, Stable Result v1)
local TeleportBtn = Instance.new("TextButton")
TeleportBtn.Parent = Main
TeleportBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
TeleportBtn.Position = UDim2.new(0, 10, 0, 155)
TeleportBtn.Size = UDim2.new(0, 55, 0, 22)
TeleportBtn.Font = Enum.Font.Gotham
TeleportBtn.Text = "Teleport"
TeleportBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
TeleportBtn.TextSize = 9

local TPCorner = Instance.new("UICorner")
TPCorner.CornerRadius = UDim.new(0, 5)
TPCorner.Parent = TeleportBtn

local StableBtn = Instance.new("TextButton")
StableBtn.Parent = Main
StableBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
StableBtn.Position = UDim2.new(0, 70, 0, 155)
StableBtn.Size = UDim2.new(0, 100, 0, 22)
StableBtn.Font = Enum.Font.Gotham
StableBtn.Text = "Stable Result v1"
StableBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
StableBtn.TextSize = 9

local StableCorner = Instance.new("UICorner")
StableCorner.CornerRadius = UDim.new(0, 5)
StableCorner.Parent = StableBtn

-- Click Button (Main Toggle)
local ClickBtn = Instance.new("TextButton")
ClickBtn.Parent = Main
ClickBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
ClickBtn.Position = UDim2.new(0, 10, 0, 183)
ClickBtn.Size = UDim2.new(1, -20, 0, 28)
ClickBtn.Font = Enum.Font.GothamBold
ClickBtn.Text = "Click"
ClickBtn.TextColor3 = Color3.new(1, 1, 1)
ClickBtn.TextSize = 12

local ClickCorner = Instance.new("UICorner")
ClickCorner.CornerRadius = UDim.new(0, 6)
ClickCorner.Parent = ClickBtn

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = Main
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 10, 0, 216)
StatusLabel.Size = UDim2.new(1, -20, 0, 22)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "🐟 0 | 💰 0"
StatusLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
StatusLabel.TextSize = 10

-- ════════════════════════════════════════════════════════
-- SLIDER LOGIC
-- ════════════════════════════════════════════════════════
local draggingReel, draggingFish = false, false

ReelSliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingReel = true end
end)

ReelSliderBg.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingReel = false end
end)

FishSliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingFish = true end
end)

FishSliderBg.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingFish = false end
end)

UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if draggingReel then
            local pos = UIS:GetMouseLocation()
            local rel = math.clamp((pos.X - ReelSliderBg.AbsolutePosition.X) / ReelSliderBg.AbsoluteSize.X, 0, 1)
            Config.DelayReels = 0.01 + rel * 0.49
            ReelSliderFill.Size = UDim2.new(rel, 0, 1, 0)
            ReelValue.Text = string.format("%.2f", Config.DelayReels)
        end
        
        if draggingFish then
            local pos = UIS:GetMouseLocation()
            local rel = math.clamp((pos.X - FishSliderBg.AbsolutePosition.X) / FishSliderBg.AbsoluteSize.X, 0, 1)
            Config.DelayFishing = 0.1 + rel * 4.9
            FishSliderFill.Size = UDim2.new(rel, 0, 1, 0)
            FishValue.Text = string.format("%.1f", Config.DelayFishing)
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- BUTTON LOGIC
-- ════════════════════════════════════════════════════════

-- Main Toggle (Automatically)
AutoBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    if Config.Enabled then
        AutoBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        AutoBtn.TextColor3 = Color3.new(1, 1, 1)
        Stroke.Color = Color3.fromRGB(80, 200, 120)
        ResetState()
        StartDetection()
        if Config.SavedPosition then TeleportToSaved() end
    else
        AutoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        AutoBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        Stroke.Color = Color3.fromRGB(80, 80, 100)
        StopDetection()
        ResetState()
    end
end)

-- Click Button
ClickBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    if Config.Enabled then
        ClickBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        AutoBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        AutoBtn.TextColor3 = Color3.new(1, 1, 1)
        Stroke.Color = Color3.fromRGB(80, 200, 120)
        ResetState()
        StartDetection()
    else
        ClickBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
        AutoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        AutoBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        Stroke.Color = Color3.fromRGB(80, 80, 100)
        StopDetection()
        ResetState()
    end
end)

-- Teleport Button (Save/TP Position)
local tpMode = "save"
TeleportBtn.MouseButton1Click:Connect(function()
    if tpMode == "save" then
        if SavePosition() then
            TeleportBtn.Text = "TP Back"
            TeleportBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
            TeleportBtn.TextColor3 = Color3.new(1, 1, 1)
            tpMode = "tp"
        end
    else
        TeleportToSaved()
        TeleportBtn.Text = "Teleport"
        TeleportBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        TeleportBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        tpMode = "save"
    end
end)

-- Stable Result (Auto Sell Toggle)
StableBtn.MouseButton1Click:Connect(function()
    Config.AutoSell = not Config.AutoSell
    if Config.AutoSell then
        StableBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        StableBtn.TextColor3 = Color3.new(1, 1, 1)
    else
        StableBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        StableBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end)

-- Menu (Hide Animation)
MenuBtn.MouseButton1Click:Connect(function()
    Config.HideAnimation = not Config.HideAnimation
    if Config.HideAnimation then
        MenuBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        MenuBtn.TextColor3 = Color3.new(1, 1, 1)
    else
        MenuBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        MenuBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end)

-- Quest (Auto Teleport)
QuestBtn.MouseButton1Click:Connect(function()
    Config.AutoTeleport = not Config.AutoTeleport
    if Config.AutoTeleport then
        QuestBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        QuestBtn.TextColor3 = Color3.new(1, 1, 1)
    else
        QuestBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        QuestBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end)

-- Trading (Sell Now)
TradingBtn.MouseButton1Click:Connect(function()
    if not IsSelling then task.spawn(SellAllFish) end
end)

-- Status Update
task.spawn(function()
    while task.wait(0.3) do
        StatusLabel.Text = string.format("🐟 %d | 💰 %d | [%d/5]", Stats.Fish, Stats.TotalSold, Stats.FishSinceLastSell)
    end
end)

-- ════════════════════════════════════════════════════════
-- KEYBINDS
-- ════════════════════════════════════════════════════════
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
    elseif input.KeyCode == Enum.KeyCode.F6 then
        ClickBtn.MouseButton1Click:Fire()
    end
end)

print("════════════════════════════════════════")
print("✅ BLATAN V1 LOADED!")
print("════════════════════════════════════════")
print("DEL = Hide/Show | F6 = Toggle")
print("════════════════════════════════════════")
