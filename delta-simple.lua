--[[
    ═══════════════════════════════════════════════════════
    🎣 FISCH AUTO - AGGRESSIVE VERSION
    By: SanzzAza
    Tries EVERYTHING to make it work!
    ═══════════════════════════════════════════════════════
]]

print("════════════════════════════════════════")
print("🎣 FISCH AUTO - AGGRESSIVE")
print("════════════════════════════════════════")

repeat task.wait() until game:IsLoaded()
task.wait(2)

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ════════════════════════════════════════════════════════
-- CONFIG
-- ════════════════════════════════════════════════════════
_G.FischConfig = {
    Enabled = true,
    AutoCast = true,
    AutoReel = true,
    AutoShake = true,
    
    -- Timing
    ReelDelay = 0.3,
    CastDelay = 3,
    
    -- Debug
    ShowDebug = true,
}

local Config = _G.FischConfig

_G.FischStats = {
    Fish = 0,
    Casts = 0,
    Reels = 0,
    Start = tick(),
}

local Stats = _G.FischStats

-- ════════════════════════════════════════════════════════
-- DEBUG
-- ════════════════════════════════════════════════════════
local function Debug(...)
    if Config.ShowDebug then
        print("🐛", ...)
    end
end

-- ════════════════════════════════════════════════════════
-- FIND ALL REMOTES
-- ════════════════════════════════════════════════════════
local AllRemotes = {}

Debug("Scanning all remotes...")
for _, v in pairs(RS:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        table.insert(AllRemotes, v)
        Debug("  Found:", v:GetFullName())
    end
end

Debug("Total remotes found:", #AllRemotes)

-- ════════════════════════════════════════════════════════
-- ANTI-AFK
-- ════════════════════════════════════════════════════════
Player.Idled:Connect(function()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

-- ════════════════════════════════════════════════════════
-- SIMPLE GUI
-- ════════════════════════════════════════════════════════
local SG = Instance.new("ScreenGui")
SG.Name = "FischGUI"
SG.Parent = PlayerGui
SG.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Parent = SG
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 3
Main.BorderColor3 = Color3.fromRGB(0, 170, 255)
Main.Position = UDim2.new(0.02, 0, 0.3, 0)
Main.Size = UDim2.new(0, 300, 0, 280)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = Main
Title.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "🎣 FISCH AUTO - AGGRESSIVE"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16

local Info = Instance.new("TextLabel")
Info.Parent = Main
Info.BackgroundTransparency = 1
Info.Position = UDim2.new(0, 10, 0, 45)
Info.Size = UDim2.new(1, -20, 0, 40)
Info.Font = Enum.Font.SourceSans
Info.TextColor3 = Color3.fromRGB(200, 200, 200)
Info.TextSize = 11
Info.TextXAlignment = Enum.TextXAlignment.Left
Info.TextYAlignment = Enum.TextYAlignment.Top
Info.Text = "Remotes: " .. #AllRemotes

task.spawn(function()
    while task.wait(0.5) do
        if Info and Info.Parent then
            Info.Text = string.format(
                "Remotes: %d\nFish: %d | Casts: %d\nReels: %d",
                #AllRemotes,
                Stats.Fish,
                Stats.Casts,
                Stats.Reels
            )
        end
    end
end)

local yPos = 95

local function MakeToggle(name, key)
    local btn = Instance.new("TextButton")
    btn.Parent = Main
    btn.BackgroundColor3 = Config[key] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    btn.BorderSizePixel = 0
    btn.Position = UDim2.new(0.1, 0, 0, yPos)
    btn.Size = UDim2.new(0.8, 0, 0, 35)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = name .. ": " .. (Config[key] and "ON" or "OFF")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 13
    
    btn.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        btn.BackgroundColor3 = Config[key] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        btn.Text = name .. ": " .. (Config[key] and "ON" or "OFF")
    end)
    
    yPos = yPos + 40
end

MakeToggle("Auto Cast", "AutoCast")
MakeToggle("Auto Reel", "AutoReel")
MakeToggle("Auto Shake", "AutoShake")
MakeToggle("Debug", "ShowDebug")

local Close = Instance.new("TextButton")
Close.Parent = Main
Close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0.1, 0, 0, yPos)
Close.Size = UDim2.new(0.8, 0, 0, 30)
Close.Font = Enum.Font.SourceSansBold
Close.Text = "CLOSE"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 13

Close.MouseButton1Click:Connect(function()
    SG:Destroy()
end)

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Delete then
        Main.Visible = not Main.Visible
    end
end)

Debug("GUI created!")

-- ════════════════════════════════════════════════════════
-- UTILITY
-- ════════════════════════════════════════════════════════
local function GetChar()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function GetRod()
    for _, v in pairs(Player.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.Name:lower():find("rod") then
            return v
        end
    end
    for _, v in pairs(GetChar():GetChildren()) do
        if v:IsA("Tool") and v.Name:lower():find("rod") then
            return v
        end
    end
    return nil
end

local function EquipRod()
    local rod = GetRod()
    if rod and rod.Parent == Player.Backpack then
        GetChar().Humanoid:EquipTool(rod)
        task.wait(0.3)
        Debug("Rod equipped")
        return true
    end
    return false
end

-- ════════════════════════════════════════════════════════
-- AGGRESSIVE FISHING
-- ════════════════════════════════════════════════════════
local IsFishing = false
local LastCast = 0

-- AUTO CAST (TRY EVERYTHING!)
task.spawn(function()
    while task.wait(1) do
        if Config.Enabled and Config.AutoCast and not IsFishing then
            if tick() - LastCast >= Config.CastDelay then
                Stats.Casts = Stats.Casts + 1
                Debug("═══ CAST ATTEMPT #" .. Stats.Casts .. " ═══")
                
                -- Method 1: Equip rod
                if EquipRod() then
                    task.wait(0.3)
                    
                    -- Method 2: Try all remotes with "cast" in name
                    local fired = false
                    for _, remote in pairs(AllRemotes) do
                        local name = remote.Name:lower()
                        if name:find("cast") or name:find("throw") or name:find("fish") then
                            Debug("Trying remote:", remote.Name)
                            pcall(function()
                                remote:FireServer()
                            end)
                            fired = true
                        end
                    end
                    
                    -- Method 3: Activate tool
                    if not fired then
                        local rod = GetRod()
                        if rod then
                            Debug("Activating tool:", rod.Name)
                            rod:Activate()
                        end
                    end
                    
                    -- Method 4: Click mouse (some games use this)
                    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.1)
                    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    
                    IsFishing = true
                    LastCast = tick()
                    Debug("✅ Cast attempted!")
                end
            end
        end
    end
end)

Debug("Cast loop started")

-- AUTO REEL (TRY EVERYTHING!)
task.spawn(function()
    while task.wait(0.2) do
        if Config.Enabled and Config.AutoReel then
            
            -- Method 1: Look for ANY visible UI
            for _, ui in pairs(PlayerGui:GetDescendants()) do
                
                -- Skip our own GUI
                if ui:IsDescendantOf(SG) then continue end
                
                local name = ui.Name:lower()
                local isVisible = false
                
                -- Check visibility
                if ui:IsA("ScreenGui") then
                    isVisible = ui.Enabled
                elseif ui:IsA("Frame") or ui:IsA("ImageLabel") then
                    isVisible = ui.Visible
                end
                
                -- Look for fishing keywords
                if isVisible and (
                    name:find("fish") or 
                    name:find("reel") or 
                    name:find("catch") or 
                    name:find("bobber") or
                    name:find("bar") or
                    name:find("progress")
                ) then
                    Stats.Reels = Stats.Reels + 1
                    
                    Debug("═══ REEL ATTEMPT #" .. Stats.Reels .. " ═══")
                    Debug("UI Found:", ui.Name, "|", ui:GetFullName())
                    
                    task.wait(Config.ReelDelay)
                    
                    -- Method 1: Try all reel remotes
                    local fired = false
                    for _, remote in pairs(AllRemotes) do
                        local rname = remote.Name:lower()
                        if rname:find("reel") or rname:find("catch") or rname:find("finish") then
                            Debug("Firing:", remote.Name)
                            pcall(function()
                                remote:FireServer(100, true)
                            end)
                            pcall(function()
                                remote:FireServer(100)
                            end)
                            pcall(function()
                                remote:FireServer()
                            end)
                            fired = true
                        end
                    end
                    
                    -- Method 2: Find and click button
                    for _, btn in pairs(ui:GetDescendants()) do
                        if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                            Debug("Clicking button:", btn.Name)
                            pcall(function() btn.MouseButton1Click:Fire() end)
                            pcall(function() firesignal(btn.MouseButton1Click) end)
                            pcall(function() btn.Activated:Fire() end)
                        end
                    end
                    
                    -- Method 3: Press E key (some games use this)
                    VIM:SendKeyEvent(true, "E", false, game)
                    task.wait(0.1)
                    VIM:SendKeyEvent(false, "E", false, game)
                    
                    -- Method 4: Click mouse
                    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.05)
                    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    
                    Stats.Fish = Stats.Fish + 1
                    IsFishing = false
                    Debug("✅ Reel attempted! Fish #" .. Stats.Fish)
                    
                    break
                end
            end
        end
    end
end)

Debug("Reel loop started")

-- AUTO SHAKE (TRY EVERYTHING!)
task.spawn(function()
    while task.wait(0.15) do
        if Config.Enabled and Config.AutoShake then
            for _, ui in pairs(PlayerGui:GetDescendants()) do
                if ui:IsDescendantOf(SG) then continue end
                
                local name = ui.Name:lower()
                if (name:find("shake") or name:find("struggle") or name:find("minigame")) and ui:IsA("Frame") and ui.Visible then
                    Debug("Shake detected!")
                    
                    -- Method 1: Try shake remotes
                    for _, remote in pairs(AllRemotes) do
                        if remote.Name:lower():find("shake") then
                            pcall(function() remote:FireServer() end)
                        end
                    end
                    
                    -- Method 2: Spam W key
                    for i = 1, 5 do
                        VIM:SendKeyEvent(true, "W", false, game)
                        task.wait(0.03)
                        VIM:SendKeyEvent(false, "W", false, game)
                        task.wait(0.03)
                    end
                    
                    -- Method 3: Click mouse
                    for i = 1, 3 do
                        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.05)
                        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        task.wait(0.05)
                    end
                    
                    break
                end
            end
        end
    end
end)

Debug("Shake loop started")

-- Safety reset
task.spawn(function()
    while task.wait(30) do
        if IsFishing and tick() - LastCast > 30 then
            IsFishing = false
            Debug("Reset timeout")
        end
    end
end)

print("════════════════════════════════════════")
print("✅ AGGRESSIVE MODE LOADED!")
print("════════════════════════════════════════")
print("This script tries EVERYTHING:")
print("  - All remotes")
print("  - Button clicks")
print("  - Key presses")
print("  - Mouse clicks")
print("════════════════════════════════════════")
print("Watch console for debug messages!")
print("Press DELETE to toggle GUI")
print("════════════════════════════════════════")
