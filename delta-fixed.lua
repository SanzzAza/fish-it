-- Versi Super Simple (Pasti muncul)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FishItMenu"
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 300)
Frame.Position = UDim2.new(0.5, -125, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "FISH IT - AUTO"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = Frame

-- Auto Fish Toggle
local Toggle = Instance.new("TextButton")
Toggle.Text = "AUTO FISH: OFF"
Toggle.Size = UDim2.new(0.9, 0, 0, 40)
Toggle.Position = UDim2.new(0.05, 0, 0.15, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Parent = Frame

local fishing = false
Toggle.MouseButton1Click:Connect(function()
    fishing = not fishing
    Toggle.Text = fishing and "AUTO FISH: ON" or "AUTO FISH: OFF"
    Toggle.BackgroundColor3 = fishing and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(60, 60, 80)
    
    while fishing do
        task.wait(1)
        pcall(function()
            local rod = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if rod and rod:FindFirstChild("events") then
                rod.events.cast:FireServer("cast")
                task.wait(1.5)
                game.ReplicatedStorage.Remotes.Fish:FireServer("reel")
            end
        end)
    end
end)

-- Auto Sell
local SellBtn = Instance.new("TextButton")
SellBtn.Text = "SELL ALL FISH"
SellBtn.Size = UDim2.new(0.9, 0, 0, 40)
SellBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
SellBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 60)
SellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SellBtn.Parent = Frame

SellBtn.MouseButton1Click:Connect(function()
    game.ReplicatedStorage.Remotes.SellFish:FireServer("SellAll")
end)

-- Close Button
local Close = Instance.new("TextButton")
Close.Text = "X"
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 0)
Close.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Parent = Frame

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
