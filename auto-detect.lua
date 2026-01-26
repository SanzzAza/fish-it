--[[
    ═══════════════════════════════════════════════════════
    🎣 FISCH AUTO - AUTO DETECT VERSION
    By: SanzzAza
    PlaceId: 121864768012064
    
    Auto deteksi remote events!
    ═══════════════════════════════════════════════════════
]]

repeat wait() until game:IsLoaded()
wait(2)

print("════════════════════════════════════════════════════════")
print("🎣 FISCH AUTO - AUTO DETECT")
print("════════════════════════════════════════════════════════")
print("PlaceId:", game.PlaceId)
print("════════════════════════════════════════════════════════")

-- ════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
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
    
    -- Debug
    ShowDebug = true,
}

local Config = getgenv().FischConfig

getgenv().FischStats = getgenv().FischStats or {
    FishCaught = 0,
    Attempts = 0,
    StartTime = tick(),
}

local Stats = getgenv().FischStats

-- ════════════════════════════════════════════════════════
-- REMOTE DETECTOR
-- ════════════════════════════════════════════════════════
local Remotes = {
    Cast = nil,
    Reel = nil,
    Shake = nil,
}

local function FindRemotes()
    print("🔍 Searching for remotes...")
    
    -- Search patterns
    local patterns = {
        Cast = {"cast", "throw", "fish", "start"},
        Reel = {"reel", "catch", "pull", "finish", "complete"},
        Shake = {"shake", "wiggle", "struggle", "minigame"},
    }
    
    -- Scan ReplicatedStorage
    local function ScanForRemote(folder, remoteType)
        for _, child in pairs(folder:GetDescendants()) do
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                local name = child.Name:lower()
                for _, pattern in pairs(patterns[remoteType]) do
                    if name:find(pattern) then
                        Remotes[remoteType] = child
                        print("  ✅ Found " .. remoteType .. ":", child:GetFullName())
                        return true
                    end
                end
            end
        end
        return false
    end
    
    ScanForRemote(ReplicatedStorage, "Cast")
    ScanForRemote(ReplicatedStorage, "Reel")
    ScanForRemote(ReplicatedStorage, "Shake")
    
    print("════════════════════════════════════════════════════════")
end

FindRemotes()

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

local function Debug(text)
    if Config.ShowDebug then
        print("🐛 " .. text)
    end
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

-- ════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ════════════════════════════════════════════════════════
local function GetRod()
    -- Check equipped
    for _, tool in pairs(Character:GetChildren()) do
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

local function EquipRod()
    local rod = GetRod()
    if rod then
        if rod.Parent == Player.Backpack then
            Humanoid:EquipTool(rod)
            wait(0.5)
            Debug("Rod equipped: " .. rod.Name)
        end
        return true
    else
        Debug("No rod found!")
        return false
    end
end

-- ════════════════════════════════════════════════════════
-- GUI
-- ════════════════════════════════════════════════════════
local function CreateGUI()
    -- Remove old
    pcall(function()
        if Player.PlayerGui:FindFirstChild("FischGUI") then
            Player.PlayerGui.FischGUI:Destroy()
        end
    end)
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FischGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = Player.PlayerGui
    
    local Main = Instance.new("Frame")
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Main.BorderSizePixel = 3
    Main.BorderColor3 = Color3.fromRGB(0, 170, 255)
    Main.Position = UDim2.new(0.02, 0, 0.25, 0)
    Main.Size = UDim2.new(0, 320, 0, 450)
    Main.Active = true
    Main.Draggable = true
    
    -- Title
    local TitleBar = Instance.new("Frame")
    TitleBar.Parent = Main
    TitleBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    
    local Title = Instance.new("TextLabel")
    Title.Parent = TitleBar
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🎣 FISCH AUTO - SanzzAza"
    Title.TextColor3 = Color3.white
    Title.TextSize = 16
    
    -- Info
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Parent = Main
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Position = UDim2.new(0, 10, 0, 50)
    InfoLabel.Size = UDim2.new(1, -20, 0, 40)
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.Text = "PlaceId: " .. game.PlaceId .. "\nStatus: Initializing..."
    InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    InfoLabel.TextSize = 11
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Update status
    spawn(function()
        while wait(1) do
            if not InfoLabel.Parent then break end
            local status = "Idle"
            if IsFishing then status = "Fishing..." end
            InfoLabel.Text = string.format(
                "PlaceId: %s\nStatus: %s\nAttempts: %d",
                game.PlaceId,
                status,
                Stats.Attempts
            )
        end
    end)
    
    -- Toggles
    local yPos = 100
    local function CreateToggle(name, configKey)
        local Button = Instance.new("TextButton")
        Button.Parent = Main
        Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        Button.BorderSizePixel = 0
        Button.Position = UDim2.new(0.08, 0, 0, yPos)
        Button.Size = UDim2.new(0.84, 0, 0, 40)
        Button.Font = Enum.Font.GothamSemibold
        Button.Text = name .. ": " .. (Config[configKey] and "ON" or "OFF")
        Button.TextColor3 = Color3.white
        Button.TextSize = 13
        
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
    CreateToggle("Show Debug", "ShowDebug")
    
    -- Stats
    local StatsLabel = Instance.new("TextLabel")
    StatsLabel.Parent = Main
    StatsLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    StatsLabel.BorderSizePixel = 0
    StatsLabel.Position = UDim2.new(0.08, 0, 0, yPos)
    StatsLabel.Size = UDim2.new(0.84, 0, 0, 70)
    StatsLabel.Font = Enum.Font.GothamMedium
    StatsLabel.Text = "Loading..."
    StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatsLabel.TextSize = 12
    
    spawn(function()
        while wait(1) do
            if not StatsLabel.Parent then break end
            local minutes = math.floor((tick() - Stats.StartTime) / 60)
            StatsLabel.Text = string.format(
                "📊 STATS\n\nFish Caught: %d\nRuntime: %d min",
                Stats.FishCaught,
                minutes
            )
        end
    end)
    
    yPos = yPos + 80
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = Main
    CloseBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Position = UDim2.new(0.08, 0, 0, yPos)
    CloseBtn.Size = UDim2.new(0.84, 0, 0, 35)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "CLOSE"
    CloseBtn.TextColor3 = Color3.white
    CloseBtn.TextSize = 14
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Toggle GUI
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.RightControl then
            Main.Visible = not Main.Visible
        end
    end)
    
    print("✅ GUI Created!")
end

-- ════════════════════════════════════════════════════════
-- FISHING FUNCTIONS
-- ════════════════════════════════════════════════════════
IsFishing = false
local LastCast = 0

local function AutoCast()
    if not Config.AutoCast then return end
    if IsFishing then return end
    if tick() - LastCast < 3 then return end
    
    Stats.Attempts = Stats.Attempts + 1
    
    pcall(function()
        -- Equip rod
        if Config.AutoEquipRod then
            if not EquipRod() then
                Debug("No rod to equip")
                return
            end
        end
        
        -- Try to cast
        if Remotes.Cast then
            Debug("Firing Cast remote")
            Remotes.Cast:FireServer()
            IsFishing = true
            LastCast = tick()
        else
            Debug("Cast remote not found!")
            
            -- Try manual cast (press and hold)
            local rod = GetRod()
            if rod and rod.Parent == Character then
                rod:Activate()
                IsFishing = true
                LastCast = tick()
                Debug("Manual cast activated")
            end
        end
    end)
end

local function AutoReel()
    if not Config.AutoReel then return end
    
    pcall(function()
        -- Check for fishing UI
        local fishingUI = Player.PlayerGui:FindFirstChild("fishing") or
                         Player.PlayerGui:FindFirstChild("FishingUI") or
                         Player.PlayerGui:FindFirstChild("reel")
        
        if fishingUI and fishingUI.Enabled then
            Debug("Fishing UI detected")
            
            wait(0.2)
            
            local quality = Config.PerfectCatch and 100 or math.random(85, 100)
            
            if Remotes.Reel then
                Debug("Firing Reel remote")
                Remotes.Reel:FireServer(quality, true)
                Stats.FishCaught = Stats.FishCaught + 1
                IsFishing = false
                Notify("Fish!", "Caught #" .. Stats.FishCaught)
            else
                Debug("Reel remote not found! Trying alternatives...")
                
                -- Try clicking reel button
                local reelBtn = fishingUI:FindFirstChild("reel", true) or
                               fishingUI:FindFirstChild("button", true)
                
                if reelBtn and reelBtn:IsA("GuiButton") then
                    Debug("Clicking reel button")
                    firesignal(reelBtn.MouseButton1Click)
                    Stats.FishCaught = Stats.FishCaught + 1
                    IsFishing = false
                end
            end
        end
    end)
end

local function AutoShake()
    if not Config.AutoShake then return end
    
    pcall(function()
        local shakeUI = Player.PlayerGui:FindFirstChild("shakeui") or
                       Player.PlayerGui:FindFirstChild("safezone")
        
        if shakeUI and shakeUI.Enabled then
            Debug("Shake UI detected")
            
            if Remotes.Shake then
                Remotes.Shake:FireServer()
            else
                -- Manual shake
                for i = 1, 3 do
                    VirtualInputManager:SendKeyEvent(true, "W", false, game)
                    wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, "W", false, game)
                    wait(0.05)
                end
            end
        end
    end)
end

-- ════════════════════════════════════════════════════════
-- MAIN LOOP
-- ════════════════════════════════════════════════════════
local function StartLoop()
    spawn(function()
        while true do
            wait(0.5)
            
            if not IsFishing then
                AutoCast()
            end
            
            AutoReel()
            AutoShake()
        end
    end)
    
    -- Safety
    spawn(function()
        while true do
            wait(30)
            if IsFishing and (tick() - LastCast > 30) then
                IsFishing = false
                Debug("Reset: Timeout")
            end
        end
    end)
end

-- ════════════════════════════════════════════════════════
-- INITIALIZE
-- ════════════════════════════════════════════════════════
Notify("Loading", "Initializing...")
wait(1)
CreateGUI()
wait(0.5)
StartLoop()
Notify("Ready!", "Script loaded!")

print("════════════════════════════════════════════════════════")
print("✅ SCRIPT LOADED!")
print("════════════════════════════════════════════════════════")
print("Controls: DELETE or RIGHT CTRL to toggle GUI")
print("════════════════════════════════════════════════════════")
