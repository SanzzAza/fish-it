--[[
    🎣 FISH IT - FIXED MENU VERSION 🎣
    Menu dijamin muncul + Auto Fish
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remotes = nil

-- Tunggu remotes loading
print("⏳ Waiting for remotes...")
task.wait(2)
remotes = ReplicatedStorage:WaitForChild("Remotes", 10)

if not remotes then
    warn("❌ Remotes not found! Script may not work properly")
end

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

print("✅ Creating UI...")

-- ==========================================
-- 🎨 CREATE UI - SIMPLE & CLEAN
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishItUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndex = 999

-- ⚠️ PENTING: Parent ke CoreGui LANGSUNG
ScreenGui.Parent = game:GetService("CoreGui")

print("✅ ScreenGui created and parented")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 500)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.CanCollide = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 1000
MainFrame.Parent = ScreenGui

print("✅ MainFrame created")

-- Corner untuk main frame
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 1001
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- Title Text
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(0.8, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.1, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🎣 FISH IT v2.0"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.ZIndex = 1002
TitleLabel.Parent = TitleBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 7.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.ZIndex = 1002
CloseBtn.Parent = TitleBar

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 6)
CloseBtnCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    getgenv().Settings.AutoFish = false
    ScreenGui:Destroy()
    print("🛑 Script closed")
end)

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(0.9, 0, 0, 30)
StatusLabel.Position = UDim2.new(0.05, 0, 0.12, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
StatusLabel.Text = "Status: Ready"
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.ZIndex = 1001
StatusLabel.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusLabel

-- Content Frame (untuk scroll buttons)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 0, 380)
ContentFrame.Position = UDim2.new(0, 0, 0.1, 0)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ZIndex = 1001
ContentFrame.Parent = MainFrame

print("✅ UI Elements created")

-- ==========================================
-- 🔘 BUTTON CREATOR
-- ==========================================

local buttonCount = 0

local function CreateButton(name, text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.Position = UDim2.new(0.05, 0, 0.08 * buttonCount, 0)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text
    btn.ZIndex = 1001
    btn.Parent = ContentFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    buttonCount = buttonCount + 1
    return btn
end

-- ==========================================
-- 🎣 AUTO EQUIP FUNCTION
-- ==========================================

local function equipRod()
    local backpack = player:WaitForChild("Backpack")
    local character = player.Character
    
    if not character then
        warn("❌ No character!")
        return false
    end
    
    -- Cari rod
    local rod = nil
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name:lower()
            if toolName:find("rod") or toolName:find("fishing") or toolName:find("cane") or toolName:find("pole") then
                rod = tool
                break
            end
        end
    end
    
    if rod then
        print("🎣 Equipping:", rod.Name)
        rod.Parent = character
        task.wait(0.5)
        return true
    else
        warn("❌ Rod not found!")
        return false
    end
end

-- ==========================================
-- 💰 AUTO SELL FUNCTION
-- ==========================================

local function autoSellFish()
    if not getgenv().Settings.AutoSell then return end
    
    local backpack = player:WaitForChild("Backpack")
    local sold = 0
    
    for _, fish in pairs(backpack:GetChildren()) do
        if fish:IsA("Tool") and fish:FindFirstChild("FishRarity") then
            local isMutation = fish:FindFirstChild("Mutation")
            local isSecret = fish:FindFirstChild("Secret")
            
            if (getgenv().Settings.KeepMutation and isMutation) or 
               (getgenv().Settings.KeepSecret and isSecret) then
                print("💎 Keeping:", fish.Name)
            else
                pcall(function()
                    if remotes and remotes:FindFirstChild("Sell") then
                        remotes.Sell:InvokeServer(fish)
                        sold = sold + 1
                        print("💰 Sold:", fish.Name)
                    end
                end)
            end
        end
    end
    
    return sold
end

-- ==========================================
-- 🎣 MAIN FISHING LOOP
-- ==========================================

local function startFishing()
    task.spawn(function()
        while getgenv().Settings.AutoFish do
            local success, err = pcall(function()
                local character = player.Character
                if not character then
                    StatusLabel.Text = "Status: Respawning..."
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
                    task.wait(1)
                    return
                end
                
                -- Check rod
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
                            task.wait(1)
                            return
                        end
                    else
                        task.wait(1)
                        return
                    end
                end
                
                -- CAST
                StatusLabel.Text = "Status: Casting..."
                StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                task.wait(0.2)
                
                if remotes and remotes:FindFirstChild("Cast") then
                    remotes.Cast:FireServer()
                    print("📤 Cast!")
                end
                
                -- WAIT
                local waitTime = getgenv().Settings.BoostReelSpeed and 0.4 or 0.8
                task.wait(waitTime)
                
                -- REEL
                StatusLabel.Text = "Status: Reeling..."
                StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                
                if remotes and remotes:FindFirstChild("Reel") then
                    remotes.Reel:FireServer()
                    print("📥 Reel!")
                end
                
                task.wait(1.2)
                
                -- SELL
                if getgenv().Settings.AutoSell then
                    StatusLabel.Text = "Status: Selling..."
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
                    autoSellFish()
                end
                
                StatusLabel.Text = "Status: Ready"
                StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                task.wait(0.3)
                
            end)
            
            if not success then
                print("❌ Error:", err)
                StatusLabel.Text = "Status: Error!"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                task.wait(2)
            end
        end
        
        StatusLabel.Text = "Status: Stopped"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 100, 100)
    end)
end

-- ==========================================
-- 🔘 CREATE BUTTONS
-- ==========================================

-- AUTO FISH BUTTON
local AutoFishBtn = CreateButton("AutoFish", "⬜ Auto Fish (OFF)", Color3.fromRGB(60, 60, 80), function()
    getgenv().Settings.AutoFish = not getgenv().Settings.AutoFish
    
    if getgenv().Settings.AutoFish then
        AutoFishBtn.Text = "✅ Auto Fish (ON)"
        AutoFishBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        equipRod()
        startFishing()
        print("🟢 Auto Fish started!")
    else
        AutoFishBtn.Text = "⬜ Auto Fish (OFF)"
        AutoFishBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        print("🔴 Auto Fish stopped!")
    end
end)

-- EQUIP ROD BUTTON
local EquipBtn = CreateButton("EquipRod", "🎣 Equip Rod Now", Color3.fromRGB(80, 100, 60), function()
    if equipRod() then
        StatusLabel.Text = "Status: Rod Equipped ✅"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        print("✅ Rod equipped!")
    else
        StatusLabel.Text = "Status: Failed to equip ❌"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        print("❌ Failed to equip rod!")
    end
end)

-- AUTO SELL BUTTON
local AutoSellBtn = CreateButton("AutoSell", "⬜ Auto Sell (OFF)", Color3.fromRGB(80, 60, 60), function()
    getgenv().Settings.AutoSell = not getgenv().Settings.AutoSell
    
    if getgenv().Settings.AutoSell then
        AutoSellBtn.Text = "✅ Auto Sell (ON)"
        AutoSellBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 0)
        print("🟢 Auto Sell enabled!")
    else
        AutoSellBtn.Text = "⬜ Auto Sell (OFF)"
        AutoSellBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 60)
        print("🔴 Auto Sell disabled!")
    end
end)

-- BOOST REEL BUTTON
local BoostBtn = CreateButton("Boost", "⬜ Boost Reel (OFF)", Color3.fromRGB(60, 80, 60), function()
    getgenv().Settings.BoostReelSpeed = not getgenv().Settings.BoostReelSpeed
    
    if getgenv().Settings.BoostReelSpeed then
        BoostBtn.Text = "✅ Boost Reel (ON)"
        BoostBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
        print("⚡ Boost enabled!")
    else
        BoostBtn.Text = "⬜ Boost Reel (OFF)"
        BoostBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 60)
        print("⚡ Boost disabled!")
    end
end)

-- SELL NOW BUTTON
CreateButton("SellNow", "💰 SELL ALL NOW", Color3.fromRGB(100, 50, 50), function()
    local sold = autoSellFish()
    print("💰 Sold " .. sold .. " fish!")
end)

-- ==========================================
-- 📝 PRINT INFO
-- ==========================================

print([[

╔══════════════════════════════════════╗
║    🎣 FISH IT SCRIPT LOADED 🎣      ║
║         Version 2.0 - FIXED          ║
╚══════════════════════════════════════╝

✅ Menu should appear on screen now!
   (Top center of your screen)

🎮 How to use:
  1. Click "Equip Rod Now" button
  2. Click "Auto Fish (ON)" to start
  3. Watch the magic happen!

📌 Buttons:
  🎣 Equip Rod Now - Manual equip
  ✅ Auto Fish - Toggle auto fishing
  💰 Auto Sell - Toggle auto selling
  ⚡ Boost Reel - Make it faster
  💰 Sell All - Manual sell

❓ Not working?
  - Make sure you're in a fishing game
  - Rod must be in your backpack
  - Remotes must exist in game

═════════════════════════════════════

]])

print("🎉 Script fully loaded!")
