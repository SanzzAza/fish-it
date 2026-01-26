--[[
    ═══════════════════════════════════════════════════════
    🎣 FISCH AUTO - BALANCED
    Bisa mancing, tapi gak gerak aneh-aneh!
    ═══════════════════════════════════════════════════════
]]

print("════════════════════════════════════════")
print("🎣 FISCH AUTO - BALANCED LOADING...")
print("════════════════════════════════════════")

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════
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
local Config = {
    Enabled = false,
    CastDelay = 2.5,
    ReelDelay = 0.3,
    ShowDebug = true,
}

local Stats = {
    Fish = 0,
    Casts = 0,
    Reels = 0,
    StartTime = tick(),
    Status = "Ready",
}

local function Log(...)
    if Config.ShowDebug then
        print("🎣", ...)
    end
end

-- ════════════════════════════════════════════════════════
-- ANTI-AFK (SOFT)
-- ════════════════════════════════════════════════════════
Player.Idled:Connect(function()
    pcall(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end)
end)

-- ════════════════════════════════════════════════════════
-- FIND REMOTES
-- ════════════════════════════════════════════════════════
local Remotes = {}

Log("Scanning remotes...")
for _, remote in pairs(RS:GetDescendants()) do
    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
        Remotes[remote.Name] = remote
        Log("Found:", remote.Name, "|", remote:GetFullName())
    end
end

-- Try to find fishing remotes
local CastRemote = nil
local ReelRemote = nil

-- Common cast names
for name, remote in pairs(Remotes) do
    local lname = name:lower()
    if lname:match("cast") or lname:match("throw") or lname:match("fish") then
        CastRemote = remote
        Log("✅ Auto-detected Cast remote:", name)
        break
    end
end

-- Common reel names  
for name, remote in pairs(Remotes) do
    local lname = name:lower()
    if lname:match("reel") or lname:match("catch") or lname:match("complete") then
        ReelRemote = remote
        Log("✅ Auto-detected Reel remote:", name)
        break
    end
end

-- ════════════════════════════════════════════════════════
-- ROD FUNCTIONS
-- ════════════════════════════════════════════════════════
local function GetRod()
    -- Check equipped
    if Player.Character then
        for _, tool in pairs(Player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if name:find("rod") or name:find("fish") then
                    return tool, "equipped"
                end
            end
        end
    end
    
    -- Check backpack
    for _, tool in pairs(Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if name:find("rod") or name:find("fish") then
                return tool, "backpack"
            end
        end
    end
    
    return nil, "none"
end

local function EquipRod()
    local rod, location = GetRod()
    if not rod then
        Log("❌ No fishing rod found!")
        return false
    end
    
    if location == "backpack" then
        Log("🎣 Equipping rod:", rod.Name)
        Player.Character.Humanoid:EquipTool(rod)
        task.wait(0.5)
        return true
    elseif location == "equipped" then
        Log("✅ Rod already equipped")
        return true
    end
    
    return false
end

-- ════════════════════════════════════════════════════════
-- UI DETECTION (BETTER)
-- ════════════════════════════════════════════════════════
local function GetFishingUI()
    local fishingGuis = {}
    
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            -- Skip our own GUI
            if gui.Name == "FischBalancedGUI" then continue end
            
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("Frame") and obj.Visible then
                    local name = obj.Name:lower()
                    local parent = obj.Parent and obj.Parent.Name:lower() or ""
                    
                    -- Look for fishing UI indicators
                    if name:find("reel") or name:find("safe") or name:find("bar") or 
                       name:find("fish") or parent:find("fish") then
                        table.insert(fishingGuis, {
                            name = obj.Name,
                            obj = obj,
                            type = "reel"
                        })
                        Log("🎯 Found fishing UI:", obj.Name, "in", obj.Parent.Name)
                    end
                end
                
                -- Look for buttons
                if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Visible then
                    local text = obj.Text and obj.Text:lower() or ""
                    local name = obj.Name:lower()
                    
                    if text:find("reel") or text:find("catch") or name:find("reel") then
                        table.insert(fishingGuis, {
                            name = obj.Name,
                            obj = obj,
                            type = "button"
                        })
                        Log("🔘 Found reel button:", obj.Name)
                    end
                end
            end
        end
    end
    
    return fishingGuis
end

-- ════════════════════════════════════════════════════════
-- FISHING FUNCTIONS (BALANCED)
-- ════════════════════════════════════════════════════════
local IsFishing = false
local LastAction = 0

local function Cast()
    if IsFishing then return false end
    if tick() - LastAction < 1 then return false end
    
    if not EquipRod() then
        Stats.Status = "❌ No Rod!"
        return false
    end
    
    Stats.Casts = Stats.Casts + 1
    Stats.Status = "🎣 Casting..."
    Log("🎣 Casting attempt #" .. Stats.Casts)
    
    local success = false
    
    -- Method 1: Try cast remote first
    if CastRemote then
        local s = pcall(function()
            CastRemote:FireServer()
        end)
        if s then
            Log("✅ Cast remote fired")
            success = true
        end
    end
    
    -- Method 2: Tool activation (SAFE - just activates, doesn't move)
    if not success then
        local rod = GetRod()
        if rod then
            Log("🔧 Activating tool")
            rod:Activate()
            success = true
        end
    end
    
    -- Method 3: Single click (not spam!)
    if not success then
        Log("🖱️ Mouse click")
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.1)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        success = true
    end
    
    if success then
        IsFishing = true
        Stats.Status = "⏳ Waiting for fish..."
        LastAction = tick()
        return true
    end
    
    return false
end

local ReelCooldown = false

local function Reel()
    if ReelCooldown then return false end
    ReelCooldown = true
    
    Stats.Reels = Stats.Reels + 1
    Stats.Status = "🔄 Reeling..."
    Log("🔄 Reeling attempt #" .. Stats.Reels)
    
    task.wait(Config.ReelDelay)
    
    local success = false
    
    -- Method 1: Reel remote
    if ReelRemote then
        local s = pcall(function()
            ReelRemote:FireServer()
        end)
        if s then
            Log("✅ Reel remote fired")
            success = true
        end
    end
    
    -- Method 2: Click fishing UI buttons
    local fishingUI = GetFishingUI()
    for _, ui in pairs(fishingUI) do
        if ui.type == "button" then
            pcall(function()
                ui.obj.MouseButton1Click:Fire()
            end)
            pcall(function()
                firesignal(ui.obj.MouseButton1Click)
            end)
            success = true
        end
    end
    
    -- Method 3: Single E key (not spam)
    if not success then
        Log("⌨️ E key press")
        VIM:SendKeyEvent(true, "E", false, game)
        task.wait(0.1)
        VIM:SendKeyEvent(false, "E", false, game)
    end
    
    -- Count as fish caught
    Stats.Fish = Stats.Fish + 1
    Stats.Status = "✅ Fish #" .. Stats.Fish
    Log("✅ Fish caught! Total: " .. Stats.Fish)
    
    task.wait(1)
    IsFishing = false
    ReelCooldown = false
    LastAction = tick()
    
    return true
end

-- ════════════════════════════════════════════════════════
-- MAIN LOOP (SMART)
-- ════════════════════════════════════════════════════════
task.spawn(function()
    Log("🚀 Auto fishing started")
    
    while task.wait(0.5) do
        if not Config.Enabled then
            Stats.Status = "⏹️ Stopped"
            continue
        end
        
        -- Check for fishing UI
        local fishingUI = GetFishingUI()
        local hasReelUI = #fishingUI > 0
        
        if hasReelUI and IsFishing then
            -- Reel the fish!
            Reel()
        elseif not IsFishing and not hasReelUI then
            -- Cast again
            if tick() - LastAction >= Config.CastDelay then
                Cast()
            end
        else
            Stats.Status = "⏳ Waiting..."
        end
        
        -- Safety reset
        if IsFishing and tick() - LastAction > 30 then
            Log("⏰ Timeout - resetting")
            IsFishing = false
            ReelCooldown = false
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- GUI (NICER!)
-- ════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FischBalancedGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.02, 0, 0.25, 0)
Main.Size = UDim2.new(0, 350, 0, 320)
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

-- Glow effect
local Glow = Instance.new("ImageLabel")
Glow.Parent = Main
Glow.BackgroundTransparency = 1
Glow.Position = UDim2.new(0, -15, 0, -15)
Glow.Size = UDim2.new(1, 30, 1, 30)
Glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
Glow.ImageColor3 = Color3.fromRGB(0, 150, 255)
Glow.ImageTransparency = 0.8
Glow.ZIndex = 0

-- Title bar
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Font = Enum.Font.GothamBold
Title.Text = "🎣 FISCH AUTO - BALANCED"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 17
Title.ZIndex = 2

local TCorner = Instance.new("UICorner")
TCorner.CornerRadius = UDim.new(0, 12)
TCorner.Parent = Title

local TCover = Instance.new("Frame")
TCover.Parent = Title
TCover.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
TCover.BorderSizePixel = 0
TCover.Position = UDim2.new(0, 0, 0.6, 0)
TCover.Size = UDim2.new(1, 0, 0.4, 0)
TCover.ZIndex = 2

-- Status frame
local StatusFrame = Instance.new("Frame")
StatusFrame.Parent = Main
StatusFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
StatusFrame.BorderSizePixel = 0
StatusFrame.Position = UDim2.new(0, 15, 0, 60)
StatusFrame.Size = UDim2.new(1, -30, 0, 120)

local SCorner = Instance.new("UICorner")
SCorner.CornerRadius = UDim.new(0, 8)
SCorner.Parent = StatusFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = StatusFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 15, 0, 10)
StatusLabel.Size = UDim2.new(1, -30, 1, -20)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Ready to fish!"
StatusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Update status
task.spawn(function()
    while task.wait(0.3) do
        if StatusLabel and StatusLabel.Parent then
            local runtime = tick() - Stats.StartTime
            local m = math.floor(runtime / 60)
            local s = math.floor(runtime % 60)
            
            local remoteStatus = ""
            if CastRemote then
                remoteStatus = "✅ Cast: " .. CastRemote.Name .. "\n"
            else
                remoteStatus = "❌ Cast: Not found\n"
            end
            if ReelRemote then
                remoteStatus = remoteStatus .. "✅ Reel: " .. ReelRemote.Name .. "\n"
            else
                remoteStatus = remoteStatus .. "❌ Reel: Not found\n"
            end
            
            StatusLabel.Text = string.format(
                "%s\n\n%s\n🐟 Fish: %d | 🎣 Casts: %d | 🔄 Reels: %d\n⏱️ Runtime: %02d:%02d",
                Stats.Status,
                remoteStatus,
                Stats.Fish,
                Stats.Casts,
                Stats.Reels,
                m, s
            )
        end
    end
end)

-- Toggle button
local Toggle = Instance.new("TextButton")
Toggle.Parent = Main
Toggle.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
Toggle.BorderSizePixel = 0
Toggle.Position = UDim2.new(0, 15, 0, 190)
Toggle.Size = UDim2.new(1, -30, 0, 50)
Toggle.Font = Enum.Font.GothamBold
Toggle.Text = "▶️ START FISHING"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.TextSize = 16

local BCorner = Instance.new("UICorner")
BCorner.CornerRadius = UDim.new(0, 8)
BCorner.Parent = Toggle

Toggle.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        Toggle.BackgroundColor3 = Color3.fromRGB(0, 220, 0)
        Toggle.Text = "⏸️ STOP FISHING"
        Log("✅ AUTO FISHING STARTED!")
        Stats.Status = "🟢 Active"
    else
        Toggle.BackgroundColor3 = Color3.fromRGB(220, 0, 0)  
        Toggle.Text = "▶️ START FISHING"
        Log("⏹️ AUTO FISHING STOPPED")
        IsFishing = false
        ReelCooldown = false
        Stats.Status = "🔴 Stopped"
    end
end)

-- Settings
local yPos = 250

local function CreateSlider(name, configKey, min, max, step)
    local Label = Instance.new("TextLabel")
    Label.Parent = Main
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 15, 0, yPos)
    Label.Size = UDim2.new(0.6, 0, 0, 20)
    Label.Font = Enum.Font.Gotham
    Label.Text = name .. ": " .. Config[configKey] .. "s"
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    yPos = yPos + 25
end

CreateSlider("Cast Delay", "CastDelay", 1, 10, 1)

-- Close button
local Close = Instance.new("TextButton")
Close.Parent = Main
Close.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0, 15, 0, 280)
Close.Size = UDim2.new(1, -30, 0, 30)
Close.Font = Enum.Font.Gotham
Close.Text = "❌ CLOSE"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 12

local CCorner = Instance.new("UICorner")
CCorner.CornerRadius = UDim.new(0, 6)
CCorner.Parent = Close

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    Config.Enabled = false
end)

-- Toggle GUI visibility
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
    end
end)

-- ════════════════════════════════════════════════════════
-- STARTUP MESSAGE
-- ════════════════════════════════════════════════════════
print("════════════════════════════════════════")
print("✅ FISCH AUTO - BALANCED LOADED!")
print("════════════════════════════════════════")
print("✨ FEATURES:")
print("  ✅ Smart remote detection")
print("  ✅ Auto equip rod")
print("  ✅ Safe tool activation")
print("  ✅ UI detection")
print("  ✅ No movement spam")
print("")
print("🎮 CONTROLS:")
print("  - Click START to begin")
print("  - Press DELETE to hide/show")
print("════════════════════════════════════════")

if CastRemote and ReelRemote then
    Log("🎉 All remotes found! Ready to fish!")
else
    Log("⚠️ Some remotes not detected, using fallback methods")
end
