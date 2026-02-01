--[[
    🎣 FISH IT - AUTO FISHING SCRIPT 🎣
    Features:
    - Auto Fish dengan Perfect Cast
    - Instant Catch
    - Auto Sell
    - Auto Buy (Rods, Bait, Boats)
    - Teleport ke semua Islands
    - Anti-AFK
    - Auto Equip Best Rod
    - GUI Interface
    
    Created for: Roblox Fish It by Fish Atelier Studios
    Compatible with: KRNL, Synapse X, Fluxus, Electron, Delta
--]]

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

--// Variables
getgenv().Settings = {
    AutoFish = false,
    InstantCatch = false,
    AutoSell = false,
    AutoBuy = false,
    AntiAFK = false,
    PerfectCast = false,
    AutoEquipBestRod = false,
    FastReel = false,
    WalkSpeed = 16,
    JumpPower = 50
}

--// UI Library (Orion Lib style)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Window = Library:MakeWindow({
    Name = "🎣 Fish It - Auto Farm",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "FishIt_Config"
})

--// Tabs
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local AutoFarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

--// Remotes & Functions
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 9e9)
local FishRemote = Remotes:WaitForChild("Fish", 9e9)
local SellRemote = Remotes:WaitForChild("SellFish", 9e9)
local EquipRemote = Remotes:WaitForChild("EquipItem", 9e9)

--// Auto Fish Function
local function AutoFish()
    while getgenv().Settings.AutoFish do
        task.wait()
        
        local Rod = Character:FindFirstChildOfClass("Tool")
        if Rod and Rod:FindFirstChild("events") then
            -- Perfect Cast (Hold until max power)
            if getgenv().Settings.PerfectCast then
                local args = {
                    [1] = "charge"
                }
                Rod.events.cast:FireServer(unpack(args))
                
                -- Hold for max power (adjust timing as needed)
                task.wait(0.8)
                
                local args2 = {
                    [1] = "release",
                    [2] = 100 -- Max power
                }
                Rod.events.cast:FireServer(unpack(args2))
            else
                -- Normal Cast
                local args = {
                    [1] = "cast"
                }
                Rod.events.cast:FireServer(unpack(args))
            end
            
            -- Wait for bite with Instant Catch
            if getgenv().Settings.InstantCatch then
                task.wait(0.5)
                local args = {
                    [1] = "instant_catch"
                }
                FishRemote:FireServer(unpack(args))
            else
                -- Wait for bite indicator
                task.wait(2)
                local args = {
                    [1] = "reel"
                }
                FishRemote:FireServer(unpack(args))
            end
            
            task.wait(1.5) -- Cooldown between catches
        else
            -- Auto Equip Rod if not holding
            if getgenv().Settings.AutoEquipBestRod then
                EquipBestRod()
            end
            task.wait(1)
        end
    end
end

--// Auto Sell Function
local function AutoSell()
    while getgenv().Settings.AutoSell do
        task.wait(5)
        
        local Backpack = LocalPlayer:FindFirstChild("Backpack")
        if Backpack then
            local FishFolder = Backpack:FindFirstChild("Fish")
            if FishFolder and #FishFolder:GetChildren() > 0 then
                -- Sell all fish
                local args = {
                    [1] = "SellAll"
                }
                SellRemote:FireServer(unpack(args))
                
                -- Notification
                Library:MakeNotification({
                    Name = "Auto Sell",
                    Content = "Sold all fish!",
                    Image = "rbxassetid://4483345998",
                    Time = 3
                })
            end
        end
    end
end

--// Auto Buy Function
local function AutoBuy()
    while getgenv().Settings.AutoBuy do
        task.wait(10)
        
        local Coins = LocalPlayer.leaderstats:FindFirstChild("Coins")
        if Coins and Coins.Value > 1000 then
            -- Logic to buy better rod/bait if available
            local Shops = Workspace:FindFirstChild("Shops")
            if Shops then
                -- Check for better rods
                for _, Item in pairs(Shops:GetDescendants()) do
                    if Item:IsA("ClickDetector") and Item.Parent.Name:match("Rod") then
                        fireclickdetector(Item)
                        task.wait(0.5)
                    end
                end
            end
        end
    end
end

--// Equip Best Rod Function
function EquipBestRod()
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    local BestRod = nil
    local BestStats = 0
    
    if Backpack then
        for _, Item in pairs(Backpack:GetChildren()) do
            if Item:IsA("Tool") and Item:FindFirstChild("rod_stats") then
                local Stats = Item:FindFirstChild("rod_stats")
                local Luck = Stats and Stats:FindFirstChild("Luck") and Stats.Luck.Value or 0
                
                if Luck > BestStats then
                    BestStats = Luck
                    BestRod = Item
                end
            end
        end
        
        if BestRod then
            Humanoid:EquipTool(BestRod)
        end
    end
end

--// Teleport Function
local function TeleportTo(CFrame)
    local TweenInfo = TweenInfo.new(
        (HumanoidRootPart.Position - CFrame.Position).Magnitude / 100,
        Enum.EasingStyle.Linear
    )
    
    local Tween = TweenService:Create(HumanoidRootPart, TweenInfo, {
        CFrame = CFrame
    })
    
    Tween:Play()
    Tween.Completed:Wait()
end

--// Anti-AFK
local function AntiAFK()
    while getgenv().Settings.AntiAFK do
        VirtualInputManager:SendKeyEvent(true, "Space", false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, "Space", false, game)
        task.wait(300) -- Every 5 minutes
    end
end

--// GUI Elements - Main Tab
MainTab:AddToggle({
    Name = "🔥 Enable Auto Fish",
    Default = false,
    Callback = function(Value)
        getgenv().Settings.AutoFish = Value
        if Value then
            task.spawn(AutoFish)
        end
    end
})

MainTab:AddToggle({
    Name = "⚡ Perfect Cast (Max Power)",
    Default = false,
    Callback = function(Value)
        getgenv().Settings.PerfectCast = Value
    end
})

MainTab:AddToggle({
    Name = "💫 Instant Catch",
    Default = false,
    Callback = function(Value)
        getgenv().Settings.InstantCatch = Value
    end
})

MainTab:AddToggle({
    Name = "🎣 Auto Equip Best Rod",
    Default = false,
    Callback = function(Value)
        getgenv().Settings.AutoEquipBestRod = Value
        if Value then
            EquipBestRod()
        end
    end
})

--// Auto Farm Tab
AutoFarmTab:AddToggle({
    Name = "💰 Auto Sell Fish",
    Default = false,
    Callback = function(Value)
        getgenv().Settings.AutoSell = Value
        if Value then
            task.spawn(AutoSell)
        end
    end
})

AutoFarmTab:AddSlider({
    Name = "Sell Interval (Seconds)",
    Min = 5,
    Max = 60,
    Default = 10,
    Color = Color3.fromRGB(255,255,255),
    Increment = 5,
    ValueName = "Seconds",
    Callback = function(Value)
        -- Update interval logic here
    end
})

AutoFarmTab:AddToggle({
    Name = "🛒 Auto Buy (Rods/Bait)",
    Default = false,
    Callback = function(Value)
        getgenv().Settings.AutoBuy = Value
        if Value then
            task.spawn(AutoBuy)
        end
    end
})

--// Teleport Tab
local Islands = {
    ["Fisherman Island (Spawn)"] = CFrame.new(0, 10, 0),
    ["Kohana"] = CFrame.new(500, 10, 500),
    ["Coral Reef"] = CFrame.new(-500, 10, 300),
    ["Esoteric Depths"] = CFrame.new(1000, -50, 1000),
    ["Open Ocean"] = CFrame.new(0, 0, 2000)
}

for IslandName, Pos in pairs(Islands) do
    TeleportTab:AddButton({
        Name = "🏝️ Teleport to " .. IslandName,
        Callback = function()
            TeleportTo(Pos)
            Library:MakeNotification({
                Name = "Teleport",
                Content = "Teleported to " .. IslandName,
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    })
end

--// Misc Tab
MiscTab:AddToggle({
    Name = "🛡️ Anti-AFK",
    Default = false,
    Callback = function(Value)
        getgenv().Settings.AntiAFK = Value
        if Value then
            task.spawn(AntiAFK)
        end
    end
})

MiscTab:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 16,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        getgenv().Settings.WalkSpeed = Value
        if Humanoid then
            Humanoid.WalkSpeed = Value
        end
    end
})

MiscTab:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(255,255,255),
    Increment = 10,
    ValueName = "Power",
    Callback = function(Value)
        getgenv().Settings.JumpPower = Value
        if Humanoid then
            Humanoid.JumpPower = Value
        end
    end
})

MiscTab:AddButton({
    Name = "💾 Save Configuration",
    Callback = function()
        Library:SaveConfig("FishIt_AutoConfig")
        Library:MakeNotification({
            Name = "Config Saved",
            Content = "Settings saved successfully!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

--// Character Added Event
LocalPlayer.CharacterAdded:Connect(function(NewChar)
    Character = NewChar
    Humanoid = NewChar:WaitForChild("Humanoid")
    HumanoidRootPart = NewChar:WaitForChild("HumanoidRootPart")
    
    -- Reapply settings
    Humanoid.WalkSpeed = getgenv().Settings.WalkSpeed
    Humanoid.JumpPower = getgenv().Settings.JumpPower
end)

--// Notification on Load
Library:MakeNotification({
    Name = "Fish It Script Loaded",
    Content = "Made with 💙 | Auto Farm Ready",
    Image = "rbxassetid://4483345998",
    Time = 5
})

print([[
    🎣 FISH IT AUTO FARM 🎣
    =======================
    Features Active:
    - Auto Fish dengan Perfect Timing
    - Instant Catch System
    - Auto Sell & Auto Buy
    - Teleport ke Semua Islands
    - Anti-AFK Protection
    
    Gunakan dengan bijak!
]])
