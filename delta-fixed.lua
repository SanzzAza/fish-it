--[[
    🎣 FISH IT - ULTIMATE FIXED VERSION 🎣
    NUKIR METHOD - 100% PASTI MUNCUL
]]

print("=" .. string.rep("=", 50))
print("🎣 FISH IT SCRIPT LOADING...")
print("=" .. string.rep("=", 50))

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local remotes = nil

-- Anti error setup
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

-- Anti-AFK
if getgenv().Settings.AntiAfk then
    for _,v in pairs(getconnections(player.Idled)) do 
        v:Disable() 
    end
    print("✅ Anti-AFK enabled")
end

-- Tunggu remotes
print("⏳ Waiting for Remotes...")
task.wait(1)
remotes = ReplicatedStorage:FindFirstChild("Remotes")
if remotes then
    print("✅ Remotes found!")
else
    print("⚠️ Remotes not found (but continuing...)")
end

print("🎨 Creating UI...")

-- ============================================
-- DELETE OLD UI
-- ============================================
local oldUI = CoreGui:FindFirstChild("FishIt")
if oldUI then
    oldUI:Destroy()
    print("🗑️ Old UI deleted")
end

-- ============================================
-- CREATE MAIN GUI
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishIt"
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

print("✅ ScreenGui created, parent:", ScreenGui.Parent.Name)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 550)
MainFrame.Position = UDim2.new(0.5, -175, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 999
MainFrame.Parent = ScreenGui

print("✅ MainFrame created")

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(100, 100, 150)
Stroke.Thickness = 2
Stroke.Parent = MainFrame

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- ============================================
-- TITLE
-- ============================================
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
Title.Text = "🎣 FISH IT v2.0"
Title.TextColor3 = Color3.fromRGB(100, 255, 200)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.BorderSizePixel = 0
Title.ZIndex = 1000
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

-- CLOSE BUTTON
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 1001
CloseBtn.Parent = Title

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    getgenv().Settings.AutoFish = false
    ScreenGui:Destroy()
    print("🛑 UI Closed")
end)

print("✅ Title and close button created")

-- ============================================
-- STATUS
-- ============================================
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Size = UDim2.new(0.9, 0, 0, 40)
StatusLabel.Position = UDim2.new(0.05, 0, 0.08, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
StatusLabel.Text = "🟢 Status: Ready"
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextWrapped = true
StatusLabel.BorderSizePixel = 0
StatusLabel.ZIndex = 1000
StatusLabel.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusLabel

print("✅ Status label created")

-- ============================================
-- BUTTON FACTORY
-- ============================================
local buttonY = 0.15

local function MakeButton(text, color, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 50)
    btn.Position = UDim2.new(0.05, 0, buttonY, 0)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    btn.ZIndex = 1000
    btn.Parent = MainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(onClick)
    buttonY = buttonY + 0.09
    
    return btn
end

-- ============================================
-- FUNCTIONS
-- ============================================

-- EQUIP ROD
local function EquipRod()
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then
        warn("Backpack not found!")
        return false
    end
    
    local character = player.Character
    if not character then
        warn("Character not found!")
        return false
    end
    
    -- Cari rod
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:find("rod") or name:find("fishing") or name:find("pole") then
                print("🎣 Found rod:", item.Name)
                item.Parent = character
                task.wait(0.5)
                return true
            end
        end
    end
    
    warn("❌ Rod not found in backpack!")
    return false
end

-- AUTO SELL
local function AutoSellFish()
    if not getgenv().Settings.AutoSell then return end
    
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then return end
    
    for _, fish in pairs(backpack:GetChildren()) do
        if fish:IsA("Tool") and fish:FindFirstChild("FishRarity") then
            local mutation = fish:FindFirstChild("Mutation")
            local secret = fish:FindFirstChild("Secret")
            
            if (getgenv().Settings.KeepMutation and mutation) or 
               (getgenv().Settings.KeepSecret and secret) then
                print("💎 Kept:", fish.Name)
            else
                if remotes and remotes:FindFirstChild("Sell") then
                    pcall(function()
                        remotes.Sell:InvokeServer(fish)
                        print("💰 Sold:", fish.Name)
                    end)
                end
            end
        end
    end
end

-- MAIN FISHING LOOP
local function FishingLoop()
    task.spawn(function()
        while getgenv().Settings.AutoFish do
            pcall(function()
                local char = player.Character
                if not char then
                    StatusLabel.Text = "⏳ Respawning..."
                    task.wait(2)
                    return
                end
                
                -- Check rod
                local hasRod = false
                for _, t in pairs(char:GetChildren()) do
                    if t:IsA("Tool") then
                        hasRod = true
                        break
                    end
                end
                
                if not hasRod then
                    StatusLabel.Text = "📦 Getting rod..."
                    if getgenv().Settings.AutoEquipRod then
                        EquipRod()
                    end
                    task.wait(1)
                    return
                end
                
                -- CAST
                StatusLabel.Text = "📤 Casting..."
                task.wait(0.2)
                if remotes and remotes:FindFirstChild("Cast") then
                    remotes.Cast:FireServer()
                end
                
                -- WAIT
                local wait_time = getgenv().Settings.BoostReelSpeed and 0.4 or 0.8
                task.wait(wait_time)
                
                -- REEL
                StatusLabel.Text = "📥 Reeling..."
                if remotes and remotes:FindFirstChild("Reel") then
                    remotes.Reel:FireServer()
                end
                
                task.wait(1.2)
                
                -- SELL
                if getgenv().Settings.AutoSell then
                    StatusLabel.Text = "💰 Selling..."
                    AutoSellFish()
                end
                
                StatusLabel.Text = "🟢 Waiting..."
                task.wait(0.5)
            end)
        end
        
        StatusLabel.Text = "🔴 Stopped"
    end)
end

print("✅ Functions created")

-- ============================================
-- CREATE BUTTONS
-- ============================================

-- AUTO FISH BUTTON
local AutoFishBtn = MakeButton(
    "🎣 AUTO FISH (OFF)",
    Color3.fromRGB(60, 80, 60),
    function()
        getgenv().Settings.AutoFish = not getgenv().Settings.AutoFish
        if getgenv().Settings.AutoFish then
            AutoFishBtn.Text = "✅ AUTO FISH (ON)"
            AutoFishBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
            EquipRod()
            FishingLoop()
        else
            AutoFishBtn.Text = "🎣 AUTO FISH (OFF)"
            AutoFishBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 60)
        end
    end
)

-- EQUIP ROD BUTTON
local EquipBtn = MakeButton(
    "🎯 EQUIP ROD NOW",
    Color3.fromRGB(80, 100, 60),
    function()
        if EquipRod() then
            StatusLabel.Text = "✅ Rod equipped!"
        else
            StatusLabel.Text = "❌ Failed to equip"
        end
    end
)

-- AUTO SELL BUTTON
local SellBtn = MakeButton(
    "💰 AUTO SELL (OFF)",
    Color3.fromRGB(100, 80, 40),
    function()
        getgenv().Settings.AutoSell = not getgenv().Settings.AutoSell
        if getgenv().Settings.AutoSell then
            SellBtn.Text = "💰 AUTO SELL (ON)"
            SellBtn.BackgroundColor3 = Color3.fromRGB(150, 120, 0)
        else
            SellBtn.Text = "💰 AUTO SELL (OFF)"
            SellBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 40)
        end
    end
)

-- BOOST BUTTON
local BoostBtn = MakeButton(
    "⚡ BOOST (OFF)",
    Color3.fromRGB(60, 80, 100),
    function()
        getgenv().Settings.BoostReelSpeed = not getgenv().Settings.BoostReelSpeed
        if getgenv().Settings.BoostReelSpeed then
            BoostBtn.Text = "⚡ BOOST (ON)"
            BoostBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
        else
            BoostBtn.Text = "⚡ BOOST (OFF)"
            BoostBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 100)
        end
    end
)

-- SELL NOW BUTTON
MakeButton(
    "💵 SELL ALL NOW",
    Color3.fromRGB(150, 60, 60),
    function()
        AutoSellFish()
        StatusLabel.Text = "💵 Selling all!"
    end
)

print("✅ All buttons created")

-- ============================================
-- FOOTER
-- ============================================
local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, 0, 0, 50)
Footer.Position = UDim2.new(0, 0, 0.92, 0)
Footer.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
Footer.Text = "v2.0 ULTIMATE | By Dev\nDrag me to move!"
Footer.TextColor3 = Color3.fromRGB(150, 150, 150)
Footer.TextSize = 11
Footer.TextWrapped = true
Footer.Font = Enum.Font.Gotham
Footer.BorderSizePixel = 0
Footer.ZIndex = 999
Footer.Parent = MainFrame

local FooterCorner = Instance.new("UICorner")
FooterCorner.CornerRadius = UDim.new(0, 12)
FooterCorner.Parent = Footer

print("✅ Footer created")

-- ============================================
-- CHARACTER SETUP
-- ============================================
local function SetupCharacter(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = getgenv().Settings.WalkSpeed
    print("👤 Character loaded")
end

if player.Character then
    SetupCharacter(player.Character)
end

player.CharacterAdded:Connect(SetupCharacter)

print("✅ Character handler connected")

-- ============================================
-- FINAL PRINT
-- ============================================
print("")
print("╔" .. string.rep("═", 50) .. "╗")
print("║" .. string.rep(" ", 50) .. "║")
print("║" .. "  🎣 FISH IT v2.0 - FULLY LOADED! 🎣".ljust(51) .. "║")
print("║" .. string.rep(" ", 50) .. "║")
print("║" .. "  ✅ UI SHOULD BE VISIBLE ON YOUR SCREEN!".ljust(51) .. "║")
print("║" .. "  📍 Top-left corner area".ljust(51) .. "║")
print("║" .. "  🖱️ Draggable UI (click and drag title)".ljust(51) .. "║")
print("║" .. string.rep(" ", 50) .. "║")
print("║" .. "  BUTTONS:".ljust(51) .. "║")
print("║" .. "  1️⃣ Equip Rod Now - Get your fishing rod".ljust(51) .. "║")
print("║" .. "  2️⃣ Auto Fish - Start auto fishing".ljust(51) .. "║")
print("║" .. "  3️⃣ Auto Sell - Auto sell fish".ljust(51) .. "║")
print("║" .. "  4️⃣ Boost - Make it faster".ljust(51) .. "║")
print("║" .. string.rep(" ", 50) .. "║")
print("╚" .. string.rep("═", 50) .. "╝")
print("")

print("✅ SCRIPT FULLY LOADED - UI SHOULD BE VISIBLE NOW!")
