-- KeyTimer.lua
-- Timer for MacUI key verification

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    API_URL = "https://zerzy.xyz/api/verify.php",
    KICK_ON_EXPIRE = true,
}

local function getLibrary()
    local g = (getgenv and getgenv()) or _G
    return g.MacUI_Library
end

local function setNote(text, color)
    local lib = getLibrary()
    if not lib or type(lib._windows) ~= "table" then return end

    for _, w in pairs(lib._windows) do
        if type(w) == "table" and type(w.SetUserNote) == "function" then
            pcall(function()
                w.SetUserNote(w, text, color)
            end)
        end
    end
end

local function kickExpired()
    pcall(function()
        LocalPlayer:Kick("Your key has expired")
    end)
end

-- Put your existing verification/timer logic below.
