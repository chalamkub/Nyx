-- KeyTimer: shows the key's remaining time (days, hours, minutes, seconds) in the main script's MacUI window.
-- It does NOT touch the main script. Run this file BEFORE the main script (it needs MacUI.lua with the new
-- "MacUI_Library" registration, uploaded to the place the main script loads it from).
--
--   loadstring(game:HttpGet("https://.../KeyTimer.lua"))()   -- 1) this timer
--   loadstring(game:HttpGet("https://.../main.lua"))()       -- 2) your main script (with the key check)
--
-- How it gets the data without a second API request: it listens to the response of the key check that your main
-- script already makes (request to API_MATCH) and takes the expiry from it. If no such response is seen within
-- FALLBACK_WAIT seconds (for example this file was started after the main script) it asks the API itself with
-- getgenv().Key and your HWID.

local CONFIG = {
    API_URL = "https://zerzy.xyz/api/verify.php", -- only used by the fallback request
    API_MATCH = "verify.php",                     -- a request whose URL contains this is the key check
    FALLBACK_WAIT = 6,                            -- seconds to wait for the main script's key check
    SERVER_UTC_OFFSET_HOURS = 7,                  -- timezone of dates like "2026-10-04 10:03:29" that carry no timezone (7 = Thailand time, what zerzy.xyz sends)
    KICK_ON_EXPIRE = false,                       -- kick the player when the key runs out while playing
    DEBUG = true,                                 -- print what the API sent and how the time was worked out (set false when done)
    COLOR = "#FF8A3D", EXPIRED_COLOR = "#FF5252",
}

local HttpService = game:GetService("HttpService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local env = getgenv()

-- run only once
env.KeyTimerRun = (env.KeyTimerRun or 0) + 1
local RUN = env.KeyTimerRun

-- ---------------------------------------------------------------- date helpers (no DateTime needed)
local MONTHS = { Jan = 1, Feb = 2, Mar = 3, Apr = 4, May = 5, Jun = 6, Jul = 7, Aug = 8, Sep = 9, Oct = 10, Nov = 11, Dec = 12 }

local function ToUnix(y, m, d, H, M, S)
    y = (m <= 2) and (y - 1) or y
    local era = math.floor(y / 400)
    local yoe = y - era * 400
    local doy = math.floor((153 * ((m + 9) % 12) + 2) / 5) + d - 1
    local doe = yoe * 365 + math.floor(yoe / 4) - math.floor(yoe / 100) + doy
    return (era * 146097 + doe - 719468) * 86400 + H * 3600 + M * 60 + S
end

-- server clock from the HTTP "Date" header, so a wrong clock on the player's PC does not matter
local function ServerNowFromHeaders(headers)
    if type(headers) ~= "table" then return nil end
    for k, v in pairs(headers) do
        if string.lower(tostring(k)) == "date" then
            local d, mon, y, H, M, S = string.match(tostring(v), "(%d+) (%a+) (%d+) (%d+):(%d+):(%d+)")
            if d and MONTHS[mon] then
                return ToUnix(tonumber(y), MONTHS[mon], tonumber(d), tonumber(H), tonumber(M), tonumber(S))
            end
        end
    end
end

local function ParseDate(str)
    local y, mo, d, rest = string.match(str, "^(%d%d%d%d)-(%d%d)-(%d%d)(.*)$")
    if not y then return nil end
    local H, M, S = 23, 59, 59 -- a date without a time means the end of that day
    local tz = 0
    local hh, mm, ss, tail = string.match(rest, "^[T ](%d%d):(%d%d):?(%d*)(.*)$")
    if hh then
        H, M, S = tonumber(hh), tonumber(mm), tonumber(ss) or 0
        local sign, th, tm = string.match(tail, "([%+%-])(%d%d):?(%d%d)$")
        if sign then
            tz = (tonumber(th) * 3600 + tonumber(tm) * 60) * (sign == "-" and -1 or 1)
        elseif string.find(tail, "Z$") then
            tz = 0
        else
            tz = CONFIG.SERVER_UTC_OFFSET_HOURS * 3600
        end
    else
        tz = CONFIG.SERVER_UTC_OFFSET_HOURS * 3600
    end
    return ToUnix(tonumber(y), tonumber(mo), tonumber(d), H, M, S) - tz
end

-- ---------------------------------------------------------------- find the expiry in the API response
local EXPIRY_FIELDS = {
    "expires_in", "expire_in", "expires_after", -- seconds left: independent of any timezone, so it goes first
    "expires_at", "expire_at", "expires", "expiry", "expire", "expiration", "expired_at", "expire_time",
    "valid_until", "end_time", "ends_at", "timeleft", "time_left", "remaining", "seconds_left", "ttl", "duration",
}
local RELATIVE_HINTS = { "left", "remain", "ttl", "duration", "_in", "_after" }

local function IsRelativeName(name)
    for _, h in ipairs(RELATIVE_HINTS) do
        if string.find(name, h, 1, true) then return true end
    end
    return false
end

-- returns seconds remaining, or "lifetime", or nil
local function ToRemaining(name, value, serverNow)
    if type(value) == "string" then
        local low = string.lower(value)
        if low == "never" or low == "lifetime" or low == "permanent" or low == "unlimited" then return "lifetime" end
        local num = tonumber(value)
        if num then
            value = num
        else
            local unix = ParseDate(value)
            return unix and (unix - serverNow) or nil
        end
    end
    if type(value) == "number" then
        if value <= 0 then return "lifetime" end
        if value > 1e12 then value = value / 1000 end -- milliseconds
        if IsRelativeName(name) or value < 1e9 then return value end -- seconds from now
        return value - serverNow -- unix time
    end
    return nil
end

local function FindRemaining(tbl, serverNow)
    for _, name in ipairs(EXPIRY_FIELDS) do
        local r = ToRemaining(name, tbl[name], serverNow)
        if r then return r end
    end
end

-- ---------------------------------------------------------------- state
local EndAt -- local os.time() when the key ends, or "lifetime"
local Resolved = false
local Failed = false -- the API said the key is not valid

local function Accept(data, headers)
    if Resolved or type(data) ~= "table" then return end
    if data.success ~= true then
        Failed, Resolved = true, true
        if CONFIG.DEBUG then
            print("[KeyTimer] API did not accept the key. API response: " .. HttpService:JSONEncode(data))
        end
        return
    end
    local headerNow = ServerNowFromHeaders(headers)
    local serverNow = headerNow or os.time()
    local remaining = FindRemaining(data, serverNow)
    if not remaining and type(data.data) == "table" then remaining = FindRemaining(data.data, serverNow) end
    if not remaining and type(data.key) == "table" then remaining = FindRemaining(data.key, serverNow) end
    Resolved = true
    if CONFIG.DEBUG then
        print("[KeyTimer] API response: " .. HttpService:JSONEncode(data))
        print("[KeyTimer] clock used: " .. (headerNow and "server Date header" or "this PC's clock (no Date header)")
            .. " = " .. tostring(serverNow) .. " | PC clock = " .. os.time())
        print("[KeyTimer] seconds left: " .. tostring(remaining))
    end
    if remaining == "lifetime" then
        EndAt = "lifetime"
    elseif remaining then
        EndAt = os.time() + math.floor(remaining) -- counted from now with the local clock (only the difference matters)
    else
        print("[KeyTimer] No expiry field found. API response: " .. HttpService:JSONEncode(data))
    end
end

-- ---------------------------------------------------------------- listen to the main script's key check
local function OnResponse(opts, resp)
    if type(opts) ~= "table" or type(resp) ~= "table" then return end
    local url = tostring(opts.Url or opts.url or "")
    if not string.find(url, CONFIG.API_MATCH, 1, true) then return end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(resp.Body or resp.body or "")
    end)
    if ok then Accept(data, resp.Headers or resp.headers) end
end

local function Wrap(container, name)
    local orig = container[name]
    if typeof(orig) ~= "function" then return end
    container[name] = function(...)
        local resp = orig(...)
        pcall(OnResponse, (...), resp) -- never changes the response the main script receives
        return resp
    end
end
Wrap(env, "request")
Wrap(env, "http_request")
if type(env.syn) == "table" then Wrap(env.syn, "request") end

-- ---------------------------------------------------------------- fallback: ask the API ourselves
task.spawn(function()
    task.wait(CONFIG.FALLBACK_WAIT)
    if Resolved or env.KeyTimerRun ~= RUN then return end
    local Key = env.Key
    local Request = (rawget(env, "request") or rawget(env, "http_request") or (type(env.syn) == "table" and env.syn.request))
    local HWID
    for _, fn in ipairs({ gethwid, get_hwid, type(env.syn) == "table" and env.syn.get_hwid or nil }) do
        if typeof(fn) == "function" then
            local ok, r = pcall(fn)
            if ok and r then
                HWID = tostring(r)
                break
            end
        end
    end
    if not (Key and tostring(Key) ~= "" and HWID and typeof(Request) == "function") then
        Resolved = true
        return
    end
    pcall(function()
        local resp = Request({
            Url = CONFIG.API_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({ key = tostring(Key), hwid = HWID }),
        })
        Accept(HttpService:JSONDecode(resp.Body or resp.body or ""), resp.Headers or resp.headers)
    end)
    Resolved = true
end)

-- ---------------------------------------------------------------- show it in every MacUI window
local function Format(left)
    if left <= 0 then
        return '<font color="' .. CONFIG.EXPIRED_COLOR .. '">Key expired</font>'
    end
    return string.format('<font color="%s">%dd %02dh %02dm %02ds</font>', CONFIG.COLOR,
        math.floor(left / 86400), math.floor(left % 86400 / 3600), math.floor(left % 3600 / 60), left % 60)
end

local lastShown = setmetatable({}, { __mode = "k" })
task.spawn(function()
    while env.KeyTimerRun == RUN do
        local text
        if EndAt == "lifetime" then
            text = '<font color="' .. CONFIG.COLOR .. '">Lifetime</font>'
        elseif EndAt then
            local left = EndAt - os.time()
            text = Format(left)
            if left <= 0 and CONFIG.KICK_ON_EXPIRE then
                LocalPlayer:Kick("Your key has expired")
                break
            end
        elseif Failed then
            text = '<font color="' .. CONFIG.EXPIRED_COLOR .. '">Key invalid</font>'
        elseif Resolved then
            text = "Key active"
        else
            text = "Checking key..."
        end

        local lib = env.MacUI_Library
        if type(lib) == "table" and type(lib._windows) == "table" then
            for _, w in ipairs(lib._windows) do
                if lastShown[w] ~= text then
                    lastShown[w] = text
                    pcall(w.SetUserNote, w, text)
                end
            end
        end
        task.wait(1)
    end
end)
