--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - BLATAN V1 (COLLAPSIBLE GUI)
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
    DelayReels = 0.03,
    DelayFishing = 0.5,
    SavedPosition = nil,
    AutoTeleport = false,
    HideAnimation = false,
}

local Stats = { Fish = 0, FishSinceLastSell = 0, Casts = 0, TotalSold = 0 }
local IsFishing, IsReeling, IsSelling, LastCast = false, false, false, 0

-- ════════════════════════════════════════════════════════
-- CORE FUNCTIONS (Same as before)
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
        end
    end
    
    Stats.TotalSold = Stats.TotalSold + Stats.FishSinceLastSell
    Stats.FishSinceLastSell = 0
    
    task.wait(0.5)
    if Config.SavedPosition then TeleportToSaved() end
    
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

task.spawn(function()
    while true do
        task.wait(0.2)
        if Config.Enabled and not IsFishing and not IsReeling and not IsSelling then
            DoCast()
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(5)
        if Config.Enabled and IsFishing and not IsReeling and tick() - LastCast > 15 then
            ResetState()
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- GUI - COLLAPSIBLE SECTIONS
-- ════════════════════════════════════════════════════════
local GUI = Instance.new("ScreenGui")
GUI.Name = "BlatanV1"
GUI.ResetOnSpawn = false
GUI.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Parent = GUI
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0, 10, 0.3, 0)
Main.Size = UDim2.new(0, 185, 0, 0) -- Will auto-size
Main.AutomaticSize = Enum.AutomaticSize.Y
Main.Active = true
Main.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 60, 80)
MainStroke.Thickness = 1
MainStroke.Parent = Main

local MainLayout = Instance.new("UIListLayout")
MainLayout.SortOrder = Enum.SortOrder.LayoutOrder
MainLayout.Padding = UDim.new(0, 2)
MainLayout.Parent = Main

local MainPadding = Instance.new("UIPadding")
MainPadding.PaddingBottom = UDim.new(0, 5)
MainPadding.Parent = Main

-- ════════════════════════════════════════════════════════
-- HELPER: Create Collapsible Section
-- ════════════════════════════════════════════════════════
local function CreateSection(name, order, defaultOpen)
    local section = Instance.new("Frame")
    section.Name = name
    section.Parent = Main
    section.BackgroundTransparency = 1
    section.Size = UDim2.new(1, 0, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.LayoutOrder = order
    
    local sectionLayout = Instance.new("UIListLayout")
    sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sectionLayout.Padding = UDim.new(0, 3)
    sectionLayout.Parent = section
    
    -- Header
    local header = Instance.new("TextButton")
    header.Name = "Header"
    header.Parent = section
    header.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    header.Size = UDim2.new(1, 0, 0, 26)
    header.Font = Enum.Font.GothamBold
    header.TextColor3 = Color3.new(1, 1, 1)
    header.TextSize = 11
    header.LayoutOrder = 0
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 6)
    headerCorner.Parent = header
    
    -- Arrow
    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.Parent = header
    arrow.BackgroundTransparency = 1
    arrow.Position = UDim2.new(0, 8, 0, 0)
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Font = Enum.Font.GothamBold
    arrow.Text = defaultOpen and "˅" or "›"
    arrow.TextColor3 = Color3.fromRGB(150, 150, 150)
    arrow.TextSize = 14
    arrow.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Parent = header
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 25, 0, 0)
    title.Size = UDim2.new(1, -30, 1, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = name
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 11
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Content
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Parent = section
    content.BackgroundTransparency = 1
    content.Size = UDim2.new(1, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Visible = defaultOpen
    content.LayoutOrder = 1
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 4)
    contentLayout.Parent = content
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingLeft = UDim.new(0, 8)
    contentPadding.PaddingRight = UDim.new(0, 8)
    contentPadding.PaddingTop = UDim.new(0, 4)
    contentPadding.PaddingBottom = UDim.new(0, 4)
    contentPadding.Parent = content
    
    -- Toggle
    local isOpen = defaultOpen
    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        content.Visible = isOpen
        arrow.Text = isOpen and "˅" or "›"
    end)
    
    return section, content, header
end

-- ════════════════════════════════════════════════════════
-- HELPER: Create Slider
-- ════════════════════════════════════════════════════════
local function CreateSlider(parent, name, min, max, default, order, callback)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.LayoutOrder = order
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(0.6, 0, 0, 14)
    label.Font = Enum.Font.Gotham
    label.Text = name
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local value = Instance.new("TextLabel")
    value.Name = "Value"
    value.Parent = frame
    value.BackgroundTransparency = 1
    value.Position = UDim2.new(0.6, 0, 0, 0)
    value.Size = UDim2.new(0.4, 0, 0, 14)
    value.Font = Enum.Font.GothamBold
    value.Text = string.format("%.2f", default)
    value.TextColor3 = Color3.new(1, 1, 1)
    value.TextSize = 10
    value.TextXAlignment = Enum.TextXAlignment.Right
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = frame
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    sliderBg.Position = UDim2.new(0, 0, 0, 17)
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Parent = sliderBg
    
    local fill = Instance.new("Frame")
    fill.Parent = sliderBg
    fill.BackgroundColor3 = Color3.fromRGB(100, 130, 255)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill
    
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
            local rel = math.clamp((pos.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local val = min + (max - min) * rel
            fill.Size = UDim2.new(rel, 0, 1, 0)
            value.Text = string.format("%.2f", val)
            callback(val)
        end
    end)
    
    return frame
end

-- ════════════════════════════════════════════════════════
-- HELPER: Create Toggle Button
-- ════════════════════════════════════════════════════════
local function CreateToggle(parent, name, default, order, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = default and Color3.fromRGB(80, 180, 100) or Color3.fromRGB(50, 50, 60)
    btn.Size = UDim2.new(1, 0, 0, 24)
    btn.Font = Enum.Font.Gotham
    btn.Text = name
    btn.TextColor3 = default and Color3.new(1,1,1) or Color3.fromRGB(150, 150, 150)
    btn.TextSize = 10
    btn.LayoutOrder = order
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(80, 180, 100) or Color3.fromRGB(50, 50, 60)
        btn.TextColor3 = state and Color3.new(1,1,1) or Color3.fromRGB(150, 150, 150)
        callback(state)
    end)
    
    return btn
end

-- ════════════════════════════════════════════════════════
-- HELPER: Create Button
-- ════════════════════════════════════════════════════════
local function CreateButton(parent, name, color, order, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = color
    btn.Size = UDim2.new(1, 0, 0, 24)
    btn.Font = Enum.Font.Gotham
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 10
    btn.LayoutOrder = order
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    
    return btn
end

-- ════════════════════════════════════════════════════════
-- BUILD GUI SECTIONS
-- ════════════════════════════════════════════════════════

-- ═══ SECTION 1: Blatant V1 ═══
local sec1, content1, header1 = CreateSection("Blatant V1", 1, true)
header1.BackgroundColor3 = Color3.fromRGB(80, 60, 140)

CreateSlider(content1, "Delay Reels", 0.01, 0.5, Config.DelayReels, 1, function(v)
    Config.DelayReels = v
end)

CreateSlider(content1, "Delay Fishing", 0.1, 3, Config.DelayFishing, 2, function(v)
    Config.DelayFishing = v
end)

-- ═══ SECTION 2: Features ═══
local sec2, content2 = CreateSection("Features", 2, false)

CreateToggle(content2, "Auto Sell (5 Fish)", Config.AutoSell, 1, function(v)
    Config.AutoSell = v
end)

CreateToggle(content2, "Hide Animation", Config.HideAnimation, 2, function(v)
    Config.HideAnimation = v
end)

CreateToggle(content2, "Auto Teleport", Config.AutoTeleport, 3, function(v)
    Config.AutoTeleport = v
end)

-- ═══ SECTION 3: Teleport ═══
local sec3, content3 = CreateSection("Teleport", 3, false)

local saveBtn = CreateButton(content3, "📍 Save Position", Color3.fromRGB(60, 120, 200), 1, function()
    if SavePosition() then
        saveBtn.Text = "✅ Saved!"
        task.delay(1, function() saveBtn.Text = "📍 Save Position" end)
    end
end)

CreateButton(content3, "🚀 Teleport Back", Color3.fromRGB(200, 120, 60), 2, function()
    TeleportToSaved()
end)

-- ═══ SECTION 4: Actions ═══
local sec4, content4 = CreateSection("Actions", 4, false)

CreateButton(content4, "💰 Sell Now", Color3.fromRGB(200, 160, 60), 1, function()
    if not IsSelling then task.spawn(SellAllFish) end
end)

CreateButton(content4, "🔄 Reset State", Color3.fromRGB(100, 100, 100), 2, function()
    ResetState()
end)

-- ═══ MAIN START BUTTON ═══
local startSection = Instance.new("Frame")
startSection.Parent = Main
startSection.BackgroundTransparency = 1
startSection.Size = UDim2.new(1, 0, 0, 40)
startSection.LayoutOrder = 10

local startPadding = Instance.new("UIPadding")
startPadding.PaddingLeft = UDim.new(0, 5)
startPadding.PaddingRight = UDim.new(0, 5)
startPadding.PaddingTop = UDim.new(0, 5)
startPadding.Parent = startSection

local StartBtn = Instance.new("TextButton")
StartBtn.Parent = startSection
StartBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
StartBtn.Size = UDim2.new(1, 0, 0, 32)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.Text = "▶ START"
StartBtn.TextColor3 = Color3.new(1, 1, 1)
StartBtn.TextSize = 13

local startCorner = Instance.new("UICorner")
startCorner.CornerRadius = UDim.new(0, 6)
startCorner.Parent = StartBtn

StartBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    if Config.Enabled then
        StartBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 100)
        StartBtn.Text = "⏹ STOP"
        MainStroke.Color = Color3.fromRGB(80, 200, 100)
        ResetState()
        StartDetection()
        if Config.SavedPosition then TeleportToSaved() end
    else
        StartBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        StartBtn.Text = "▶ START"
        MainStroke.Color = Color3.fromRGB(60, 60, 80)
        StopDetection()
        ResetState()
    end
end)

-- ═══ STATUS BAR ═══
local statusSection = Instance.new("Frame")
statusSection.Parent = Main
statusSection.BackgroundTransparency = 1
statusSection.Size = UDim2.new(1, 0, 0, 20)
statusSection.LayoutOrder = 11

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = statusSection
StatusLabel.BackgroundTransparency = 1
StatusLabel.Size = UDim2.new(1, 0, 1, 0)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "🐟 0 | 💰 0"
StatusLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
StatusLabel.TextSize = 10

task.spawn(function()
    while task.wait(0.3) do
        local status = Config.Enabled and "🟢" or "🔴"
        StatusLabel.Text = string.format("%s 🐟 %d | 💰 %d | [%d/%d]", 
            status, Stats.Fish, Stats.TotalSold, Stats.FishSinceLastSell, Config.SellThreshold)
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
        StartBtn.MouseButton1Click:Fire()
    end
end)

print("════════════════════════════════════════")
print("✅ BLATAN V1 LOADED!")
print("════════════════════════════════════════")
print("DEL = Hide/Show | F6 = Toggle")
print("════════════════════════════════════════")
