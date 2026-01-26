--[[
    ═══════════════════════════════════════════════════════
    🎣 FISCH AUTO FISH - UNIVERSAL
    By: SanzzAza
    Works on ALL Fisch servers!
    ═══════════════════════════════════════════════════════
]]

-- Skip game verification, langsung jalan!
repeat wait() until game:IsLoaded()
wait(2)

print("════════════════════════════════════════════════════════")
print("🎣 FISCH AUTO - UNIVERSAL VERSION")
print("════════════════════════════════════════════════════════")
print("Game:", game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
print("PlaceId:", game.PlaceId)
print("════════════════════════════════════════════════════════")

-- ════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- ════════════════════════════════════════════════════════
-- WAIT FOR CHARACTER
-- ════════════════════════════════════════════════════════
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- ════════════════════════════════════════════════════════
-- CONFIG
-- ════════════════════════════════════════════════════════
getgenv().FischConfig = getgenv().FischConfig or {
    AutoCast = true,
    AutoReel = true,
    AutoShake = true,
    PerfectCatch = true,
    AutoEquipRod = true,
}

local Config = getgenv().FischConfig

getgenv().FischStats = getgenv().FischStats or {
    FishCaught = 0,
    PerfectCatches = 0,
    StartTime = tick(),
}

local Stats = getgenv().FischStats

-- ════════════════════════════════════════════════════════
-- NOTIFICATION
-- ════════════════════════════════════════════════════════
local function Notify(title, text)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "🎣 " .. title;
            Text = text;
            Duration = 3;
        })
    end)
end

-- ════════════════════════════════════════════════════════
-- ANTI-AFK
-- ════════════════════════════════════════════════════════
local vu = game:GetService("VirtualUser")
Player.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

print("✅ Anti-AFK Active")

-- ════════════════════════════════════════════════════════
-- AUTO EQUIP ROD
-- ════════════════════════════════════════════════════════
local function GetRod()
    -- Check character
    for _, tool in pairs(Character:GetChildren()) do
        if tool:IsA("Tool") then
            if tool.Name:lower():find("rod") or tool.Name:lower():find("fishing") then
                return tool
            end
        end
    end
    
    -- Check backpack
    for _, tool in pairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            if tool.Name:lower():find("rod") or tool.Name:lower():find("fishing") then
                return tool
            end
        end
    end
    
    return nil
end

local function EquipRod()
    if not Config.AutoEquipRod then return false end
    
    local rod = GetRod()
    if rod and rod.Parent == Player.Backpack then
        Humanoid:EquipTool(rod)
        wait(0.5)
        return true
    end
    return rod ~= nil
end

-- ════════════════════════════════════════════════════════
-- GUI
-- ════════════════════════════════════════════════════════
local function CreateGUI()
    print("🎨 Creating GUI...")
    
    -- Remove old GUI
    pcall(function()
        if Player.PlayerGui:FindFirstChild("FischGUI") then
            Player.PlayerGui.FischGUI:Destroy()
        end
    end)
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FischGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = Player.PlayerGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.AnchorPoint = Vector2.new(0, 0)
    Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Main.BorderSizePixel = 3
    Main.BorderColor3 = Color3.fromRGB(0, 170, 255)
    Main.Position = UDim2.new(0.05, 0, 0.25, 0)
    Main.Size = UDim2.new(0, 300, 0, 380)
    Main.Active = true
    Main.Draggable = true
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Parent = Main
    TitleBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    
    local Title = Instance.new("TextLabel")
    Title.Parent = TitleBar
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(0.7, 0, 1, 0)
    Title.Position = UDim2.new(0.05, 0, 0, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🎣 FISCH AUTO"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local Version = Instance.new("TextLabel")
    Version.Parent = TitleBar
    Version.BackgroundTransparency = 1
    Version.Size = UDim2.new(0.25, 0, 1, 0)
    Version.Position = UDim2.new(0.75, 0, 0, 0)
    Version.Font = Enum.Font.GothamBold
    Version.Text = "v1.0"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Version.TextSize = 14
    
    -- Credit
    local Credit = Instance.new("TextLabel")
    Credit.Parent = Main
    Credit.BackgroundTransparency = 1
    Credit.Position = UDim2.new(0, 0, 0, 45)
    Credit.Size = UDim2.new(1, 0, 0, 20)
    Credit.Font = Enum.Font.Gotham
    Credit.Text = "By: SanzzAza"
    Credit.TextColor3 = Color3.fromRGB(150, 150, 150)
    Credit.TextSize = 12
    
    -- PlaceId Display
    local PlaceIdLabel = Instance.new("TextLabel")
    PlaceIdLabel.Parent = Main
    PlaceIdLabel.BackgroundTransparency = 1
    PlaceIdLabel.Position = UDim2.new(0, 0, 0, 65)
    PlaceIdLabel.Size = UDim2.new(1, 0, 0, 15)
    PlaceIdLabel.Font = Enum.Font.GothamMedium
    PlaceIdLabel.Text = "PlaceId: " .. game.PlaceId
    PlaceIdLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    PlaceIdLabel.TextSize = 10
    
    -- Toggles
    local yPos = 90
    local function CreateToggle(name, configKey)
        local Container = Instance.new("Frame")
        Container.Parent = Main
        Container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Container.BorderSizePixel = 0
        Container.Position = UDim2.new(0.08, 0, 0, yPos)
        Container.Size = UDim2.new(0.84, 0, 0, 40)
        
        local Button = Instance.new("TextButton")
        Button.Parent = Container
        Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.Font = Enum.Font.GothamSemibold
        Button.Text = name
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 14
        
        local Status = Instance.new("TextLabel")
        Status.Parent = Button
        Status.BackgroundTransparency = 1
        Status.Position = UDim2.new(0.65, 0, 0, 0)
        Status.Size = UDim2.new(0.35, 0, 1, 0)
        Status.Font = Enum.Font.GothamBold
        Status.Text = Config[configKey] and "ON" or "OFF"
        Status.TextColor3 = Color3.fromRGB(255, 255, 255)
        Status.TextSize = 14
        
        Button.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
            Status.Text = Config[configKey] and "ON" or "OFF"
            Notify("Toggle", name .. " " .. (Config[configKey] and "enabled" or "disabled"))
        end)
        
        yPos = yPos + 48
    end
    
    CreateToggle("Auto Cast", "AutoCast")
    CreateToggle("Auto Reel", "AutoReel")
    CreateToggle("Auto Shake", "AutoShake")
    CreateToggle("Perfect Catch", "PerfectCatch")
    CreateToggle("Auto Equip Rod", "AutoEquipRod")
    
    -- Stats
    local StatsFrame = Instance.new("Frame")
    StatsFrame.Parent = Main
    StatsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    StatsFrame.BorderSizePixel = 0
    StatsFrame.Position = UDim2.new(0.08, 0, 0, yPos)
    StatsFrame.Size = UDim2.new(0.84, 0, 0, 65)
    
    local StatsLabel = Instance.new("TextLabel")
    StatsLabel.Parent = StatsFrame
    StatsLabel.BackgroundTransparency = 1
    StatsLabel.Size = UDim2.new(1, -10, 1, -10)
    StatsLabel.Position = UDim2.new(0, 5, 0, 5)
    StatsLabel.Font = Enum.Font.GothamMedium
    StatsLabel.Text = "Loading stats..."
    StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatsLabel.TextSize = 12
    StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatsLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    spawn(function()
        while wait(1) do
            if not StatsLabel or not StatsLabel.Parent then break end
            local runtime = tick() - Stats.StartTime
            local minutes = math.floor(runtime / 60)
            local seconds = math.floor(runtime % 60)
            StatsLabel.Text = string.format(
                "📊 STATS\nFish: %d | Perfect: %d\nTime: %02d:%02d",
                Stats.FishCaught,
                Stats.PerfectCatches,
                minutes,
                seconds
            )
        end
    end)
    
    yPos = yPos + 73
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Parent = Main
    CloseButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(0.08, 0, 0, yPos)
    CloseButton.Size = UDim2.new(0.84, 0, 0, 35)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "✕ CLOSE"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Toggle visibility
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.RightControl then
            Main.Visible = not Main.Visible
        end
    end)
    
    print("✅ GUI Created Successfully!")
    Notify("Ready", "GUI loaded! Press DEL to toggle")
end

-- ════════════════════════════════════════════════════════
-- FISHING LOGIC
-- ════════════════════════════════════════════════════════
local IsFishing = false
local LastCast = 0

local function AutoCast()
    if not Config.AutoCast then return end
    if IsFishing then return end
    if tick() - LastCast < 3 then return end
    
    pcall(function()
        -- Auto equip rod
        EquipRod()
        
        -- Find cast remote
        local events = ReplicatedStorage:FindFirstChild("events")
        if events then
            local castRemote = events:FindFirstChild("cast")
            if castRemote then
                castRemote:FireServer()
                IsFishing = true
                LastCast = tick()
                print("🎣 Cast rod")
            end
        end
    end)
end

local function AutoReel()
    if not Config.AutoReel then return end
    
    pcall(function()
        local fishingUI = Player.PlayerGui:FindFirstChild("fishing")
        
        if fishingUI and fishingUI.Enabled then
            local reelBar = fishingUI:FindFirstChild("reel")
            
            if reelBar and reelBar.Visible then
                wait(0.15)
                
                local quality = Config.PerfectCatch and 100 or math.random(85, 100)
                
                local events = ReplicatedStorage:FindFirstChild("events")
                if events then
                    local reelRemote = events:FindFirstChild("reelfinished") or events:FindFirstChild("reel")
                    if reelRemote then
                        reelRemote:FireServer(quality, true)
                        
                        Stats.FishCaught = Stats.FishCaught + 1
                        if quality >= 95 then
                            Stats.PerfectCatches = Stats.PerfectCatches + 1
                        end
                        
                        IsFishing = false
                        print("🐟 Fish caught! Total:", Stats.FishCaught)
                    end
                end
            end
        end
    end)
end

local function AutoShake()
    if not Config.AutoShake then return end
    
    pcall(function()
        local shakeUI = Player.PlayerGui:FindFirstChild("shakeui")
        
        if shakeUI and shakeUI.Enabled then
            for i = 1, 3 do
                VirtualInputManager:SendKeyEvent(true, "W", false, game)
                wait(0.05)
                VirtualInputManager:SendKeyEvent(false, "W", false, game)
                wait(0.05)
            end
            print("💪 Shake completed")
        end
    end)
end

-- ════════════════════════════════════════════════════════
-- MAIN LOOP
-- ════════════════════════════════════════════════════════
local function StartLoop()
    print("🎣 Starting fishing loop...")
    
    spawn(function()
        while true do
            wait(0.5)
            AutoCast()
            AutoReel()
            AutoShake()
        end
    end)
    
    -- Safety reset
    spawn(function()
        while true do
            wait(30)
            if IsFishing and (tick() - LastCast > 30) then
                IsFishing = false
                print("🔄 Fishing state reset")
            end
        end
    end)
    
    print("✅ Fishing loop started!")
end

-- ════════════════════════════════════════════════════════
-- INITIALIZE
-- ════════════════════════════════════════════════════════
Notify("Loading", "Initializing script...")

wait(1)
CreateGUI()
wait(0.5)
StartLoop()

Notify("Ready!", "Script loaded successfully!")

print("════════════════════════════════════════════════════════")
print("✅ FISCH AUTO LOADED!")
print("════════════════════════════════════════════════════════")
print("Controls:")
print("  - DELETE or RIGHT CTRL: Toggle GUI")
print("  - Drag title bar to move GUI")
print("════════════════════════════════════════════════════════")
