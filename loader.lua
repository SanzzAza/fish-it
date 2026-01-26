--[[
    ═══════════════════════════════════════════════════════
    🎣 FISCH AUTO FISH LOADER
    By: SanzzAza
    Repository: https://github.com/SanzzAza/fish-it
    Version: 3.0.0
    
    Loadstring:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SanzzAza/fish-it/main/loader.lua"))()
    ═══════════════════════════════════════════════════════
]]

repeat wait() until game:IsLoaded()
repeat wait() until game.Players.LocalPlayer

local LoaderVersion = "3.0.0"

-- ════════════════════════════════════════════════════════
-- CONFIGURATION (Auto-detected)
-- ════════════════════════════════════════════════════════
local Config = {
    Username = "SanzzAza",
    Repository = "fish-it",
    Branch = "main",
}

local BaseURL = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/",
    Config.Username,
    Config.Repository,
    Config.Branch
)

-- ════════════════════════════════════════════════════════
-- NOTIFICATION FUNCTION
-- ════════════════════════════════════════════════════════
local function Notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🎣 " .. title;
            Text = text;
            Duration = duration or 5;
            Icon = "rbxassetid://7733993211";
        })
    end)
end

-- ════════════════════════════════════════════════════════
-- GAME VERIFICATION
-- ════════════════════════════════════════════════════════
local SupportedGames = {
    [16732694052] = "Fisch",
}

local GameName = SupportedGames[game.PlaceId]

if not GameName then
    Notify("⚠️ Warning", "Game might not be supported!", 10)
    warn("PlaceId:", game.PlaceId)
    warn("This script is optimized for Fisch")
end

-- ════════════════════════════════════════════════════════
-- ANTI-DUPLICATE CHECK
-- ════════════════════════════════════════════════════════
if getgenv().FischAutoLoaded then
    Notify("⚠️ Already Running", "Script is already active!", 5)
    return
end

getgenv().FischAutoLoaded = true

-- ════════════════════════════════════════════════════════
-- LOADING ANIMATION
-- ════════════════════════════════════════════════════════
Notify("Loading...", "Fisch Auto v" .. LoaderVersion, 3)

print("════════════════════════════════════════════════════════")
print("🎣 FISCH AUTO FISH LOADER")
print("════════════════════════════════════════════════════════")
print("Version:", LoaderVersion)
print("GitHub:", "SanzzAza/fish-it")
print("Loading from:", BaseURL)
print("════════════════════════════════════════════════════════")

-- ════════════════════════════════════════════════════════
-- LOAD MAIN SCRIPT
-- ════════════════════════════════════════════════════════
local LoadAttempts = 0
local MaxAttempts = 3

local function LoadScript(scriptName)
    LoadAttempts = LoadAttempts + 1
    
    local success, result = pcall(function()
        return game:HttpGet(BaseURL .. scriptName, true)
    end)
    
    if success and result then
        return result
    else
        if LoadAttempts < MaxAttempts then
            warn("Attempt", LoadAttempts, "failed. Retrying...")
            wait(1)
            return LoadScript(scriptName)
        else
            return nil
        end
    end
end

local scriptContent = LoadScript("main.lua")

if scriptContent then
    Notify("✅ Loaded Successfully!", "Fisch Auto is ready!", 3)
    
    local success, err = pcall(function()
        loadstring(scriptContent)()
    end)
    
    if not success then
        Notify("❌ Execution Error", tostring(err), 10)
        warn("Execution Error:", err)
    end
else
    Notify("❌ Load Failed", "Could not fetch main.lua", 10)
    warn("════════════════════════════════════════════════════════")
    warn("❌ FAILED TO LOAD SCRIPT")
    warn("════════════════════════════════════════════════════════")
    warn("Possible reasons:")
    warn("1. main.lua not uploaded to GitHub")
    warn("2. Repository is private (must be public)")
    warn("3. Internet connection issue")
    warn("4. GitHub is down")
    warn("")
    warn("Expected URL:")
    warn(BaseURL .. "main.lua")
    warn("════════════════════════════════════════════════════════")
end
