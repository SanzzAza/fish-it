--[[
    ═══════════════════════════════════════════════════════
    🎣 FISCH AUTO FISH - MAIN SCRIPT
    By: SanzzAza
    Game: Fisch (Fish It)
    Version: 3.0.0
    ═══════════════════════════════════════════════════════
]]

-- ════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ════════════════════════════════════════════════════════
-- CONFIGURATION
-- ════════════════════════════════════════════════════════
getgenv().FischConfig = getgenv().FischConfig or {
    -- Main Features
    Enabled = true,
    AutoCast = true,
    AutoReel = true,
    AutoShake = true,
    PerfectCatch = true,
    
    -- Timing
    CastDelay = 0.3,
    ReelDelay = 0.15,
    ShakeSpeed = 0.1,
    
    -- Advanced
    AutoSell = false,
    SellInterval = 300,
    AutoEquipRod = true,
    
    -- Anti-Detection
    Randomization = true,
    RandomRange = {0.05, 0.15},
    
    -- UI
    ShowGUI = true,
    ShowNotifications = true,
    GUIKey = Enum.KeyCode.RightControl,
}

local Config = getgenv().FischConfig

-- ════════════════════════════════════════════════════════
-- STATISTICS
-- ════════════════════════════════════════════════════════
getgenv().FischStats = getgenv().FischStats or {
    FishCaught = 0,
    PerfectCatches = 0,
    StartTime = os.time(),
    SessionTime = 0,
}

local Stats = getgenv().FischStats

-- ════════════════════════════════════════════════════════
-- UTILITIES
-- ════════════════════════════════════════════════════════
local Utils = {}

function Utils.Notify(title, text, duration)
    if not Config.ShowNotifications then return end
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🎣 " .. title;
            Text = text;
            Duration = duration or 3;
        })
    end)
end

function Utils.RandomDelay()
    if not Config.Randomization then return 0 end
    local min, max = Config.RandomRange[1], Config.RandomRange[2]
    return math.random() * (max - min) + min
end

function Utils.GetCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

function Utils.GetRod()
    local character = Utils.GetCharacter()
    
    -- Check character
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("rod") or tool.Name:lower():find("fishing")) then
            return tool
        end
    end
    
    -- Check backpack
    for _, tool in pairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("rod") or tool.Name:lower():find("fishing")) then
            return tool
        end
    end
    
    return nil
end

function Utils.EquipRod()
    local rod = Utils.GetRod()
    if rod and rod.Parent == Player.Backpack then
        local character = Utils.GetCharacter()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:EquipTool(rod)
            wait(0.3)
            return true
        end
    end
    return rod ~= nil
end

-- ════════════════════════════════════════════════════════
-- ANTI-AFK
-- ════════════════════════════════════════════════════════
local VU = game:GetService("VirtualUser")
Player.Idled:Connect(function()
    VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- ════════════════════════════════════════════════════════
-- FISHING CORE
-- ════════════════════════════════════════════════════════
local Fishing = {}
Fishing.IsFishing = false
Fishing.LastCast = 0

function Fishing.Cast()
    if not Config.Enabled or not Config.AutoCast then return end
    if Fishing.IsFishing then return end
    if tick() - Fishing.LastCast < 2 then return end
    
    pcall(function()
        -- Equip rod
        if Config.AutoEquipRod then
            if not Utils.EquipRod() then
                return
            end
        end
        
        -- Find and fire cast remote
        local events = ReplicatedStorage:FindFirstChild("events")
        if events then
            local castRemote = events:FindFirstChild("cast")
            if castRemote then
                castRemote:FireServer()
                Fishing.IsFishing = true
                Fishing.LastCast = tick()
            end
        end
        
        wait(Config.CastDelay + Utils.RandomDelay())
    end)
end

function Fishing.Reel()
    if not Config.Enabled or not Config.AutoReel then return end
    
    pcall(function()
        local fishingUI = PlayerGui:FindFirstChild("fishing") or 
                         PlayerGui:FindFirstChild("reel")
        
        if fishingUI and fishingUI.Enabled then
            local reelButton = fishingUI:FindFirstChild("reel") or
                              fishingUI:FindFirstChild("button")
            
            if reelButton and reelButton.Visible then
                wait(Config.ReelDelay + Utils.RandomDelay())
                
                -- Calculate catch quality
                local quality = Config.PerfectCatch and 100 or math.random(85, 100)
                
                -- Fire reel remote
                local events = ReplicatedStorage:FindFirstChild("events")
                if events then
                    local reelRemote = events:FindFirstChild("reelfinished") or
                                     events:FindFirstChild("reel")
                    if reelRemote then
                        reelRemote:FireServer(quality, true)
                        
                        Stats.FishCaught = Stats.FishCaught + 1
                        if quality >= 95 then
                            Stats.PerfectCatches = Stats.PerfectCatches + 1
                        end
                        
                        Fishing.IsFishing = false
                    end
                end
            end
        end
    end)
end

function Fishing.Shake()
    if not Config.Enabled or not Config.AutoShake then return end
    
    pcall(function()
        local shakeUI = PlayerGui:FindFirstChild("shakeui")
        
        if shakeUI and shakeUI.Enabled then
            for i = 1, 3 do
                VirtualInputManager:SendKeyEvent(true, "W", false, game)
                wait(Config.ShakeSpeed)
                VirtualInputManager:SendKeyEvent(false, "W", false, game)
                wait(Config.ShakeSpeed)
            end
        end
    end)
end

-- ════════════════════════════════════════════════════════
-- MAIN LOOP
-- ════════════════════════════════════════════════════════
function Fishing.Start()
    Utils.Notify("Started", "Auto fishing is now active!", 3)
    
    spawn(function()
        while true do
            if Config.Enabled then
                if not Fishing.IsFishing then
                    Fishing.Cast()
                end
                
                Fishing.Reel()
                Fishing.Shake()
            end
            
            Stats.SessionTime = os.time() - Stats.StartTime
            RunService.Heartbeat:Wait()
        end
    end)
    
    -- Safety reset
    spawn(function()
        while true do
            wait(30)
            if Fishing.IsFishing and (tick() - Fishing.LastCast > 30) then
                Fishing.IsFishing = false
            end
        end
    end)
end

-- ════════════════════════════════════════════════════════
-- GUI
-- ════════════════════════════════════════════════════════
local GUI = {}

function GUI.Create()
    -- Remove old
    if game.CoreGui:FindFirstChild("FischAutoGUI") then
        game.CoreGui:FindFirstChild("FischAutoGUI"):Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FischAutoGUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
    MainFrame.Size = UDim2.new(0, 320, 0, 420)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🎣 FISCH AUTO - By SanzzAza"
    Title.TextColor3 = Color3.white
    Title.TextSize = 15
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = Title
    
    -- Create toggle function
    local yPos = 60
    local function CreateToggle(name, configKey)
        local Button = Instance.new("TextButton")
        Button.Parent = MainFrame
        Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        Button.BorderSizePixel = 0
        Button.Position = UDim2.new(0.05, 0, 0, yPos)
        Button.Size = UDim2.new(0.9, 0, 0, 40)
        Button.Font = Enum.Font.Gotham
        Button.Text = name .. ": " .. (Config[configKey] and "ON" or "OFF")
        Button.TextColor3 = Color3.white
        Button.TextSize = 13
        
        local BCorner = Instance.new("UICorner")
        BCorner.CornerRadius = UDim.new(0, 8)
        BCorner.Parent = Button
        
        Button.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
            Button.Text = name .. ": " .. (Config[configKey] and "ON" or "OFF")
        end)
        
        yPos = yPos + 50
    end
    
    CreateToggle("Auto Cast", "AutoCast")
    CreateToggle("Auto Reel", "AutoReel")
    CreateToggle("Auto Shake", "AutoShake")
    CreateToggle("Perfect Catch", "PerfectCatch")
    CreateToggle("Auto Equip Rod", "AutoEquipRod")
    
    -- Stats
    local StatsFrame = Instance.new("Frame")
    StatsFrame.Parent = MainFrame
    StatsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    StatsFrame.BorderSizePixel = 0
    StatsFrame.Position = UDim2.new(0.05, 0, 0, yPos)
    StatsFrame.Size = UDim2.new(0.9, 0, 0, 70)
    
    local SCorner = Instance.new("UICorner")
    SCorner.CornerRadius = UDim.new(0, 8)
    SCorner.Parent = StatsFrame
    
    local StatsLabel = Instance.new("TextLabel")
    StatsLabel.Parent = StatsFrame
    StatsLabel.BackgroundTransparency = 1
    StatsLabel.Size = UDim2.new(1, 0, 1, 0)
    StatsLabel.Font = Enum.Font.GothamMedium
    StatsLabel.TextColor3 = Color3.white
    StatsLabel.TextSize = 12
    
    spawn(function()
        while true do
            wait(1)
            local minutes = math.floor(Stats.SessionTime / 60)
            StatsLabel.Text = string.format(
                "📊 STATS\nFish: %d | Perfect: %d\nTime: %d min",
                Stats.FishCaught,
                Stats.PerfectCatches,
                minutes
            )
        end
    end)
    
    -- Close button
    yPos = yPos + 80
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = MainFrame
    CloseBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Position = UDim2.new(0.05, 0, 0, yPos)
    CloseBtn.Size = UDim2.new(0.9, 0, 0, 35)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "CLOSE"
    CloseBtn.TextColor3 = Color3.white
    CloseBtn.TextSize = 14
    
    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(0, 8)
    CCorner.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Toggle visibility
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Config.GUIKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
end

-- ════════════════════════════════════════════════════════
-- INITIALIZE
-- ════════════════════════════════════════════════════════
if Config.ShowGUI then
    GUI.Create()
end

Fishing.Start()

Utils.Notify("Ready!", "Press Right Ctrl to toggle GUI", 5)

print("════════════════════════════════════════════════════════")
print("🎣 FISCH AUTO - By SanzzAza")
print("✅ Loaded Successfully!")
print("════════════════════════════════════════════════════════")
