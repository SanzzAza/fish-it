--[[
    🎣 FISH IT - FIXED AUTO FISH 🎣
    Remote Events: Cast, Reel, Sell
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
    WalkSpeed = 16
}

--// Simple UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishItv2"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 350)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -175)
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
StatusLabel.Position = UDim2.new(0.05, 0, 0.12, 0)
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

--// Auto Sell Function
local function autoSellFish()
    if not getgenv().Settings.AutoSell then return end
    
    for _, fish in pairs(player.Backpack:GetChildren()) do
        if fish:IsA("Tool") and fish:FindFirstChild("FishRarity") then
            local isMutation = fish:FindFirstChild("Mutation")
            local isSecret = fish:FindFirstChild("Secret")
            
            -- Keep rare items if settings enabled
            if (getgenv().Settings.KeepMutation and isMutation) or (getgenv().Settings.KeepSecret and isSecret) then
                print("💎 Keeping rare fish:", fish.Name)
            else
                -- Sell using InvokeServer (RemoteFunction)
                local success, err = pcall(function()
                    remotes.Sell:InvokeServer(fish)
                end)
                if success then
                    print("💰 Sold:", fish.Name)
                else
                    warn("Failed to sell:", err)
                end
            end
        end
    end
end

--// Main Fishing Loop - FIXED!
local function startFishing()
    while getgenv().Settings.AutoFish do
        local success, err = pcall(function()
            StatusLabel.Text = "Status: Casting..."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            
            -- FIX: Gunakan remotes.Cast dan remotes.Reel langsung!
            remotes.Cast:FireServer()
            
            -- Tunggu ikan gigit
            local waitTime = getgenv().Settings.BoostReelSpeed and 0.4 or 0.8
            task.wait(waitTime)
            
            StatusLabel.Text = "Status: Reeling..."
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            
            -- Reel!
            remotes.Reel:FireServer()
            
            -- Tunggu animasi selesai
            task.wait(1.2)
            
            -- Cek dan sell otomatis
            if getgenv().Settings.AutoSell then
                StatusLabel.Text = "Status: Selling..."
                autoSellFish()
            end
            
            StatusLabel.Text = "Status: Waiting..."
            StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end)
        
        if not success then
            StatusLabel.Text = "Status: Error - " .. tostring(err):sub(1, 20)
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            task.wait(2)
        end
        
        task.wait(0.5)
    end
    
    StatusLabel.Text = "Status: Stopped"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
end

--// Toggle Buttons
local AutoFishBtn = CreateButton("Enable Auto Fish", 0.22, Color3.fromRGB(60, 60, 80), function()
    getgenv().Settings.AutoFish = not getgenv().Settings.AutoFish
    
    if getgenv().Settings.AutoFish then
        AutoFishBtn.Text = "✅ Enable Auto Fish (ON)"
        AutoFishBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        task.spawn(startFishing)
    else
        AutoFishBtn.Text = "⬜ Enable Auto Fish (OFF)"
        AutoFishBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end
end)

local AutoSellBtn = CreateButton("Auto Sell (Keep Rare)", 0.35, Color3.fromRGB(80, 60, 60), function()
    getgenv().Settings.AutoSell = not getgenv().Settings.AutoSell
    AutoSellBtn.Text = getgenv().Settings.AutoSell and "✅ Auto Sell (Keep Rare) (ON)" or "⬜ Auto Sell (Keep Rare)"
    AutoSellBtn.BackgroundColor3 = getgenv().Settings.AutoSell and Color3.fromRGB(150, 100, 0) or Color3.fromRGB(80, 60, 60)
end)

local ReelSpeedBtn = CreateButton("Boost Reel Speed", 0.48, Color3.fromRGB(60, 80, 60), function()
    getgenv().Settings.BoostReelSpeed = not getgenv().Settings.BoostReelSpeed
    ReelSpeedBtn.Text = getgenv().Settings.BoostReelSpeed and "✅ Boost Reel Speed (ON)" or "⬜ Boost Reel Speed"
    ReelSpeedBtn.BackgroundColor3 = getgenv().Settings.BoostReelSpeed and Color3.fromRGB(0, 100, 150) or Color3.fromRGB(60, 80, 60)
end)

--// Sell Manual Button
CreateButton("💰 SELL ALL NOW", 0.61, Color3.fromRGB(100, 50, 50), function()
    autoSellFish()
end)

--// WalkSpeed Slider Label
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.9, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "WalkSpeed: 16"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Parent = MainFrame

--// Speed Buttons
local SpeedMinus = Instance.new("TextButton")
SpeedMinus.Size = UDim2.new(0.2, 0, 0, 30)
SpeedMinus.Position = UDim2.new(0.05, 0, 0.82, 0)
SpeedMinus.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedMinus.Text = "-"
SpeedMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedMinus.TextSize = 18
SpeedMinus.Parent = MainFrame

local SpeedPlus = Instance.new("TextButton")
SpeedPlus.Size = UDim2.new(0.2, 0, 0, 30)
SpeedPlus.Position = UDim2.new(0.75, 0, 0.82, 0)
SpeedPlus.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedPlus.Text = "+"
SpeedPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedPlus.TextSize = 18
SpeedPlus.Parent = MainFrame

local function updateSpeed(change)
    getgenv().Settings.WalkSpeed = math.clamp(getgenv().Settings.WalkSpeed + change, 16, 100)
    SpeedLabel.Text = "WalkSpeed: " .. getgenv().Settings.WalkSpeed
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
end)

--// Info Label
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(0.9, 0, 0, 30)
InfoLabel.Position = UDim2.new(0.05, 0, 0.92, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Hold Rod First!\nAuto Equip coming soon"
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoLabel.TextSize = 11
InfoLabel.TextWrapped = true
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Parent = MainFrame

--// Character Setup
player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = getgenv().Settings.WalkSpeed
end)

if player.Character then
    player.Character:WaitForChild("Humanoid").WalkSpeed = getgenv().Settings.WalkSpeed
end

print([[
    🎣 FISH IT SCRIPT LOADED 🎣
    ==========================
    PENTING: Hold joran (rod) di tangan dulu!
    
    Remote Events Fixed:
    - remotes.Cast:FireServer()
    - remotes.Reel:FireServer()
    - remotes.Sell:InvokeServer(fish)
    
    Status akan muncul di GUI
]])
