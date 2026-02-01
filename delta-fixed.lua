--[[
    🎣 FISH IT - FULL VERSION 🎣
    Remote Events: Cast, Reel, Sell
    Auto Equip + Auto Fish + Auto Sell
    Tested & Working
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")

--// Services
local VirtualInputManager = game:GetService("VirtualInputManager")

--// Variables
getgenv().Settings = {
    AutoFish = false,
    AutoSell = false,
    KeepMutation = true,
    KeepSecret = true,
    BoostReelSpeed = true,
    AntiAfk = true,
    WalkSpeed = 16,
    AutoEquipRod = true
}

--// Simple UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishItv2"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 420)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Title.Text = "🎣 FISH IT - AUTO FARM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local Corner2 = Instance.new("UICorner")
Corner2.CornerRadius = UDim.new(0, 8)
Corner2.Parent = Title

--// Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 25)
StatusLabel.Position = UDim2.new(0.05, 0, 0.08, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

--// Button Creator
local function CreateButton(text, posY, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.9, 0, 0, 40)
    Btn.Position = UDim2.new(0.05, 0, posY, 0)
    Btn.BackgroundColor3 = color
    Btn.Text = "⬜ " .. text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 14
    Btn.Font = Enum.Font.GothamSemibold
    Btn.Parent = MainFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

--// Anti-AFK
if getgenv().Settings.AntiAfk then
    for _,v in pairs(getconnections(player.Idled)) do 
        v:Disable() 
    end
end

--// ✅ AUTO EQUIP ROD FUNCTION
local function equipRod()
    local backpack = player:WaitForChild("Backpack")
    local character = player.Character or player.CharacterAdded:Wait()
    
    -- Cari rod di backpack
    local rod = nil
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            if tool.Name:lower():find("rod") or 
               tool.Name:lower():find("fishing") or
               tool.Name:lower():find("cane") then
                rod = tool
                break
            end
        end
    end
    
    if rod then
        print("🎣 Equipping rod:", rod.Name)
        rod.Parent = character -- Equip ke character
        task.wait(0.5)
        return true
    else
        warn("❌ Rod tidak ditemukan di backpack!")
        return false
    end
end

--// ✅ OPTIMIZED SELL FUNCTION
local function autoSellFish()
    if not getgenv().Settings.AutoSell then return end
    
    local backpack = player:WaitForChild("Backpack")
    for _, fish in pairs(backpack:GetChildren()) do
        if fish:IsA("Tool") and fish:FindFirstChild("FishRarity") then
            local isMutation = fish:FindFirstChild("Mutation")
            local isSecret = fish:FindFirstChild("Secret")
            
            -- Keep rare items if settings enabled
            if (getgenv().Settings.KeepMutation and isMutation) or 
               (getgenv().Settings.KeepSecret and isSecret) then
                print("💎 Keeping rare fish:", fish.Name)
            else
                -- Sell using InvokeServer (RemoteFunction)
                local success, err = pcall(function()
                    remotes.Sell:InvokeServer(fish)
                end)
                if success then
                    print("💰 Sold:", fish.Name)
                    task.wait(0.2) -- Delay antar jual
                else
                    warn("Failed to sell:", err)
                end
            end
        end
    end
end

--// ✅ MAIN FISHING LOOP - OPTIMIZED
local function startFishing()
    task.spawn(function()
        while getgenv().Settings.AutoFish do
            local success, err = pcall(function()
                -- Check character exists
                local character = player.Character
                if not character then
                    StatusLabel.Text = "Status: Waiting for respawn..."
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
                    task.wait(1)
                    return
                end
                
                -- Check if rod equipped
                local hasRod = false
                for _, tool in pairs(character:GetChildren()) do
                    if tool:IsA("Tool") then
                        hasRod = true
                        break
                    end
                end
                
                if not hasRod then
                    StatusLabel.Text = "Status: Equipping rod..."
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                    
                    if getgenv().Settings.AutoEquipRod then
                        if not equipRod() then
                            task.wait(2)
                            return
                        end
                    else
                        print("⚠️ Rod not equipped!")
                        task.wait(2)
                        return
                    end
                end
                
                -- CASTING
                StatusLabel.Text = "Status: Casting..."
                StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                task.wait(0.3)
                
                remotes.Cast:FireServer()
                print("📤 Cast fired!")
                
                -- Wait for bite
                local waitTime = getgenv().Settings.BoostReelSpeed 
                    and math.random(3, 5)/10 
                    or math.random(7, 10)/10
                task.wait(waitTime)
                
                -- REELING
                StatusLabel.Text = "Status: Reeling..."
                StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                
                remotes.Reel:FireServer()
                print("📥 Reel fired!")
                
                -- Wait animation finish
                task.wait(1.2)
                
                -- Auto Sell
                if getgenv().Settings.AutoSell then
                    StatusLabel.Text = "Status: Selling..."
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
                    autoSellFish()
                end
                
                StatusLabel.Text = "Status: Waiting..."
                StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                task.wait(0.5)
                
            end)
            
            if not success then
                StatusLabel.Text = "Status: Error!"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                print("❌ Error in fishing loop:", err)
                task.wait(2)
            end
        end
        
        StatusLabel.Text = "Status: Stopped"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        print("🛑 Auto Fish stopped")
    end)
end

--// ✅ TOGGLE AUTO FISH BUTTON
local AutoFishBtn = CreateButton("Enable Auto Fish", 0.17, Color3.fromRGB(60, 60, 80), function()
    getgenv().Settings.AutoFish = not getgenv().Settings.AutoFish
    
    if getgenv().Settings.AutoFish then
        AutoFishBtn.Text = "✅ Enable Auto Fish (ON)"
        AutoFishBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        
        -- Auto equip rod first
        if getgenv().Settings.AutoEquipRod then
            equipRod()
        end
        
        startFishing()
        print("🟢 Auto Fish STARTED")
    else
        AutoFishBtn.Text = "⬜ Enable Auto Fish (OFF)"
        AutoFishBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        print("🔴 Auto Fish STOPPED")
    end
end)

--// ✅ EQUIP ROD BUTTON
local EquipBtn = CreateButton("🎣 Equip Rod Now", 0.27, Color3.fromRGB(80, 100, 60), function()
    if equipRod() then
        print("✅ Rod equipped successfully!")
        StatusLabel.Text = "Status: Rod equipped ✅"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        print("❌ Failed to equip rod")
        StatusLabel.Text = "Status: Failed to equip rod ❌"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

--// ✅ TOGGLE AUTO SELL
local AutoSellBtn = CreateButton("Auto Sell (Keep Rare)", 0.37, Color3.fromRGB(80, 60, 60), function()
    getgenv().Settings.AutoSell = not getgenv().Settings.AutoSell
    
    if getgenv().Settings.AutoSell then
        AutoSellBtn.Text = "✅ Auto Sell (Keep Rare) (ON)"
        AutoSellBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 0)
        print("🟢 Auto Sell ENABLED")
    else
        AutoSellBtn.Text = "⬜ Auto Sell (Keep Rare) (OFF)"
        AutoSellBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 60)
        print("🔴 Auto Sell DISABLED")
    end
end)

--// ✅ TOGGLE REEL SPEED
local ReelSpeedBtn = CreateButton("Boost Reel Speed", 0.47, Color3.fromRGB(60, 80, 60), function()
    getgenv().Settings.BoostReelSpeed = not getgenv().Settings.BoostReelSpeed
    
    if getgenv().Settings.BoostReelSpeed then
        ReelSpeedBtn.Text = "✅ Boost Reel Speed (ON)"
        ReelSpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
        print("⚡ Boost Mode ON")
    else
        ReelSpeedBtn.Text = "⬜ Boost Reel Speed (OFF)"
        ReelSpeedBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 60)
        print("⚡ Boost Mode OFF")
    end
end)

--// ✅ TOGGLE AUTO EQUIP
local AutoEquipBtn = CreateButton("Auto Equip Rod", 0.57, Color3.fromRGB(70, 70, 70), function()
    getgenv().Settings.AutoEquipRod = not getgenv().Settings.AutoEquipRod
    
    if getgenv().Settings.AutoEquipRod then
        AutoEquipBtn.Text = "✅ Auto Equip Rod (ON)"
        AutoEquipBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 0)
        print("🟢 Auto Equip ENABLED")
    else
        AutoEquipBtn.Text = "⬜ Auto Equip Rod (OFF)"
        AutoEquipBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        print("🔴 Auto Equip DISABLED")
    end
end)

--// SELL MANUAL BUTTON
CreateButton("💰 SELL ALL NOW", 0.67, Color3.fromRGB(100, 50, 50), function()
    autoSellFish()
    print("💰 Manual sell executed!")
end)

--// WalkSpeed Slider Label
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.9, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0.05, 0, 0.78, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "WalkSpeed: 16"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Parent = MainFrame

--// Speed Buttons
local SpeedMinus = Instance.new("TextButton")
SpeedMinus.Size = UDim2.new(0.2, 0, 0, 30)
SpeedMinus.Position = UDim2.new(0.05, 0, 0.85, 0)
SpeedMinus.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedMinus.Text = "-"
SpeedMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedMinus.TextSize = 18
SpeedMinus.Font = Enum.Font.GothamBold
SpeedMinus.Parent = MainFrame

local Corner_SpeedMinus = Instance.new("UICorner")
Corner_SpeedMinus.CornerRadius = UDim.new(0, 6)
Corner_SpeedMinus.Parent = SpeedMinus

local SpeedValue = Instance.new("TextLabel")
SpeedValue.Size = UDim2.new(0.55, 0, 0, 30)
SpeedValue.Position = UDim2.new(0.27, 0, 0.85, 0)
SpeedValue.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
SpeedValue.Text = "16"
SpeedValue.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedValue.TextSize = 16
SpeedValue.Font = Enum.Font.GothamBold
SpeedValue.Parent = MainFrame

local Corner_SpeedValue = Instance.new("UICorner")
Corner_SpeedValue.CornerRadius = UDim.new(0, 6)
Corner_SpeedValue.Parent = SpeedValue

local SpeedPlus = Instance.new("TextButton")
SpeedPlus.Size = UDim2.new(0.2, 0, 0, 30)
SpeedPlus.Position = UDim2.new(0.75, 0, 0.85, 0)
SpeedPlus.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedPlus.Text = "+"
SpeedPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedPlus.TextSize = 18
SpeedPlus.Font = Enum.Font.GothamBold
SpeedPlus.Parent = MainFrame

local Corner_SpeedPlus = Instance.new("UICorner")
Corner_SpeedPlus.CornerRadius = UDim.new(0, 6)
Corner_SpeedPlus.Parent = SpeedPlus

--// Speed Update Function
local function updateSpeed(change)
    getgenv().Settings.WalkSpeed = math.clamp(getgenv().Settings.WalkSpeed + change, 16, 100)
    SpeedLabel.Text = "WalkSpeed: " .. getgenv().Settings.WalkSpeed
    SpeedValue.Text = tostring(getgenv().Settings.WalkSpeed)
    
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = getgenv().Settings.WalkSpeed
    end
end

SpeedMinus.MouseButton1Click:Connect(function() updateSpeed(-5) end)
SpeedPlus.MouseButton1Click:Connect(function() updateSpeed(5) end)

--// Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

local Corner3 = Instance.new("UICorner")
Corner3.CornerRadius = UDim.new(0, 6)
Corner3.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    getgenv().Settings.AutoFish = false
    ScreenGui:Destroy()
    print("🛑 Script closed")
end)

--// Info Label
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(0.9, 0, 0, 40)
InfoLabel.Position = UDim2.new(0.05, 0, 0.95, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "v2.0 | Auto Equip Ready\nClick 'Equip Rod Now' to start!"
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoLabel.TextSize = 11
InfoLabel.TextWrapped = true
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Parent = MainFrame

--// Character Setup
local function setupCharacter(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = getgenv().Settings.WalkSpeed
    print("👤 Character loaded - WalkSpeed set to " .. getgenv().Settings.WalkSpeed)
end

player.CharacterAdded:Connect(setupCharacter)

if player.Character then
    setupCharacter(player.Character)
end

--// Print startup info
print([[
    ╔═══════════════════════════════════╗
    ║   🎣 FISH IT SCRIPT LOADED 🎣    ║
    ║         Version 2.0 Full          ║
    ╚═══════════════════════════════════╝
    
    ✅ Features:
    - Auto Fish (Cast + Reel)
    - Auto Equip Rod
    - Auto Sell Fish
    - Keep Rare Fish (Mutation/Secret)
    - Boost Reel Speed
    - WalkSpeed Controller
    - Anti-AFK
    
    📝 How to use:
    1. Click 'Equip Rod Now' button
    2. Click 'Enable Auto Fish' to start
    3. Adjust settings as needed
    
    🔧 Remotes used:
    - remotes.Cast:FireServer()
    - remotes.Reel:FireServer()
    - remotes.Sell:InvokeServer(fish)
    
    ═══════════════════════════════════
]])
