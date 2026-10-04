local CONFIG = {
    API_URL = "https://zerzy.xyz/api/verify.php",
    API_MATCH = "verify.php",
    FALLBACK_WAIT = 6,
    SERVER_UTC_OFFSET_HOURS = 0,
    KICK_ON_EXPIRE = true,
    COLOR = "#FF8A3D",
    EXPIRED_COLOR = "#FF5252",
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G

-- run only once
env.KeyTimerRun = (env.KeyTimerRun or 0) + 1
local RUN = env.KeyTimerRun

local MONTHS = {
    Jan=1, Feb=2, Mar=3, Apr=4, May=5, Jun=6,
    Jul=7, Aug=8, Sep=9, Oct=10, Nov=11, Dec=12
}

local function ToUnix(y, m, d, H, M, S)
    y = (m <= 2) and (y - 1) or y
    local era = math.floor(y / 400)
    local yoe = y - era * 400
    local doy = math.floor((153 * ((m + 9) % 12) + 2) / 5) + d - 1
    local doe = yoe * 365 + math.floor(yoe / 4) - math.floor(yoe / 100) + doy
    return (era * 146097 + doe - 719468) * 86400 + H * 3600 + M * 60 + S
end

local function ServerNowFromHeaders(headers)
    if type(headers) ~= "table" then return nil end
    for k, v in pairs(headers) do
        if string.lower(tostring(k)) == "date" then
            local d, mon, y, H, M, S =
                string.match(tostring(v), "(%d+) (%a+) (%d+) (%d+):(%d+):(%d+)")
            if d and MONTHS[mon] then
                return ToUnix(
                    tonumber(y), MONTHS[mon], tonumber(d),
                    tonumber(H), tonumber(M), tonumber(S)
                )
            end
        end
    end
end

local function ParseDate(str)
    if type(str) ~= "string" then return nil end

    local y, mo, d, rest =
        string.match(str, "^(%d%d%d%d)-(%d%d)-(%d%d)(.*)$")
    if not y then return nil end

    local H, M, S = 23, 59, 59
    local tz = 0

    local hh, mm, ss, tail =
        string.match(rest, "^[T ](%d%d):(%d%d):?(%d*)(.*)$")

    if hh then
        H, M, S = tonumber(hh), tonumber(mm), tonumber(ss) or 0

        local sign, th, tm =
            string.match(tail, "([%+%-])(%d%d):?(%d%d)$")

        if sign then
            tz = (tonumber(th) * 3600 + tonumber(tm) * 60)
                * (sign == "-" and -1 or 1)
        elseif string.find(tail, "Z$") then
            tz = 0
        else
            tz = CONFIG.SERVER_UTC_OFFSET_HOURS * 3600
        end
    else
        tz = CONFIG.SERVER_UTC_OFFSET_HOURS * 3600
    end

    return ToUnix(
        tonumber(y), tonumber(mo), tonumber(d),
        H, M, S
    ) - tz
end

local EXPIRY_FIELDS = {
    "expires_at", "expire_at", "expires", "expiry", "expire",
    "expiration", "expired_at", "expire_time",
    "valid_until", "end_time", "ends_at",
    "timeleft", "time_left", "remaining",
    "seconds_left", "ttl", "duration",
}

local RELATIVE_HINTS = {
    "left", "remain", "ttl", "duration"
}

local function IsRelativeName(name)
    name = string.lower(tostring(name))
    for _, h in ipairs(RELATIVE_HINTS) do
        if string.find(name, h, 1, true) then
            return true
        end
    end
    return false
end

local function ToRemaining(name, value, serverNow)
    if type(value) == "string" then
        local low = string.lower(value)

        if low == "never"
        or low == "lifetime"
        or low == "permanent"
        or low == "unlimited" then
            return "lifetime"
        end

        local num = tonumber(value)
        if num then
            value = num
        else
            local unix = ParseDate(value)
            return unix and (unix - serverNow) or nil
        end
    end

    if type(value) == "number" then
        if value <= 0 then
            return "lifetime"
        end

        if value > 1e12 then
            value = value / 1000
        end

        if IsRelativeName(name) or value < 1e9 then
            return value
        end

        return value - serverNow
    end

    return nil
end

local function FindRemaining(tbl, serverNow)
    if type(tbl) ~= "table" then return nil end

    for _, name in ipairs(EXPIRY_FIELDS) do
        local r = ToRemaining(name, tbl[name], serverNow)
        if r then
            return r
        end
    end

    return nil
end

local EndAt
local Resolved = false
local Failed = false

local function Accept(data, headers)
    if Resolved or type(data) ~= "table" then
        return
    end

    if data.success ~= true then
        Failed = true
        Resolved = true
        return
    end

    local serverNow = ServerNowFromHeaders(headers) or os.time()

    local remaining = FindRemaining(data, serverNow)

    if not remaining and type(data.data) == "table" then
        remaining = FindRemaining(data.data, serverNow)
    end

    if not remaining and type(data.key) == "table" then
        remaining = FindRemaining(data.key, serverNow)
    end

    Resolved = true

    if remaining == "lifetime" then
        EndAt = "lifetime"
    elseif remaining then
        EndAt = os.time() + math.floor(remaining)
    else
        warn(
            "[KeyTimer] No expiry field found. API response: "
            .. HttpService:JSONEncode(data)
        )
    end
end

local function OnResponse(opts, resp)
    if type(opts) ~= "table" or type(resp) ~= "table" then
        return
    end

    local url = tostring(opts.Url or opts.url or "")

    if not string.find(url, CONFIG.API_MATCH, 1, true) then
        return
    end

    local body = resp.Body or resp.body or ""

    local ok, data = pcall(function()
        return HttpService:JSONDecode(body)
    end)

    if ok then
        Accept(data, resp.Headers or resp.headers)
    end
end

local function Wrap(container, name)
    if type(container) ~= "table" then return end

    local orig = rawget(container, name)

    if typeof(orig) ~= "function" then
        return
    end

    container[name] = function(...)
        local args = table.pack(...)
        local resp = orig(table.unpack(args, 1, args.n))

        pcall(function()
            OnResponse(args[1], resp)
        end)

        return resp
    end
end

Wrap(env, "request")
Wrap(env, "http_request")

if type(env.syn) == "table" then
    Wrap(env.syn, "request")
end

-- fallback: ask the verification API ourselves
task.spawn(function()
    task.wait(CONFIG.FALLBACK_WAIT)

    if Resolved or env.KeyTimerRun ~= RUN then
        return
    end

    local Key = env.Key

    local Request =
        rawget(env, "request")
        or rawget(env, "http_request")
        or (type(env.syn) == "table" and rawget(env.syn, "request"))

    local HWID

    local hwidFunctions = {
        gethwid,
        get_hwid,
        type(env.syn) == "table" and env.syn.get_hwid or nil
    }

    for _, fn in ipairs(hwidFunctions) do
        if typeof(fn) == "function" then
            local ok, result = pcall(fn)

            if ok and result then
                HWID = tostring(result)
                break
            end
        end
    end

    if not (
        Key
        and tostring(Key) ~= ""
        and HWID
        and typeof(Request) == "function"
    ) then
        Resolved = true
        return
    end

    pcall(function()
        local resp = Request({
            Url = CONFIG.API_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({
                key = tostring(Key),
                hwid = HWID
            })
        })

        local body = resp.Body or resp.body or ""
        local data = HttpService:JSONDecode(body)

        Accept(data, resp.Headers or resp.headers)
    end)

    Resolved = true
end)

local function Format(left)
    if left <= 0 then
        return '<font color="' .. CONFIG.EXPIRED_COLOR .. '">Key expired</font>'
    end

    return string.format(
        '<font color="%s">%dd %02dh %02dm %02ds</font>',
        CONFIG.COLOR,
        math.floor(left / 86400),
        math.floor(left % 86400 / 3600),
        math.floor(left % 3600 / 60),
        left % 60
    )
end

local lastShown = setmetatable({}, { __mode = "k" })

task.spawn(function()
    while env.KeyTimerRun == RUN do
        local text

        if EndAt == "lifetime" then
            text =
                '<font color="' .. CONFIG.COLOR .. '">Lifetime</font>'

        elseif EndAt then
            local left = EndAt - os.time()

            text = Format(left)

            if left <= 0 and CONFIG.KICK_ON_EXPIRE then
                pcall(function()
                    LocalPlayer:Kick("Your key has expired")
                end)

                break
            end

        elseif Failed then
            text =
                '<font color="' .. CONFIG.EXPIRED_COLOR .. '">Key invalid</font>'

        elseif Resolved then
            text = "Key active"

        else
            text = "Checking key..."
        end

        -- MacUI_Library.lua must expose:
        -- getgenv().MacUI_Library._windows
        local lib = env.MacUI_Library

        if type(lib) == "table" and type(lib._windows) == "table" then
            for _, w in pairs(lib._windows) do
                if type(w) == "table"
                and type(w.SetUserNote) == "function"
                and lastShown[w] ~= text then

                    lastShown[w] = text

                    pcall(function()
                        w:SetUserNote(text)
                    end)
                end
            end
        end

        task.wait(1)
    end
end)
