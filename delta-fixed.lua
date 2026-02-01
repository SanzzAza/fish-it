--[[
    🎣 FISH IT - AUTO FISHING SCRIPT V2 🎣
    UI: Rayfield (Stable) + Fallback UI
    Compatible: KRNL, Fluxus, Delta, Electron, Xeno, Solara, Hydrogen
--]]

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

--// Settings
getgenv().FishItSettings = {
    AutoFish = false,
    InstantCatch = false,
    AutoSell = false,
    PerfectCast = true,
    FastReel = false,
    AntiAFK = false,
    WalkSpeed = 16,
    JumpPower = 50
}

--// Simple UI Function (Fallback)
local function CreateSimpleUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FishItSimpleUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Title.Text = "🎣 Fish It - Auto Farm"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    local Corner2 = Instance.new("UICorner")
    Corner2.CornerRadius = UDim.new(0, 8)
    Corner2.Parent = Title
    
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Name = "ScrollingFrame"
    ScrollingFrame.Size = UDim2.new(1, -20, 1, -50)
    ScrollingFrame.Position = UDim2.new(0, 10, 0, 45)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.ScrollBarThickness = 4
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
    ScrollingFrame.Parent = MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.Parent = ScrollingFrame
    
    -- Create Toggle Button Function
    local function CreateToggle(text, settingName)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -10, 0, 40)
        Button.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        Button.Text = "⬜ " .. text
        Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        Button.TextSize = 14
        Button.Font = Enum.Font.GothamSemibold
        Button.Parent = ScrollingFrame
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Button
        
        Button.MouseButton1Click:Connect(function()
            getgenv().FishItSettings[settingName] = not getgenv().FishItSettings[settingName]
            if getgenv().FishItSettings[settingName] then
                Button.Text = "✅ " .. text
                Button.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
            else
                Button.Text = "⬜ " .. text
                Button.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            end
        end)
        
        return Button
    end
    
    CreateToggle("Auto Fish", "AutoFish")
    CreateToggle("Instant Catch", "InstantCatch")
    CreateToggle("Perfect Cast", "PerfectCast")
    CreateToggle("Auto Sell", "AutoSell")
    CreateToggle("Anti-AFK", "AntiAFK")
    CreateToggle("Fast Reel", "FastReel")
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = MainFrame
    
    local Corner3 = Instance.new("UICorner")
    Corner3.CornerRadius = UDim.new(0, 6)
    Corner3.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Minimize Button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -70, 0, 5)
    MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.TextSize = 20
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Parent = MainFrame
    
    local Corner4 = Instance.new("UICorner")
    Corner4.CornerRadius = UDim.new(0, 6)
    Corner4.Parent = MinBtn
    
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        ScrollingFrame.Visible = not minimized
        if minimized then
            MainFrame.Size = UDim2.new(0, 300, 0, 50)
            MinBtn.Text = "+"
        else
            MainFrame.Size = UDim2.new(0, 300, 0, 400)
            MinBtn.Text = "-"
        end
    end)
    
    return ScreenGui
end

--// Try to Load Rayfield UI
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("⚠️ Rayfield failed to load, using Simple UI...")
    CreateSimpleUI()
else
    --// Rayfield UI Setup
    local Window = Rayfield:CreateWindow({
        Name = "🎣 Fish It - Auto Farm Premium",
        LoadingTitle = "Fish It Script",
        LoadingSubtitle = "by Premium Dev",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "FishItHub",
            FileName = "Config"
        },
        Discord = {
            Enabled = false,
            Invite = "",
            RememberJoins = true
        },
        KeySystem = false,
        Theme = "Default"
    })

    local MainTab = Window:CreateTab("Auto Fish", 4483362458)
    local SellTab = Window:CreateTab("Auto Sell", 4483362458)
    local TeleportTab = Window:CreateTab("Teleport", 4483362458)
    local MiscTab = Window:CreateTab("Misc", 4483362458)

    --// Auto Fish Logic
    local function AutoFish()
        while getgenv().FishItSettings.AutoFish do
            task.wait()
            
            pcall(function()
                local Rod = Character:FindFirstChildOfClass("Tool")
                if Rod and Rod:FindFirstChild("events") then
                    -- Cast
                    if getgenv().FishItSettings.PerfectCast then
                        Rod.events.cast:FireServer("charge")
                        task.wait(0.8)
                        Rod.events.cast:FireServer("release", 100)
                    else
                        Rod.events.cast:FireServer("cast")
                    end
                    
                    -- Catch
                    if getgenv().FishItSettings.InstantCatch then
                        task.wait(0.3)
                        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Fish"):FireServer("instant_catch")
                    else
                        task.wait(1.5)
                        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Fish"):FireServer("reel")
                    end
                    
                    task.wait(1.2)
                end
            end)
        end
    end

    --// Auto Sell Logic
    local function AutoSell()
        while getgenv().FishItSettings.AutoSell do
            task.wait(10)
            pcall(function()
                ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SellFish"):FireServer("SellAll")
                Rayfield:Notify({
                    Title = "Auto Sell",
                    Content = "Sold all fish!",
                    Duration = 3,
                    Image = 4483362458
                })
            end)
        end
    end

    --// Anti-AFK
    local function AntiAFK()
        while getgenv().FishItSettings.AntiAFK do
            VirtualInputManager:SendKeyEvent(true, "Space", false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, "Space", false, game)
            task.wait(300)
        end
    end

    --// GUI Elements
    MainTab:CreateToggle({
        Name = "🔥 Enable Auto Fish",
        CurrentValue = false,
        Callback = function(Value)
            getgenv().FishItSettings.AutoFish = Value
            if Value then task.spawn(AutoFish) end
        end
    })

    MainTab:CreateToggle({
        Name = "⚡ Perfect Cast (Max Power)",
        CurrentValue = true,
        Callback = function(Value)
            getgenv().FishItSettings.PerfectCast = Value
        end
    })

    MainTab:CreateToggle({
        Name = "💫 Instant Catch (No Wait)",
        CurrentValue = false,
        Callback = function(Value)
            getgenv().FishItSettings.InstantCatch = Value
        end
    })

    MainTab:CreateToggle({
        Name = "🌀 Fast Reel Speed",
        CurrentValue = false,
        Callback = function(Value)
            getgenv().FishItSettings.FastReel = Value
        end
    })

    SellTab:CreateToggle({
        Name = "💰 Auto Sell Fish",
        CurrentValue = false,
        Callback = function(Value)
            getgenv().FishItSettings.AutoSell = Value
            if Value then task.spawn(AutoSell) end
        end
    })

    SellTab:CreateSlider({
        Name = "Sell Interval (Seconds)",
        Range = {5, 60},
        Increment = 5,
        Suffix = "s",
        CurrentValue = 10,
        Callback = function(Value)
            -- Update interval logic
        end
    })

    --// Teleport
    local Locations = {
        ["Fisherman Island"] = CFrame.new(0, 10, 0),
        ["Kohana Village"] = CFrame.new(500, 10, 500),
        ["Coral Reef"] = CFrame.new(-500, 10, 300),
        ["Esoteric Depths"] = CFrame.new(1000, -50, 1000),
        ["Open Ocean"] = CFrame.new(0, 0, 2000)
    }

    for name, cf in pairs(Locations) do
        TeleportTab:CreateButton({
            Name = "🏝️ Teleport to " .. name,
            Callback = function()
                HumanoidRootPart.CFrame = cf
                Rayfield:Notify({
                    Title = "Teleport",
                    Content = "Teleported to " .. name,
                    Duration = 3
                })
            end
        })
    end

    MiscTab:CreateToggle({
        Name = "🛡️ Anti-AFK",
        CurrentValue = false,
        Callback = function(Value)
            getgenv().FishItSettings.AntiAFK = Value
            if Value then task.spawn(AntiAFK) end
        end
    })

    MiscTab:CreateSlider({
        Name = "WalkSpeed",
        Range = {16, 200},
        Increment = 1,
        Suffix = "Speed",
        CurrentValue = 16,
        Callback = function(Value)
            Humanoid.WalkSpeed = Value
        end
    })

    Rayfield:Notify({
        Title = "Script Loaded!",
        Content = "Fish It Auto Farm is ready to use",
        Duration = 5,
        Image = 4483362458
    })
end

--// Character Added Connection
LocalPlayer.CharacterAdded:Connect(function(NewChar)
    Character = NewChar
    Humanoid = NewChar:WaitForChild("Humanoid")
    HumanoidRootPart = NewChar:WaitForChild("HumanoidRootPart")
end)

print([[
    🎣 FISH IT SCRIPT LOADED SUCCESSFULLY 🎣
    =======================================
    If menu not visible:
    - Check your executor's UI toggle key (Usually Insert or Delete)
    - Try re-executing the script
    - Check console for errors (F9)
]])
