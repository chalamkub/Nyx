local HttpService = game:GetService("HttpService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local API_URL = "https://zerzy.xyz/api/verify.php"

local Key = getgenv().Key
if not Key or tostring(Key) == "" then
    LocalPlayer:Kick("Whitelist Key is missing")
    return
end
Key = tostring(Key)

local function GetHWID()
    local fns = { gethwid, get_hwid, syn and syn.get_hwid }
    for _, fn in ipairs(fns) do
        if typeof(fn) == "function" then
            local ok, result = pcall(fn)
            if ok and result then return tostring(result) end
        end
    end
end

local HWID = GetHWID()
if not HWID then
    LocalPlayer:Kick("Unable to get HWID")
    return
end

local RequestFunction = request or http_request or (syn and syn.request)
if typeof(RequestFunction) ~= "function" then
    LocalPlayer:Kick("HTTP request is not supported")
    return
end

local Response
local ok = pcall(function()
    Response = RequestFunction({
        Url = API_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode({ key = Key, hwid = HWID })
    })
end)
if not ok or not Response then
    LocalPlayer:Kick("Whitelist API connection failed")
    return
end

local Data
local DecodeOK = pcall(function()
    Data = HttpService:JSONDecode(Response.Body or Response.body or "")
end)
if not DecodeOK or type(Data) ~= "table" then
    LocalPlayer:Kick("Invalid API response")
    return
end

if Data.success ~= true then
    LocalPlayer:Kick(tostring(Data.message or "Whitelist verification failed"))
    return
end

-- =====================================================================
-- Key time left
-- =====================================================================

-- 1) Find the expiry in the API response.
--    The server's field name is unknown to this script, so it tries the common names (also inside Data.data).
--    If the timer says "Key active" instead of a time, look at the printed JSON in the console and put the
--    real field name first in the list below.
local EXPIRY_FIELDS = {
    "expires_at", "expire_at", "expires", "expiry", "expire", "expiration", "expired_at", "expire_time",
    "valid_until", "end_time", "ends_at", "timeleft", "time_left", "remaining", "seconds_left", "ttl", "duration",
}
local RELATIVE_HINTS = { "left", "remain", "ttl", "duration" } -- field names that hold "seconds from now"

local function IsRelativeName(name)
    for _, h in ipairs(RELATIVE_HINTS) do
        if string.find(name, h, 1, true) then return true end
    end
    return false
end

-- returns: unix time when the key ends, or "lifetime", or nil when nothing was found
local function ToExpiryTime(name, value)
    local t = type(value)
    if t == "string" then
        local low = string.lower(value)
        if low == "never" or low == "lifetime" or low == "permanent" or low == "unlimited" then return "lifetime" end
        local num = tonumber(value)
        if num then
            value, t = num, "number"
        else
            local iso = string.gsub(value, " ", "T", 1)
            if not string.find(iso, "Z$") and not string.find(iso, "[%+%-]%d%d:?%d%d$") then
                iso = iso .. "Z" -- a date without a timezone is read as UTC; add the offset yourself if the server uses local time
            end
            local good, dt = pcall(function() return DateTime.fromIsoDate(iso) end)
            if good and dt then return dt.UnixTimestamp end
            return nil
        end
    end
    if t == "number" then
        if value <= 0 then return "lifetime" end
        if value > 1e12 then value = value / 1000 end        -- milliseconds
        if IsRelativeName(name) or value < 1e9 then          -- seconds from now
            return os.time() + value
        end
        return value                                         -- unix time
    end
    return nil
end

local function FindExpiry(tbl)
    for _, name in ipairs(EXPIRY_FIELDS) do
        local result = ToExpiryTime(name, tbl[name])
        if result then return result end
    end
end

local ExpireAt = FindExpiry(Data)
if not ExpireAt and type(Data.data) == "table" then ExpireAt = FindExpiry(Data.data) end
if not ExpireAt and type(Data.key) == "table" then ExpireAt = FindExpiry(Data.key) end
if not ExpireAt then
    print("[Key] No expiry field found. API response: " .. HttpService:JSONEncode(Data))
end

-- 2) Load the UI and create the window
local MacUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/USER/REPO/main/MacUI.lua"))() -- <- your raw link
local Window = MacUI.CreateWindow({
    Title = "My Hub",
    Subtitle = "Primary",
    -- MaskName = true,   -- show the name as "iM*****"
})

-- 3) Show the time left under your name (bottom left of the sidebar)
local ORANGE, RED = "#FF8A3D", "#FF5252"

local function Format(left)
    if left <= 0 then
        return '<font color="' .. RED .. '">Key expired</font>'
    elseif left >= 86400 then
        return string.format('Expires: <font color="%s">%dd %dh</font>', ORANGE, math.floor(left / 86400), math.floor(left % 86400 / 3600))
    end
    return string.format('Expires: <font color="%s">%dh %dm</font>', ORANGE, math.floor(left / 3600), math.floor(left % 3600 / 60))
end

if ExpireAt == "lifetime" then
    Window:SetUserNote('Expires: <font color="' .. ORANGE .. '">Lifetime</font>')
elseif ExpireAt then
    task.spawn(function()
        while table.find(MacUI._windows, Window) do -- stops by itself when the UI is closed
            local left = ExpireAt - os.time()
            Window:SetUserNote(Format(left))
            if left <= 0 then
                -- the key has run out while the script was running: add your own action here, e.g.
                -- LocalPlayer:Kick("Your key has expired")
                break
            end
            task.wait(15)
        end
    end)
else
    Window:SetUserNote("Key active")
end

-- ใส่โค้ดสคริปต์หลักของคุณต่อจากตรงนี้ (Window:AddTab(...), Tab:AddSection(...) ...)

-- ============================================================
--  2SKI Universal Script Hub & Telemetry Loader v3
--  Features:
--    1. Multi-Map Auto-Routing via PlaceId & Central Registry
--    2. Real-Time ID & Telemetry Tracker (Who runs, which map)
--    3. Anti-Environment & Tamper Protection
--    4. Maintenance Killswitch per Game
-- ============================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local MarketplaceService = game:GetService("MarketplaceService")

local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local currentPlaceId = game.PlaceId

local GITHUB_BASE = "https://raw.githubusercontent.com/hxrendontcry/2kscripts/main/"
local cacheBust = "?t=" .. tostring(os.time())

-- Notification Helper
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "2K Script Hub",
            Text = text or "",
            Duration = duration or 5
        })
    end)
end

-- Telemetry Reporter (ส่งข้อมูล ID ผู้รันเข้า Web Dashboard แบบไม่ขัดจังหวะ)
local function sendTelemetry(action, details)
    task.spawn(function()
        pcall(function()
            local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
            if not requestFunc then return end

            local gameName = "Roblox Experience"
            pcall(function()
                gameName = MarketplaceService:GetProductInfo(currentPlaceId).Name
            end)

            local execName = "Unknown"
            pcall(function()
                execName = (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "Executor"
            end)

            local payload = {
                userId = localPlayer.UserId,
                username = localPlayer.Name,
                displayName = localPlayer.DisplayName,
                placeId = currentPlaceId,
                gameName = gameName,
                executor = execName,
                action = action or "execute",
                details = details or {}
            }

            -- Telemetry endpoints: 24/7 Permanent Vercel Server + Localhost fallback
            local endpoints = {
                "https://2k-telemetry-dashboard.vercel.app/api/telemetry",
                "http://localhost:3000/api/telemetry"
            }

            for _, ep in ipairs(endpoints) do
                pcall(function()
                    requestFunc({
                        Url = ep,
                        Method = "POST",
                        Headers = { 
                            ["Content-Type"] = "application/json",
                            ["x-2k-signature"] = "2k-sec-v3-e8a9f2"
                        },
                        Body = HttpService:JSONEncode(payload)
                    })
                end)
            end
        end)
    end)
end

-- ── Heartbeat Watchdog: ส่งสัญญาณชีพทุก 35 วินาที เพื่อให้แดชบอร์ดระบุว่า ONLINE ตลอดเวลาที่เล่น ──
task.spawn(function()
    while true do
        task.wait(35)
        sendTelemetry("heartbeat", { ping = true })
    end
end)

-- ── Layer 1: Anti-Environment Guard ──────────────────────────
local okAnti, anti = pcall(function()
    return loadstring(game:HttpGet(GITHUB_BASE .. "anti_env.lua" .. cacheBust))()
end)

if okAnti and anti then
    pcall(anti.enforce)
    anti.startWatchdog(25)
else
    local genv = getgenv and getgenv() or _G
    if genv.Hydroxide or genv.RemoteSpy or genv.SimpleSpy then
        localPlayer:Kick("[2SKI] Blocked")
        error("", 0)
    end
end

-- ── Layer 2: Universal Map Routing & Execution ────────────────
local function executeTargetScript(scriptUrl, gameTitle)
    notify("2K Script Hub", "กำลังโหลดสคริปต์สำหรับ " .. (gameTitle or "เกมนี้") .. "...", 3)
    sendTelemetry("execute", { title = gameTitle, url = scriptUrl })

    local okFetch, src = pcall(game.HttpGet, game, scriptUrl .. cacheBust)
    if not okFetch or not src or src == "" then
        notify("2K Script Hub", "เกิดข้อผิดพลาดในการดาวน์โหลดสคริปต์", 6)
        return
    end

    local fn, err = loadstring(src)
    if not fn then
        notify("2K Script Hub", "Syntax Error: " .. tostring(err), 8)
        error("[2SKI] Compile error: " .. tostring(err), 0)
        return
    end

    local okRun, runErr = pcall(fn)
    if not okRun then
        notify("2K Script Hub", "Runtime Error: " .. tostring(runErr), 8)
        warn("[2SKI] Execution failed: " .. tostring(runErr))
    end
end

-- ดึงสารบัญเกมจาก GitHub Registry
local okGames, gamesJson = pcall(game.HttpGet, game, GITHUB_BASE .. "games.json" .. cacheBust)
local matchedGame = nil

if okGames and gamesJson and gamesJson ~= "" then
    local okParse, gamesList = pcall(function()
        return HttpService:JSONDecode(gamesJson)
    end)

    if okParse and type(gamesList) == "table" then
        for _, g in ipairs(gamesList) do
            if g.placeIds and type(g.placeIds) == "table" then
                for _, pid in ipairs(g.placeIds) do
                    if tonumber(pid) == tonumber(currentPlaceId) then
                        matchedGame = g
                        break
                    end
                end
            end
            if matchedGame then break end
        end
    end
end

-- ประมวลผลผลลัพธ์การจับคู่แมพ
if matchedGame then
    if matchedGame.status == "maintenance" then
        notify("2K Script Hub", "สคริปต์แมพ [" .. matchedGame.name .. "] กำลังปิดปรับปรุงชั่วคราว", 7)
        sendTelemetry("maintenance_alert", { name = matchedGame.name })
        return
    end

    executeTargetScript(matchedGame.scriptUrl, matchedGame.name)
else
    -- Fallback เฉพาะกรณี PlaceId 118805555015549 (Loot to Forge)
    if tonumber(currentPlaceId) == 118805555015549 then
        executeTargetScript(GITHUB_BASE .. "LootToForge.luau", "+1 ของรางวัลที่จะหลอม (Loot to Forge)")
    else
        -- แมพที่ยังไม่รองรับ: บันทึกข้อมูลเข้า Dashboard เพื่อให้แอดมินรู้ว่าคนอยากเล่นแมพไหน
        local gName = "Roblox Experience"
        pcall(function()
            gName = MarketplaceService:GetProductInfo(currentPlaceId).Name
        end)

        sendTelemetry("unsupported", { name = gName, placeId = currentPlaceId })
        notify("2K Script Hub", "แมพนี้ยังไม่รองรับ (" .. gName .. ")\nPlaceId: " .. tostring(currentPlaceId) .. " บันทึกคำขอแล้ว!", 8)
    end
end
