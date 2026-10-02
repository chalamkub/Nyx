-- NYX API TEST
-- API: https://zerzy.com/api/verify.php

print("================================")
print("[NYX] TESTER START")
print("================================")

-- ============================================
-- 1. CHECK ENVIRONMENT
-- ============================================

print("[NYX] Checking environment...")

print("getgenv:", type(getgenv))
print("loadstring:", type(loadstring))
print("HttpGet:", type(game.HttpGet))
print("request:", type(request))
print("http_request:", type(http_request))

-- ============================================
-- 2. GET KEY
-- ============================================

local Env = getgenv()

local Key = Env.Key

print("[NYX] Key:", tostring(Key))

if not Key then
    warn("[NYX] ERROR: Key is nil")
    return
end

-- ============================================
-- 3. GET HTTP REQUEST FUNCTION
-- ============================================

local Request = nil

if type(request) == "function" then
    Request = request
    print("[NYX] Request function: request")
elseif type(http_request) == "function" then
    Request = http_request
    print("[NYX] Request function: http_request")
elseif syn and type(syn.request) == "function" then
    Request = syn.request
    print("[NYX] Request function: syn.request")
end

if not Request then
    warn("[NYX] ERROR: No request function found")
    return
end

-- ============================================
-- 4. GET HWID
-- ============================================

local HWID = nil

if type(gethwid) == "function" then

    local Success, Result = pcall(function()
        return gethwid()
    end)

    if Success then
        HWID = tostring(Result)
        print("[NYX] HWID source: gethwid")
    else
        warn("[NYX] gethwid error:", Result)
    end

elseif type(get_hwid) == "function" then

    local Success, Result = pcall(function()
        return get_hwid()
    end)

    if Success then
        HWID = tostring(Result)
        print("[NYX] HWID source: get_hwid")
    else
        warn("[NYX] get_hwid error:", Result)
    end

elseif syn and type(syn.get_hwid) == "function" then

    local Success, Result = pcall(function()
        return syn.get_hwid()
    end)

    if Success then
        HWID = tostring(Result)
        print("[NYX] HWID source: syn.get_hwid")
    else
        warn("[NYX] syn.get_hwid error:", Result)
    end

end

if not HWID or HWID == "" or HWID == "nil" then
    warn("[NYX] ERROR: Cannot get HWID")
    return
end

print("[NYX] HWID:", HWID)

-- ============================================
-- 5. JSON
-- ============================================

local HttpService = game:GetService("HttpService")

local EncodeSuccess, Body = pcall(function()

    return HttpService:JSONEncode({
        key = tostring(Key),
        hwid = HWID
    })

end)

if not EncodeSuccess then
    warn("[NYX] JSON Encode Error:")
    warn(Body)
    return
end

print("[NYX] JSON:")
print(Body)

-- ============================================
-- 6. API REQUEST
-- ============================================

local API_URL = "https://zerzy.com/api/verify.php"

print("[NYX] API:")
print(API_URL)

print("[NYX] Sending POST...")

local RequestSuccess, Response = pcall(function()

    return Request({
        Url = API_URL,
        Method = "POST",

        Headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json"
        },

        Body = Body
    })

end)

if not RequestSuccess then

    warn("================================")
    warn("[NYX] REQUEST ERROR")
    warn("================================")

    warn(tostring(Response))

    return
end

if not Response then
    warn("[NYX] ERROR: Response is nil")
    return
end

-- ============================================
-- 7. SHOW RAW RESPONSE
-- ============================================

print("================================")
print("[NYX] API RESPONSE")
print("================================")

print("StatusCode:")
print(tostring(Response.StatusCode))

print("Status:")
print(tostring(Response.Status))

print("Body:")
print(tostring(Response.Body))

print("================================")

-- ============================================
-- 8. DECODE RESPONSE
-- ============================================

local ResponseBody = tostring(Response.Body or "")

if ResponseBody == "" then
    warn("[NYX] ERROR: Empty response body")
    return
end

local DecodeSuccess, Data = pcall(function()

    return HttpService:JSONDecode(ResponseBody)

end)

if not DecodeSuccess then

    warn("================================")
    warn("[NYX] JSON DECODE ERROR")
    warn("================================")

    warn("Raw response:")
    warn(ResponseBody)

    return
end

-- ============================================
-- 9. SHOW API RESULT
-- ============================================

print("================================")
print("[NYX] API JSON")
print("================================")

print("success:")
print(tostring(Data.success))

print("message:")
print(tostring(Data.message))

print("expires_at:")
print(tostring(Data.expires_at))

print("================================")

-- ============================================
-- 10. RESULT
-- ============================================

if Data.success == true then

    print("================================")
    print("[NYX] WHITELIST SUCCESS")
    print("================================")

else

    warn("================================")
    warn("[NYX] WHITELIST FAILED")
    warn("Reason:", tostring(Data.message))
    warn("================================")

end
