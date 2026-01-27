--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - SPAM REEL + AUTO SELL ALL FISH
    CLICK TERUS SAMPAI IKAN MASUK!
    AUTO SELL SEMUA IKAN DI INVENTORY!
    ════════════════════════════════════════════════════════
]]

print("🎣 LOADING SPAM REEL + AUTO SELL...")

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
    AutoSell = true,
    SellThreshold = 5,
    ClickSpeed = 0.03,
}

local Stats = {
    Fish = 0,
    FishSinceLastSell = 0,
    Casts = 0,
    Clicks = 0,
    TotalSold = 0,
}

-- ════════════════════════════════════════════════════════
-- STATE
-- ════════════════════════════════════════════════════════
local IsFishing = false
local IsReeling = false
local IsSelling = false
local LastCast = 0

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
-- FISCH SELL SYSTEM - JUAL SEMUA IKAN DI INVENTORY
-- ════════════════════════════════════════════════════════

-- Debug: Print semua remote yang ada
local function DebugRemotes()
    print("═══════ DEBUG REMOTES ═══════")
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            print("📡 " .. obj.ClassName .. ": " .. obj:GetFullName())
        end
    end
    print("═════════════════════════════")
end

-- Cari Network/Remotes folder di Fisch
local function GetNetworkFolder()
    local possiblePaths = {
        RS:FindFirstChild("Network"),
        RS:FindFirstChild("Remotes"),
        RS:FindFirstChild("Events"),
        RS:FindFirstChild("RemoteEvents"),
        RS:FindFirstChild("Comm"),
        RS:FindFirstChild("Packages") and RS.Packages:FindFirstChild("Knit") and RS.Packages.Knit:FindFirstChild("Services"),
    }
    
    for _, folder in pairs(possiblePaths) do
        if folder then
            return folder
        end
    end
    
    return RS
end

-- Cari inventory ikan player
local function GetPlayerInventory()
    local possiblePaths = {
        Player:FindFirstChild("Data"),
        Player:FindFirstChild("PlayerData"),
        Player:FindFirstChild("Inventory"),
        Player:FindFirstChild("Fish"),
        Player:FindFirstChild("Fishes"),
        Player:FindFirstChild("Catches"),
    }
    
    for _, data in pairs(possiblePaths) do
        if data then
            return data
        end
    end
    
    -- Cari di leaderstats atau stats
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        return leaderstats
    end
    
    return nil
end

-- Cari semua remote yang berhubungan dengan sell
local function FindAllSellRemotes()
    local sellRemotes = {}
    
    local keywords = {"sell", "shop", "vendor", "merchant", "trade", "exchange"}
    
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            for _, keyword in pairs(keywords) do
                if name:find(keyword) then
                    table.insert(sellRemotes, obj)
                    break
                end
            end
        end
    end
    
    return sellRemotes
end

-- MAIN SELL FUNCTION - JUAL SEMUA IKAN
local function SellAllFish()
    if IsSelling then return false end
    IsSelling = true
    
    print("💰 ═══════════════════════════════════")
    print("💰 SELLING ALL FISH IN INVENTORY...")
    print("💰 ═══════════════════════════════════")
    
    local soldCount = 0
    local success = false
    
    -- ═══════════════════════════════════════════
    -- METHOD 1: Fisch specific remotes
    -- ═══════════════════════════════════════════
    local networkFolder = GetNetworkFolder()
    
    -- Coba berbagai nama remote yang umum di Fisch
    local fischRemoteNames = {
        "SellFish",
        "SellAllFish", 
        "Sell",
        "SellAll",
        "sellfish",
        "sellall",
        "QuickSell",
        "InstaSell",
        "SellInventory",
        "SellCatch",
        "SellCatches",
    }
    
    for _, remoteName in pairs(fischRemoteNames) do
        local remote = RS:FindFirstChild(remoteName, true)
        if remote then
            print("💰 Found: " .. remote:GetFullName())
            
            pcall(function()
                if remote:IsA("RemoteEvent") then
                    -- Coba berbagai parameter
                    remote:FireServer()
                    task.wait(0.1)
                    remote:FireServer("All")
                    task.wait(0.1)
                    remote:FireServer("all")
                    task.wait(0.1)
                    remote:FireServer(true)
                    task.wait(0.1)
                    remote:FireServer({All = true})
                    task.wait(0.1)
                    remote:FireServer("SellAll")
                elseif remote:IsA("RemoteFunction") then
                    remote:InvokeServer()
                    task.wait(0.1)
                    remote:InvokeServer("All")
                    task.wait(0.1)
                    remote:InvokeServer(true)
                end
            end)
            
            success = true
            task.wait(0.2)
        end
    end
    
    -- ═══════════════════════════════════════════
    -- METHOD 2: Cari di Network folder
    -- ═══════════════════════════════════════════
    if networkFolder and networkFolder ~= RS then
        print("💰 Checking Network folder...")
        
        for _, obj in pairs(networkFolder:GetDescendants()) do
            if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and obj.Name:lower():find("sell") then
                print("💰 Network Remote: " .. obj.Name)
                
                pcall(function()
                    if obj:IsA("RemoteEvent") then
                        obj:FireServer()
                        obj:FireServer("All")
                        obj:FireServer(true)
                    else
                        obj:InvokeServer()
                        obj:InvokeServer("All")
                    end
                end)
                
                success = true
                task.wait(0.2)
            end
        end
    end
    
    -- ═══════════════════════════════════════════
    -- METHOD 3: Jual per-ikan dari inventory
    -- ═══════════════════════════════════════════
    local inventory = GetPlayerInventory()
    if inventory then
        print("💰 Found inventory: " .. inventory:GetFullName())
        
        -- Cari remote untuk jual individual fish
        local sellFishRemote = RS:FindFirstChild("SellFish", true) or 
                               RS:FindFirstChild("Sell", true) or
                               RS:FindFirstChild("SellItem", true)
        
        if sellFishRemote then
            for _, item in pairs(inventory:GetChildren()) do
                if item:IsA("ValueBase") or item:IsA("Folder") then
                    print("💰 Selling: " .. item.Name)
                    
                    pcall(function()
                        if sellFishRemote:IsA("RemoteEvent") then
                            sellFishRemote:FireServer(item.Name)
                            sellFishRemote:FireServer(item)
                            sellFishRemote:FireServer({Name = item.Name})
                            sellFishRemote:FireServer({Fish = item.Name})
                        else
                            sellFishRemote:InvokeServer(item.Name)
                        end
                    end)
                    
                    soldCount = soldCount + 1
                    task.wait(0.05)
                end
            end
            success = true
        end
    end
    
    -- ═══════════════════════════════════════════
    -- METHOD 4: Fire semua sell-related remotes
    -- ═══════════════════════════════════════════
    local allSellRemotes = FindAllSellRemotes()
    if #allSellRemotes > 0 then
        print("💰 Found " .. #allSellRemotes .. " sell remotes")
        
        for _, remote in pairs(allSellRemotes) do
            print("💰 Trying: " .. remote:GetFullName())
            
            pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer()
                    remote:FireServer("All")
                    remote:FireServer("all")
                    remote:FireServer(true)
                    remote:FireServer("Fish")
                    remote:FireServer({Type = "All"})
                    remote:FireServer({SellAll = true})
                elseif remote:IsA("RemoteFunction") then
                    pcall(function() remote:InvokeServer() end)
                    pcall(function() remote:InvokeServer("All") end)
                    pcall(function() remote:InvokeServer(true) end)
                end
            end)
            
            success = true
            task.wait(0.1)
        end
    end
    
    -- ═══════════════════════════════════════════
    -- METHOD 5: ProximityPrompt Sell
    -- ═══════════════════════════════════════════
    print("💰 Checking ProximityPrompts...")
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local name = obj.Name:lower()
            local parentName = obj.Parent and obj.Parent.Name:lower() or ""
            local actionText = obj.ActionText and obj.ActionText:lower() or ""
            local objectText = obj.ObjectText and obj.ObjectText:lower() or ""
            
            if name:find("sell") or parentName:find("sell") or 
               actionText:find("sell") or objectText:find("sell") then
                
                print("💰 Found sell prompt: " .. obj:GetFullName())
                
                -- Teleport ke prompt
                if obj.Parent and obj.Parent:IsA("BasePart") then
                    local promptPos = obj.Parent.Position
                    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                        Player.Character.HumanoidRootPart.CFrame = CFrame.new(promptPos + Vector3.new(0, 3, 3))
                        task.wait(0.5)
                    end
                end
                
                -- Fire prompt
                pcall(function()
                    if fireproximityprompt then
                        fireproximityprompt(obj)
                    end
                end)
                
                success = true
                task.wait(0.5)
            end
        end
    end
    
    -- ═══════════════════════════════════════════
    -- METHOD 6: GUI Sell Buttons
    -- ═══════════════════════════════════════════
    print("💰 Checking GUI sell buttons...")
    
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "FischSpamGUI" then
            for _, obj in pairs(gui:GetDescendants()) do
                if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Visible then
                    local name = obj.Name:lower()
                    local text = obj:IsA("TextButton") and obj.Text:lower() or ""
                    
                    if name:find("sell") or text:find("sell") then
                        print("💰 Found GUI button: " .. obj.Name .. " - " .. text)
                        
                        pcall(function()
                            if getconnections then
                                for _, conn in pairs(getconnections(obj.MouseButton1Click)) do
                                    conn:Fire()
                                end
                            end
                            
                            if firesignal then
                                firesignal(obj.MouseButton1Click)
                            end
                        end)
                        
                        -- Juga coba click langsung
                        pcall(function()
                            local pos = obj.AbsolutePosition + obj.AbsoluteSize / 2
                            VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                            task.wait(0.05)
                            VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                        end)
                        
                        success = true
                        task.wait(0.3)
                        
                        -- Cari "Sell All" atau "Confirm" button
                        for _, btn in pairs(gui:GetDescendants()) do
                            if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                                local btnName = btn.Name:lower()
                                local btnText = btn:IsA("TextButton") and btn.Text:lower() or ""
                                
                                if btnName:find("all") or btnText:find("all") or
                                   btnName:find("confirm") or btnText:find("confirm") or
                                   btnName:find("yes") or btnText:find("yes") then
                                    
                                    print("💰 Clicking: " .. btn.Name)
                                    
                                    pcall(function()
                                        if getconnections then
                                            for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
                                                conn:Fire()
                                            end
                                        end
                                    end)
                                    
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- ═══════════════════════════════════════════
    -- METHOD 7: Teleport ke NPC dan interact
    -- ═══════════════════════════════════════════
    print("💰 Looking for sell NPCs...")
    
    local sellNPCNames = {"Sell", "SellNPC", "Merchant", "Vendor", "Shop", "FishSeller", "Seller", "NPC"}
    
    for _, npcName in pairs(sellNPCNames) do
        local npc = workspace:FindFirstChild(npcName, true)
        if npc then
            print("💰 Found NPC: " .. npc:GetFullName())
            
            local targetPos = nil
            
            if npc:IsA("Model") then
                if npc:FindFirstChild("HumanoidRootPart") then
                    targetPos = npc.HumanoidRootPart.Position
                elseif npc.PrimaryPart then
                    targetPos = npc.PrimaryPart.Position
                else
                    local part = npc:FindFirstChildWhichIsA("BasePart")
                    if part then targetPos = part.Position end
                end
            elseif npc:IsA("BasePart") then
                targetPos = npc.Position
            end
            
            if targetPos and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 5))
                task.wait(0.5)
                
                -- Cari prompt di dekat NPC
                for _, prompt in pairs(npc:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        pcall(function()
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            end
                        end)
                        success = true
                        task.wait(0.3)
                    end
                end
                
                -- Cari ClickDetector
                for _, click in pairs(npc:GetDescendants()) do
                    if click:IsA("ClickDetector") then
                        pcall(function()
                            fireclickdetector(click)
                        end)
                        success = true
                        task.wait(0.3)
                    end
                end
            end
        end
    end
    
    -- ═══════════════════════════════════════════
    -- RESULT
    -- ═══════════════════════════════════════════
    if success then
        Stats.TotalSold = Stats.TotalSold + Stats.FishSinceLastSell
        print("💰 ═══════════════════════════════════")
        print(string.format("💰 SELL COMPLETE! Total sold: %d", Stats.TotalSold))
        print("💰 ═══════════════════════════════════")
        Stats.FishSinceLastSell = 0
    else
        print("⚠️ ═══════════════════════════════════")
        print("⚠️ Could not find sell method!")
        print("⚠️ Try these:")
        print("⚠️ 1. Go to sell NPC manually first")
        print("⚠️ 2. Check if shop GUI is open")
        print("⚠️ ═══════════════════════════════════")
        DebugRemotes()
    end
    
    IsSelling = false
    task.wait(1)
    
    return success
end

local function CheckAndSell()
    if not Config.AutoSell then return end
    if IsSelling then return end
    
    if Stats.FishSinceLastSell >= Config.SellThreshold then
        print(string.format("💰 Reached %d fish! Auto selling...", Config.SellThreshold))
        
        IsFishing = false
        IsReeling = false
        
        task.wait(0.5)
        
        SellAllFish()
        
        task.wait(1)
    end
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
-- SPAM REEL (CLICK TERUS!)
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
        Stats.FishSinceLastSell = Stats.FishSinceLastSell + 1
        print(string.format("✅ Fish #%d! (%d clicks, %dms) [%d/%d to sell]", 
            Stats.Fish, clickCount, duration, Stats.FishSinceLastSell, Config.SellThreshold))
        
        IsReeling = false
        IsFishing = false
        
        task.spawn(function()
            task.wait(0.5)
            CheckAndSell()
        end)
        
        task.wait(1)
    end)
end

local function StopSpamReel()
    IsReeling = false
    ReelThread = nil
end

-- ════════════════════════════════════════════════════════
-- DETECTION (60 FPS)
-- ════════════════════════════════════════════════════════
local ReelDetection = nil

local function StartReelDetection()
    if ReelDetection then return end
    
    ReelDetection = RunService.RenderStepped:Connect(function()
        if Config.Enabled and IsFishing and not IsReeling and not IsSelling then
            local hasUI = HasReelUI()
            if hasUI then
                print("🎯 UI DETECTED!")
                StartSpamReel()
            end
        end
    end)
    print("✅ Detection active!")
end

local function StopReelDetection()
    if ReelDetection then
        ReelDetection:Disconnect()
        ReelDetection = nil
    end
    print("❌ Detection stopped!")
end

-- ════════════════════════════════════════════════════════
-- TOGGLE FUNCTIONS
-- ════════════════════════════════════════════════════════
local ToggleButton, Glow, SellToggleButton, MainToggle

local function ToggleScript()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        if ToggleButton then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            ToggleButton.Text = "⚡ STOP"
        end
        if MainToggle then
            MainToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            MainToggle.Text = "⚡ STOP FISHING"
        end
        if Glow then
            Glow.Color = Color3.fromRGB(0, 255, 0)
        end
        StartReelDetection()
        print("✅ SPAM MODE ON!")
    else
        if ToggleButton then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            ToggleButton.Text = "🔴 START"
        end
        if MainToggle then
            MainToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            MainToggle.Text = "🎣 START FISHING"
        end
        if Glow then
            Glow.Color = Color3.fromRGB(255, 0, 255)
        end
        StopReelDetection()
        StopSpamReel()
        IsFishing = false
        print("❌ STOPPED!")
    end
end

local function ToggleAutoSell()
    Config.AutoSell = not Config.AutoSell
    
    if SellToggleButton then
        if Config.AutoSell then
            SellToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            SellToggleButton.Text = string.format("💰 Auto Sell: ON (%d Fish)", Config.SellThreshold)
            print("✅ Auto Sell ON!")
        else
            SellToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            SellToggleButton.Text = "💰 Auto Sell: OFF"
            print("❌ Auto Sell OFF!")
        end
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
-- GUI
-- ════════════════════════════════════════════════════════
print("Creating GUI...")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FischSpamGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success = pcall(function()
    ScreenGui.Parent = PlayerGui
end)

if not success then
    warn("Failed to parent GUI, retrying...")
    task.wait(1)
    ScreenGui.Parent = PlayerGui
end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.35, 0, 0.2, 0)
Main.Size = UDim2.new(0, 320, 0, 320)
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 15)
Corner.Parent = Main

Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(255, 0, 255)
Glow.Thickness = 3
Glow.Parent = Main

local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Font = Enum.Font.GothamBold
Title.Text = "🎣 FISCH AUTO + SELL ALL"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = Title

local TitleFix = Instance.new("Frame")
TitleFix.Parent = Title
TitleFix.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
TitleFix.BorderSizePixel = 0
TitleFix.Position = UDim2.new(0, 0, 0.6, 0)
TitleFix.Size = UDim2.new(1, 0, 0.4, 0)

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = Main
StatsLabel.BackgroundTransparency = 1
StatsLabel.Position = UDim2.new(0, 15, 0, 55)
StatsLabel.Size = UDim2.new(1, -30, 0, 100)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Ready to fish!"
StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsLabel.TextSize = 12
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            local status = Config.Enabled and "⚡ FISHING!" or "🔴 STOPPED"
            local currentAction = ""
            
            if Config.Enabled then
                if IsSelling then
                    currentAction = "💰💰 SELLING ALL FISH! 💰💰"
                elseif IsReeling then
                    currentAction = "⚡⚡ REELING! ⚡⚡"
                elseif IsFishing then
                    currentAction = "⏳ Waiting for bite..."
                else
                    currentAction = "🎣 Casting..."
                end
            end
            
            local sellStatus = Config.AutoSell and 
                string.format("✅ ON [%d/%d fish]", Stats.FishSinceLastSell, Config.SellThreshold) or 
                "❌ OFF"
            
            StatsLabel.Text = string.format(
                "%s\n%s\n\n🐟 Fish Caught: %d\n🎣 Total Casts: %d | 🖱️ Clicks: %d\n💰 Total Sold: %d\n📦 Auto Sell: %s",
                status,
                currentAction,
                Stats.Fish,
                Stats.Casts,
                Stats.Clicks,
                Stats.TotalSold,
                sellStatus
            )
        end)
    end
end)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = Main
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0, 15, 0, 160)
SpeedLabel.Size = UDim2.new(1, -30, 0, 20)
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.Text = "⚡ Click Speed: ULTRA FAST"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
SpeedLabel.TextSize = 11
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

-- AUTO SELL TOGGLE
SellToggleButton = Instance.new("TextButton")
SellToggleButton.Parent = Main
SellToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
SellToggleButton.BorderSizePixel = 0
SellToggleButton.Position = UDim2.new(0, 15, 0, 185)
SellToggleButton.Size = UDim2.new(1, -30, 0, 32)
SellToggleButton.Font = Enum.Font.GothamBold
SellToggleButton.Text = "💰 Auto Sell: ON (5 Fish)"
SellToggleButton.TextColor3 = Color3.new(1, 1, 1)
SellToggleButton.TextSize = 12

local SellButtonCorner = Instance.new("UICorner")
SellButtonCorner.CornerRadius = UDim.new(0, 8)
SellButtonCorner.Parent = SellToggleButton

SellToggleButton.MouseButton1Click:Connect(ToggleAutoSell)

-- SELL NOW BUTTON
local SellNowButton = Instance.new("TextButton")
SellNowButton.Parent = Main
SellNowButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
SellNowButton.BorderSizePixel = 0
SellNowButton.Position = UDim2.new(0, 15, 0, 222)
SellNowButton.Size = UDim2.new(0.5, -20, 0, 32)
SellNowButton.Font = Enum.Font.GothamBold
SellNowButton.Text = "💰 SELL ALL NOW"
SellNowButton.TextColor3 = Color3.new(1, 1, 1)
SellNowButton.TextSize = 11

local SellNowCorner = Instance.new("UICorner")
SellNowCorner.CornerRadius = UDim.new(0, 8)
SellNowCorner.Parent = SellNowButton

SellNowButton.MouseButton1Click:Connect(function()
    if not IsSelling then
        task.spawn(function()
            SellAllFish()
        end)
    end
end)

-- DEBUG BUTTON
local DebugButton = Instance.new("TextButton")
DebugButton.Parent = Main
DebugButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
DebugButton.BorderSizePixel = 0
DebugButton.Position = UDim2.new(0.5, 5, 0, 222)
DebugButton.Size = UDim2.new(0.5, -20, 0, 32)
DebugButton.Font = Enum.Font.GothamBold
DebugButton.Text = "🔍 DEBUG"
DebugButton.TextColor3 = Color3.new(1, 1, 1)
DebugButton.TextSize = 11

local DebugCorner = Instance.new("UICorner")
DebugCorner.CornerRadius = UDim.new(0, 8)
DebugCorner.Parent = DebugButton

DebugButton.MouseButton1Click:Connect(function()
    DebugRemotes()
end)

-- MAIN START/STOP BUTTON
MainToggle = Instance.new("TextButton")
MainToggle.Parent = Main
MainToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
MainToggle.BorderSizePixel = 0
MainToggle.Position = UDim2.new(0, 15, 0, 260)
MainToggle.Size = UDim2.new(1, -30, 0, 45)
MainToggle.Font = Enum.Font.GothamBold
MainToggle.Text = "🎣 START FISHING"
MainToggle.TextColor3 = Color3.new(1, 1, 1)
MainToggle.TextSize = 16

local MainToggleCorner = Instance.new("UICorner")
MainToggleCorner.CornerRadius = UDim.new(0, 10)
MainToggleCorner.Parent = MainToggle

MainToggle.MouseButton1Click:Connect(ToggleScript)

ToggleButton = MainToggle

-- ════════════════════════════════════════════════════════
-- KEYBINDS
-- ════════════════════════════════════════════════════════
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
        print("GUI Toggled:", Main.Visible)
    elseif input.KeyCode == Enum.KeyCode.F6 then
        ToggleScript()
    elseif input.KeyCode == Enum.KeyCode.F7 then
        ToggleAutoSell()
    elseif input.KeyCode == Enum.KeyCode.F8 then
        if not IsSelling then
            task.spawn(function()
                SellAllFish()
            end)
        end
    end
end)

print("════════════════════════════════════════")
print("✅ FISCH AUTO + SELL ALL LOADED!")
print("════════════════════════════════════════")
print("🎮 KEYBINDS:")
print("  DELETE = Hide/Show GUI")
print("  F6 = Start/Stop Fishing")
print("  F7 = Toggle Auto Sell")
print("  F8 = Sell All Fish NOW")
print("════════════════════════════════════════")
print("💰 Auto sells ALL fish after 5 catches!")
print("🔍 Use DEBUG button to see remotes")
print("════════════════════════════════════════")

task.wait(1)
if Main.Visible then
    print("✅ GUI is visible!")
end
