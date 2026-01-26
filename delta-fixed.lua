--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - SPAM REEL + AUTO SELL FIXED!
    JUAL TIAP 5 IKAN!
    ════════════════════════════════════════════════════════
]]

print("🎣 LOADING SPAM REEL + AUTO SELL (FIXED)...")

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Backpack = Player:WaitForChild("Backpack")

-- ════════════════════════════════════════════════════════
-- CONFIG
-- ════════════════════════════════════════════════════════
local Config = {
    Enabled = false,
    ClickSpeed = 0.03,
    AutoSell = true,
    SellInterval = 5, -- JUAL TIAP 5 IKAN!
}

local Stats = {
    Fish = 0,
    Casts = 0,
    Clicks = 0,
    Sells = 0,
    Money = 0,
}

-- ════════════════════════════════════════════════════════
-- STATE
-- ════════════════════════════════════════════════════════
local IsFishing = false
local IsReeling = false
local IsSelling = false
local LastCast = 0
local OriginalPosition = nil

-- ════════════════════════════════════════════════════════
-- UPDATE CHARACTER REFERENCE
-- ════════════════════════════════════════════════════════
local function UpdateCharacter()
    local char = Player.Character or Player.CharacterAdded:Wait()
    return char, char:WaitForChild("HumanoidRootPart")
end

local Character, HRP = UpdateCharacter()

Player.CharacterAdded:Connect(function(char)
    Character = char
    HRP = char:WaitForChild("HumanoidRootPart")
end)

-- ════════════════════════════════════════════════════════
-- ANTI-AFK
-- ════════════════════════════════════════════════════════
Player.Idled:Connect(function()
    pcall(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):Button1Down(Vector2.new())
    end)
end)

-- ════════════════════════════════════════════════════════
-- ADVANCED MERCHANT FINDER (MULTIPLE METHODS!)
-- ════════════════════════════════════════════════════════
local function FindMerchant()
    print("🔍 Searching for merchant...")
    
    -- Method 1: Workspace NPCs
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") then
            local name = npc.Name:lower()
            -- Nama umum merchant di Fisch
            if name:find("merchant") or name:find("appraiser") or name:find("marc") or 
               name:find("shipwright") or name:find("trader") or name:find("shop") then
                local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")
                if root then
                    print("✅ Found NPC:", npc.Name)
                    return npc, root
                end
            end
        end
    end
    
    -- Method 2: Cari berdasarkan ProximityPrompt dengan keyword "sell"
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local name = obj.Name:lower()
            local parent = obj.Parent
            
            if name:find("sell") or name:find("apprai") or name:find("merchant") or name:find("shop") then
                print("✅ Found sell prompt:", obj.Name, "in", parent.Name)
                
                -- Cari part terdekat
                local targetPart = nil
                if parent:IsA("BasePart") then
                    targetPart = parent
                elseif parent:IsA("Model") then
                    targetPart = parent:FindFirstChild("HumanoidRootPart") or parent.PrimaryPart
                end
                
                if targetPart then
                    return parent, targetPart
                end
            end
        end
    end
    
    -- Method 3: Cari folder khusus
    local npcs = workspace:FindFirstChild("NPCs") or workspace:FindFirstChild("Merchants") or workspace:FindFirstChild("world")
    if npcs then
        for _, npc in pairs(npcs:GetDescendants()) do
            if npc:IsA("Model") then
                local name = npc.Name:lower()
                if name:find("merchant") or name:find("apprai") or name:find("marc") then
                    local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Head")
                    if root then
                        print("✅ Found in folder:", npc.Name)
                        return npc, root
                    end
                end
            end
        end
    end
    
    warn("❌ Merchant not found!")
    warn("💡 Tip: Pergi ke merchant dulu, lalu klik 'MANUAL SELL' untuk debug!")
    return nil, nil
end

-- ════════════════════════════════════════════════════════
-- TELEPORT FUNCTION (SAFE!)
-- ════════════════════════════════════════════════════════
local function SafeTeleport(targetCFrame)
    if not HRP then
        Character, HRP = UpdateCharacter()
    end
    
    -- Method 1: Instant TP
    pcall(function()
        HRP.CFrame = targetCFrame
    end)
    
    task.wait(0.3)
    
    -- Method 2: Tween (smooth)
    local tween = TweenService:Create(HRP, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
end

-- ════════════════════════════════════════════════════════
-- AUTO SELL (IMPROVED!)
-- ════════════════════════════════════════════════════════
local function AutoSell()
    if IsSelling then return end
    IsSelling = true
    
    print("════════════════════════════════════════")
    print("💰 STARTING AUTO SELL...")
    print("════════════════════════════════════════")
    
    -- Update character ref
    Character, HRP = UpdateCharacter()
    
    -- Save posisi
    if not OriginalPosition then
        OriginalPosition = HRP.CFrame
        print("📍 Saved fishing position")
    end
    
    -- Cari merchant
    local merchant, merchantPart = FindMerchant()
    
    if not merchant or not merchantPart then
        warn("❌ SELL FAILED: Merchant not found!")
        warn("💡 Coba manual: Pergi ke merchant, lalu tekan F7")
        IsSelling = false
        return
    end
    
    print("📍 Merchant found:", merchant.Name)
    print("📍 Teleporting...")
    
    -- TP ke merchant (dengan offset)
    local targetPos = merchantPart.CFrame * CFrame.new(0, 2, 5)
    SafeTeleport(targetPos)
    
    task.wait(0.5)
    
    -- SELL METHOD 1: ProximityPrompt
    local sold = false
    for _, prompt in pairs(merchant:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            print("💰 Trying ProximityPrompt:", prompt.Name)
            
            -- Fire multiple times
            for i = 1, 3 do
                pcall(function()
                    fireproximityprompt(prompt)
                end)
                task.wait(0.2)
            end
            
            sold = true
            break
        end
    end
    
    -- SELL METHOD 2: Spam E
    print("💰 Spamming E key...")
    for i = 1, 15 do
        VIM:SendKeyEvent(true, "E", false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, "E", false, game)
        task.wait(0.1)
    end
    
    -- SELL METHOD 3: Click spam
    print("💰 Click spam...")
    for i = 1, 10 do
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        task.wait(0.1)
    end
    
    -- SELL METHOD 4: Remote (cari semua kemungkinan)
    for _, remote in pairs(RS:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local name = remote.Name:lower()
            if name:find("sell") or name:find("apprai") then
                print("💰 Trying remote:", remote.Name)
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer()
                        remote:FireServer("all") -- some games use parameter
                    else
                        remote:InvokeServer()
                    end
                end)
                task.wait(0.2)
            end
        end
    end
    
    task.wait(1)
    
    Stats.Sells = Stats.Sells + 1
    print("✅ Sell attempt #" .. Stats.Sells .. " complete!")
    
    -- Balik ke fishing spot
    if OriginalPosition then
        print("📍 Returning to fishing spot...")
        SafeTeleport(OriginalPosition)
        task.wait(0.5)
    end
    
    print("════════════════════════════════════════")
    print("✅ SELL COMPLETE! Resuming fishing...")
    print("════════════════════════════════════════")
    
    IsSelling = false
end

-- ════════════════════════════════════════════════════════
-- ROD FUNCTIONS
-- ════════════════════════════════════════════════════════
local function GetRod()
    if Player.Character then
        for _, tool in pairs(Player.Character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("rod") then
                return tool
            end
        end
    end
    
    for _, tool in pairs(Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("rod") then
            return tool
        end
    end
end

local function EquipRod()
    local rod = GetRod()
    if rod and rod.Parent == Backpack then
        Player.Character.Humanoid:EquipTool(rod)
        task.wait(0.3)
        return true
    end
    return rod ~= nil
end

-- ════════════════════════════════════════════════════════
-- UI DETECTION
-- ════════════════════════════════════════════════════════
local function HasReelUI()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "FischSpamGUI" then
            local reel = gui:FindFirstChild("reel", true)
            if reel and reel:IsA("GuiObject") and reel.Visible then
                return true, reel
            end
            
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("GuiObject") and obj.Visible then
                    local name = obj.Name:lower()
                    if name == "reel" or name == "safezone" or name == "bar" or 
                       name == "reelbar" or name == "fishingbar" or name == "progress" or
                       name == "playerbar" or name:find("reel") or name:find("safe") then
                        return true, obj
                    end
                end
            end
        end
    end
    return false, nil
end

-- ════════════════════════════════════════════════════════
-- CAST
-- ════════════════════════════════════════════════════════
local function DoCast()
    if IsFishing or IsReeling or IsSelling or tick() - LastCast < 2 then return end
    
    Stats.Casts = Stats.Casts + 1
    print("🎣 Casting #" .. Stats.Casts)
    
    EquipRod()
    
    local rod = GetRod()
    if rod then
        rod:Activate()
    end
    
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    IsFishing = true
    LastCast = tick()
    
    task.delay(20, function()
        if IsFishing and not IsReeling then 
            IsFishing = false 
        end
    end)
end

-- ════════════════════════════════════════════════════════
-- SPAM REEL
-- ════════════════════════════════════════════════════════
local ReelThread = nil

local function StartSpamReel()
    if IsReeling then return end
    IsReeling = true
    
    print("⚡ SPAM STARTED!")
    
    local startTime = tick()
    local clickCount = 0
    
    ReelThread = task.spawn(function()
        while IsReeling and Config.Enabled do
            local hasUI = HasReelUI()
            
            if not hasUI then
                print("✅ UI hilang! Ikan masuk!")
                break
            end
            
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.01)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            
            clickCount = clickCount + 1
            Stats.Clicks = Stats.Clicks + 1
            
            task.wait(Config.ClickSpeed)
            
            if tick() - startTime > 30 then
                print("⏰ Timeout!")
                break
            end
        end
        
        local duration = math.floor((tick() - startTime) * 1000)
        Stats.Fish = Stats.Fish + 1
        print(string.format("✅ Fish #%d! (%d clicks, %dms)", Stats.Fish, clickCount, duration))
        
        IsReeling = false
        IsFishing = false
        
        -- AUTO SELL CHECK (TIAP 5 IKAN!)
        if Config.AutoSell and Stats.Fish % Config.SellInterval == 0 then
            print("💰 5 IKAN TERCAPAI! JUAL OTOMATIS...")
            task.wait(1)
            AutoSell()
        else
            task.wait(1)
        end
    end)
end

local function StopSpamReel()
    IsReeling = false
    if ReelThread then
        task.cancel(ReelThread)
        ReelThread = nil
    end
end

-- ════════════════════════════════════════════════════════
-- DETECTION
-- ════════════════════════════════════════════════════════
local ReelDetection = nil

local function StartReelDetection()
    if ReelDetection then return end
    
    ReelDetection = RunService.RenderStepped:Connect(function()
        if Config.Enabled and IsFishing and not IsReeling and not IsSelling then
            local hasUI = HasReelUI()
            if hasUI then
                StartSpamReel()
            end
        end
    end)
end

local function StopReelDetection()
    if ReelDetection then
        ReelDetection:Disconnect()
        ReelDetection = nil
    end
end

-- ════════════════════════════════════════════════════════
-- MAIN LOOP
-- ════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(0.5) do
        if Config.Enabled and not IsFishing and not IsReeling and not IsSelling then
            DoCast()
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- DEBUG COMMAND
-- ════════════════════════════════════════════════════════
_G.FischDebug = function()
    print("════════════════════════════════════════")
    print("🔍 FISCH DEBUG INFO")
    print("════════════════════════════════════════")
    
    local merchant, part = FindMerchant()
    if merchant then
        print("✅ Merchant:", merchant.Name)
        print("✅ Position:", part.Position)
        
        -- List all prompts
        for _, prompt in pairs(merchant:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                print("  → ProximityPrompt:", prompt.Name)
            end
        end
    else
        print("❌ No merchant found")
    end
    
    print("════════════════════════════════════════")
end

-- ════════════════════════════════════════════════════════
-- GUI
-- ════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FischSpamGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.35, 0, 0.25, 0)
Main.Size = UDim2.new(0, 340, 0, 280)
Main.Active = true
Main.Draggable = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)

local Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(255, 215, 0)
Glow.Thickness = 3
Glow.Parent = Main

local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡💰 SELL TIAP 5 IKAN!"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 17

Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 15)

local TitleFix = Instance.new("Frame")
TitleFix.Parent = Title
TitleFix.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
TitleFix.BorderSizePixel = 0
TitleFix.Position = UDim2.new(0, 0, 0.6, 0)
TitleFix.Size = UDim2.new(1, 0, 0.4, 0)

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = Main
StatsLabel.BackgroundTransparency = 1
StatsLabel.Position = UDim2.new(0, 15, 0, 60)
StatsLabel.Size = UDim2.new(1, -30, 0, 100)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Ready!"
StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsLabel.TextSize = 13
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            local status = Config.Enabled and "⚡ ACTIVE!" or "🔴 STOPPED"
            local currentAction = ""
            
            if Config.Enabled then
                if IsSelling then
                    currentAction = "💰💰 SELLING! 💰💰"
                elseif IsReeling then
                    currentAction = "⚡⚡⚡ SPAMMING! ⚡⚡⚡"
                elseif IsFishing then
                    currentAction = "⏳ Waiting bite..."
                else
                    currentAction = "🎣 Casting..."
                end
            end
            
            local nextSell = Config.SellInterval - (Stats.Fish % Config.SellInterval)
            if nextSell == 0 then nextSell = Config.SellInterval end
            
            StatsLabel.Text = string.format(
                "%s\n%s\n\n🐟 Fish: %d | 🎣 Casts: %d\n🖱️ Clicks: %d | 💰 Sells: %d\n\n📊 Sell in: %d fish",
                status,
                currentAction,
                Stats.Fish,
                Stats.Casts,
                Stats.Clicks,
                Stats.Sells,
                nextSell
            )
        end)
    end
end)

local SellToggle = Instance.new("TextButton")
SellToggle.Parent = Main
SellToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
SellToggle.BorderSizePixel = 0
SellToggle.Position = UDim2.new(0, 15, 0, 170)
SellToggle.Size = UDim2.new(1, -30, 0, 35)
SellToggle.Font = Enum.Font.GothamBold
SellToggle.Text = "💰 AUTO SELL: ON (5 FISH)"
SellToggle.TextColor3 = Color3.new(1, 1, 1)
SellToggle.TextSize = 13

Instance.new("UICorner", SellToggle).CornerRadius = UDim.new(0, 8)

SellToggle.MouseButton1Click:Connect(function()
    Config.AutoSell = not Config.AutoSell
    
    if Config.AutoSell then
        SellToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        SellToggle.Text = "💰 AUTO SELL: ON (5 FISH)"
    else
        SellToggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        SellToggle.Text = "💰 AUTO SELL: OFF"
    end
end)

local ManualSell = Instance.new("TextButton")
ManualSell.Parent = Main
ManualSell.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
ManualSell.BorderSizePixel = 0
ManualSell.Position = UDim2.new(0, 15, 0, 210)
ManualSell.Size = UDim2.new(1, -30, 0, 25)
ManualSell.Font = Enum.Font.GothamBold
ManualSell.Text = "🔧 MANUAL SELL NOW"
ManualSell.TextColor3 = Color3.new(1, 1, 1)
ManualSell.TextSize = 12

Instance.new("UICorner", ManualSell).CornerRadius = UDim.new(0, 6)

ManualSell.MouseButton1Click:Connect(function()
    if not IsSelling then
        print("🔧 Manual sell triggered!")
        task.spawn(AutoSell)
    end
end)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Main
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0, 15, 0, 240)
ToggleButton.Size = UDim2.new(1, -30, 0, 30)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "🔴 START"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = 15

Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)

ToggleButton.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        ToggleButton.Text = "⚡ STOP"
        Glow.Color = Color3.fromRGB(0, 255, 0)
        StartReelDetection()
        
        Character, HRP = UpdateCharacter()
        OriginalPosition = HRP.CFrame
        
        print("✅ STARTED! Jual tiap 5 ikan!")
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ToggleButton.Text = "🔴 START"
        Glow.Color = Color3.fromRGB(255, 215, 0)
        StopReelDetection()
        StopSpamReel()
        IsFishing = false
        IsSelling = false
        print("❌ STOPPED!")
    end
end)

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
    elseif input.KeyCode == Enum.KeyCode.F6 then
        ToggleButton.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.F7 then
        if not IsSelling then
            task.spawn(AutoSell)
        end
    elseif input.KeyCode == Enum.KeyCode.F8 then
        _G.FischDebug()
    end
end)

print("════════════════════════════════════════")
print("✅ FISCH AUTO LOADED!")
print("════════════════════════════════════════")
print("💰 AUTO SELL: TIAP 5 IKAN!")
print("════════════════════════════════════════")
print("🎮 Controls:")
print("  DELETE = Hide/Show")
print("  F6 = Toggle ON/OFF")
print("  F7 = Manual Sell")
print("  F8 = Debug (cek merchant)")
print("════════════════════════════════════════")
print("💡 Kalau sell ga work:")
print("  1. Pergi ke merchant")
print("  2. Tekan F7 (manual sell)")
print("  3. Tekan F8 (debug)")
print("  4. Kasih tau nama NPC di console!")
print("════════════════════════════════════════")
