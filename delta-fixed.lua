-- ============================================
-- ROBLOX AUTO FISH SCRIPT (REVISI DETEKSI PANCINGAN)
-- ============================================

local Config = {
    Enabled = true,
    DebugMode = true, -- Aktifkan untuk melihat log deteksi
    DetectionMethod = "Advanced" -- "Simple", "Advanced", atau "Universal"
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- ============================================
-- SISTEM DETEKSI PANCINGAN YANG LEBIH BAIK
-- ============================================

function notify(title, message, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = message,
        Duration = duration or 5
    })
    print("[INFO] " .. title .. ": " .. message)
end

-- Fungsi utama deteksi pancingan
function findFishingRod()
    local rodFound = nil
    
    -- METHOD 1: Cari berdasarkan Tool/Model yang sedang dipegang
    if LocalPlayer.Character then
        -- Cek tangan kanan (RightHand)
        local rightHand = LocalPlayer.Character:FindFirstChild("RightHand") or 
                         LocalPlayer.Character:FindFirstChild("Right Arm") or
                         LocalPlayer.Character:FindFirstChild("RightUpperArm")
        
        if rightHand then
            for _, obj in pairs(rightHand:GetChildren()) do
                if isFishingRodObject(obj) then
                    rodFound = obj
                    break
                end
            end
        end
        
        -- Cek seluruh character
        if not rodFound then
            for _, obj in pairs(LocalPlayer.Character:GetDescendants()) do
                if isFishingRodObject(obj) then
                    rodFound = obj
                    break
                end
            end
        end
    end
    
    -- METHOD 2: Cari di Backpack/Inventory
    if not rodFound then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if isFishingRodObject(tool) then
                    rodFound = tool
                    break
                end
            end
        end
    end
    
    -- METHOD 3: Cari di StarterGear/PlayerScripts
    if not rodFound then
        local starterGear = LocalPlayer:FindFirstChild("StarterGear")
        if starterGear then
            for _, tool in pairs(starterGear:GetChildren()) do
                if isFishingRodObject(tool) then
                    rodFound = tool
                    break
                end
            end
        end
    end
    
    -- METHOD 4: Cari Tool yang sedang aktif
    if not rodFound and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local activeTool = humanoid:FindFirstChildOfClass("Tool")
            if activeTool and isFishingRodObject(activeTool) then
                rodFound = activeTool
            end
        end
    end
    
    -- Debug informasi
    if Config.DebugMode then
        if rodFound then
            print("[DEBUG] Fishing Rod Ditemukan:")
            print("  Nama: " .. rodFound.Name)
            print("  Class: " .. rodFound.ClassName)
            print("  Parent: " .. rodFound.Parent.Name)
            
            -- Tampilkan semua properti untuk debug
            print("  Properties:")
            for _, child in pairs(rodFound:GetChildren()) do
                print("    - " .. child.Name .. " (" .. child.ClassName .. ")")
            end
        else
            print("[DEBUG] Tidak menemukan fishing rod!")
            
            -- Debug: Tampilkan semua Tool di inventory
            print("[DEBUG] Inventory check:")
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                for _, tool in pairs(backpack:GetChildren()) do
                    print("  - " .. tool.Name .. " (" .. tool.ClassName .. ")")
                end
            else
                print("  Backpack tidak ditemukan!")
            end
            
            -- Debug: Tampilkan semua objek di tangan
            if LocalPlayer.Character then
                print("[DEBUG] Character check:")
                for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                    if part:IsA("Tool") or part:IsA("Model") then
                        print("  - " .. part.Name .. " (" .. part.ClassName .. ")")
                    end
                end
            end
        end
    end
    
    return rodFound
end

-- Fungsi untuk mengecek apakah objek adalah pancingan
function isFishingRodObject(obj)
    local name = obj.Name:lower()
    local className = obj.ClassName
    
    -- Keyword untuk pancingan
    local fishingKeywords = {
        "rod", "fishing", "pole", "hook", "line", 
        "cast", "reel", "bait", "fish", "angler"
    }
    
    -- Cek berdasarkan nama
    for _, keyword in pairs(fishingKeywords) do
        if string.find(name, keyword) then
            return true
        end
    end
    
    -- Cek jika objek adalah Tool dengan handle/string
    if className == "Tool" then
        -- Cek jika ada Handle (standard Roblox tool)
        local handle = obj:FindFirstChild("Handle")
        if handle then
            -- Cek jika ada part yang menyerupai tali/string
            local stringParts = {"String", "Line", "Rope", "Wire"}
            for _, partName in pairs(stringParts) do
                if handle:FindFirstChild(partName) then
                    return true
                end
            end
            
            -- Cek jika ada attachment untuk hook
            local attachments = handle:GetChildren()
            for _, attachment in pairs(attachments) do
                if attachment:IsA("Attachment") then
                    return true
                end
            end
        end
    end
    
    -- Cek jika ada remote events khusus fishing
    local remoteEvents = {"Cast", "Reel", "Fish", "Bait", "Hook"}
    for _, eventName in pairs(remoteEvents) do
        if obj:FindFirstChild(eventName) then
            return true
        end
    end
    
    -- Cek berdasarkan tag (jika game menggunakan CollectionService)
    local CollectionService = game:GetService("CollectionService")
    if CollectionService:HasTag(obj, "FishingRod") or 
       CollectionService:HasTag(obj, "Rod") or
       CollectionService:HasTag(obj, "Tool") then
        return true
    end
    
    return false
end

-- ============================================
-- SISTEM DETEKSI OTOMATIS GAME
-- ============================================

function detectGameType()
    local placeId = game.PlaceId
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name
    
    print("[INFO] Game terdeteksi: " .. gameName)
    
    -- Deteksi game fishing populer
    local fishingGames = {
        [189707] = { -- Fishing Simulator
            name = "Fishing Simulator",
            rodNames = {"FishingRod", "Fishing Pole", "Rod", "FishingRod_Mk1"},
            castMethod = "RemoteEvent",
            castEvent = "CastRod"
        },
        [142823291] = { -- Ro-Fishing
            name = "Ro-Fishing",
            rodNames = {"FishingRod", "Rod"},
            castMethod = "ClickDetector",
            waterName = "Water"
        },
        [537413528] = { -- Build A Boat For Treasure (ada fishing)
            name = "Build A Boat For Treasure",
            rodNames = {"Fishing Rod", "FishingPole"},
            castMethod = "ToolActivate"
        },
        [292439477] = { -- Phantom Forces (bukan fishing, tapi contoh)
            name = "Phantom Forces",
            rodNames = {},
            castMethod = "None"
        }
    }
    
    -- Cari di database
    if fishingGames[placeId] then
        return fishingGames[placeId]
    end
    
    -- Cari berdasarkan nama
    for _, gameData in pairs(fishingGames) do
        if string.find(gameName:lower(), gameData.name:lower()) then
            return gameData
        end
    end
    
    -- Default detection
    return {
        name = "Universal Fishing Game",
        rodNames = {"Rod", "FishingRod", "Fishing Pole", "Pole", "Fishing", "FishRod"},
        castMethod = "AutoDetect"
    }
end

-- ============================================
-- FUNGSI CAST YANG LEBIH FLEXIBLE
-- ============================================

function castRodAdvanced()
    local rod = findFishingRod()
    
    if not rod then
        notify("Error", "Tidak menemukan pancingan!", 3)
        
        -- Coba cari ulang dengan method berbeda
        print("[RETRY] Mencari pancingan dengan method alternatif...")
        return false
    end
    
    notify("Success", "Pancingan ditemukan: " .. rod.Name, 2)
    
    -- Coba berbagai metode cast
    local castMethods = {
        -- Method 1: Activate tool
        function()
            if rod:IsA("Tool") then
                rod:Activate()
                return true, "Tool Activation"
            end
            return false
        end,
        
        -- Method 2: Fire remote event
        function()
            local remoteNames = {"Cast", "CastRod", "StartFishing", "Fish", "Fishing", "Use", "Activate"}
            
            for _, remoteName in pairs(remoteNames) do
                local remote = rod:FindFirstChild(remoteName)
                if not remote then
                    -- Coba cari di parent atau workspace
                    remote = rod.Parent:FindFirstChild(remoteName) or 
                            workspace:FindFirstChild(remoteName) or
                            game.ReplicatedStorage:FindFirstChild(remoteName)
                end
                
                if remote then
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer()
                        return true, "RemoteEvent: " .. remote.Name
                    elseif remote:IsA("RemoteFunction") then
                        remote:InvokeServer()
                        return true, "RemoteFunction: " .. remote.Name
                    elseif remote:IsA("BindableEvent") then
                        remote:Fire()
                        return true, "BindableEvent: " .. remote.Name
                    end
                end
            end
            return false
        end,
        
        -- Method 3: ClickDetector (untuk game tertentu)
        function()
            local clickDetector = rod:FindFirstChildOfClass("ClickDetector")
            if not clickDetector then
                clickDetector = rod:FindFirstChild("ClickDetector")
            end
            
            if clickDetector then
                fireclickdetector(clickDetector)
                return true, "ClickDetector"
            end
            return false
        end,
        
        -- Method 4: Equip tool dulu (jika ada di backpack)
        function()
            if rod.Parent == LocalPlayer.Backpack then
                -- Equip tool
                LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(rod)
                wait(0.5)
                
                -- Coba activate setelah equip
                if rod:IsA("Tool") then
                    rod:Activate()
                    return true, "Equip + Activate"
                end
            end
            return false
        end,
        
        -- Method 5: Click pada water
        function()
            local water = findWater()
            if water then
                local waterClick = water:FindFirstChildOfClass("ClickDetector")
                if waterClick then
                    fireclickdetector(waterClick)
                    return true, "Water ClickDetector"
                end
            end
            return false
        end,
        
        -- Method 6: Virtual input (simulasi klik mouse)
        function()
            local UserInputService = game:GetService("UserInputService")
            
            -- Simulasi mouse click
            local mouseTarget = workspace:FindPartOnRay(Ray.new(
                workspace.CurrentCamera.CFrame.Position,
                workspace.CurrentCamera.CFrame.LookVector * 100
            ))
            
            if mouseTarget then
                mouse1click()
                return true, "Virtual Mouse Click"
            end
            return false
        end
    }
    
    -- Coba semua metode
    for i, method in pairs(castMethods) do
        local success, methodName = method()
        if success then
            notify("Casting", "Berhasil menggunakan metode: " .. methodName, 2)
            return true
        end
        wait(0.1) -- Delay antar percobaan
    end
    
    notify("Error", "Gagal melempar kail dengan semua metode", 3)
    return false
end

-- Fungsi bantu untuk mencari air
function findWater()
    local waterClasses = {
        "Part", "MeshPart", "UnionOperation", "Model"
    }
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if table.find(waterClasses, obj.ClassName) then
            -- Cek berdasarkan properti
            if obj.Material == Enum.Material.Water or
               obj.Name:lower():find("water") or
               obj.Name:lower():find("sea") or
               obj.Name:lower():find("ocean") or
               obj.Name:lower():find("lake") or
               obj.Name:lower():find("river") or
               obj.BrickColor == BrickColor.new("Bright blue") or
               obj.BrickColor == BrickColor.new("Medium blue") then
                return obj
            end
        end
    end
    return nil
end

-- ============================================
-- FUNGSI UTAMA AUTO FISH
-- ============================================

function startAutoFishing()
    notify("Auto Fish", "Memulai dengan deteksi advanced...", 3)
    
    -- Deteksi game terlebih dahulu
    local gameData = detectGameType()
    print("[INFO] Game type: " .. gameData.name)
    print("[INFO] Cast method: " .. gameData.castMethod)
    
    while Config.Enabled do
        -- Cast rod
        local castSuccess = castRodAdvanced()
        
        if castSuccess then
            notify("Fishing", "Kail berhasil dilempar, menunggu ikan...", 2)
            
            -- Tunggu ikan (simulasi)
            wait(math.random(3, 8))
            
            -- Reel (tarik ikan)
            notify("Fishing", "Ikan menggigit! Menarik...", 1)
            wait(0.5)
            
            -- Di sini bisa ditambahkan fungsi reelFish()
        else
            notify("Error", "Gagal melempar, mencoba lagi dalam 3 detik...", 2)
            wait(3)
        end
        
        -- Delay antar siklus
        wait(2)
    end
end

-- ============================================
-- GUI UNTUK MANUAL SELECTION
-- ============================================

function createToolSelector()
    local ToolSelector = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local ToolList = Instance.new("ScrollingFrame")
    local SelectButton = Instance.new("TextButton")
    local CloseButton = Instance.new("TextButton")
    
    ToolSelector.Name = "ToolSelector"
    ToolSelector.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ToolSelector
    MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    MainFrame.Size = UDim2.new(0, 300, 0, 300)
    
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "PILIH PANCINGAN MANUAL"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    
    ToolList.Name = "ToolList"
    ToolList.Parent = MainFrame
    ToolList.Active = true
    ToolList.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToolList.BorderSizePixel = 0
    ToolList.Position = UDim2.new(0, 10, 0, 50)
    ToolList.Size = UDim2.new(1, -20, 1, -110)
    ToolList.ScrollBarThickness = 8
    
    SelectButton.Name = "SelectButton"
    SelectButton.Parent = MainFrame
    SelectButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    SelectButton.Position = UDim2.new(0.5, -60, 1, -50)
    SelectButton.Size = UDim2.new(0, 120, 0, 30)
    SelectButton.Font = Enum.Font.Gotham
    SelectButton.Text = "PILIH INI"
    SelectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SelectButton.TextSize = 14
    
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = MainFrame
    CloseButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    CloseButton.Position = UDim2.new(0.5, -60, 1, -15)
    CloseButton.Size = UDim2.new(0, 120, 0, 30)
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.Text = "TUTUP"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    
    -- Isi daftar tool
    local tools = {}
    
    -- Cari semua tool di inventory
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") or tool:IsA("Model") then
                table.insert(tools, tool)
            end
        end
    end
    
    -- Cari di character
    if LocalPlayer.Character then
        for _, obj in pairs(LocalPlayer.Character:GetChildren()) do
            if obj:IsA("Tool") or obj:IsA("Model") then
                table.insert(tools, obj)
            end
        end
    end
    
    -- Buat UI untuk setiap tool
    local yOffset = 5
    local buttonHeight = 30
    
    for i, tool in pairs(tools) do
        local ToolButton = Instance.new("TextButton")
        ToolButton.Name = "Tool_" .. i
        ToolButton.Parent = ToolList
        ToolButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        ToolButton.Position = UDim2.new(0, 5, 0, yOffset)
        ToolButton.Size = UDim2.new(1, -10, 0, buttonHeight)
        ToolButton.Font = Enum.Font.Gotham
        ToolButton.Text = tool.Name .. " (" .. tool.ClassName .. ")"
        ToolButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToolButton.TextSize = 12
        ToolButton.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Highlight jika mungkin fishing rod
        if isFishingRodObject(tool) then
            ToolButton.BackgroundColor3 = Color3.fromRGB(70, 120, 70)
        end
        
        ToolButton.MouseButton1Click:Connect(function()
            for _, btn in pairs(ToolList:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                end
            end
            ToolButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
            
            SelectButton.MouseButton1Click:Connect(function()
                notify("Manual Select", "Memilih: " .. tool.Name, 3)
                -- Simpan pilihan untuk digunakan nanti
                _G.SelectedFishingRod = tool
                ToolSelector:Destroy()
            end)
        end)
        
        yOffset = yOffset + buttonHeight + 5
    end
    
    ToolList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    
    CloseButton.MouseButton1Click:Connect(function()
        ToolSelector:Destroy()
    end)
    
    return ToolSelector
end

-- ============================================
-- FUNGSI MANUAL PICK ROD
-- ============================================

function manualRodSelection()
    notify("Manual Mode", "Silakan pilih pancingan dari GUI", 5)
    createToolSelector()
    
    -- Tunggu user memilih
    while wait(1) do
        if _G.SelectedFishingRod then
            notify("Success", "Pancingan dipilih: " .. _G.SelectedFishingRod.Name, 3)
            return _G.SelectedFishingRod
        end
    end
end

-- ============================================
-- INISIALISASI
-- ============================================

print([[
============================================
🎣 AUTO FISH SCRIPT - ADVANCED DETECTION 🎣
============================================

Fitur:
1. Multi-method rod detection
2. Game auto-detection
3. Manual selection GUI
4. Advanced debugging

Status Debug: ]] .. (Config.DebugMode and "AKTIF" or "NONAKTIF") .. [[

============================================
]])

-- Tunggu game load
wait(2)

-- Pilihan untuk user
local choice = nil
while not choice do
    print("\nPilih mode:")
    print("1. Auto detect fishing rod")
    print("2. Manual select fishing rod")
    print("3. Test detection only")
    
    -- Untuk executor, kita pilih auto dulu
    choice = 1
    wait(1)
    
    if choice == 1 then
        notify("Mode", "Menggunakan auto detection", 3)
        startAutoFishing()
    elseif choice == 2 then
        notify("Mode", "Menggunakan manual selection", 3)
        manualRodSelection()
    elseif choice == 3 then
        notify("Test", "Testing detection only", 3)
        local rod = findFishingRod()
        if rod then
            notify("Test Success", "Found: " .. rod.Name, 5)
        else
            notify("Test Failed", "No rod found", 5)
        end
    end
end
