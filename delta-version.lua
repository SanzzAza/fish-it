--[[
    ═══════════════════════════════════════════════════════
    🎣 FISCH AUTO - CLEAN VERSION
    By: SanzzAza (Original) | Clean & Fixed
    
    FIXES:
    ✅ Tidak spam keyboard (tidak loncat-loncat)
    ✅ Hanya fokus auto fishing
    ✅ Tidak ganggu movement
    ✅ Clean detection
    ═══════════════════════════════════════════════════════
]]

-- ════════════════════════════════════════════════════════
-- CLEANUP OLD INSTANCE
-- ════════════════════════════════════════════════════════
if _G.FischRunning then
    _G.FischRunning = false
    task.wait(0.5)
end

pcall(function()
    game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("FischGUI"):Destroy()
end)

print("════════════════════════════════════════")
print("🎣 FISCH AUTO - CLEAN VERSION")
print("════════════════════════════════════════")

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ════════════════════════════════════════════════════════
-- STATE
-- ════════════════════════════════════════════════════════
_G.FischRunning = true

local Connections = {}
local Config = {
    AutoCast = true,
    AutoReel = true,
    AutoShake = true,
    ShowDebug = false,
    
    CastDelay = 3,
    ReelDelay = 0.3,
}

local Stats = {
    Fish = 0,
    Casts = 0,
    Start = tick(),
}

-- ════════════════════════════════════════════════════════
-- UTILITIES
-- ════════════════════════════════════════════════════════
local function Connect(signal, func)
    local conn = signal:Connect(func)
    table.insert(Connections, conn)
    return conn
end

local function Debug(...)
    if Config.ShowDebug then
        print("🐛", ...)
    end
end

local function Cleanup()
    _G.FischRunning = false
    for _, conn in pairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Connections = {}
end

-- Fire signal compatibility
local function FireSignal(signal)
    pcall(function()
        if firesignal then
            firesignal(signal)
        elseif syn and syn.fire_signal then
            syn.fire_signal(signal)
        elseif getconnections then
            for _, v in pairs(getconnections(signal)) do
                if v.Fire then v:Fire() end
            end
        end
    end)
end

-- ════════════════════════════════════════════════════════
-- ROD FUNCTIONS
-- ════════════════════════════════════════════════════════
local function GetCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function FindRod()
    -- Check equipped
    local char = GetCharacter()
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("rod") then
                return tool, true -- rod, isEquipped
            end
        end
    end
    
    -- Check backpack
    for _, tool in pairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("rod") then
            return tool, false
        end
    end
    
    return nil, false
end

local function EquipRod()
    local rod, equipped = FindRod()
    if rod and not equipped then
        local hum = GetCharacter():FindFirstChildOfClass("Humanoid")
        if hum then
            hum:EquipTool(rod)
            task.wait(0.3)
            return true
        end
    end
    return equipped
end

-- ════════════════════════════════════════════════════════
-- ANTI-AFK
-- ════════════════════════════════════════════════════════
Connect(Player.Idled, function()
    pcall(function()
        local VU = game:GetService("VirtualUser")
        VU:CaptureController()
        VU:ClickButton2(Vector2.new())
    end)
end)

-- ════════════════════════════════════════════════════════
-- GUI
-- ════════════════════════════════════════════════════════
local Gui = Instance.new("ScreenGui")
Gui.Name = "FischGUI"
Gui.Parent = PlayerGui
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = Gui
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.Position = UDim2.new(0.02, 0, 0.3, 0)
Main.Size = UDim2.new(0, 280, 0, 290)
Main.Active = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(0, 150, 255)
Stroke.Thickness = 2

-- Dragging
local dragging, dragStart, startPos

Connect(Main.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

Connect(Main.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

Connect(UIS.InputChanged, function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Title
local Title = Instance.new("Frame")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(0, 130, 210)
Title.Size = UDim2.new(1, 0, 0, 40)
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local TitleFix = Instance.new("Frame")
TitleFix.Parent = Title
TitleFix.BackgroundColor3 = Color3.fromRGB(0, 130, 210)
TitleFix.BorderSizePixel = 0
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)

local TitleText = Instance.new("TextLabel")
TitleText.Parent = Title
TitleText.BackgroundTransparency = 1
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "🎣 FISCH AUTO - CLEAN"
TitleText.TextColor3 = Color3.new(1, 1, 1)
TitleText.TextSize = 16

-- Info
local Info = Instance.new("TextLabel")
Info.Name = "Info"
Info.Parent = Main
Info.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Info.Position = UDim2.new(0.05, 0, 0, 50)
Info.Size = UDim2.new(0.9, 0, 0, 50)
Info.Font = Enum.Font.RobotoMono
Info.TextColor3 = Color3.fromRGB(200, 200, 200)
Info.TextSize = 11
Info.Text = "Loading..."
Instance.new("UICorner", Info).CornerRadius = UDim.new(0, 8)

-- Update info
task.spawn(function()
    while _G.FischRunning do
        task.wait(0.5)
        if Info and Info.Parent then
            local elapsed = tick() - Stats.Start
            local mins = math.floor(elapsed / 60)
            local secs = math.floor(elapsed % 60)
            Info.Text = string.format("⏱️ %02d:%02d | 🐟 Fish: %d | 🎯 Casts: %d", mins, secs, Stats.Fish, Stats.Casts)
        end
    end
end)

-- Toggle Creator
local yPos = 110

local function CreateToggle(name, key, icon)
    local frame = Instance.new("Frame")
    frame.Parent = Main
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    frame.Position = UDim2.new(0.05, 0, 0, yPos)
    frame.Size = UDim2.new(0.9, 0, 0, 35)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = icon .. " " .. name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Position = UDim2.new(1, -60, 0.5, -12)
    btn.Size = UDim2.new(0, 50, 0, 24)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local function update()
        btn.Text = Config[key] and "ON" or "OFF"
        btn.BackgroundColor3 = Config[key] and Color3.fromRGB(0, 170, 70) or Color3.fromRGB(170, 50, 50)
    end
    update()
    
    Connect(btn.MouseButton1Click, function()
        Config[key] = not Config[key]
        update()
    end)
    
    yPos = yPos + 40
end

CreateToggle("Auto Cast", "AutoCast", "🎣")
CreateToggle("Auto Reel", "AutoReel", "🔄")
CreateToggle("Auto Shake", "AutoShake", "💥")
CreateToggle("Debug", "ShowDebug", "🐛")

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Main
CloseBtn.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
CloseBtn.Position = UDim2.new(0.05, 0, 0, yPos)
CloseBtn.Size = UDim2.new(0.9, 0, 0, 30)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✖ CLOSE"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextSize = 13
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

Connect(CloseBtn.MouseButton1Click, function()
    Cleanup()
    Gui:Destroy()
end)

-- Toggle visibility
Connect(UIS.InputBegan, function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
    end
end)

-- ════════════════════════════════════════════════════════
-- FISHING STATE
-- ════════════════════════════════════════════════════════
local IsFishing = false
local LastCast = 0

-- ════════════════════════════════════════════════════════
-- AUTO CAST (CLEAN - NO KEY SPAM)
-- ════════════════════════════════════════════════════════
task.spawn(function()
    Debug("Cast system started")
    
    while _G.FischRunning do
        task.wait(0.5)
        
        if not Config.AutoCast then continue end
        if IsFishing then continue end
        if tick() - LastCast < Config.CastDelay then continue end
        
        -- Equip rod
        if not EquipRod() then
            task.wait(1)
            continue
        end
        
        local rod, equipped = FindRod()
        if not rod or not equipped then continue end
        
        Stats.Casts = Stats.Casts + 1
        Debug("Casting #" .. Stats.Casts)
        
        -- ONLY use tool activation (no key spam!)
        pcall(function()
            rod:Activate()
        end)
        
        IsFishing = true
        LastCast = tick()
    end
end)

-- ════════════════════════════════════════════════════════
-- AUTO REEL (CLEAN - DETECT UI AND CLICK BUTTONS ONLY)
-- ════════════════════════════════════════════════════════
task.spawn(function()
    Debug("Reel system started")
    
    while _G.FischRunning do
        task.wait(0.1)
        
        if not Config.AutoReel then continue end
        
        -- Cari fishing UI (bar, minigame, dll)
        for _, ui in pairs(PlayerGui:GetDescendants()) do
            if ui:IsDescendantOf(Gui) then continue end
            
            local name = ui.Name:lower()
            local isVisible = false
            
            pcall(function()
                if ui:IsA("GuiObject") then
                    isVisible = ui.Visible
                end
            end)
            
            -- Detect fishing minigame UI
            if isVisible and ui:IsA("Frame") then
                if name:find("reel") or name:find("fish") or name:find("catch") or 
                   name:find("minigame") or name:find("bar") or name:find("meter") then
                    
                    Debug("Fishing UI detected:", ui.Name)
                    task.wait(Config.ReelDelay)
                    
                    -- HANYA klik tombol di dalam UI (tidak spam keyboard!)
                    for _, child in pairs(ui:GetDescendants()) do
                        if child:IsA("TextButton") or child:IsA("ImageButton") then
                            Debug("Clicking button:", child.Name)
                            FireSignal(child.MouseButton1Click)
                            FireSignal(child.Activated)
                        end
                    end
                    
                    Stats.Fish = Stats.Fish + 1
                    IsFishing = false
                    Debug("Fish caught! Total:", Stats.Fish)
                    
                    break
                end
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- AUTO SHAKE (CLEAN - ONLY CLICK SHAKE BUTTONS)
-- ════════════════════════════════════════════════════════
task.spawn(function()
    Debug("Shake system started")
    
    while _G.FischRunning do
        task.wait(0.08)
        
        if not Config.AutoShake then continue end
        
        for _, ui in pairs(PlayerGui:GetDescendants()) do
            if ui:IsDescendantOf(Gui) then continue end
            
            local name = ui.Name:lower()
            local isVisible = false
            
            pcall(function()
                if ui:IsA("GuiObject") then
                    isVisible = ui.Visible
                end
            end)
            
            -- Detect shake button
            if isVisible then
                if name:find("shake") or name:find("struggle") or name:find("!") then
                    
                    -- HANYA klik tombol shake (tidak spam keyboard!)
                    if ui:IsA("TextButton") or ui:IsA("ImageButton") then
                        FireSignal(ui.MouseButton1Click)
                        FireSignal(ui.Activated)
                        Debug("Shake clicked!")
                    end
                    
                    -- Atau cari button di dalamnya
                    if ui:IsA("Frame") then
                        for _, btn in pairs(ui:GetDescendants()) do
                            if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                                FireSignal(btn.MouseButton1Click)
                                FireSignal(btn.Activated)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- TIMEOUT SAFETY
-- ════════════════════════════════════════════════════════
task.spawn(function()
    while _G.FischRunning do
        task.wait(20)
        if IsFishing and tick() - LastCast > 25 then
            IsFishing = false
            Debug("Timeout reset")
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- DONE
-- ════════════════════════════════════════════════════════
print("════════════════════════════════════════")
print("✅ FISCH AUTO - CLEAN VERSION LOADED!")
print("════════════════════════════════════════")
print("🎣 Tidak spam keyboard!")
print("🎣 Tidak bikin loncat-loncat!")
print("🎣 Hanya fokus fishing!")
print("════════════════════════════════════════")
print("Press DELETE to toggle GUI")
print("════════════════════════════════════════")
