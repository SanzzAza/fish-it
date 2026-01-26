--[[
    🎣 FISCH AUTO - ULTRA SIMPLE DELTA VERSION
    By: SanzzAza
    Minimal GUI, Maximum Compatibility
]]

print("🎣 Loading Fisch Auto...")
task.wait(2)

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

print("✅ Player:", Player.Name)

-- ════════════════════════════════════════════════════════
-- CONFIG
-- ════════════════════════════════════════════════════════
_G.Config = {
    AutoCast = true,
    AutoReel = true,
    AutoShake = true,
    PerfectCatch = true,
    ReelDelay = 0.5,    -- Bisa diubah (detik)
    CastDelay = 3,      -- Bisa diubah (detik)
    DebugMode = true,   -- Set false kalau ga mau spam console
}

_G.Stats = {
    Fish = 0,
    Casts = 0,
    Reels = 0,
}

local Config = _G.Config
local Stats = _G.Stats

print("✅ Config loaded")

-- ════════════════════════════════════════════════════════
-- ANTI-AFK
-- ════════════════════════════════════════════════════════
Player.Idled:Connect(function()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

print("✅ Anti-AFK enabled")

-- ════════════════════════════════════════════════════════
-- SIMPLE GUI
-- ════════════════════════════════════════════════════════
print("🎨 Creating GUI...")

local SG = Instance.new("ScreenGui")
SG.Name = "FischGUI"
SG.Parent = PlayerGui
SG.ResetOnSpawn = false

print("  ✅ ScreenGui created")

-- Main Frame (SIMPLE!)
local Main = Instance.new("Frame")
Main.Parent = SG
Main.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.new(0, 0.7, 1)
Main.Position = UDim2.new(0.02, 0, 0.3, 0)
Main.Size = UDim2.new(0, 280, 0, 320)
Main.Active = true
Main.Draggable = true

print("  ✅ Main frame created")

-- Title (SIMPLE!)
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.new(0, 0.7, 1)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "FISCH AUTO"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18

print("  ✅ Title created")

-- Status Label
local Status = Instance.new("TextLabel")
Status.Parent = Main
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 10, 0, 40)
Status.Size = UDim2.new(1, -20, 0, 20)
Status.Font = Enum.Font.SourceSans
Status.Text = "By: SanzzAza | Status: Loading..."
Status.TextColor3 = Color3.new(0.7, 0.7, 0.7)
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left

-- Update status
task.spawn(function()
    while task.wait(1) do
        if Status and Status.Parent then
            Status.Text = string.format("Fish: %d | Casts: %d | Reels: %d", Stats.Fish, Stats.Casts, Stats.Reels)
        end
    end
end)

print("  ✅ Status label created")

-- Toggles (SIMPLE BUTTONS!)
local yPos = 70

local function MakeButton(text, key)
    local btn = Instance.new("TextButton")
    btn.Parent = Main
    btn.BackgroundColor3 = Config[key] and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0)
    btn.BorderSizePixel = 0
    btn.Position = UDim2.new(0.1, 0, 0, yPos)
    btn.Size = UDim2.new(0.8, 0, 0, 35)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = text .. ": " .. (Config[key] and "ON" or "OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 14
    
    btn.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        btn.BackgroundColor3 = Config[key] and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0)
        btn.Text = text .. ": " .. (Config[key] and "ON" or "OFF")
        print("🔄", text, "=", Config[key])
    end)
    
    yPos = yPos + 40
end

MakeButton("Auto Cast", "AutoCast")
MakeButton("Auto Reel", "AutoReel")
MakeButton("Auto Shake", "AutoShake")
MakeButton("Perfect Catch", "PerfectCatch")
MakeButton("Debug Mode", "DebugMode")

print("  ✅ Buttons created")

-- Close Button
local Close = Instance.new("TextButton")
Close.Parent = Main
Close.BackgroundColor3 = Color3.new(0.8, 0, 0)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0.1, 0, 0, yPos)
Close.Size = UDim2.new(0.8, 0, 0, 30)
Close.Font = Enum.Font.SourceSansBold
Close.Text = "CLOSE"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 14

Close.MouseButton1Click:Connect(function()
    SG:Destroy()
    print("GUI Closed")
end)

print("  ✅ Close button created")

-- Toggle with DELETE
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
        print("GUI toggled:", Main.Visible)
    end
end)

print("✅ GUI fully created!")
print("════════════════════════════════════════")

-- ════════════════════════════════════════════════════════
-- FIND REMOTES
-- ════════════════════════════════════════════════════════
local RS = game:GetService("ReplicatedStorage")
local CastRemote = nil
local ReelRemote = nil

print("🔍 Finding remotes...")

for _, v in pairs(RS:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        local name = v.Name:lower()
        if name:find("cast") and not CastRemote then
            CastRemote = v
            print("  ✅ Cast:", v:GetFullName())
        end
        if name:find("reel") and not ReelRemote then
            ReelRemote = v
            print("  ✅ Reel:", v:GetFullName())
        end
    end
end

if not CastRemote then print("  ⚠️ Cast remote not found") end
if not ReelRemote then print("  ⚠️ Reel remote not found") end

-- ════════════════════════════════════════════════════════
-- UTILITY
-- ════════════════════════════════════════════════════════
local function Debug(...)
    if Config.DebugMode then
        print("🐛", ...)
    end
end

local function GetRod()
    for _, v in pairs(Player.Backpack:GetChildren()) do
        if v:IsA("Tool") and (v.Name:lower():find("rod") or v.Name:lower():find("fishing")) then
            return v
        end
    end
    for _, v in pairs(Player.Character:GetChildren()) do
        if v:IsA("Tool") and (v.Name:lower():find("rod") or v.Name:lower():find("fishing")) then
            return v
        end
    end
    return nil
end

local function EquipRod()
    local rod = GetRod()
    if rod and rod.Parent == Player.Backpack then
        Player.Character.Humanoid:EquipTool(rod)
        task.wait(0.3)
        return true
    end
    return false
end

-- ════════════════════════════════════════════════════════
-- FISHING LOGIC
-- ════════════════════════════════════════════════════════
local IsFishing = false
local LastCast = 0

-- AUTO CAST
task.spawn(function()
    while task.wait(1) do
        if Config.AutoCast and not IsFishing then
            if tick() - LastCast >= Config.CastDelay then
                Stats.Casts = Stats.Casts + 1
                
                EquipRod()
                task.wait(0.2)
                
                if CastRemote then
                    CastRemote:FireServer()
                    IsFishing = true
                    LastCast = tick()
                    Debug("Cast fired!")
                else
                    local rod = GetRod()
                    if rod then
                        rod:Activate()
                        IsFishing = true
                        LastCast = tick()
                        Debug("Rod activated!")
                    end
                end
            end
        end
    end
end)

print("✅ Cast loop started")

-- AUTO REEL (IMPROVED!)
task.spawn(function()
    while task.wait(0.3) do
        if Config.AutoReel then
            
            -- Check every UI in PlayerGui
            for _, ui in pairs(PlayerGui:GetDescendants()) do
                local name = ui.Name:lower()
                
                -- Look for fishing/reel UI
                if name:find("fishing") or name:find("reel") or name:find("catch") or name:find("bobber") then
                    
                    local isVisible = false
                    
                    if ui:IsA("ScreenGui") then
                        isVisible = ui.Enabled
                    elseif ui:IsA("Frame") then
                        isVisible = ui.Visible
                    end
                    
                    if isVisible then
                        Stats.Reels = Stats.Reels + 1
                        
                        Debug("🐟 Reel UI found:", ui.Name)
                        Debug("  Path:", ui:GetFullName())
                        Debug("  Waiting", Config.ReelDelay, "seconds...")
                        
                        -- WAIT BEFORE REEL!
                        task.wait(Config.ReelDelay)
                        
                        -- Try reel
                        if ReelRemote then
                            local quality = Config.PerfectCatch and 100 or 85
                            ReelRemote:FireServer(quality, true)
                            Stats.Fish = Stats.Fish + 1
                            IsFishing = false
                            Debug("✅ Reeled! Fish #" .. Stats.Fish)
                            print("🐟 Fish caught! Total:", Stats.Fish)
                        else
                            -- Try clicking button
                            local btn = ui:FindFirstChild("reel", true) or ui:FindFirstChild("button", true)
                            if btn then
                                Debug("Clicking button:", btn.Name)
                                pcall(function() btn:Fire() end)
                                pcall(function() firesignal(btn.MouseButton1Click) end)
                                Stats.Fish = Stats.Fish + 1
                                IsFishing = false
                                print("🐟 Fish caught! Total:", Stats.Fish)
                            end
                        end
                        
                        break
                    end
                end
            end
        end
    end
end)

print("✅ Reel loop started")

-- AUTO SHAKE
task.spawn(function()
    while task.wait(0.2) do
        if Config.AutoShake then
            for _, ui in pairs(PlayerGui:GetDescendants()) do
                if ui.Name:lower():find("shake") and ui:IsA("Frame") and ui.Visible then
                    Debug("💪 Shake detected!")
                    for i = 1, 3 do
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, "W", false, game)
                        task.wait(0.05)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, "W", false, game)
                        task.wait(0.05)
                    end
                    break
                end
            end
        end
    end
end)

print("✅ Shake loop started")

-- SAFETY RESET
task.spawn(function()
    while task.wait(30) do
        if IsFishing and (tick() - LastCast > 30) then
            IsFishing = false
            Debug("Reset timeout")
        end
    end
end)

print("✅ Safety loop started")

print("════════════════════════════════════════")
print("✅ FISCH AUTO - FULLY LOADED!")
print("════════════════════════════════════════")
print("GUI should be visible now!")
print("Press DELETE to toggle GUI")
print("════════════════════════════════════════")
print("Current Config:")
print("  ReelDelay:", Config.ReelDelay, "seconds")
print("  CastDelay:", Config.CastDelay, "seconds")
print("════════════════════════════════════════")
print("To change delays, edit script:")
print("  _G.Config.ReelDelay = 1.0  -- Change this")
print("  _G.Config.CastDelay = 5.0  -- Change this")
print("════════════════════════════════════════")
