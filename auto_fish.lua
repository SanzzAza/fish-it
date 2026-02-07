--[[
  Fish It (Roblox) - Auto Fish Script (template)
  Gunakan di executor yang menyediakan: getgenv, task, VirtualInputManager, fireproximityprompt.
  Catatan: nama RemoteEvent/RemoteFunction bisa berbeda tiap update game.
]]

local SETTINGS = {
    enabled = true,
    autoSell = true,
    autoRecastDelay = 0.35,
    perfectHookDelay = 0.05,
    sellDelay = 30,
    debug = false,
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local localPlayer = Players.LocalPlayer
local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage

-- Ubah sesuai structure game jika perlu
local castRemote = remotesFolder:FindFirstChild("CastRod")
local hookRemote = remotesFolder:FindFirstChild("HookFish")
local reelRemote = remotesFolder:FindFirstChild("ReelFish")
local sellRemote = remotesFolder:FindFirstChild("SellAll")

local function log(...)
    if SETTINGS.debug then
        print("[AutoFish]", ...)
    end
end

local function hasRodEquipped()
    local char = localPlayer.Character
    if not char then
        return false
    end

    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("rod") or tool.Name:lower():find("pancing")) then
            return true
        end
    end

    return false
end

local function cast()
    if castRemote and castRemote:IsA("RemoteEvent") then
        castRemote:FireServer()
        log("Cast via remote")
        return
    end

    -- fallback: klik kiri mouse
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    log("Cast via virtual input")
end

local function hook()
    if hookRemote and hookRemote:IsA("RemoteEvent") then
        hookRemote:FireServer(true)
        log("Hook via remote")
        return
    end

    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.03)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    log("Hook via virtual input")
end

local function reel()
    if reelRemote and reelRemote:IsA("RemoteEvent") then
        reelRemote:FireServer()
        log("Reel via remote")
    end
end

local function sellAll()
    if not SETTINGS.autoSell then
        return
    end

    if sellRemote and sellRemote:IsA("RemoteEvent") then
        sellRemote:FireServer()
        log("Sell via remote")
        return
    end

    local map = workspace:FindFirstChild("Map")
    if not map then
        return
    end

    local sellPrompt = map:FindFirstChild("SellPrompt", true)
    if sellPrompt and sellPrompt:IsA("ProximityPrompt") then
        fireproximityprompt(sellPrompt)
        log("Sell via proximity prompt")
    end
end

local function waitForBite(timeout)
    local elapsed = 0
    timeout = timeout or 12

    while elapsed < timeout and SETTINGS.enabled do
        -- Placeholder pendeteksi bite: ubah sesuai indikator game
        -- Contoh: cek attribute/state character atau UI "Bite!"
        local gui = localPlayer:FindFirstChild("PlayerGui")
        local biteGui = gui and gui:FindFirstChild("BiteIndicator", true)
        if biteGui and biteGui.Enabled then
            return true
        end

        task.wait(0.1)
        elapsed += 0.1
    end

    return false
end

local function mainLoop()
    local sellTick = 0

    while SETTINGS.enabled do
        if not hasRodEquipped() then
            log("Rod belum di-equip")
            task.wait(1)
            continue
        end

        cast()
        local gotBite = waitForBite(12)

        if gotBite then
            task.wait(SETTINGS.perfectHookDelay)
            hook()
            task.wait(0.2)
            reel()
        end

        sellTick += 1
        if sellTick >= SETTINGS.sellDelay then
            sellAll()
            sellTick = 0
        end

        task.wait(SETTINGS.autoRecastDelay)
    end
end

getgenv().FishItAutoFish = {
    Stop = function()
        SETTINGS.enabled = false
    end,
    Start = function()
        if SETTINGS.enabled then
            return
        end

        SETTINGS.enabled = true
        task.spawn(mainLoop)
    end,
    Settings = SETTINGS,
}

task.spawn(mainLoop)

print("[AutoFish] Loaded. Gunakan getgenv().FishItAutoFish.Stop() untuk berhenti.")
