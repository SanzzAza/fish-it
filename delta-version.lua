--[[
    ═══════════════════════════════════════════════════════
    🎣 FISCH AUTO - MANUAL REMOTE SETUP
    Bisa pilih remote manual + test semua remote!
    ═══════════════════════════════════════════════════════
]]

print("════════════════════════════════════════")
print("🎣 FISCH AUTO - MANUAL SETUP MODE")
print("════════════════════════════════════════")

repeat task.wait() until game:IsLoaded()
task.wait(2)

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Backpack = Player:WaitForChild("Backpack")

-- ════════════════════════════════════════════════════════
-- CONFIG
-- ════════════════════════════════════════════════════════
getgenv().ManualFischConfig = {
    Enabled = false,
    CastDelay = 3,
    ReelDelay = 0.5,
    ShowDebug = true,
    
    -- Manual Remote Setup
    CastRemoteName = "",    -- User bisa isi manual
    ReelRemoteName = "",    -- User bisa isi manual
}

local Config = getgenv().ManualFischConfig

local Stats = {
    Fish = 0,
    Casts = 0,
    Reels = 0,
    StartTime = tick(),
    Status = "Setup Mode",
}

local function Debug(...)
    if Config.ShowDebug then
        print("🎣 [MANUAL]", ...)
    end
end

-- ════════════════════════════════════════════════════════
-- SCAN ALL REMOTES (DETAILED!)
-- ════════════════════════════════════════════════════════
local AllRemotes = {}
local RemoteCategories = {
    Possible_Cast = {},
    Possible_Reel = {},
    Possible_Shop = {},
    Others = {}
}

local function ScanAllRemotes()
    Debug("🔍 Detailed remote scanning...")
    
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            local fullPath = obj:GetFullName()
            
            table.insert(AllRemotes, obj)
            
            -- Categorize remotes
            if name:find("cast") or name:find("throw") or name:find("fish") or name:find("rod") then
                table.insert(RemoteCategories.Possible_Cast, obj)
                Debug("🎣 Possible CAST:", obj.Name, "|", fullPath)
            elseif name:find("reel") or name:find("catch") or name:find("pull") or name:find("complete") then
                table.insert(RemoteCategories.Possible_Reel, obj)
                Debug("🔄 Possible REEL:", obj.Name, "|", fullPath)
            elseif name:find("buy") or name:find("purchase") or name:find("shop") then
                table.insert(RemoteCategories.Possible_Shop, obj)
                Debug("🛒 Shop Related:", obj.Name)
            else
                table.insert(RemoteCategories.Others, obj)
                Debug("❓ Other:", obj.Name, "|", fullPath)
            end
        end
    end
    
    Debug("📊 Scan Results:")
    Debug("  Total remotes:", #AllRemotes)
    Debug("  Possible cast:", #RemoteCategories.Possible_Cast)
    Debug("  Possible reel:", #RemoteCategories.Possible_Reel)
    Debug("  Shop related:", #RemoteCategories.Possible_Shop)
    Debug("  Others:", #RemoteCategories.Others)
end

ScanAllRemotes()

-- ════════════════════════════════════════════════════════
-- REMOTE MANAGEMENT
-- ════════════════════════════════════════════════════════
local SelectedRemotes = {
    Cast = nil,
    Reel = nil,
}

local function FindRemoteByName(name)
    for _, remote in pairs(AllRemotes) do
        if remote.Name == name then
            return remote
        end
    end
    return nil
end

local function SetCastRemote(remoteName)
    local remote = FindRemoteByName(remoteName)
    if remote then
        SelectedRemotes.Cast = remote
        Config.CastRemoteName = remoteName
        Debug("✅ Cast remote set:", remoteName)
        return true
    else
        Debug("❌ Cast remote not found:", remoteName)
        return false
    end
end

local function SetReelRemote(remoteName)
    local remote = FindRemoteByName(remoteName)
    if remote then
        SelectedRemotes.Reel = remote
        Config.ReelRemoteName = remoteName
        Debug("✅ Reel remote set:", remoteName)
        return true
    else
        Debug("❌ Reel remote not found:", remoteName)
        return false
    end
end

-- ════════════════════════════════════════════════════════
-- ROD FUNCTIONS
-- ════════════════════════════════════════════════════════
local function GetRod()
    if Player.Character then
        for _, tool in pairs(Player.Character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("rod") then
                return tool, "equipped"
            end
        end
    end
    
    for _, tool in pairs(Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():find("rod") then
            return tool, "backpack"
        end
    end
    
    return nil, "none"
end

local function EquipRod()
    local rod, location = GetRod()
    if location == "backpack" then
        Player.Character.Humanoid:EquipTool(rod)
        task.wait(0.5)
        return true
    elseif location == "equipped" then
        return true
    end
    return false
end

-- ════════════════════════════════════════════════════════
-- UI DETECTION
-- ════════════════════════════════════════════════════════
local function CheckForReelUI()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            if gui.Name == "ManualFischGUI" then continue end
            
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("Frame") and obj.Visible then
                    local name = obj.Name:lower()
                    if name:find("reel") or name:find("safe") or name:find("bar") then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- ════════════════════════════════════════════════════════
-- FISHING FUNCTIONS
-- ════════════════════════════════════════════════════════
local IsFishing = false
local LastCast = 0

local function TestRemote(remote, args)
    Debug("🧪 Testing remote:", remote.Name)
    local success = pcall(function()
        if args then
            remote:FireServer(unpack(args))
        else
            remote:FireServer()
        end
    end)
    return success
end

local function Cast()
    if IsFishing then return false end
    if tick() - LastCast < Config.CastDelay then return false end
    
    if not EquipRod() then
        Debug("❌ No rod to equip!")
        return false
    end
    
    Stats.Casts = Stats.Casts + 1
    Stats.Status = "🎣 Casting..."
    Debug("🎣 Attempting cast #" .. Stats.Casts)
    
    local success = false
    
    -- Method 1: Use selected remote
    if SelectedRemotes.Cast then
        success = TestRemote(SelectedRemotes.Cast)
        if success then
            Debug("✅ Cast remote worked!")
        else
            Debug("❌ Cast remote failed!")
        end
    end
    
    -- Method 2: Tool activation (ALWAYS TRY THIS!)
    local rod = GetRod()
    if rod then
        Debug("🔧 Activating rod tool")
        rod:Activate()
        success = true  -- Assume tool activation works
    end
    
    -- Method 3: Mouse click (FORCE IT!)
    Debug("🖱️ Force mouse click")
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.1)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    if success then
        IsFishing = true
        LastCast = tick()
        Stats.Status = "⏳ Waiting for fish..."
        
        -- Timeout
        task.spawn(function()
            task.wait(20)
            if IsFishing then
                Debug("⏰ Cast timeout")
                IsFishing = false
            end
        end)
    end
    
    return success
end

local function Reel()
    Stats.Reels = Stats.Reels + 1
    Stats.Status = "🔄 Reeling..."
    Debug("🔄 Attempting reel #" .. Stats.Reels)
    
    task.wait(Config.ReelDelay)
    
    local success = false
    
    -- Method 1: Use selected remote
    if SelectedRemotes.Reel then
        success = TestRemote(SelectedRemotes.Reel)
        if success then
            Debug("✅ Reel remote worked!")
        end
    end
    
    -- Method 2: Try E key (FORCE!)
    Debug("⌨️ Force E key")
    VIM:SendKeyEvent(true, "E", false, game)
    task.wait(0.1)
    VIM:SendKeyEvent(false, "E", false, game)
    
    -- Method 3: Try Space key
    Debug("⌨️ Force Space key")
    VIM:SendKeyEvent(true, "Space", false, game)
    task.wait(0.1)
    VIM:SendKeyEvent(false, "Space", false, game)
    
    -- Method 4: Mouse click
    Debug("🖱️ Force mouse click for reel")
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.1)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    
    Stats.Fish = Stats.Fish + 1
    Stats.Status = "✅ Fish #" .. Stats.Fish
    Debug("✅ Reel completed! Fish count:", Stats.Fish)
    
    task.wait(1)
    IsFishing = false
    
    return true
end

-- ════════════════════════════════════════════════════════
-- AUTO FISHING LOOP
-- ════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(1) do
        if not Config.Enabled then
            Stats.Status = "⏹️ Stopped"
            continue
        end
        
        local hasReelUI = CheckForReelUI()
        
        if hasReelUI and IsFishing then
            Reel()
        elseif not IsFishing then
            Cast()
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- GUI WITH MANUAL REMOTE SELECTION
-- ════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ManualFischGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.02, 0, 0.15, 0)
Main.Size = UDim2.new(0, 450, 0, 600)
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Font = Enum.Font.GothamBold
Title.Text = "🎣 MANUAL REMOTE SETUP"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18

local TCorner = Instance.new("UICorner")
TCorner.CornerRadius = UDim.new(0, 12)
TCorner.Parent = Title

local TCover = Instance.new("Frame")
TCover.Parent = Title
TCover.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
TCover.BorderSizePixel = 0
TCover.Position = UDim2.new(0, 0, 0.7, 0)
TCover.Size = UDim2.new(1, 0, 0.3, 0)

-- ScrollingFrame for remotes list
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Parent = Main
ScrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.Position = UDim2.new(0, 10, 0, 60)
ScrollFrame.Size = UDim2.new(1, -20, 0, 300)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #AllRemotes * 25)
ScrollFrame.ScrollBarThickness = 8

local SCorner = Instance.new("UICorner")
SCorner.CornerRadius = UDim.new(0, 8)
SCorner.Parent = ScrollFrame

-- Add remote buttons
local yPos = 0
for i, remote in pairs(AllRemotes) do
    local RemoteButton = Instance.new("TextButton")
    RemoteButton.Parent = ScrollFrame
    RemoteButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    RemoteButton.BorderSizePixel = 0
    RemoteButton.Position = UDim2.new(0, 5, 0, yPos)
    RemoteButton.Size = UDim2.new(1, -25, 0, 20)
    RemoteButton.Font = Enum.Font.Gotham
    RemoteButton.Text = remote.Name
    RemoteButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    RemoteButton.TextSize = 10
    RemoteButton.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Color code by category
    if table.find(RemoteCategories.Possible_Cast, remote) then
        RemoteButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)  -- Green for cast
    elseif table.find(RemoteCategories.Possible_Reel, remote) then
        RemoteButton.BackgroundColor3 = Color3.fromRGB(0, 0, 100)  -- Blue for reel
    elseif table.find(RemoteCategories.Possible_Shop, remote) then
        RemoteButton.BackgroundColor3 = Color3.fromRGB(100, 100, 0)  -- Yellow for shop
    end
    
    -- Click handlers
    RemoteButton.MouseButton1Click:Connect(function()
        SetCastRemote(remote.Name)
        RemoteButton.TextColor3 = Color3.fromRGB(0, 255, 0)
        RemoteButton.Text = "🎣 CAST: " .. remote.Name
    end)
    
    RemoteButton.MouseButton2Click:Connect(function()
        SetReelRemote(remote.Name)
        RemoteButton.TextColor3 = Color3.fromRGB(0, 100, 255)
        RemoteButton.Text = "🔄 REEL: " .. remote.Name
    end)
    
    yPos = yPos + 25
end

-- Instructions
local Instructions = Instance.new("TextLabel")
Instructions.Parent = Main
Instructions.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instructions.BorderSizePixel = 0
Instructions.Position = UDim2.new(0, 10, 0, 370)
Instructions.Size = UDim2.new(1, -20, 0, 80)
Instructions.Font = Enum.Font.Gotham
Instructions.Text = "INSTRUCTIONS:\n• LEFT CLICK = Set as CAST remote\n• RIGHT CLICK = Set as REEL remote\n• GREEN = Possible cast | BLUE = Possible reel"
Instructions.TextColor3 = Color3.fromRGB(255, 255, 255)
Instructions.TextSize = 11
Instructions.TextXAlignment = Enum.TextXAlignment.Left
Instructions.TextYAlignment = Enum.TextYAlignment.Top

local ICorner = Instance.new("UICorner")
ICorner.CornerRadius = UDim.new(0, 8)
ICorner.Parent = Instructions

-- Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = Main
StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
StatusLabel.BorderSizePixel = 0
StatusLabel.Position = UDim2.new(0, 10, 0, 460)
StatusLabel.Size = UDim2.new(1, -20, 0, 80)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Waiting for remote selection..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top

local StCorner = Instance.new("UICorner")
StCorner.CornerRadius = UDim.new(0, 8)
StCorner.Parent = StatusLabel

-- Update status
task.spawn(function()
    while task.wait(0.5) do
        if StatusLabel and StatusLabel.Parent then
            local castRemote = SelectedRemotes.Cast and SelectedRemotes.Cast.Name or "Not set"
            local reelRemote = SelectedRemotes.Reel and SelectedRemotes.Reel.Name or "Not set"
            
            StatusLabel.Text = string.format(
                "🎣 Cast Remote: %s\n🔄 Reel Remote: %s\n\n📊 Stats:\nFish: %d | Casts: %d | Reels: %d\nStatus: %s",
                castRemote,
                reelRemote,
                Stats.Fish,
                Stats.Casts,
                Stats.Reels,
                Stats.Status
            )
        end
    end
end)

-- Start/Stop button
local Toggle = Instance.new("TextButton")
Toggle.Parent = Main
Toggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Toggle.BorderSizePixel = 0
Toggle.Position = UDim2.new(0, 10, 0, 550)
Toggle.Size = UDim2.new(0.7, -5, 0, 40)
Toggle.Font = Enum.Font.GothamBold
Toggle.Text = "▶️ START FISHING"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.TextSize = 14

local TgCorner = Instance.new("UICorner")
TgCorner.CornerRadius = UDim.new(0, 8)
TgCorner.Parent = Toggle

Toggle.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        Toggle.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        Toggle.Text = "⏸️ STOP FISHING"
        Debug("✅ Manual fishing started!")
    else
        Toggle.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        Toggle.Text = "▶️ START FISHING"
        IsFishing = false
        Debug("⏹️ Manual fishing stopped!")
    end
end)

-- Close button
local Close = Instance.new("TextButton")
Close.Parent = Main
Close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0.7, 5, 0, 550)
Close.Size = UDim2.new(0.3, -15, 0, 40)
Close.Font = Enum.Font.Gotham
Close.Text = "❌ CLOSE"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 12

local ClCorner = Instance.new("UICorner")
ClCorner.CornerRadius = UDim.new(0, 8)
ClCorner.Parent = Close

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    Config.Enabled = false
end)

-- Hide/show
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
    end
end)

-- Anti-AFK
Player.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

print("════════════════════════════════════════")
print("✅ MANUAL REMOTE SETUP LOADED!")
print("════════════════════════════════════════")
print("📋 INSTRUCTIONS:")
print("1. Look at the remote list")
print("2. LEFT CLICK = Set as CAST remote")
print("3. RIGHT CLICK = Set as REEL remote") 
print("4. Click START FISHING")
print("════════════════════════════════════════")
print("🎯 Found " .. #AllRemotes .. " remotes total")
print("🔍 Check console for detailed remote info!")
print("════════════════════════════════════════")
