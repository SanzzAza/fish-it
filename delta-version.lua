--[[
    ═══════════════════════════════════════════════════════
    🎣 FISCH AUTO - DELTA EXECUTOR VERSION
    By: SanzzAza
    Optimized for Delta Executor
    PlaceId: 121864768012064
    ═══════════════════════════════════════════════════════
]]

print("════════════════════════════════════════")
print("🎣 FISCH AUTO - DELTA VERSION")
print("════════════════════════════════════════")

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ════════════════════════════════════════════════════════
-- SERVICES (Delta Compatible)
-- ════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:FindFirstChildOfClass("PlayerGui") or Player:WaitForChild("PlayerGui")

print("✅ Player:", Player.Name)
print("✅ PlayerGui loaded")

-- ════════════════════════════════════════════════════════
-- CONFIG
-- ════════════════════════════════════════════════════════
_G.FischAuto = _G.FischAuto or {}
_G.FischAuto.Config = {
    AutoCast = true,
    AutoReel = true,
    AutoShake = true,
    PerfectCatch = true,
}

_G.FischAuto.Stats = {
    FishCaught = 0,
    StartTime = tick(),
}

local Config = _G.FischAuto.Config
local Stats = _G.FischAuto.Stats

-- ════════════════════════════════════════════════════════
-- NOTIFICATION (Delta Compatible)
-- ════════════════════════════════════════════════════════
local function Notify(title, text)
    local success = pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🎣 " .. tostring(title),
            Text = tostring(text),
            Duration = 3,
        })
    end)
    
    if success then
        print("📢", title, "-", text)
    else
        print("📢 [NOTIFY]", title, "-", text)
    end
end

-- ════════════════════════════════════════════════════════
-- ANTI-AFK (Delta Compatible)
-- ════════════════════════════════════════════════════════
local VirtualUser = game:GetService("VirtualUser")
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

print("✅ Anti-AFK enabled")

-- ════════════════════════════════════════════════════════
-- GUI CREATION (Delta Optimized)
-- ════════════════════════════════════════════════════════
local function CreateGUI()
    print("🎨 Creating GUI...")
    
    -- Remove old GUI
    task.spawn(function()
        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui.Name == "FischAutoGUI" then
                gui:Destroy()
            end
        end
    end)
    
    task.wait(0.2)
    
    -- Create ScreenGui (Delta uses PlayerGui, NOT CoreGui!)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FischAutoGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = PlayerGui
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 3
    MainFrame.BorderColor3 = Color3.fromRGB(0, 170, 255)
    MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
    MainFrame.Size = UDim2.new(0, 350, 0, 450)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    print("  ✅ MainFrame created")
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Parent = TitleBar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(0.8, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0.05, 0, 0, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "🎣 FISCH AUTO"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 20
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local VersionLabel = Instance.new("TextLabel")
    VersionLabel.Parent = TitleBar
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.Size = UDim2.new(0.2, 0, 1, 0)
    VersionLabel.Position = UDim2.new(0.8, 0, 0, 0)
    VersionLabel.Font = Enum.Font.GothamBold
    VersionLabel.Text = "DELTA"
    VersionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    VersionLabel.TextSize = 12
    
    -- Credit
    local CreditLabel = Instance.new("TextLabel")
    CreditLabel.Parent = MainFrame
    CreditLabel.BackgroundTransparency = 1
    CreditLabel.Position = UDim2.new(0, 10, 0, 55)
    CreditLabel.Size = UDim2.new(1, -20, 0, 20)
    CreditLabel.Font = Enum.Font.Gotham
    CreditLabel.Text = "By: SanzzAza | Delta Executor"
    CreditLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    CreditLabel.TextSize = 11
    CreditLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local PlaceIdLabel = Instance.new("TextLabel")
    PlaceIdLabel.Parent = MainFrame
    PlaceIdLabel.BackgroundTransparency = 1
    PlaceIdLabel.Position = UDim2.new(0, 10, 0, 75)
    PlaceIdLabel.Size = UDim2.new(1, -20, 0, 15)
    PlaceIdLabel.Font = Enum.Font.GothamMedium
    PlaceIdLabel.Text = "PlaceId: " .. game.PlaceId
    PlaceIdLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    PlaceIdLabel.TextSize = 9
    PlaceIdLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    print("  ✅ Title created")
    
    -- Toggle Buttons
    local yPosition = 100
    
    local function CreateToggle(name, configKey)
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Name = configKey
        ToggleButton.Parent = MainFrame
        ToggleButton.BackgroundColor3 = Config[configKey] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Position = UDim2.new(0.08, 0, 0, yPosition)
        ToggleButton.Size = UDim2.new(0.84, 0, 0, 45)
        ToggleButton.Font = Enum.Font.GothamBold
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.TextSize = 14
        ToggleButton.Text = name .. ": " .. (Config[configKey] and "ON" or "OFF")
        
        ToggleButton.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            ToggleButton.BackgroundColor3 = Config[configKey] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
            ToggleButton.Text = name .. ": " .. (Config[configKey] and "ON" or "OFF")
            Notify("Toggle", name .. " " .. (Config[configKey] and "enabled" or "disabled"))
            print("🔄", name, "=", Config[configKey])
        end)
        
        yPosition = yPosition + 55
        return ToggleButton
    end
    
    CreateToggle("Auto Cast", "AutoCast")
    CreateToggle("Auto Reel", "AutoReel")
    CreateToggle("Auto Shake", "AutoShake")
    CreateToggle("Perfect Catch", "PerfectCatch")
    
    print("  ✅ Toggles created")
    
    -- Stats Frame
    local StatsFrame = Instance.new("Frame")
    StatsFrame.Name = "StatsFrame"
    StatsFrame.Parent = MainFrame
    StatsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    StatsFrame.BorderSizePixel = 1
    StatsFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
    StatsFrame.Position = UDim2.new(0.08, 0, 0, yPosition)
    StatsFrame.Size = UDim2.new(0.84, 0, 0, 80)
    
    local StatsLabel = Instance.new("TextLabel")
    StatsLabel.Name = "StatsText"
    StatsLabel.Parent = StatsFrame
    StatsLabel.BackgroundTransparency = 1
    StatsLabel.Size = UDim2.new(1, -10, 1, -10)
    StatsLabel.Position = UDim2.new(0, 5, 0, 5)
    StatsLabel.Font = Enum.Font.GothamMedium
    StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatsLabel.TextSize = 13
    StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatsLabel.TextYAlignment = Enum.TextYAlignment.Top
    StatsLabel.Text = "📊 STATISTICS\n\nFish: 0\nTime: 0 min"
    
    -- Update stats
    task.spawn(function()
        while task.wait(1) do
            if not StatsLabel or not StatsLabel.Parent then break end
            
            local runtime = tick() - Stats.StartTime
            local minutes = math.floor(runtime / 60)
            local seconds = math.floor(runtime % 60)
            
            StatsLabel.Text = string.format(
                "📊 STATISTICS\n\nFish Caught: %d\nRuntime: %d:%02d",
                Stats.FishCaught,
                minutes,
                seconds
            )
        end
    end)
    
    yPosition = yPosition + 90
    
    print("  ✅ Stats created")
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = MainFrame
    CloseButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(0.08, 0, 0, yPosition)
    CloseButton.Size = UDim2.new(0.84, 0, 0, 40)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "✕ CLOSE GUI"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 15
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        Notify("GUI", "Closed")
    end)
    
    print("  ✅ Close button created")
    
    -- Toggle GUI visibility with DELETE key
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Delete then
            MainFrame.Visible = not MainFrame.Visible
            print("🔄 GUI toggled:", MainFrame.Visible)
        end
    end)
    
    print("✅ GUI Created Successfully!")
    return ScreenGui
end

-- ════════════════════════════════════════════════════════
-- REMOTE FINDER (Delta Compatible)
-- ════════════════════════════════════════════════════════
local Remotes = {
    Cast = nil,
    Reel = nil,
    Shake = nil,
}

local function FindRemotes()
    print("🔍 Searching for remotes...")
    
    local patterns = {
        Cast = {"cast", "throw", "start", "fish"},
        Reel = {"reel", "catch", "pull", "finish", "complete"},
        Shake = {"shake", "wiggle", "struggle"},
    }
    
    for _, descendant in pairs(ReplicatedStorage:GetDescendants()) do
        if descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") then
            local name = descendant.Name:lower()
            
            for remoteType, patternList in pairs(patterns) do
                for _, pattern in pairs(patternList) do
                    if name:find(pattern) and not Remotes[remoteType] then
                        Remotes[remoteType] = descendant
                        print("  ✅ Found", remoteType, ":", descendant:GetFullName())
                        break
                    end
                end
            end
        end
    end
    
    print("🔍 Remote search complete")
end

FindRemotes()

-- ════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ════════════════════════════════════════════════════════
local function GetCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function GetRod()
    local character = GetCharacter()
    
    -- Check equipped
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:find("rod") or name:find("fishing") then
                return item
            end
        end
    end
    
    -- Check backpack
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:find("rod") or name:find("fishing") then
                return item
            end
        end
    end
    
    return nil
end

local function EquipRod()
    local rod = GetRod()
    if rod then
        if rod.Parent == Player.Backpack then
            local character = GetCharacter()
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:EquipTool(rod)
                task.wait(0.3)
                print("🎣 Rod equipped:", rod.Name)
            end
        end
        return true
    end
    return false
end

-- ════════════════════════════════════════════════════════
-- FISHING LOGIC (Delta Optimized)
-- ════════════════════════════════════════════════════════
local IsFishing = false
local LastCast = 0

local function AutoCast()
    if not Config.AutoCast then return end
    if IsFishing then return end
    if tick() - LastCast < 3 then return end
    
    task.spawn(function()
        pcall(function()
            -- Equip rod
            if not EquipRod() then
                return
            end
            
            task.wait(0.2)
            
            -- Try casting
            if Remotes.Cast then
                Remotes.Cast:FireServer()
                IsFishing = true
                LastCast = tick()
                print("🎣 Cast fired!")
            else
                -- Fallback: activate tool
                local rod = GetRod()
                if rod and rod.Parent == GetCharacter() then
                    rod:Activate()
                    IsFishing = true
                    LastCast = tick()
                    print("🎣 Rod activated!")
                end
            end
        end)
    end)
end

local function AutoReel()
    if not Config.AutoReel then return end
    
    task.spawn(function()
        pcall(function()
            -- Look for fishing UI
            for _, gui in pairs(PlayerGui:GetDescendants()) do
                local name = gui.Name:lower()
                
                if name == "fishing" or name == "reel" or name == "fishingui" then
                    if gui:IsA("Frame") or gui:IsA("ScreenGui") then
                        local isVisible = false
                        
                        if gui:IsA("ScreenGui") then
                            isVisible = gui.Enabled
                        else
                            isVisible = gui.Visible
                        end
                        
                        if isVisible then
                            print("🐟 Fishing UI detected!")
                            
                            task.wait(0.2)
                            
                            if Remotes.Reel then
                                local quality = Config.PerfectCatch and 100 or math.random(85, 100)
                                Remotes.Reel:FireServer(quality, true)
                                Stats.FishCaught = Stats.FishCaught + 1
                                IsFishing = false
                                print("✅ Fish caught! Total:", Stats.FishCaught)
                                Notify("Fish!", "Caught #" .. Stats.FishCaught)
                            else
                                -- Try clicking button
                                local button = gui:FindFirstChild("reel", true) or gui:FindFirstChild("button", true)
                                if button and button:IsA("GuiButton") then
                                    firesignal(button.MouseButton1Click)
                                    Stats.FishCaught = Stats.FishCaught + 1
                                    IsFishing = false
                                    print("✅ Fish caught (button)! Total:", Stats.FishCaught)
                                end
                            end
                            
                            break
                        end
                    end
                end
            end
        end)
    end)
end

local function AutoShake()
    if not Config.AutoShake then return end
    
    task.spawn(function()
        pcall(function()
            for _, gui in pairs(PlayerGui:GetDescendants()) do
                local name = gui.Name:lower()
                
                if name == "shakeui" or name == "safezone" or name == "minigame" then
                    if gui:IsA("Frame") and gui.Visible then
                        print("💪 Shake UI detected!")
                        
                        if Remotes.Shake then
                            Remotes.Shake:FireServer()
                        else
                            -- Manual shake
                            for i = 1, 4 do
                                VirtualInputManager:SendKeyEvent(true, "W", false, game)
                                task.wait(0.05)
                                VirtualInputManager:SendKeyEvent(false, "W", false, game)
                                task.wait(0.05)
                            end
                        end
                        
                        break
                    end
                end
            end
        end)
    end)
end

-- ════════════════════════════════════════════════════════
-- MAIN LOOP
-- ════════════════════════════════════════════════════════
local function StartFishing()
    print("🎣 Starting fishing loop...")
    
    -- Main fishing loop
    task.spawn(function()
        while task.wait(1) do
            AutoCast()
        end
    end)
    
    -- Reel check loop
    task.spawn(function()
        while task.wait(0.5) do
            AutoReel()
        end
    end)
    
    -- Shake check loop
    task.spawn(function()
        while task.wait(0.3) do
            AutoShake()
        end
    end)
    
    -- Safety reset
    task.spawn(function()
        while task.wait(30) do
            if IsFishing and (tick() - LastCast > 30) then
                IsFishing = false
                print("🔄 Fishing state reset (timeout)")
            end
        end
    end)
    
    print("✅ Fishing loops started!")
end

-- ════════════════════════════════════════════════════════
-- INITIALIZE
-- ════════════════════════════════════════════════════════
Notify("Loading", "Initializing script...")
print("🔧 Initializing...")

task.wait(1)

local gui = CreateGUI()
if gui then
    print("✅ GUI initialized")
    Notify("GUI", "Loaded successfully!")
else
    warn("❌ Failed to create GUI")
end

task.wait(0.5)

StartFishing()
Notify("Ready!", "Script is running!")

print("════════════════════════════════════════")
print("✅ FISCH AUTO - FULLY LOADED!")
print("════════════════════════════════════════")
print("Controls:")
print("  DELETE - Toggle GUI visibility")
print("  Drag title bar to move GUI")
print("════════════════════════════════════════")
print("Status:")
print("  Cast Remote:", Remotes.Cast and "✅ Found" or "❌ Not found")
print("  Reel Remote:", Remotes.Reel and "✅ Found" or "❌ Not found")
print("  Shake Remote:", Remotes.Shake and "✅ Found" or "❌ Not found")
print("════════════════════════════════════════")
