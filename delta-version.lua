--[[
    ═══════════════════════════════════════════════════════
    🎣 FISCH AUTO - SIMPLE VERSION
    Klik ON = Langsung Auto Fish!
    ═══════════════════════════════════════════════════════
]]

-- Cleanup old
if _G.StopFisch then _G.StopFisch() end
pcall(function() game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("FischAuto"):Destroy() end)

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ════════════════════════════════════════════════════════
-- SETUP
-- ════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Mouse = Player:GetMouse()

local Running = true
local AutoFishEnabled = false
local Stats = { Fish = 0, Casts = 0 }

-- ════════════════════════════════════════════════════════
-- MOUSE FUNCTIONS
-- ════════════════════════════════════════════════════════
local function MouseDown()
    pcall(function() mouse1press() end)
    pcall(function()
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
    end)
end

local function MouseUp()
    pcall(function() mouse1release() end)
    pcall(function()
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
    end)
end

local function ClickMouse()
    MouseDown()
    task.wait(0.05)
    MouseUp()
end

-- ════════════════════════════════════════════════════════
-- ROD FUNCTIONS
-- ════════════════════════════════════════════════════════
local function GetRod()
    local char = Player.Character
    if char then
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("Tool") then return v, true end
        end
    end
    for _, v in pairs(Player.Backpack:GetChildren()) do
        if v:IsA("Tool") then return v, false end
    end
    return nil, false
end

local function EquipRod()
    local rod, equipped = GetRod()
    if rod and not equipped then
        local char = Player.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):EquipTool(rod)
            task.wait(0.5)
        end
    end
end

-- ════════════════════════════════════════════════════════
-- DETECTION FUNCTIONS
-- ════════════════════════════════════════════════════════
local function FindReelUI()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= "FischAuto" and gui.Enabled then
            for _, v in pairs(gui:GetDescendants()) do
                if v:IsA("Frame") and v.Visible then
                    local n = v.Name:lower()
                    if n:find("reel") or n:find("fish") or n:find("bar") or n:find("meter") or n:find("progress") or n:find("minigame") then
                        return v
                    end
                end
            end
        end
    end
    return nil
end

local function FindShakeButton()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= "FischAuto" and gui.Enabled then
            for _, v in pairs(gui:GetDescendants()) do
                if (v:IsA("TextButton") or v:IsA("ImageButton") or v:IsA("Frame")) and v.Visible then
                    local n = v.Name:lower()
                    if n:find("shake") or n:find("!") or n:find("struggle") or n:find("tap") then
                        return v
                    end
                end
            end
        end
    end
    return nil
end

local function ClickButton(btn)
    if not btn then return end
    pcall(function()
        if firesignal then firesignal(btn.MouseButton1Click) end
    end)
    pcall(function()
        if getconnections then
            for _, c in pairs(getconnections(btn.MouseButton1Click)) do
                if c.Fire then c:Fire() end
            end
        end
    end)
end

-- ════════════════════════════════════════════════════════
-- ANTI-AFK
-- ════════════════════════════════════════════════════════
Player.Idled:Connect(function()
    pcall(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end)
end)

-- ════════════════════════════════════════════════════════
-- GUI
-- ════════════════════════════════════════════════════════
local Gui = Instance.new("ScreenGui")
Gui.Name = "FischAuto"
Gui.Parent = PlayerGui
Gui.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Parent = Gui
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.Position = UDim2.new(0.02, 0, 0.4, 0)
Main.Size = UDim2.new(0, 220, 0, 150)
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 170, 255)

-- Drag
local drag, dragStart, startPos
Main.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
        dragStart = i.Position
        startPos = Main.Position
    end
end)
Main.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
end)
UIS.InputChanged:Connect(function(i)
    if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.GothamBold
Title.Text = "🎣 FISCH AUTO"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

-- Status
local Status = Instance.new("TextLabel")
Status.Parent = Main
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 10, 0, 40)
Status.Size = UDim2.new(1, -20, 0, 25)
Status.Font = Enum.Font.GothamBold
Status.TextColor3 = Color3.fromRGB(255, 255, 100)
Status.TextSize = 14
Status.Text = "Status: OFF"
Status.TextXAlignment = Enum.TextXAlignment.Left

-- Stats
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = Main
StatsLabel.BackgroundTransparency = 1
StatsLabel.Position = UDim2.new(0, 10, 0, 60)
StatsLabel.Size = UDim2.new(1, -20, 0, 20)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatsLabel.TextSize = 12
StatsLabel.Text = "🐟 0 Fish | 🎯 0 Casts"
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left

-- AUTO FISH BUTTON (MAIN TOGGLE)
local AutoBtn = Instance.new("TextButton")
AutoBtn.Parent = Main
AutoBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
AutoBtn.Position = UDim2.new(0.1, 0, 0, 90)
AutoBtn.Size = UDim2.new(0.8, 0, 0, 45)
AutoBtn.Font = Enum.Font.GothamBold
AutoBtn.Text = "AUTO FISH: OFF"
AutoBtn.TextColor3 = Color3.new(1, 1, 1)
AutoBtn.TextSize = 16
Instance.new("UICorner", AutoBtn).CornerRadius = UDim.new(0, 10)

-- Toggle function
local function UpdateButton()
    if AutoFishEnabled then
        AutoBtn.Text = "AUTO FISH: ON"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        Status.Text = "Status: RUNNING..."
        Status.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        AutoBtn.Text = "AUTO FISH: OFF"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        Status.Text = "Status: OFF"
        Status.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

AutoBtn.MouseButton1Click:Connect(function()
    AutoFishEnabled = not AutoFishEnabled
    UpdateButton()
    print(AutoFishEnabled and "🎣 Auto Fish STARTED!" or "🛑 Auto Fish STOPPED!")
end)

-- Hide GUI
UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
    end
end)

-- ════════════════════════════════════════════════════════
-- MAIN AUTO FISH LOOP
-- ════════════════════════════════════════════════════════
task.spawn(function()
    while Running do
        task.wait(0.1)
        
        -- Update stats
        StatsLabel.Text = string.format("🐟 %d Fish | 🎯 %d Casts", Stats.Fish, Stats.Casts)
        
        -- Only run if enabled
        if not AutoFishEnabled then 
            task.wait(0.2)
            continue 
        end
        
        -- ═══════════════════════════════════════
        -- PRIORITY 1: SHAKE BUTTON
        -- ═══════════════════════════════════════
        local shake = FindShakeButton()
        if shake then
            Status.Text = "Status: SHAKING!"
            for i = 1, 5 do
                ClickButton(shake)
                ClickMouse()
                task.wait(0.05)
            end
            continue
        end
        
        -- ═══════════════════════════════════════
        -- PRIORITY 2: REEL MINIGAME
        -- ═══════════════════════════════════════
        local reelUI = FindReelUI()
        if reelUI then
            Status.Text = "Status: REELING!"
            
            -- Hold mouse untuk reel
            MouseDown()
            task.wait(0.3)
            MouseUp()
            task.wait(0.1)
            
            -- Click any buttons
            for _, v in pairs(reelUI:GetDescendants()) do
                if v:IsA("TextButton") or v:IsA("ImageButton") then
                    ClickButton(v)
                end
            end
            
            continue
        end
        
        -- ═══════════════════════════════════════
        -- PRIORITY 3: CAST ROD
        -- ═══════════════════════════════════════
        Status.Text = "Status: CASTING..."
        
        -- Equip rod
        EquipRod()
        task.wait(0.3)
        
        local rod, equipped = GetRod()
        if rod and equipped then
            Stats.Casts = Stats.Casts + 1
            
            -- Activate rod
            pcall(function() rod:Activate() end)
            task.wait(0.1)
            
            -- Hold mouse untuk power, lalu release untuk cast
            MouseDown()
            task.wait(1) -- Hold 1 detik untuk power
            MouseUp()
            
            Status.Text = "Status: WAITING..."
            task.wait(3) -- Tunggu ikan gigit
        else
            Status.Text = "Status: NO ROD!"
            task.wait(1)
        end
    end
end)

-- Fish counter (detect when reel UI disappears)
local wasReeling = false
task.spawn(function()
    while Running do
        task.wait(0.5)
        local reelUI = FindReelUI()
        if wasReeling and not reelUI then
            Stats.Fish = Stats.Fish + 1
            print("🐟 Fish caught! Total:", Stats.Fish)
        end
        wasReeling = reelUI ~= nil
    end
end)

-- Cleanup
_G.StopFisch = function()
    Running = false
    AutoFishEnabled = false
    MouseUp()
    print("🛑 Fisch Auto Stopped!")
end

-- ════════════════════════════════════════════════════════
print("═══════════════════════════════════════")
print("✅ FISCH AUTO LOADED!")
print("═══════════════════════════════════════")
print("👆 Klik tombol 'AUTO FISH: OFF' untuk mulai!")
print("🔑 Tekan DELETE untuk hide/show GUI")
print("═══════════════════════════════════════")
