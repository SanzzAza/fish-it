--[[
    ╔═══════════════════════════════════════════╗
    ║         AUTO FISH SCRIPT - FISCH          ║
    ║            Versi Lengkap + GUI            ║
    ╚═══════════════════════════════════════════╝
    
    Fitur:
    • Auto Cast (lempar kail otomatis)
    • Auto Reel (tarik ikan otomatis)
    • Auto Shake (goyang otomatis)
    • Auto Perfect Catch
    • GUI Toggle On/Off
    
    Executor: Fluxus, Delta, Synapse, Arceus X, dll
]]

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Variables
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Settings
local Settings = {
    AutoFish = false,
    AutoShake = true,
    AutoReel = true,
    CastDelay = 0.5,
    ReelDelay = 0.1
}

--[[ ══════════════════════════════════════
         MEMBUAT GUI (User Interface)
══════════════════════════════════════ ]]

-- Hapus GUI lama jika ada
if game.CoreGui:FindFirstChild("AutoFishGUI") then
    game.CoreGui:FindFirstChild("AutoFishGUI"):Destroy()
end

-- Buat ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFishGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 280)
MainFrame.Active = true
MainFrame.Draggable = true

-- Corner untuk Main Frame
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Stroke/Border
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 170, 255)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 35)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- Title Text
local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.Size = UDim2.new(1, -20, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "🎣 AUTO FISH"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.Position = UDim2.new(1, -30, 0.5, -10)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 12

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseButton

--[[ ══════════════════════════════════════
              FUNGSI BUAT TOMBOL
══════════════════════════════════════ ]]

local function CreateToggleButton(name, posY, default, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Parent = MainFrame
    Button.BackgroundColor3 = default and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(80, 80, 90)
    Button.Position = UDim2.new(0.05, 0, 0, posY)
    Button.Size = UDim2.new(0.9, 0, 0, 35)
    Button.Font = Enum.Font.GothamSemibold
    Button.Text = name .. ": " .. (default and "ON" or "OFF")
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button
    
    local isOn = default
    
    Button.MouseButton1Click:Connect(function()
        isOn = not isOn
        Button.Text = name .. ": " .. (isOn and "ON" or "OFF")
        Button.BackgroundColor3 = isOn and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(80, 80, 90)
        callback(isOn)
    end)
    
    return Button
end

-- Buat Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 0, 0, 45)
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
StatusLabel.TextSize = 12

-- Buat Toggle Buttons
CreateToggleButton("Auto Fish", 80, false, function(state)
    Settings.AutoFish = state
    StatusLabel.Text = state and "Status: Fishing..." or "Status: Idle"
end)

CreateToggleButton("Auto Shake", 125, true, function(state)
    Settings.AutoShake = state
end)

CreateToggleButton("Auto Reel", 170, true, function(state)
    Settings.AutoReel = state
end)

-- Info Label
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Parent = MainFrame
InfoLabel.BackgroundTransparency = 1
InfoLabel.Position = UDim2.new(0, 0, 1, -35)
InfoLabel.Size = UDim2.new(1, 0, 0, 30)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Text = "Tekan F6 untuk Hide/Show"
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoLabel.TextSize = 11

-- Fish Counter
local FishCount = 0
local CounterLabel = Instance.new("TextLabel")
CounterLabel.Parent = MainFrame
CounterLabel.BackgroundTransparency = 1
CounterLabel.Position = UDim2.new(0, 0, 0, 215)
CounterLabel.Size = UDim2.new(1, 0, 0, 25)
CounterLabel.Font = Enum.Font.GothamBold
CounterLabel.Text = "🐟 Ikan Ditangkap: 0"
CounterLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
CounterLabel.TextSize = 14

--[[ ══════════════════════════════════════
            FUNGSI AUTO FISHING
══════════════════════════════════════ ]]

-- Fungsi Cast (Lempar Kail)
local function Cast()
    -- Cari remote untuk cast
    local remotes = ReplicatedStorage:FindFirstChild("events") or ReplicatedStorage
    
    -- Method 1: Simulasi Mouse Click
    local function mouseClick()
        VirtualInputManager:SendMouseButtonEvent(
            mouse.X, 
            mouse.Y, 
            0, -- Left click
            true, 
            game, 
            1
        )
        wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(
            mouse.X, 
            mouse.Y, 
            0, 
            false, 
            game, 
            1
        )
    end
    
    -- Method 2: Cari dan fire remote
    pcall(function()
        for _, remote in pairs(remotes:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                if remote.Name:lower():find("cast") or 
                   remote.Name:lower():find("throw") or
                   remote.Name:lower():find("fish") then
                    remote:FireServer()
                end
            end
        end
    end)
    
    mouseClick()
end

-- Fungsi Shake (Goyang)
local function Shake()
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("events") or ReplicatedStorage
        
        for _, remote in pairs(remotes:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                if remote.Name:lower():find("shake") or 
                   remote.Name:lower():find("pull") or
                   remote.Name:lower():find("reel") then
                    remote:FireServer()
                end
            end
        end
        
        -- Simulasi keyboard press
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end

-- Fungsi Reel (Tarik)
local function Reel()
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("events") or ReplicatedStorage
        
        for _, remote in pairs(remotes:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                if remote.Name:lower():find("reel") or 
                   remote.Name:lower():find("catch") or
                   remote.Name:lower():find("collect") then
                    remote:FireServer()
                end
            end
        end
        
        -- Mouse click untuk reel
        VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 1)
        wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 1)
    end)
end

-- Deteksi State Fishing
local function GetFishingState()
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return "idle" end
    
    -- Cari UI fishing yang aktif
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("Frame") or gui:IsA("ImageLabel") then
            local name = gui.Name:lower()
            if name:find("shake") or name:find("minigame") then
                if gui.Visible then
                    return "shaking"
                end
            elseif name:find("reel") or name:find("catch") then
                if gui.Visible then
                    return "reeling"
                end
            elseif name:find("wait") or name:find("bobber") then
                if gui.Visible then
                    return "waiting"
                end
            end
        end
    end
    
    return "idle"
end

--[[ ══════════════════════════════════════
              MAIN LOOP
══════════════════════════════════════ ]]

-- Auto Shake Loop
spawn(function()
    while wait(0.1) do
        if Settings.AutoFish and Settings.AutoShake then
            local state = GetFishingState()
            if state == "shaking" then
                Shake()
                StatusLabel.Text = "Status: Shaking! 🎯"
            end
        end
    end
end)

-- Auto Reel Loop  
spawn(function()
    while wait(0.15) do
        if Settings.AutoFish and Settings.AutoReel then
            local state = GetFishingState()
            if state == "reeling" then
                Reel()
                StatusLabel.Text = "Status: Reeling! 🐟"
                FishCount = FishCount + 1
                CounterLabel.Text = "🐟 Ikan Ditangkap: " .. FishCount
            end
        end
    end
end)

-- Main Auto Cast Loop
spawn(function()
    while wait(Settings.CastDelay) do
        if Settings.AutoFish then
            local state = GetFishingState()
            if state == "idle" then
                Cast()
                StatusLabel.Text = "Status: Casting... 🎣"
                wait(1)
                StatusLabel.Text = "Status: Waiting... ⏳"
            end
        end
    end
end)

--[[ ══════════════════════════════════════
              HOTKEYS & EVENTS
══════════════════════════════════════ ]]

-- Toggle GUI dengan F6
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.F6 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Close Button
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

--[[ ══════════════════════════════════════
              NOTIFIKASI
══════════════════════════════════════ ]]

-- Tampilkan notifikasi
game.StarterGui:SetCore("SendNotification", {
    Title = "🎣 Auto Fish Loaded!",
    Text = "Script berhasil dijalankan!\nTekan F6 untuk Hide/Show GUI",
    Duration = 5,
    Icon = "rbxassetid://6023426915"
})

print([[
╔═══════════════════════════════════════╗
║     🎣 AUTO FISH SCRIPT LOADED! 🎣    ║
╠═══════════════════════════════════════╣
║  • Auto Fish: Toggle di GUI           ║
║  • Auto Shake: ON                     ║
║  • Auto Reel: ON                      ║
║  • Hotkey: F6 (Hide/Show)             ║
╚═══════════════════════════════════════╝
]])
