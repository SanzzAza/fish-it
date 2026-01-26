--[[
    ════════════════════════════════════════════════════════
    🎣 FISCH AUTO - FULLY FIXED VERSION
    PROPER REEL MINIGAME + NO JUMP!
    ════════════════════════════════════════════════════════
]]

print("🎣 LOADING FULLY FIXED FISCH AUTO...")

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

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Backpack = Player:WaitForChild("Backpack")

-- ════════════════════════════════════════════════════════
-- CONFIG
-- ════════════════════════════════════════════════════════
local Config = {
    Enabled = false,
    AutoShake = true,
    ShakeSpeed = 0.05,
}

local Stats = {
    Fish = 0,
    Casts = 0,
}

-- ════════════════════════════════════════════════════════
-- STATE
-- ════════════════════════════════════════════════════════
local IsFishing = false
local IsReeling = false
local LastCast = 0
local HoldingClick = false

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
            if tool:IsA("Tool") and (tool.Name:lower():find("rod") or tool:FindFirstChild("events")) then
                return tool
            end
        end
    end
    for _, tool in pairs(Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("rod") or tool:FindFirstChild("events")) then
            return tool
        end
    end
    return nil
end

local function EquipRod()
    local rod = GetRod()
    if rod and rod.Parent == Backpack then
        Player.Character.Humanoid:EquipTool(rod)
        task.wait(0.5)
    end
    return GetRod()
end

-- ════════════════════════════════════════════════════════
-- UI DETECTION (IMPROVED!)
-- ════════════════════════════════════════════════════════
local function FindFishingUI()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            -- Method 1: Look for reel frame
            local reel = gui:FindFirstChild("reel", true)
            if reel and reel:IsA("Frame") and reel.Visible then
                return {
                    GUI = gui,
                    ReelFrame = reel,
                    PlayerBar = reel:FindFirstChild("playerbar", true) or reel:FindFirstChild("bar", true),
                    SafeZone = reel:FindFirstChild("safezone", true) or reel:FindFirstChild("fish", true),
                }
            end
            
            -- Method 2: Look for any fishing-related UI
            for _, desc in pairs(gui:GetDescendants()) do
                if desc:IsA("Frame") and desc.Visible then
                    local name = desc.Name:lower()
                    if name == "reel" or name == "minigame" or name == "fishing" then
                        return {
                            GUI = gui,
                            ReelFrame = desc,
                            PlayerBar = desc:FindFirstChild("playerbar", true) or desc:FindFirstChild("bar", true),
                            SafeZone = desc:FindFirstChild("safezone", true) or desc:FindFirstChild("target", true),
                        }
                    end
                end
            end
        end
    end
    return nil
end

local function FindShakeUI()
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, desc in pairs(gui:GetDescendants()) do
                if desc:IsA("ImageLabel") or desc:IsA("TextLabel") then
                    local name = desc.Name:lower()
                    -- Deteksi "!" atau shake indicator
                    if (name:find("shake") or name:find("alert") or name:find("indicator") or name:find("!")) 
                       and desc.Visible then
                        return desc
                    end
                end
            end
        end
    end
    return nil
end

-- ════════════════════════════════════════════════════════
-- CLICK CONTROL (PROPER HOLD/RELEASE!)
-- ════════════════════════════════════════════════════════
local function StartHold()
    if not HoldingClick then
        HoldingClick = true
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    end
end

local function StopHold()
    if HoldingClick then
        HoldingClick = false
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
end

local function QuickClick()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- ════════════════════════════════════════════════════════
-- REEL MINIGAME (FIXED!)
-- ════════════════════════════════════════════════════════
local function DoReelMinigame(uiData)
    if not uiData or not uiData.ReelFrame then return end
    
    IsReeling = true
    print("🎯 Starting reel minigame...")
    
    local startTime = tick()
    local maxTime = 30 -- Max 30 detik per fish
    
    while Config.Enabled and IsReeling and (tick() - startTime) < maxTime do
        -- Re-check UI masih ada
        local currentUI = FindFishingUI()
        if not currentUI then
            print("✅ Minigame selesai!")
            break
        end
        
        local playerBar = currentUI.PlayerBar
        local safeZone = currentUI.SafeZone
        
        if playerBar and safeZone then
            -- Get positions
            local playerPos = playerBar.AbsolutePosition.Y + (playerBar.AbsoluteSize.Y / 2)
            local safeTop = safeZone.AbsolutePosition.Y
            local safeBottom = safeZone.AbsolutePosition.Y + safeZone.AbsoluteSize.Y
            local safeCenter = (safeTop + safeBottom) / 2
            
            -- Logic: HOLD untuk naik, RELEASE untuk turun
            if playerPos > safeCenter + 5 then
                -- Player bar terlalu bawah, perlu naik = HOLD
                StartHold()
            elseif playerPos < safeCenter - 5 then
                -- Player bar terlalu atas, perlu turun = RELEASE
                StopHold()
            else
                -- Di tengah safe zone, maintain
                -- Toggle untuk stay in place
                if math.random() > 0.5 then
                    StartHold()
                else
                    StopHold()
                end
            end
        else
            -- Fallback: just hold/release randomly
            if math.random() > 0.5 then
                StartHold()
            else
                StopHold()
            end
        end
        
        task.wait(0.03) -- Smooth control
    end
    
    StopHold()
    Stats.Fish = Stats.Fish + 1
    IsReeling = false
    IsFishing = false
    print("🐟 Fish caught! Total: " .. Stats.Fish)
    task.wait(1)
end

-- ════════════════════════════════════════════════════════
-- SHAKE HANDLER
-- ════════════════════════════════════════════════════════
local function DoShake()
    print("⚡ Shake detected! Clicking...")
    for i = 1, 10 do
        QuickClick()
        task.wait(Config.ShakeSpeed)
        
        -- Check if shake UI gone
        if not FindShakeUI() then
            break
        end
    end
end

-- ════════════════════════════════════════════════════════
-- CAST FUNCTION
-- ════════════════════════════════════════════════════════
local function DoCast()
    if IsFishing or IsReeling or (tick() - LastCast) < 3 then return end
    
    local rod = EquipRod()
    if not rod then 
        print("❌ No rod found!")
        return 
    end
    
    Stats.Casts = Stats.Casts + 1
    print("🎣 Casting #" .. Stats.Casts)
    
    -- Activate rod
    pcall(function() rod:Activate() end)
    
    -- Also send click
    task.wait(0.1)
    QuickClick()
    
    IsFishing = true
    LastCast = tick()
    
    -- Timeout reset
    task.delay(20, function()
        if IsFishing and not IsReeling then
            IsFishing = false
            print("⏰ Cast timeout, recasting...")
        end
    end)
end

-- ════════════════════════════════════════════════════════
-- MAIN LOOP (IMPROVED!)
-- ════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(0.1) do
        if Config.Enabled then
            -- Priority 1: Check for reel minigame
            local fishingUI = FindFishingUI()
            if fishingUI and not IsReeling then
                DoReelMinigame(fishingUI)
            end
            
            -- Priority 2: Check for shake
            if Config.AutoShake then
                local shakeUI = FindShakeUI()
                if shakeUI then
                    DoShake()
                end
            end
            
            -- Priority 3: Cast if not doing anything
            if not IsFishing and not IsReeling then
                DoCast()
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- ALTERNATIVE: RenderStepped for smoother control
-- ════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if Config.Enabled and IsReeling then
        local fishingUI = FindFishingUI()
        if fishingUI and fishingUI.PlayerBar and fishingUI.SafeZone then
            local playerBar = fishingUI.PlayerBar
            local safeZone = fishingUI.SafeZone
            
            local playerPos = playerBar.AbsolutePosition.Y + (playerBar.AbsoluteSize.Y / 2)
            local safeCenter = safeZone.AbsolutePosition.Y + (safeZone.AbsoluteSize.Y / 2)
            
            if playerPos > safeCenter then
                StartHold()
            else
                StopHold()
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════
-- GUI (IMPROVED)
-- ════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FischAutoGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.4, 0, 0.3, 0)
Main.Size = UDim2.new(0, 280, 0, 180)
Main.Active = true
Main.Draggable = true

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(100, 200, 255)
Stroke.Thickness = 2
Stroke.Parent = Main

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(30, 120, 200)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "🎣 FISCH AUTO - FIXED"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

-- Status
local Status = Instance.new("TextLabel")
Status.Parent = Main
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 15, 0, 50)
Status.Size = UDim2.new(1, -30, 0, 50)
Status.Font = Enum.Font.Gotham
Status.TextColor3 = Color3.new(1, 1, 1)
Status.TextSize = 13
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
    while task.wait(0.3) do
        local state = "Idle"
        if IsReeling then state = "🔄 Reeling..."
        elseif IsFishing then state = "⏳ Waiting for bite..."
        elseif Config.Enabled then state = "🎣 Casting..." end
        
        Status.Text = string.format(
            "%s %s\n🐟 Fish: %d | 🎣 Casts: %d\n%s",
            Config.Enabled and "🟢" or "🔴",
            Config.Enabled and "ACTIVE" or "STOPPED",
            Stats.Fish,
            Stats.Casts,
            state
        )
    end
end)

-- Toggle Button
local Toggle = Instance.new("TextButton")
Toggle.Parent = Main
Toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Toggle.Position = UDim2.new(0, 15, 1, -55)
Toggle.Size = UDim2.new(1, -30, 0, 40)
Toggle.Font = Enum.Font.GothamBold
Toggle.Text = "▶ START"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.TextSize = 15
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 8)

Toggle.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    if Config.Enabled then
        Toggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        Toggle.Text = "⏹ STOP"
        Stroke.Color = Color3.fromRGB(50, 255, 50)
    else
        Toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        Toggle.Text = "▶ START"
        Stroke.Color = Color3.fromRGB(100, 200, 255)
        StopHold()
        IsFishing = false
        IsReeling = false
    end
end)

-- Keybind
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
    elseif input.KeyCode == Enum.KeyCode.F6 then
        Toggle.MouseButton1Click:Fire()
    end
end)

print("════════════════════════════════════════")
print("✅ FISCH AUTO FULLY FIXED!")
print("════════════════════════════════════════")
print("🔧 IMPROVEMENTS:")
print("  ✅ Proper HOLD/RELEASE for minigame")
print("  ✅ Bar position tracking")
print("  ✅ RenderStepped for smooth control")
print("  ✅ Shake detection")
print("  ✅ No jumping (no space key)")
print("════════════════════════════════════════")
print("🎮 Controls: DELETE=Hide | F6=Toggle")
print("════════════════════════════════════════")
