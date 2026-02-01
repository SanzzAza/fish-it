--[[
    ╔═══════════════════════════════════════════════════╗
    ║          AUTO FISH SCRIPT - FISH IT!              ║
    ║              Versi Lengkap + GUI                  ║
    ╚═══════════════════════════════════════════════════╝
    
    Game: Fish It!
    Fitur:
    • Auto Cast (lempar kail otomatis)
    • Auto Catch/Reel (tangkap ikan otomatis)
    • Auto Minigame (selesaikan minigame otomatis)
    • Auto Sell (jual ikan otomatis) [Optional]
    • GUI dengan Toggle
    • Fish Counter
    
    Executor: Delta, Fluxus, Arceus X, Hydrogen, dll
]]

-- ═══════════════════════════════════════
--              SERVICES
-- ═══════════════════════════════════════
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Variables
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()

-- Settings
local Settings = {
    AutoFish = false,
    AutoMinigame = true,
    AutoSell = false,
    CastPower = 100, -- 0-100
    Delay = 0.3
}

-- Stats
local Stats = {
    FishCaught = 0,
    FishSold = 0,
    SessionTime = 0
}

-- ═══════════════════════════════════════
--         HAPUS GUI LAMA
-- ═══════════════════════════════════════
if game.CoreGui:FindFirstChild("FishItAutoGUI") then
    game.CoreGui:FindFirstChild("FishItAutoGUI"):Destroy()
end

-- ═══════════════════════════════════════
--           BUAT GUI UTAMA
-- ═══════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishItAutoGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.02, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 240, 0, 340)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Gradient Background
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 30, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 15, 30))
})
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

-- Glowing Border
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 150, 255)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.3
UIStroke.Parent = MainFrame

-- ═══════════════════════════════════════
--              TITLE BAR
-- ═══════════════════════════════════════
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 40)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Fix corner overlap
local TitleFix = Instance.new("Frame")
TitleFix.Parent = TitleBar
TitleFix.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
TitleFix.BorderSizePixel = 0
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)

-- Title Icon & Text
local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.Size = UDim2.new(1, -60, 1, 0)
TitleText.Font = Enum.Font.GothamBlack
TitleText.Text = "🎣 FISH IT! AUTO"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = TitleBar
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
MinimizeBtn.Position = UDim2.new(1, -60, 0.5, -10)
MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
MinimizeBtn.TextSize = 16

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 5)
MinCorner.Parent = MinimizeBtn

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Position = UDim2.new(1, -32, 0.5, -10)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseBtn

-- ═══════════════════════════════════════
--           CONTENT FRAME
-- ═══════════════════════════════════════
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "Content"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 0, 0, 45)
ContentFrame.Size = UDim2.new(1, 0, 1, -45)

-- ═══════════════════════════════════════
--            STATUS SECTION
-- ═══════════════════════════════════════
local StatusFrame = Instance.new("Frame")
StatusFrame.Parent = ContentFrame
StatusFrame.BackgroundColor3 = Color3.fromRGB(30, 35, 55)
StatusFrame.Position = UDim2.new(0.05, 0, 0, 5)
StatusFrame.Size = UDim2.new(0.9, 0, 0, 50)

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = StatusFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Size = UDim2.new(1, 0, 0.5, 0)
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.Text = "⏸️ Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
StatusLabel.TextSize = 13

local CounterLabel = Instance.new("TextLabel")
CounterLabel.Parent = StatusFrame
CounterLabel.BackgroundTransparency = 1
CounterLabel.Position = UDim2.new(0, 0, 0.5, 0)
CounterLabel.Size = UDim2.new(1, 0, 0.5, 0)
CounterLabel.Font = Enum.Font.GothamBold
CounterLabel.Text = "🐟 Fish Caught: 0"
CounterLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
CounterLabel.TextSize = 14

-- ═══════════════════════════════════════
--         FUNGSI BUAT TOGGLE
-- ═══════════════════════════════════════
local buttonY = 60

local function CreateToggle(name, icon, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Parent = ContentFrame
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
    ToggleFrame.Position = UDim2.new(0.05, 0, 0, buttonY)
    ToggleFrame.Size = UDim2.new(0.9, 0, 0, 38)
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Parent = ToggleFrame
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.Size = UDim2.new(0.65, 0, 1, 0)
    ToggleLabel.Font = Enum.Font.GothamSemibold
    ToggleLabel.Text = icon .. " " .. name
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 13
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = ToggleFrame
    ToggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 110)
    ToggleBtn.Position = UDim2.new(0.72, 0, 0.15, 0)
    ToggleBtn.Size = UDim2.new(0.23, 0, 0.7, 0)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Text = default and "ON" or "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 12
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = ToggleBtn
    
    local isOn = default
    
    ToggleBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        ToggleBtn.Text = isOn and "ON" or "OFF"
        
        -- Animate color change
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = isOn and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 110)
        }):Play()
        
        callback(isOn)
    end)
    
    buttonY = buttonY + 45
    return ToggleBtn
end

-- Buat Toggle Buttons
CreateToggle("Auto Fish", "🎣", false, function(state)
    Settings.AutoFish = state
    if state then
        StatusLabel.Text = "▶️ Status: Active"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        StatusLabel.Text = "⏸️ Status: Idle"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    end
end)

CreateToggle("Auto Minigame", "🎮", true, function(state)
    Settings.AutoMinigame = state
end)

CreateToggle("Auto Sell", "💰", false, function(state)
    Settings.AutoSell = state
end)

-- ═══════════════════════════════════════
--           INFO SECTION
-- ═══════════════════════════════════════
local InfoFrame = Instance.new("Frame")
InfoFrame.Parent = ContentFrame
InfoFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
InfoFrame.Position = UDim2.new(0.05, 0, 0, buttonY + 10)
InfoFrame.Size = UDim2.new(0.9, 0, 0, 55)

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 8)
InfoCorner.Parent = InfoFrame

local InfoText = Instance.new("TextLabel")
InfoText.Parent = InfoFrame
InfoText.BackgroundTransparency = 1
InfoText.Size = UDim2.new(1, 0, 1, 0)
InfoText.Font = Enum.Font.Gotham
InfoText.Text = "📌 Hotkeys:\nF5 = Toggle Auto Fish\nF6 = Hide/Show GUI"
InfoText.TextColor3 = Color3.fromRGB(180, 180, 200)
InfoText.TextSize = 11
InfoText.TextYAlignment = Enum.TextYAlignment.Center

-- Credits
local CreditsLabel = Instance.new("TextLabel")
CreditsLabel.Parent = ContentFrame
CreditsLabel.BackgroundTransparency = 1
CreditsLabel.Position = UDim2.new(0, 0, 1, -20)
CreditsLabel.Size = UDim2.new(1, 0, 0, 20)
CreditsLabel.Font = Enum.Font.Gotham
CreditsLabel.Text = "Fish It! Auto v1.0"
CreditsLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
CreditsLabel.TextSize = 10

-- ═══════════════════════════════════════
--         FISHING FUNCTIONS
-- ═══════════════════════════════════════

-- Cari Remotes
local function FindRemotes()
    local remotes = {}
    
    pcall(function()
        -- Cari di ReplicatedStorage
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = obj.Name:lower()
                if name:find("cast") or name:find("throw") or name:find("rod") then
                    remotes.Cast = obj
                elseif name:find("reel") or name:find("catch") or name:find("pull") then
                    remotes.Reel = obj
                elseif name:find("shake") or name:find("hook") then
                    remotes.Shake = obj
                elseif name:find("sell") then
                    remotes.Sell = obj
                elseif name:find("minigame") or name:find("game") then
                    remotes.Minigame = obj
                end
            end
        end
    end)
    
    return remotes
end

local Remotes = FindRemotes()

-- Fungsi Cast Rod
local function CastRod()
    pcall(function()
        -- Method 1: Fire Remote
        if Remotes.Cast then
            if Remotes.Cast:IsA("RemoteEvent") then
                Remotes.Cast:FireServer()
            elseif Remotes.Cast:IsA("RemoteFunction") then
                Remotes.Cast:InvokeServer()
            end
        end
        
        -- Method 2: Simulasi Mouse Hold & Release (untuk power bar)
        VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 1)
        wait(0.8) -- Hold untuk power
        VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 1)
    end)
end

-- Fungsi Auto Minigame
local function DoMinigame()
    pcall(function()
        -- Cari minigame UI
        for _, gui in pairs(playerGui:GetDescendants()) do
            -- Cari button atau area yang perlu diklik
            if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                local name = gui.Name:lower()
                if (name:find("catch") or name:find("reel") or name:find("pull") or name:find("click")) and gui.Visible then
                    -- Klik button
                    firesignal(gui.MouseButton1Click)
                end
            end
            
            -- Untuk minigame dengan bar/slider
            if gui:IsA("Frame") and gui.Name:lower():find("bar") then
                if gui.Visible then
                    -- Simulasi klik
                    VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 1)
                    wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 1)
                end
            end
        end
        
        -- Fire minigame remote jika ada
        if Remotes.Minigame then
            if Remotes.Minigame:IsA("RemoteEvent") then
                Remotes.Minigame:FireServer()
            end
        end
        
        if Remotes.Reel then
            if Remotes.Reel:IsA("RemoteEvent") then
                Remotes.Reel:FireServer()
            end
        end
        
        -- Spam klik untuk minigame
        for i = 1, 3 do
            VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 1)
            wait(0.03)
            VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 1)
            wait(0.03)
        end
    end)
end

-- Fungsi Auto Sell
local function SellFish()
    pcall(function()
        if Remotes.Sell then
            if Remotes.Sell:IsA("RemoteEvent") then
                Remotes.Sell:FireServer()
            elseif Remotes.Sell:IsA("RemoteFunction") then
                Remotes.Sell:InvokeServer()
            end
        end
        
        -- Cari NPC sell atau tombol sell
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("TextButton") then
                local text = gui.Text:lower()
                if text:find("sell") and gui.Visible then
                    firesignal(gui.MouseButton1Click)
                    Stats.FishSold = Stats.FishSold + 1
                end
            end
        end
    end)
end

-- Deteksi State Fishing
local function GetFishingState()
    -- Cek apakah ada minigame aktif
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("Frame") or gui:IsA("ScreenGui") then
            local name = gui.Name:lower()
            
            if gui.Visible or (gui:IsA("ScreenGui") and gui.Enabled) then
                if name:find("minigame") or name:find("catch") or name:find("reel") then
                    return "minigame"
                elseif name:find("wait") or name:find("bobber") or name:find("fishing") then
                    return "waiting"
                end
            end
        end
    end
    
    -- Cek berdasarkan tool/rod yang diequip
    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            local name = tool.Name:lower()
            if name:find("rod") or name:find("fish") then
                return "ready"
            end
        end
    end
    
    return "idle"
end

-- ═══════════════════════════════════════
--            MAIN LOOPS
-- ═══════════════════════════════════════

-- Auto Fishing Loop
spawn(function()
    while wait(0.5) do
        if Settings.AutoFish then
            local state = GetFishingState()
            
            if state == "idle" or state == "ready" then
                StatusLabel.Text = "🎣 Status: Casting..."
                CastRod()
                wait(1.5)
                StatusLabel.Text = "⏳ Status: Waiting..."
            end
        end
    end
end)

-- Auto Minigame Loop
spawn(function()
    while wait(0.1) do
        if Settings.AutoFish and Settings.AutoMinigame then
            local state = GetFishingState()
            
            if state == "minigame" then
                StatusLabel.Text = "🎮 Status: Minigame!"
                DoMinigame()
                Stats.FishCaught = Stats.FishCaught + 1
                CounterLabel.Text = "🐟 Fish Caught: " .. Stats.FishCaught
            end
        end
    end
end)

-- Auto Sell Loop
spawn(function()
    while wait(30) do -- Check setiap 30 detik
        if Settings.AutoFish and Settings.AutoSell then
            SellFish()
        end
    end
end)

-- Update Character Reference
player.CharacterAdded:Connect(function(char)
    character = char
end)

-- ═══════════════════════════════════════
--              HOTKEYS
-- ═══════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    -- F5 = Toggle Auto Fish
    if input.KeyCode == Enum.KeyCode.F5 then
        Settings.AutoFish = not Settings.AutoFish
        if Settings.AutoFish then
            StatusLabel.Text = "▶️ Status: Active"
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            StatusLabel.Text = "⏸️ Status: Idle"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        end
    end
    
    -- F6 = Toggle GUI
    if input.KeyCode == Enum.KeyCode.F6 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ═══════════════════════════════════════
--           BUTTON EVENTS
-- ═══════════════════════════════════════

-- Minimize
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    ContentFrame.Visible = not isMinimized
    
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {
        Size = isMinimized and UDim2.new(0, 240, 0, 40) or UDim2.new(0, 240, 0, 340)
    }):Play()
    
    MinimizeBtn.Text = isMinimized and "+" or "−"
end)

-- Close
CloseBtn.MouseButton1Click:Connect(function()
    Settings.AutoFish = false
    ScreenGui:Destroy()
end)

-- ═══════════════════════════════════════
--            NOTIFICATIONS
-- ═══════════════════════════════════════
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "🎣 Fish It! Auto",
        Text = "Script loaded successfully!\nF5 = Toggle | F6 = Hide GUI",
        Duration = 5,
        Icon = "rbxassetid://6023426915"
    })
end)

-- Print Info
print([[
╔═══════════════════════════════════════════╗
║      🎣 FISH IT! AUTO FISH LOADED 🎣      ║
╠═══════════════════════════════════════════╣
║   Hotkeys:                                ║
║   • F5 = Toggle Auto Fish                 ║
║   • F6 = Hide/Show GUI                    ║
║                                           ║
║   Features:                               ║
║   • Auto Cast                             ║
║   • Auto Minigame                         ║
║   • Auto Sell                             ║
║   • Fish Counter                          ║
╚═══════════════════════════════════════════╝
]])

-- Anti AFK
spawn(function()
    while wait(60) do
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)
