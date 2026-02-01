-- ============================================
-- ROBLOX AUTO FISH SCRIPT (Lua - Untuk Executor)
-- ============================================
-- Script ini untuk game fishing di Roblox
-- Harap gunakan dengan bijak dan bertanggung jawab

-- Nama Game yang Support: Fishing Simulator, Ro-Fishing, dll
-- Compatible dengan: Synapse X, KRNL, Script-Ware, dll

-- ============================================
-- KONFIGURASI
-- ============================================
local Config = {
    Enabled = true,               -- Aktif/Nonaktif auto fish
    AutoCast = true,              -- Auto lempar kail
    AutoReel = true,              -- Auto tarik ikan
    AutoSell = false,             -- Auto jual ikan (jika ada fitur)
    Delay = {                     -- Pengaturan delay
        AfterCast = 2,            -- Delay setelah lempar kail (detik)
        AfterBite = 0.5,          -- Delay setelah ikan menggigit (detik)
        BetweenFish = 1,          -- Delay antara ikan (detik)
        SellDelay = 3             -- Delay setelah jual (detik)
    },
    Notifications = true,         -- Tampilkan notifikasi
    SoundAlert = false,           -- Bunyi alert (jika support)
    AntiAFK = true,               -- Anti AFK system
    DebugMode = false             -- Mode debug untuk testing
}

-- ============================================
-- VARIABEL GLOBAL
-- ============================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")

local Fishing = {}
local Connections = {}
local IsFishing = false
local LastActionTime = tick()
local FishCaught = 0
local StartTime = tick()

-- ============================================
-- FUNGSI UTILITAS
-- ============================================
function notify(title, message, duration)
    if Config.Notifications then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = message,
            Duration = duration or 5,
            Icon = "rbxassetid://4483345998"
        })
    end
    if Config.DebugMode then
        print("[DEBUG] " .. title .. ": " .. message)
    end
end

function waitForChild(parent, childName, timeout)
    timeout = timeout or 10
    local startTime = tick()
    while tick() - startTime < timeout do
        local child = parent:FindFirstChild(childName)
        if child then return child end
        wait(0.1)
    end
    return nil
end

function isGameLoaded()
    return LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

-- ============================================
-- FUNGSI DETEKSI GAME FISHING
-- ============================================
function detectFishingGame()
    local gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
    notify("Auto Fish", "Memulai di: " .. gameName, 3)
    
    -- Deteksi game fishing populer
    local gameSignatures = {
        ["Fishing Simulator"] = {
            rodName = "FishingRod",
            waterName = "Water",
            fishName = "Fish",
            sellButton = "Sell"
        },
        ["Ro-Fishing"] = {
            rodName = "FishingRod",
            waterName = "Water",
            fishName = "Fish",
            sellButton = "SellButton"
        },
        ["Fishing Empire"] = {
            rodName = "Rod",
            waterName = "Ocean",
            fishName = "Catch",
            sellButton = "Trade"
        }
    }
    
    for gamePattern, data in pairs(gameSignatures) do
        if string.find(gameName:lower(), gamePattern:lower()) then
            notify("Game Terdeteksi", "Menggunakan preset: " .. gamePattern, 3)
            return data
        end
    end
    
    -- Default detection
    notify("Auto Fish", "Game tidak dikenal, menggunakan mode universal", 3)
    return {
        rodName = "Rod",
        waterName = "Water",
        fishName = "Fish",
        sellButton = "Sell"
    }
end

local GameData = detectFishingGame()

-- ============================================
-- FUNGSI FISHING UTAMA
-- ============================================
function findFishingRod()
    if LocalPlayer.Character then
        -- Cari di backpack
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, item in pairs(backpack:GetChildren()) do
                if string.find(item.Name:lower(), GameData.rodName:lower()) or 
                   string.find(item.Name:lower(), "rod") or
                   string.find(item.Name:lower(), "fishing") then
                    return item
                end
            end
        end
        
        -- Cari di tangan character
        for _, item in pairs(LocalPlayer.Character:GetChildren()) do
            if string.find(item.Name:lower(), GameData.rodName:lower()) or 
               string.find(item.Name:lower(), "rod") then
                return item
            end
        end
    end
    return nil
end

function findWater()
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name:lower():find(GameData.waterName:lower()) or 
           obj.Name:lower():find("water") or 
           obj.Name:lower():find("sea") or 
           obj.Name:lower():find("ocean") or 
           obj.Name:lower():find("lake") or
           obj.ClassName == "Part" and (obj.Material == Enum.Material.Water or obj.BrickColor == BrickColor.new("Bright blue")) then
            return obj
        end
    end
    return nil
end

function castRod()
    if not Config.AutoCast then return false end
    
    local rod = findFishingRod()
    if not rod then
        notify("Error", "Tidak menemukan pancingan", 3)
        return false
    end
    
    -- Simulasi klik/tombol cast
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        -- Coba berbagai metode cast
        local success = false
        
        -- Method 1: Activate tool
        if rod:IsA("Tool") then
            rod:Activate()
            success = true
        end
        
        -- Method 2: Fire remote event
        local remotes = {"CastRod", "StartFishing", "FishCast", "FishingCast"}
        for _, remoteName in pairs(remotes) do
            local remote = rod:FindFirstChild(remoteName) or 
                          Workspace:FindFirstChild(remoteName) or
                          game.ReplicatedStorage:FindFirstChild(remoteName)
            
            if remote and remote:IsA("RemoteEvent") then
                remote:FireServer()
                success = true
                break
            elseif remote and remote:IsA("RemoteFunction") then
                remote:InvokeServer()
                success = true
                break
            end
        end
        
        -- Method 3: Click on water
        if not success then
            local water = findWater()
            if water then
                fireclickdetector(water:FindFirstChildOfClass("ClickDetector"), 0)
                success = true
            end
        end
        
        if success then
            notify("Memancing", "Kail dilempar...", 2)
            LastActionTime = tick()
            return true
        end
    end
    
    return false
end

function detectFishBite()
    -- Method 1: Deteksi perubahan warna/visual
    local screenGui = LocalPlayer:FindFirstChild("PlayerGui")
    if screenGui then
        for _, gui in pairs(screenGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                -- Cari indikator ikan menggigit
                local indicators = {"Bite", "Pull", "Fish", "Catch", "Reel", "!"}
                for _, indicator in pairs(indicators) do
                    local element = gui:FindFirstChild(indicator, true)
                    if element and element:IsA("TextLabel") and element.Visible then
                        return true
                    elseif element and element:IsA("ImageLabel") and element.Visible then
                        return true
                    elseif element and element:IsA("Frame") and element.Visible then
                        return true
                    end
                end
            end
        end
    end
    
    -- Method 2: Deteksi suara (jika ada)
    local sounds = {"BiteSound", "FishBite", "PullSound"}
    for _, soundName in pairs(sounds) do
        local sound = Workspace:FindFirstChild(soundName) or 
                     game.ReplicatedStorage:FindFirstChild(soundName)
        if sound and sound:IsA("Sound") and sound.Playing then
            return true
        end
    end
    
    -- Method 3: Deteksi partikel/efek visual
    if LocalPlayer.Character then
        local rod = findFishingRod()
        if rod then
            for _, effect in pairs(rod:GetDescendants()) do
                if (effect:IsA("ParticleEmitter") and effect.Enabled) or
                   (effect:IsA("BillboardGui") and effect.Visible) then
                    return true
                end
            end
        end
    end
    
    return false
end

function reelFish()
    if not Config.AutoReel then return false end
    
    -- Coba berbagai metode reel
    local methods = {
        -- Method 1: Tekan tombol reel (E, F, R, atau Spasi)
        function()
            local keys = {Enum.KeyCode.E, Enum.KeyCode.F, Enum.KeyCode.R, Enum.KeyCode.Space}
            for _, key in pairs(keys) do
                game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, nil)
                wait(0.05)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, key, false, nil)
            end
            return true
        end,
        
        -- Method 2: Fire remote event
        function()
            local remotes = {"Reel", "CatchFish", "FishReel", "ReelFish"}
            for _, remoteName in pairs(remotes) do
                local remote = Workspace:FindFirstChild(remoteName) or 
                              game.ReplicatedStorage:FindFirstChild(remoteName)
                
                if remote and remote:IsA("RemoteEvent") then
                    remote:FireServer()
                    return true
                elseif remote and remote:IsA("RemoteFunction") then
                    remote:InvokeServer()
                    return true
                end
            end
            return false
        end,
        
        -- Method 3: Click reel button di GUI
        function()
            local screenGui = LocalPlayer:FindFirstChild("PlayerGui")
            if screenGui then
                local buttons = {"ReelButton", "CatchButton", "PullButton", "Button"}
                for _, gui in pairs(screenGui:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        for _, btnName in pairs(buttons) do
                            local button = gui:FindFirstChild(btnName, true)
                            if button and button:IsA("TextButton") and button.Visible then
                                firesignal(button.MouseButton1Click)
                                return true
                            elseif button and button:IsA("ImageButton") and button.Visible then
                                firesignal(button.MouseButton1Click)
                                return true
                            end
                        end
                    end
                end
            end
            return false
        end
    }
    
    for _, method in pairs(methods) do
        if method() then
            FishCaught = FishCaught + 1
            notify("Berhasil!", "Ikan berhasil ditangkap! (" .. FishCaught .. ")", 2)
            return true
        end
        wait(0.1)
    end
    
    return false
end

function autoSell()
    if not Config.AutoSell then return end
    
    -- Cari NPC atau tempat jual
    local sellAreas = {"Sell", "Market", "Shop", "Store", "Trader"}
    for _, areaName in pairs(sellAreas) do
        local sellPart = Workspace:FindFirstChild(areaName)
        if sellPart then
            local clickDetector = sellPart:FindFirstChildOfClass("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector, 0)
                notify("Auto Sell", "Menjual ikan...", 3)
                wait(Config.Delay.SellDelay)
                
                -- Coba klik semua button jual di GUI
                local screenGui = LocalPlayer:FindFirstChild("PlayerGui")
                if screenGui then
                    for _, gui in pairs(screenGui:GetChildren()) do
                        if gui:IsA("ScreenGui") then
                            local sellButtons = {"SellAll", "Sell", "Confirm", "Yes"}
                            for _, btnName in pairs(sellButtons) do
                                local button = gui:FindFirstChild(btnName, true)
                                if button and button:IsA("TextButton") and button.Visible then
                                    firesignal(button.MouseButton1Click)
                                    wait(0.5)
                                end
                            end
                        end
                    end
                end
                break
            end
        end
    end
end

-- ============================================
-- SISTEM ANTI-AFK
-- ============================================
function setupAntiAFK()
    if not Config.AntiAFK then return end
    
    local virtualUser = game:GetService("VirtualUser")
    local connection
    
    connection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new())
        if Config.DebugMode then
            print("[ANTI-AFK] Mencegah AFK...")
        end
    end)
    
    table.insert(Connections, connection)
    notify("Anti-AFK", "Sistem Anti-AFK diaktifkan", 3)
end

-- ============================================
-- LOOP FISHING UTAMA
-- ============================================
function startFishingLoop()
    if IsFishing then return end
    IsFishing = true
    
    notify("Auto Fish", "Memulai auto fishing...", 3)
    setupAntiAFK()
    
    while Config.Enabled and IsFishing do
        if not isGameLoaded() then
            wait(5)
            notify("Menunggu", "Menunggu game load...", 3)
            continue
        end
        
        -- Step 1: Cast rod
        if castRod() then
            wait(Config.Delay.AfterCast)
            
            -- Step 2: Tunggu ikan menggigit
            local biteDetected = false
            local waitTime = 0
            local maxWaitTime = 30 -- Maksimal 30 detik menunggu
            
            while waitTime < maxWaitTime do
                if detectFishBite() then
                    biteDetected = true
                    break
                end
                
                -- Cek juga jika ada fish di hook
                if LocalPlayer.Character then
                    local fishOnHook = LocalPlayer.Character:FindFirstChild(GameData.fishName) or
                                      Workspace:FindFirstChild(GameData.fishName)
                    if fishOnHook then
                        biteDetected = true
                        break
                    end
                end
                
                wait(0.5)
                waitTime = waitTime + 0.5
                
                -- Jika timeout, break
                if waitTime >= maxWaitTime then
                    notify("Timeout", "Tidak ada ikan yang menggigit", 2)
                    break
                end
            end
            
            -- Step 3: Reel jika ikan menggigit
            if biteDetected then
                wait(Config.Delay.AfterBite)
                if reelFish() then
                    -- Optional: Auto sell
                    if Config.AutoSell and FishCaught % 5 == 0 then -- Jual setiap 5 ikan
                        autoSell()
                    end
                end
            end
            
            -- Step 4: Tunggu sebelum cast lagi
            wait(Config.Delay.BetweenFish)
            
            -- Update statistik
            local elapsed = math.floor(tick() - StartTime)
            local fishPerMinute = FishCaught / (elapsed / 60)
            
            if Config.DebugMode then
                print(string.format("[STAT] Ikan: %d | Waktu: %ds | FPM: %.1f", 
                    FishCaught, elapsed, fishPerMinute))
            end
        else
            wait(3)
        end
        
        -- Small delay untuk mencegah lag
        RunService.Heartbeat:Wait()
    end
    
    IsFishing = false
    notify("Auto Fish", "Auto fishing dihentikan", 3)
end

function stopFishingLoop()
    IsFishing = false
    Config.Enabled = false
end

-- ============================================
-- GUI CONTROL PANEL
-- ============================================
function createControlPanel()
    -- Hapus GUI lama jika ada
    local existingGUI = LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("AutoFishGUI")
    if existingGUI then existingGUI:Destroy() end
    
    -- Buat ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoFishGUI"
    screenGui.Parent = LocalPlayer:FindFirstChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    title.Text = "🛠️ AUTO FISH CONTROL PANEL 🎣"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title
    
    -- Status Text
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, -20, 0, 30)
    statusText.Position = UDim2.new(0, 10, 0, 50)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Status: " .. (Config.Enabled and "🟢 AKTIF" or "🔴 NONAKTIF")
    statusText.TextColor3 = Config.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    statusText.Font = Enum.Font.Gotham
    statusText.TextSize = 14
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Name = "StatusText"
    statusText.Parent = mainFrame
    
    -- Stats Text
    local statsText = Instance.new("TextLabel")
    statsText.Size = UDim2.new(1, -20, 0, 60)
    statsText.Position = UDim2.new(0, 10, 0, 85)
    statsText.BackgroundTransparency = 1
    statsText.Text = "📊 STATISTIK:\nIkan: 0\nWaktu: 0s\nFPM: 0.0"
    statsText.TextColor3 = Color3.fromRGB(200, 200, 255)
    statsText.Font = Enum.Font.Gotham
    statsText.TextSize = 12
    statsText.TextXAlignment = Enum.TextXAlignment.Left
    statsText.TextYAlignment = Enum.TextYAlignment.Top
    statsText.Name = "StatsText"
    statsText.Parent = mainFrame
    
    -- Toggle Button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, -20, 0, 40)
    toggleButton.Position = UDim2.new(0, 10, 0, 155)
    toggleButton.BackgroundColor3 = Config.Enabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 200, 50)
    toggleButton.Text = Config.Enabled and "⏸️ STOP FISHING" or "▶️ START FISHING"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 14
    toggleButton.Parent = mainFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = toggleButton
    
    -- Settings Frame
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Size = UDim2.new(1, -20, 0, 170)
    settingsFrame.Position = UDim2.new(0, 10, 0, 205)
    settingsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    settingsFrame.BorderSizePixel = 0
    settingsFrame.Parent = mainFrame
    
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 6)
    settingsCorner.Parent = settingsFrame
    
    local settingsTitle = Instance.new("TextLabel")
    settingsTitle.Size = UDim2.new(1, 0, 0, 30)
    settingsTitle.Position = UDim2.new(0, 0, 0, 0)
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Text = "⚙️ PENGATURAN"
    settingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsTitle.Font = Enum.Font.GothamBold
    settingsTitle.TextSize = 14
    settingsTitle.Parent = settingsFrame
    
    -- Auto Cast Toggle
    local autoCastToggle = createToggle("Auto Cast", 35, Config.AutoCast, settingsFrame)
    local autoReelToggle = createToggle("Auto Reel", 60, Config.AutoReel, settingsFrame)
    local autoSellToggle = createToggle("Auto Sell", 85, Config.AutoSell, settingsFrame)
    local notificationsToggle = createToggle("Notifications", 110, Config.Notifications, settingsFrame)
    local antiAFKToggle = createToggle("Anti-AFK", 135, Config.AntiAFK, settingsFrame)
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton
    
    -- Fungsi toggle
    toggleButton.MouseButton1Click:Connect(function()
        Config.Enabled = not Config.Enabled
        toggleButton.Text = Config.Enabled and "⏸️ STOP FISHING" or "▶️ START FISHING"
        toggleButton.BackgroundColor3 = Config.Enabled and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 200, 50)
        statusText.Text = "Status: " .. (Config.Enabled and "🟢 AKTIF" or "🔴 NONAKTIF")
        statusText.TextColor3 = Config.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        
        if Config.Enabled then
            spawn(startFishingLoop)
        else
            stopFishingLoop()
        end
    end)
    
    -- Update stats loop
    spawn(function()
        while screenGui and screenGui.Parent do
            local elapsed = math.floor(tick() - StartTime)
            local fishPerMinute = FishCaught > 0 and FishCaught / (elapsed / 60) or 0
            statsText.Text = string.format("📊 STATISTIK:\nIkan: %d\nWaktu: %ds\nFPM: %.1f", 
                FishCaught, elapsed, fishPerMinute)
            wait(1)
        end
    end)
    
    -- Close button
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    return screenGui
end

function createToggle(label, yPos, initialState, parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 20)
    frame.Position = UDim2.new(0, 5, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.7, 0, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = "  " .. label
    labelText.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = frame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 40, 0, 20)
    toggleButton.Position = UDim2.new(1, -40, 0, 0)
    toggleButton.BackgroundColor3 = initialState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
    toggleButton.Text = initialState and "ON" or "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.Gotham
    toggleButton.TextSize = 11
    toggleButton.Name = label
    toggleButton.Parent = frame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = toggleButton
    
    toggleButton.MouseButton1Click:Connect(function()
        local newState = not (toggleButton.Text == "ON")
        toggleButton.Text = newState and "ON" or "OFF"
        toggleButton.BackgroundColor3 = newState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
        
        -- Update config
        if label == "Auto Cast" then
            Config.AutoCast = newState
        elseif label == "Auto Reel" then
            Config.AutoReel = newState
        elseif label == "Auto Sell" then
            Config.AutoSell = newState
        elseif label == "Notifications" then
            Config.Notifications = newState
        elseif label == "Anti-AFK" then
            Config.AntiAFK = newState
        end
    end)
    
    return toggleButton
end

-- ============================================
-- FUNGSI INISIALISASI
-- ============================================
function initialize()
    -- Tunggu game load
    while not isGameLoaded() do
        wait(1)
    end
    
    notify("Auto Fish", "Script loaded successfully!", 3)
    
    -- Buat control panel
    createControlPanel()
    
    -- Start fishing jika enabled
    if Config.Enabled then
        spawn(startFishingLoop)
    end
end

-- ============================================
-- COMMANDS & KEYBINDS
-- ============================================
-- Hotkey untuk toggle (F6)
local toggleConnection
toggleConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.F6 then
            Config.Enabled = not Config.Enabled
            
            if Config.Enabled then
                notify("Auto Fish", "AUTO FISH DIHIDUPKAN (F6)", 2)
                spawn(startFishingLoop)
            else
                notify("Auto Fish", "Auto fish dimatikan (F6)", 2)
                stopFishingLoop()
            end
        elseif input.KeyCode == Enum.KeyCode.F7 then
            -- Toggle GUI
            local gui = LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("AutoFishGUI")
            if gui then
                gui.Enabled = not gui.Enabled
            else
                createControlPanel()
            end
        elseif input.KeyCode == Enum.KeyCode.F8 then
            -- Reset stats
            FishCaught = 0
            StartTime = tick()
            notify("Reset", "Statistik direset", 2)
        end
    end
end)

table.insert(Connections, toggleConnection)

-- ============================================
-- CLEANUP FUNCTION
-- ============================================
function cleanup()
    IsFishing = false
    Config.Enabled = false
    
    -- Putuskan semua koneksi
    for _, connection in pairs(Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    -- Hapus GUI
    local gui = LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("AutoFishGUI")
    if gui then gui:Destroy() end
    
    notify("Auto Fish", "Script dihentikan dan dibersihkan", 3)
end

-- ============================================
-- EXECUTE SCRIPT
-- ============================================
-- Tunggu player load
if not LocalPlayer or not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

-- Inisialisasi setelah delay kecil
wait(2)
initialize()

-- Hook cleanup ke karakter removal
LocalPlayer.CharacterRemoving:Connect(cleanup)
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        cleanup()
    end
end)

-- ============================================
-- INFORMASI PENGGUNAAN
-- ============================================
print([[
============================================
🎣 AUTO FISH SCRIPT LOADED 🎣
============================================
HOTKEYS:
• F6 - Toggle Auto Fish
• F7 - Toggle Control Panel
• F8 - Reset Statistics

FITUR:
• Auto Cast & Reel
• Auto Sell (opsional)
• Anti-AFK System
• Statistics Tracker
• Control Panel GUI

STATUS: ]] .. (Config.Enabled and "AKTIF" or "NONAKTIF") .. [[

============================================
]])

-- Return config untuk modifikasi manual
return {
    Config = Config,
    start = startFishingLoop,
    stop = stopFishingLoop,
    cleanup = cleanup
}
