--[[
    ═══════════════════════════════════════════════════════
    🎣 FISCH AUTO - DELTA FIXED VERSION
    By: SanzzAza
    With Adjustable Reel Delay & Debug Mode
    ═══════════════════════════════════════════════════════
]]

print("════════════════════════════════════════")
print("🎣 FISCH AUTO - DELTA FIXED")
print("════════════════════════════════════════")

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

print("✅ Services loaded")

-- ════════════════════════════════════════════════════════
-- CONFIG (ADJUSTABLE!)
-- ════════════════════════════════════════════════════════
_G.FischAuto = _G.FischAuto or {}
_G.FischAuto.Config = {
    -- Main Features
    AutoCast = true,
    AutoReel = true,
    AutoShake = true,
    PerfectCatch = true,
    
    -- TIMING (BISA DIUBAH!)
    CastDelay = 3,          -- Delay setelah cast (detik)
    ReelDelay = 0.5,        -- Delay sebelum reel (detik) ← PENTING!
    ReelWaitTime = 1.5,     -- Waktu tunggu detect reel UI (detik)
    ShakeDelay = 0.1,       -- Delay shake (detik)
    
    -- Debug
    DebugMode = true,       -- Show debug messages
    ShowAllUI = false,      -- Show semua UI yang terdetect
}

_G.FischAuto.Stats = {
    FishCaught = 0,
    CastAttempts = 0,
    ReelAttempts = 0,
    StartTime = tick(),
}

local Config = _G.FischAuto.Config
local Stats = _G.FischAuto.Stats

-- ════════════════════════════════════════════════════════
-- NOTIFICATION & DEBUG
-- ════════════════════════════════════════════════════════
local function Notify(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🎣 " .. tostring(title),
            Text = tostring(text),
            Duration = 3,
        })
    end)
    print("📢", title, "-", text)
end

local function Debug(...)
    if Config.DebugMode then
        print("🐛 [DEBUG]", ...)
    end
end

-- ════════════════════════════════════════════════════════
-- ANTI-AFK
-- ════════════════════════════════════════════════════════
Player.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

Debug("Anti-AFK enabled")

-- ════════════════════════════════════════════════════════
-- REMOTE FINDER
-- ════════════════════════════════════════════════════════
local Remotes = {
    Cast = nil,
    Reel = nil,
    Shake = nil,
}

local function FindRemotes()
    Debug("Searching for remotes...")
    
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            
            -- Cast
            if (name:find("cast") or name:find("throw") or name:find("fish")) and not Remotes.Cast then
                Remotes.Cast = v
                Debug("Found Cast:", v:GetFullName())
            end
            
            -- Reel
            if (name:find("reel") or name:find("catch") or name:find("finish")) and not Remotes.Reel then
                Remotes.Reel = v
                Debug("Found Reel:", v:GetFullName())
            end
            
            -- Shake
            if (name:find("shake") or name:find("struggle")) and not Remotes.Shake then
                Remotes.Shake = v
                Debug("Found Shake:", v:GetFullName())
            end
        end
    end
end

FindRemotes()

-- ════════════════════════════════════════════════════════
-- UTILITY
-- ════════════════════════════════════════════════════════
local function GetCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function GetRod()
    local char = GetCharacter()
    
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") and (item.Name:lower():find("rod") or item.Name:lower():find("fishing")) then
            return item
        end
    end
    
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") and (item.Name:lower():find("rod") or item.Name:lower():find("fishing")) then
            return item
        end
    end
    
    return nil
end

local function EquipRod()
    local rod = GetRod()
    if rod and rod.Parent == Player.Backpack then
        local char = GetCharacter()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:EquipTool(rod)
            task.wait(0.5)
            Debug("Rod equipped:", rod.Name)
            return true
        end
    end
    return rod ~= nil
end

-- ════════════════════════════════════════════════════════
-- GUI WITH DELAY CONTROLS
-- ════════════════════════════════════════════════════════
local function CreateGUI()
    Debug("Creating GUI...")
    
    -- Remove old
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui.Name == "FischAutoGUI" then
            gui:Destroy()
        end
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FischAutoGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui
    
    local Main = Instance.new("Frame")
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BorderSizePixel = 3
    Main.BorderColor3 = Color3.fromRGB(0, 170, 255)
    Main.Position = UDim2.new(0.25, 0, 0.2, 0)
    Main.Size = UDim2.new(0, 380, 0, 550)
    Main.Active = true
    Main.Draggable = true
    
    -- Title
    local Title = Instance.new("Frame")
    Title.Parent = Main
    Title.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 50)
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Parent = Title
    TitleText.BackgroundTransparency = 1
    TitleText.Size = UDim2.new(1, 0, 1, 0)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Text = "🎣 FISCH AUTO - DELTA"
    TitleText.TextColor3 = Color3.white
    TitleText.TextSize = 18
    
    -- Info
    local Info = Instance.new("TextLabel")
    Info.Parent = Main
    Info.BackgroundTransparency = 1
    Info.Position = UDim2.new(0, 10, 0, 55)
    Info.Size = UDim2.new(1, -20, 0, 20)
    Info.Font = Enum.Font.Gotham
    Info.Text = "By: SanzzAza | PlaceId: " .. game.PlaceId
    Info.TextColor3 = Color3.fromRGB(150, 150, 150)
    Info.TextSize = 10
    Info.TextXAlignment = Enum.TextXAlignment.Left
    
    local yPos = 85
    
    -- Toggle Function
    local function MakeToggle(name, key)
        local btn = Instance.new("TextButton")
        btn.Parent = Main
        btn.BackgroundColor3 = Config[key] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        btn.BorderSizePixel = 0
        btn.Position = UDim2.new(0.08, 0, 0, yPos)
        btn.Size = UDim2.new(0.84, 0, 0, 40)
        btn.Font = Enum.Font.GothamBold
        btn.Text = name .. ": " .. (Config[key] and "ON" or "OFF")
        btn.TextColor3 = Color3.white
        btn.TextSize = 13
        
        btn.MouseButton1Click:Connect(function()
            Config[key] = not Config[key]
            btn.BackgroundColor3 = Config[key] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
            btn.Text = name .. ": " .. (Config[key] and "ON" or "OFF")
            Notify("Toggle", name .. " " .. (Config[key] and "ON" or "OFF"))
        end)
        
        yPos = yPos + 48
        return btn
    end
    
    -- Toggles
    MakeToggle("Auto Cast", "AutoCast")
    MakeToggle("Auto Reel", "AutoReel")
    MakeToggle("Auto Shake", "AutoShake")
    MakeToggle("Perfect Catch", "PerfectCatch")
    MakeToggle("Debug Mode", "DebugMode")
    
    -- DELAY CONTROLS (SLIDER!)
    local function MakeSlider(labelText, configKey, minVal, maxVal, step)
        local Container = Instance.new("Frame")
        Container.Parent = Main
        Container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Container.BorderSizePixel = 1
        Container.BorderColor3 = Color3.fromRGB(50, 50, 50)
        Container.Position = UDim2.new(0.08, 0, 0, yPos)
        Container.Size = UDim2.new(0.84, 0, 0, 50)
        
        local Label = Instance.new("TextLabel")
        Label.Parent = Container
        Label.BackgroundTransparency = 1
        Label.Position = UDim2.new(0, 5, 0, 5)
        Label.Size = UDim2.new(0.6, 0, 0, 20)
        Label.Font = Enum.Font.GothamMedium
        Label.Text = labelText
        Label.TextColor3 = Color3.white
        Label.TextSize = 11
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Parent = Container
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Position = UDim2.new(0.6, 0, 0, 5)
        ValueLabel.Size = UDim2.new(0.35, 0, 0, 20)
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.Text = string.format("%.1fs", Config[configKey])
        ValueLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
        ValueLabel.TextSize = 12
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        
        -- Buttons
        local MinusBtn = Instance.new("TextButton")
        MinusBtn.Parent = Container
        MinusBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        MinusBtn.BorderSizePixel = 0
        MinusBtn.Position = UDim2.new(0.05, 0, 0, 28)
        MinusBtn.Size = UDim2.new(0.2, 0, 0, 18)
        MinusBtn.Font = Enum.Font.GothamBold
        MinusBtn.Text = "-"
        MinusBtn.TextColor3 = Color3.white
        MinusBtn.TextSize = 14
        
        local PlusBtn = Instance.new("TextButton")
        PlusBtn.Parent = Container
        PlusBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        PlusBtn.BorderSizePixel = 0
        PlusBtn.Position = UDim2.new(0.75, 0, 0, 28)
        PlusBtn.Size = UDim2.new(0.2, 0, 0, 18)
        PlusBtn.Font = Enum.Font.GothamBold
        PlusBtn.Text = "+"
        PlusBtn.TextColor3 = Color3.white
        PlusBtn.TextSize = 14
        
        local CurrentValue = Instance.new("TextLabel")
        CurrentValue.Parent = Container
        CurrentValue.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        CurrentValue.BorderSizePixel = 0
        CurrentValue.Position = UDim2.new(0.28, 0, 0, 28)
        CurrentValue.Size = UDim2.new(0.44, 0, 0, 18)
        CurrentValue.Font = Enum.Font.GothamBold
        CurrentValue.Text = string.format("%.1fs", Config[configKey])
        CurrentValue.TextColor3 = Color3.white
        CurrentValue.TextSize = 11
        
        MinusBtn.MouseButton1Click:Connect(function()
            Config[configKey] = math.max(minVal, Config[configKey] - step)
            ValueLabel.Text = string.format("%.1fs", Config[configKey])
            CurrentValue.Text = string.format("%.1fs", Config[configKey])
            Debug(labelText, "set to", Config[configKey])
        end)
        
        PlusBtn.MouseButton1Click:Connect(function()
            Config[configKey] = math.min(maxVal, Config[configKey] + step)
            ValueLabel.Text = string.format("%.1fs", Config[configKey])
            CurrentValue.Text = string.format("%.1fs", Config[configKey])
            Debug(labelText, "set to", Config[configKey])
        end)
        
        yPos = yPos + 58
    end
    
    -- Delay Sliders
    MakeSlider("Reel Delay", "ReelDelay", 0.1, 5.0, 0.1)
    MakeSlider("Cast Delay", "CastDelay", 1.0, 10.0, 0.5)
    MakeSlider("Reel Wait Time", "ReelWaitTime", 0.5, 5.0, 0.5)
    
    -- Stats
    local Stats = Instance.new("TextLabel")
    Stats.Parent = Main
    Stats.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Stats.BorderSizePixel = 1
    Stats.BorderColor3 = Color3.fromRGB(50, 50, 50)
    Stats.Position = UDim2.new(0.08, 0, 0, yPos)
    Stats.Size = UDim2.new(0.84, 0, 0, 70)
    Stats.Font = Enum.Font.GothamMedium
    Stats.TextColor3 = Color3.fromRGB(200, 200, 200)
    Stats.TextSize = 11
    Stats.Text = "Loading..."
    
    task.spawn(function()
        while task.wait(1) do
            if not Stats.Parent then break end
            local runtime = tick() - _G.FischAuto.Stats.StartTime
            local minutes = math.floor(runtime / 60)
            Stats.Text = string.format(
                "📊 STATS\nFish: %d | Casts: %d\nReels: %d | Time: %dm",
                _G.FischAuto.Stats.FishCaught,
                _G.FischAuto.Stats.CastAttempts,
                _G.FischAuto.Stats.ReelAttempts,
                minutes
            )
        end
    end)
    
    yPos = yPos + 78
    
    -- Close
    local Close = Instance.new("TextButton")
    Close.Parent = Main
    Close.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    Close.BorderSizePixel = 0
    Close.Position = UDim2.new(0.08, 0, 0, yPos)
    Close.Size = UDim2.new(0.84, 0, 0, 35)
    Close.Font = Enum.Font.GothamBold
    Close.Text = "CLOSE"
    Close.TextColor3 = Color3.white
    Close.TextSize = 14
    
    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Toggle
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Delete then
            Main.Visible = not Main.Visible
        end
    end)
    
    Debug("GUI created!")
end

-- ════════════════════════════════════════════════════════
-- FISHING LOGIC
-- ════════════════════════════════════════════════════════
local IsFishing = false
local LastCast = 0

-- AUTO CAST
local function AutoCast()
    if not Config.AutoCast then return end
    if IsFishing then return end
    if tick() - LastCast < Config.CastDelay then return end
    
    task.spawn(function()
        pcall(function()
            Stats.CastAttempts = Stats.CastAttempts + 1
            
            if not EquipRod() then
                Debug("No rod to equip")
                return
            end
            
            task.wait(0.3)
            
            if Remotes.Cast then
                Remotes.Cast:FireServer()
                IsFishing = true
                LastCast = tick()
                Debug("Cast fired! (Remote)")
            else
                local rod = GetRod()
                if rod and rod.Parent == GetCharacter() then
                    rod:Activate()
                    IsFishing = true
                    LastCast = tick()
                    Debug("Cast activated! (Tool)")
                end
            end
        end)
    end)
end

-- AUTO REEL (IMPROVED!)
local function AutoReel()
    if not Config.AutoReel then return end
    
    task.spawn(function()
        pcall(function()
            -- Show all UI if debug
            if Config.ShowAllUI then
                for _, gui in pairs(PlayerGui:GetDescendants()) do
                    if gui:IsA("Frame") or gui:IsA("ScreenGui") then
                        local visible = gui:IsA("ScreenGui") and gui.Enabled or gui.Visible
                        if visible then
                            Debug("UI Found:", gui.Name, "|", gui:GetFullName())
                        end
                    end
                end
            end
            
            -- Look for fishing UI
            local foundUI = false
            
            for _, gui in pairs(PlayerGui:GetDescendants()) do
                local name = gui.Name:lower()
                
                -- Check for fishing-related UI
                if name:find("fishing") or name:find("reel") or name:find("catch") or name:find("bobber") then
                    if gui:IsA("Frame") or gui:IsA("ScreenGui") then
                        local isVisible = false
                        
                        if gui:IsA("ScreenGui") then
                            isVisible = gui.Enabled
                        elseif gui:IsA("Frame") then
                            isVisible = gui.Visible
                        end
                        
                        if isVisible then
                            foundUI = true
                            Stats.ReelAttempts = Stats.ReelAttempts + 1
                            
                            Debug("🐟 REEL UI DETECTED:", gui.Name)
                            Debug("  Path:", gui:GetFullName())
                            Debug("  Waiting", Config.ReelDelay, "seconds before reel...")
                            
                            -- WAIT BEFORE REEL (ADJUSTABLE!)
                            task.wait(Config.ReelDelay)
                            
                            -- Try remote first
                            if Remotes.Reel then
                                local quality = Config.PerfectCatch and 100 or math.random(85, 100)
                                Remotes.Reel:FireServer(quality, true)
                                Stats.FishCaught = Stats.FishCaught + 1
                                IsFishing = false
                                Debug("✅ Reel fired! (Remote) Quality:", quality)
                                Notify("Fish!", "Caught #" .. Stats.FishCaught)
                            else
                                -- Try finding reel button
                                local btn = gui:FindFirstChild("reel", true) or 
                                           gui:FindFirstChild("button", true) or
                                           gui:FindFirstChild("catch", true)
                                
                                if btn and (btn:IsA("TextButton") or btn:IsA("ImageButton")) then
                                    Debug("Clicking reel button:", btn.Name)
                                    
                                    -- Try multiple click methods
                                    pcall(function() btn.MouseButton1Click:Fire() end)
                                    pcall(function() firesignal(btn.MouseButton1Click) end)
                                    pcall(function() btn.Activated:Fire() end)
                                    
                                    Stats.FishCaught = Stats.FishCaught + 1
                                    IsFishing = false
                                    Debug("✅ Button clicked!")
                                    Notify("Fish!", "Caught #" .. Stats.FishCaught)
                                else
                                    Debug("⚠️ No reel button found in UI")
                                end
                            end
                            
                            break
                        end
                    end
                end
            end
            
            if not foundUI and Config.DebugMode then
                -- Debug("No fishing UI detected")
            end
        end)
    end)
end

-- AUTO SHAKE
local function AutoShake()
    if not Config.AutoShake then return end
    
    task.spawn(function()
        pcall(function()
            for _, gui in pairs(PlayerGui:GetDescendants()) do
                local name = gui.Name:lower()
                
                if name:find("shake") or name:find("struggle") or name:find("minigame") then
                    if gui:IsA("Frame") and gui.Visible then
                        Debug("💪 Shake UI detected:", gui.Name)
                        
                        if Remotes.Shake then
                            Remotes.Shake:FireServer()
                            Debug("Shake remote fired")
                        else
                            for i = 1, 4 do
                                VirtualInputManager:SendKeyEvent(true, "W", false, game)
                                task.wait(Config.ShakeDelay)
                                VirtualInputManager:SendKeyEvent(false, "W", false, game)
                                task.wait(Config.ShakeDelay)
                            end
                            Debug("Manual shake completed")
                        end
                        
                        break
                    end
                end
            end
        end)
    end)
end

-- ════════════════════════════════════════════════════════
-- MAIN LOOPS
-- ════════════════════════════════════════════════════════
local function StartLoops()
    Debug("Starting fishing loops...")
    
    -- Cast loop
    task.spawn(function()
        while task.wait(1) do
            AutoCast()
        end
    end)
    
    -- Reel loop (faster check)
    task.spawn(function()
        while task.wait(0.2) do
            AutoReel()
        end
    end)
    
    -- Shake loop
    task.spawn(function()
        while task.wait(0.2) do
            AutoShake()
        end
    end)
    
    -- Safety reset
    task.spawn(function()
        while task.wait(30) do
            if IsFishing and (tick() - LastCast > 30) then
                IsFishing = false
                Debug("🔄 Fishing reset (timeout)")
            end
        end
    end)
    
    Debug("All loops started!")
end

-- ════════════════════════════════════════════════════════
-- INITIALIZE
-- ════════════════════════════════════════════════════════
Notify("Loading", "Initializing...")
task.wait(1)

CreateGUI()
task.wait(0.5)

StartLoops()

Notify("Ready!", "Script loaded! Press DELETE to toggle")

print("════════════════════════════════════════")
print("✅ FISCH AUTO - FULLY LOADED!")
print("════════════════════════════════════════")
print("Remotes Found:")
print("  Cast:", Remotes.Cast and "✅" or "❌")
print("  Reel:", Remotes.Reel and "✅" or "❌")
print("  Shake:", Remotes.Shake and "✅" or "❌")
print("════════════════════════════════════════")
print("Controls:")
print("  DELETE - Toggle GUI")
print("  +/- Buttons - Adjust delays")
print("════════════════════════════════════════")
print("Tips:")
print("  - Enable Debug Mode to see what's happening")
print("  - Increase Reel Delay if catching too fast")
print("  - Check console for debug messages")
print("════════════════════════════════════════")
