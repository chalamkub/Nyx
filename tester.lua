--[[
    KeyTimer.lua - MacUI Key Timer
    Fixed version

    วิธีใช้:
      1) โหลด MacUI.lua ก่อน
      2) โหลด KeyTimer.lua
      3) โหลด main.lua

    ไฟล์นี้จะไม่สร้าง/เปลี่ยน UI หลักเอง
    มันจะเชื่อมกับ MacUI_Library ที่ MacUI.lua ลงทะเบียนไว้
    และแสดงเวลาคีย์ผ่าน window:SetUserNote(...)

    หมายเหตุ:
    - ต้องมี MacUI_Library._windows
    - ถ้า UI Library ยังไม่มี SetUserNote ไฟล์นี้จะไม่ทำให้ UI พัง
    - ถ้า API ไม่ตอบกลับ จะใช้ fallback ตามที่กำหนด
]]

local CONFIG = {
    API_URL = "https://zerzy.xyz/api/verify.php",
    API_MATCH = "verify.php",

    FALLBACK_WAIT = 6,

    -- API ของ zerzy.xyz ส่งเวลาที่ไม่มี timezone เป็นเวลาไทย
    SERVER_UTC_OFFSET_HOURS = 7,

    KICK_ON_EXPIRE = false,

    DEBUG = true,

    COLOR = "#FF8A3D",
    EXPIRED_COLOR = "#FF5252",
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local env = getgenv()

if not LocalPlayer then
    warn("[KeyTimer] LocalPlayer not found.")
    return
end

-- =========================================================
-- Prevent duplicate execution
-- =========================================================

env.KeyTimerRun = (tonumber(env.KeyTimerRun) or 0) + 1
local RUN = env.KeyTimerRun

-- =========================================================
-- Safe helpers
-- =========================================================

local function Debug(...)
    if CONFIG.DEBUG then
        print("[KeyTimer]", ...)
    end
end

local function SafeJSONDecode(value)
    if type(value) ~= "string" or value == "" then
        return nil
    end

    local ok, result = pcall(function()
        return HttpService:JSONDecode(value)
    end)

    if ok and type(result) == "table" then
        return result
    end

    return nil
end

local function GetResponseBody(response)
    if type(response) ~= "table" then
        return ""
    end

    return tostring(
        response.Body
        or response.body
        or ""
    )
end

local function GetResponseHeaders(response)
    if type(response) ~= "table" then
        return nil
    end

    return response.Headers or response.headers
end

-- =========================================================
-- Date helpers
-- =========================================================

local MONTHS = {
    Jan = 1,
    Feb = 2,
    Mar = 3,
    Apr = 4,
    May = 5,
    Jun = 6,
    Jul = 7,
    Aug = 8,
    Sep = 9,
    Oct = 10,
    Nov = 11,
    Dec = 12,
}

local function ToUnix(y, m, d, H, M, S)
    y = (m <= 2) and (y - 1) or y

    local era = math.floor(y / 400)
    local yoe = y - era * 400
    local doy = math.floor((153 * ((m + 9) % 12) + 2) / 5) + d - 1
    local doe =
        yoe * 365
        + math.floor(yoe / 4)
        - math.floor(yoe / 100)
        + doy

    return (era * 146097 + doe - 719468) * 86400
        + H * 3600
        + M * 60
        + S
end

local function ServerNowFromHeaders(headers)
    if type(headers) ~= "table" then
        return nil
    end

    for key, value in pairs(headers) do
        if string.lower(tostring(key)) == "date" then
            local d, mon, y, H, M, S = string.match(
                tostring(value),
                "(%d+) (%a+) (%d+) (%d+):(%d+):(%d+)"
            )

            if d and MONTHS[mon] then
                return ToUnix(
                    tonumber(y),
                    MONTHS[mon],
                    tonumber(d),
                    tonumber(H),
                    tonumber(M),
                    tonumber(S)
                )
            end
        end
    end

    return nil
end

local function ParseDate(str)
    if type(str) ~= "string" then
        return nil
    end

    local y, mo, d, rest = string.match(
        str,
        "^(%d%d%d%d)-(%d%d)-(%d%d)(.*)$"
    )

    if not y then
        return nil
    end

    local H, M, S = 23, 59, 59
    local tz = 0

    local hh, mm, ss, tail = string.match(
        rest,
        "^[T ](%d%d):(%d%d):?(%d*)(.*)$"
    )

    if hh then
        H = tonumber(hh) or 0
        M = tonumber(mm) or 0
        S = tonumber(ss) or 0

        local sign, th, tm = string.match(
            tail,
            "([%+%-])(%d%d):?(%d%d)$"
        )

        if sign then
            tz =
                (tonumber(th) * 3600 + tonumber(tm) * 60)
                * (sign == "-" and -1 or 1)
        elseif string.find(tail, "Z$", 1, true) then
            tz = 0
        else
            tz = CONFIG.SERVER_UTC_OFFSET_HOURS * 3600
        end
    else
        tz = CONFIG.SERVER_UTC_OFFSET_HOURS * 3600
    end

    return ToUnix(
        tonumber(y),
        tonumber(mo),
        tonumber(d),
        H,
        M,
        S
    ) - tz
end

-- =========================================================
-- Expiry parsing
-- =========================================================

local EXPIRY_FIELDS = {
    "expires_in",
    "expire_in",
    "expires_after",

    "expires_at",
    "expire_at",
    "expires",
    "expiry",
    "expire",
    "expiration",
    "expired_at",
    "expire_time",

    "valid_until",
    "end_time",
    "ends_at",

    "timeleft",
    "time_left",
    "remaining",
    "seconds_left",
    "ttl",
    "duration",
}

local RELATIVE_HINTS = {
    "left",
    "remain",
    "ttl",
    "duration",
    "_in",
    "_after",
}

local function IsRelativeName(name)
    name = string.lower(tostring(name))

    for _, hint in ipairs(RELATIVE_HINTS) do
        if string.find(name, hint, 1, true) then
            return true
        end
    end

    return false
end

local function ToRemaining(name, value, serverNow)
    if value == nil then
        return nil
    end

    if type(value) == "string" then
        local low = string.lower(value)

        if
            low == "never"
            or low == "lifetime"
            or low == "permanent"
            or low == "unlimited"
        then
            return "lifetime"
        end

        local numberValue = tonumber(value)

        if numberValue then
            value = numberValue
        else
            local unix = ParseDate(value)

            if unix then
                return unix - serverNow
            end

            return nil
        end
    end

    if type(value) == "number" then
        if value <= 0 then
            return "lifetime"
        end

        -- milliseconds
        if value > 1e12 then
            value = value / 1000
        end

        -- relative seconds
        if IsRelativeName(name) or value < 1e9 then
            return value
        end

        -- unix timestamp
        return value - serverNow
    end

    return nil
end

local function FindRemaining(tbl, serverNow)
    if type(tbl) ~= "table" then
        return nil
    end

    for _, name in ipairs(EXPIRY_FIELDS) do
        local result = ToRemaining(
            name,
            tbl[name],
            serverNow
        )

        if result ~= nil then
            return result
        end
    end

    return nil
end

-- =========================================================
-- State
-- =========================================================

local EndAt = nil
local Resolved = false
local Failed = false

-- =========================================================
-- API response
-- =========================================================

local function Accept(data, headers)
    if Resolved then
        return
    end

    if type(data) ~= "table" then
        return
    end

    if data.success ~= true then
        Failed = true
        Resolved = true

        Debug(
            "API did not accept the key. Response:",
            HttpService:JSONEncode(data)
        )

        return
    end

    local headerNow = ServerNowFromHeaders(headers)
    local serverNow = headerNow or os.time()

    local remaining = FindRemaining(data, serverNow)

    if remaining == nil and type(data.data) == "table" then
        remaining = FindRemaining(data.data, serverNow)
    end

    if remaining == nil and type(data.key) == "table" then
        remaining = FindRemaining(data.key, serverNow)
    end

    Resolved = true

    Debug(
        "API response:",
        HttpService:JSONEncode(data)
    )

    Debug(
        "Clock:",
        headerNow and "server Date header" or "local PC clock",
        serverNow
    )

    Debug(
        "Seconds left:",
        tostring(remaining)
    )

    if remaining == "lifetime" then
        EndAt = "lifetime"
    elseif type(remaining) == "number" then
        EndAt = os.time() + math.floor(remaining)

        if EndAt < os.time() then
            EndAt = os.time()
        end
    else
        Debug(
            "No expiry field found in API response."
        )
    end
end

-- =========================================================
-- Request listener
-- =========================================================

local function OnResponse(options, response)
    if type(options) ~= "table" then
        return
    end

    if type(response) ~= "table" then
        return
    end

    local url = tostring(
        options.Url
        or options.url
        or ""
    )

    if url == "" then
        return
    end

    if not string.find(
        string.lower(url),
        string.lower(CONFIG.API_MATCH),
        1,
        true
    ) then
        return
    end

    local data = SafeJSONDecode(
        GetResponseBody(response)
    )

    if data then
        Accept(
            data,
            GetResponseHeaders(response)
        )
    else
        Debug("Could not decode API response.")
    end
end

-- =========================================================
-- Safe request wrapper
-- =========================================================

local Wrapped = {}

local function Wrap(container, name)
    if type(container) ~= "table" then
        return false
    end

    if Wrapped[container] and Wrapped[container][name] then
        return true
    end

    local original = rawget(container, name)

    if typeof(original) ~= "function" then
        return false
    end

    Wrapped[container] = Wrapped[container] or {}
    Wrapped[container][name] = true

    local wrapper = function(...)
        local args = table.pack(...)

        local ok, response = pcall(
            original,
            table.unpack(args, 1, args.n)
        )

        if not ok then
            error(response, 0)
        end

        pcall(
            OnResponse,
            args[1],
            response
        )

        return response
    end

    local success = pcall(function()
        container[name] = wrapper
    end)

    if not success then
        Wrapped[container][name] = nil
        return false
    end

    return true
end

-- Wrap only existing request functions.
-- This prevents this timer from creating/replacing a missing request API.
pcall(function()
    Wrap(env, "request")
    Wrap(env, "http_request")

    if type(env.syn) == "table" then
        Wrap(env.syn, "request")
    end
end)

-- =========================================================
-- Fallback request
-- =========================================================

task.spawn(function()
    task.wait(CONFIG.FALLBACK_WAIT)

    if env.KeyTimerRun ~= RUN then
        return
    end

    if Resolved then
        return
    end

    local Key = env.Key

    local Request =
        rawget(env, "request")
        or rawget(env, "http_request")
        or (
            type(env.syn) == "table"
            and rawget(env.syn, "request")
        )

    if not Key or tostring(Key) == "" then
        Debug("Fallback skipped: getgenv().Key is missing.")
        Resolved = true
        return
    end

    if typeof(Request) ~= "function" then
        Debug("Fallback skipped: request function is missing.")
        Resolved = true
        return
    end

    local HWID = nil

    local hwidFunctions = {
        rawget(_G, "gethwid"),
        rawget(_G, "get_hwid"),
    }

    if type(env.syn) == "table" then
        table.insert(
            hwidFunctions,
            rawget(env.syn, "get_hwid")
        )
    end

    for _, fn in ipairs(hwidFunctions) do
        if typeof(fn) == "function" then
            local ok, result = pcall(fn)

            if ok and result then
                HWID = tostring(result)
                break
            end
        end
    end

    if not HWID or HWID == "" then
        Debug("Fallback skipped: HWID function is missing.")
        Resolved = true
        return
    end

    local ok, response = pcall(function()
        return Request({
            Url = CONFIG.API_URL,
            Method = "POST",

            Headers = {
                ["Content-Type"] = "application/json",
            },

            Body = HttpService:JSONEncode({
                key = tostring(Key),
                hwid = HWID,
            }),
        })
    end)

    if not ok then
        Debug("Fallback request failed:", response)
        Resolved = true
        return
    end

    local data = SafeJSONDecode(
        GetResponseBody(response)
    )

    if data then
        Accept(
            data,
            GetResponseHeaders(response)
        )
    else
        Debug("Fallback response was not valid JSON.")
    end
end)

-- =========================================================
-- UI display
-- =========================================================

local function Format(left)
    left = math.max(0, math.floor(left))

    if left <= 0 then
        return '<font color="' ..
            CONFIG.EXPIRED_COLOR ..
            '">Key expired</font>'
    end

    local days = math.floor(left / 86400)
    local hours = math.floor(
        (left % 86400) / 3600
    )
    local minutes = math.floor(
        (left % 3600) / 60
    )
    local seconds = left % 60

    return string.format(
        '<font color="%s">%dd %02dh %02dm %02ds</font>',
        CONFIG.COLOR,
        days,
        hours,
        minutes,
        seconds
    )
end

local lastShown = setmetatable({}, {
    __mode = "k",
})

local function GetLibrary()
    local lib = rawget(env, "MacUI_Library")

    if type(lib) ~= "table" then
        return nil
    end

    return lib
end

local function UpdateWindows(text)
    local lib = GetLibrary()

    if not lib then
        return
    end

    if type(lib._windows) ~= "table" then
        return
    end

    for _, window in ipairs(lib._windows) do
        if type(window) == "table" then
            local setter = window.SetUserNote

            if typeof(setter) == "function" then
                if lastShown[window] ~= text then
                    lastShown[window] = text

                    pcall(
                        setter,
                        window,
                        text
                    )
                end
            end
        end
    end
end

task.spawn(function()
    while env.KeyTimerRun == RUN do
        local text

        if EndAt == "lifetime" then
            text =
                '<font color="' ..
                CONFIG.COLOR ..
                '">Lifetime</font>'

        elseif type(EndAt) == "number" then
            local left = EndAt - os.time()

            text = Format(left)

            if left <= 0 and CONFIG.KICK_ON_EXPIRE then
                pcall(function()
                    LocalPlayer:Kick(
                        "Your key has expired"
                    )
                end)

                break
            end

        elseif Failed then
            text =
                '<font color="' ..
                CONFIG.EXPIRED_COLOR ..
                '">Key invalid</font>'

        elseif Resolved then
            text = "Key active"

        else
            text = "Checking key..."
        end

        UpdateWindows(text)

        task.wait(1)
    end
end)

Debug("KeyTimer loaded successfully.")
