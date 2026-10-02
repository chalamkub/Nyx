--[[
    NYX Whitelist Tester
    Key + HWID Verification

    API:
    https://zerzy.xyz/api/verify.php

    Loader:
    getgenv().Key = "YOUR-KEY"

    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/chalamkub/Nyx/refs/heads/main/tester.lua"
    ))()
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- =========================================================
-- CONFIG
-- =========================================================

local API_URL = "https://zerzy.xyz/api/verify.php"

local UI_LIBRARY_URL =
    "https://raw.githubusercontent.com/chalamkub/Nyx/refs/heads/main/MacUI_Library_v2.lua"

-- =========================================================
-- DEBUG
-- =========================================================

local function Debug(...)
    print("[NYX]", ...)
end

local function Fail(Message)
    warn("[NYX] " .. tostring(Message))

    if LocalPlayer then
        pcall(function()
            LocalPlayer:Kick("Whitelist: " .. tostring(Message))
        end)
    end
end

-- =========================================================
-- GET KEY
-- =========================================================

local Key

local KeySuccess, KeyResult = pcall(function()
    return getgenv().Key
end)

if KeySuccess then
    Key = KeyResult
end

if not Key or tostring(Key) == "" then
    Fail("ไม่พบ Key")
    return
end

Key = tostring(Key)

Debug("Key:", Key)

-- =========================================================
-- GET HWID
-- =========================================================

local function GetHWID()

    -- gethwid
    if type(gethwid) == "function" then

        local Success, Result = pcall(function()
            return gethwid()
        end)

        if Success and Result and tostring(Result) ~= "" then
            Debug("HWID source: gethwid")
            return tostring(Result)
        end
    end

    -- get_hwid
    if type(get_hwid) == "function" then

        local Success, Result = pcall(function()
            return get_hwid()
        end)

        if Success and Result and tostring(Result) ~= "" then
            Debug("HWID source: get_hwid")
            return tostring(Result)
        end
    end

    -- syn.get_hwid
    if syn and type(syn.get_hwid) == "function" then

        local Success, Result = pcall(function()
            return syn.get_hwid()
        end)

        if Success and Result and tostring(Result) ~= "" then
            Debug("HWID source: syn.get_hwid")
            return tostring(Result)
        end
    end

    return nil
end

local HWID = GetHWID()

if not HWID then
    Fail("ไม่สามารถอ่าน HWID ได้")
    return
end

Debug("HWID:", HWID)

-- =========================================================
-- GET REQUEST FUNCTION
-- =========================================================

local function GetRequestFunction()

    if type(request) == "function" then
        Debug("HTTP function: request")
        return request
    end

    if type(http_request) == "function" then
        Debug("HTTP function: http_request")
        return http_request
    end

    if syn and type(syn.request) == "function" then
        Debug("HTTP function: syn.request")
        return syn.request
    end

    return nil
end

local Request = GetRequestFunction()

if not Request then
    Fail("Executor ไม่มี HTTP Request function")
    return
end

-- =========================================================
-- CREATE JSON
-- =========================================================

local EncodeSuccess, RequestBody = pcall(function()

    return HttpService:JSONEncode({
        key = Key,
        hwid = HWID
    })

end)

if not EncodeSuccess then
    Fail("ไม่สามารถสร้าง JSON ได้")
    return
end

Debug("Request Body:")
print(RequestBody)

-- =========================================================
-- SEND API REQUEST
-- =========================================================

Debug("API:", API_URL)
Debug("Sending POST request...")

local RequestSuccess, RequestResult = pcall(function()

    return Request({

        Url = API_URL,

        Method = "POST",

        Headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json"
        },

        Body = RequestBody

    })

end)

-- =========================================================
-- REQUEST ERROR
-- =========================================================

if not RequestSuccess then

    warn("======================================")
    warn("[NYX] REQUEST ERROR")
    warn("======================================")
    warn(tostring(RequestResult))
    warn("======================================")

    Fail("ส่ง Request ไป API ไม่สำเร็จ")
    return
end

if not RequestResult then
    Fail("API ไม่ส่ง Response กลับมา")
    return
end

-- =========================================================
-- RESPONSE
-- =========================================================

local StatusCode = RequestResult.StatusCode
local ResponseBody = RequestResult.Body

warn("======================================")
warn("[NYX] API RESPONSE")
warn("======================================")

warn("StatusCode:")
warn(tostring(StatusCode))

warn("Status:")
warn(tostring(RequestResult.Status))

warn("Body:")
warn(tostring(ResponseBody))

warn("======================================")

-- =========================================================
-- CHECK RESPONSE
-- =========================================================

if not ResponseBody then
    Fail("API ไม่มี Response Body")
    return
end

ResponseBody = tostring(ResponseBody)

if ResponseBody == "" then
    Fail("API ส่ง Response ว่างกลับมา")
    return
end

-- =========================================================
-- DECODE JSON
-- =========================================================

local DecodeSuccess, Data = pcall(function()

    return HttpService:JSONDecode(ResponseBody)

end)

if not DecodeSuccess then

    warn("======================================")
    warn("[NYX] JSON DECODE ERROR")
    warn("======================================")

    warn("Raw Response:")
    warn(ResponseBody)

    warn("======================================")

    Fail("Server ส่งข้อมูลไม่ถูกต้อง")
    return
end

if type(Data) ~= "table" then
    Fail("รูปแบบข้อมูลจาก Server ไม่ถูกต้อง")
    return
end

-- =========================================================
-- API RESULT
-- =========================================================

local Success = Data.success
local Message = tostring(Data.message or "")
local ExpiresAt = tostring(Data.expires_at or "")

Debug("API success:", tostring(Success))
Debug("API message:", Message)
Debug("Expires:", ExpiresAt)

-- =========================================================
-- WHITELIST FAILED
-- =========================================================

if Success ~= true then

    warn("======================================")
    warn("[NYX] WHITELIST FAILED")
    warn("======================================")

    warn("Reason:", Message)

    warn("======================================")

    Fail(Message ~= "" and Message or "Whitelist verification failed")
    return
end

-- =========================================================
-- WHITELIST SUCCESS
-- =========================================================

print("======================================")
print("[NYX] WHITELIST SUCCESS")
print("======================================")

print("Key:", Key)
print("HWID:", HWID)
print("Message:", Message)
print("Expires:", ExpiresAt)

print("======================================")

-- =========================================================
-- LOAD UI LIBRARY
-- =========================================================

Debug("Loading UI Library...")

local UISuccess, MacUI = pcall(function()

    return loadstring(
        game:HttpGet(UI_LIBRARY_URL)
    )()

end)

if not UISuccess then

    warn("======================================")
    warn("[NYX] UI LIBRARY ERROR")
    warn("======================================")

    warn(tostring(MacUI))

    warn("======================================")

    Fail("โหลด UI Library ไม่สำเร็จ")
    return
end

if not MacUI then
    Fail("UI Library ไม่ส่ง Library กลับมา")
    return
end

Debug("UI Library loaded successfully")

-- =========================================================
-- CREATE WINDOW
-- =========================================================

local WindowSuccess, Window = pcall(function()

    return MacUI:MakeWindow({

        Name = "My Premium Script",

        HidePremium = false,

        SaveConfig = true,

        ConfigFolder = "MyScriptConfig"

    })

end)

if not WindowSuccess then

    warn("[NYX] MakeWindow Error:")
    warn(tostring(Window))

    Fail("สร้าง UI ไม่สำเร็จ")
    return
end

-- =========================================================
-- CREATE TAB
-- =========================================================

local TabSuccess, MainTab = pcall(function()

    return Window:MakeTab({

        Name = "Main",

        Icon = "rbxassetid://4483345998",

        PremiumOnly = false

    })

end)

if not TabSuccess then

    warn("[NYX] MakeTab Error:")
    warn(tostring(MainTab))

    Fail("สร้าง Tab ไม่สำเร็จ")
    return
end

-- =========================================================
-- BUTTON
-- =========================================================

local ButtonSuccess, ButtonError = pcall(function()

    MainTab:AddButton({

        Name = "ฟังก์ชันทำงาน",

        Callback = function()

            print("[NYX] Script is working!")

        end

    })

end)

if not ButtonSuccess then

    warn("[NYX] AddButton Error:")
    warn(tostring(ButtonError))

    Fail("สร้างปุ่มไม่สำเร็จ")
    return
end

-- =========================================================
-- COMPLETE
-- =========================================================

print("======================================")
print("[NYX] SCRIPT LOADED SUCCESSFULLY")
print("======================================")

print("Whitelist: ACTIVE")
print("Expires:", ExpiresAt)

print("======================================")
