```lua
--[[
    NYX Whitelist Tester
    Key + HWID verification

    API:
    https://zerzy.com/api/verify.php

    วิธีใช้:
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

local API_URL = "https://zerzy.com/api/verify.php"

local UI_LIBRARY_URL =
    "https://raw.githubusercontent.com/chalamkub/Nyx/refs/heads/main/MacUI_Library_v2.lua"

-- =========================================================
-- DEBUG
-- =========================================================

local function Debug(...)
    print("[NYX]", ...)
end

local function Fail(message)
    warn("[NYX] " .. tostring(message))

    if LocalPlayer then
        pcall(function()
            LocalPlayer:Kick("Whitelist: " .. tostring(message))
        end)
    end
end

-- =========================================================
-- GET KEY
-- =========================================================

local Key = getgenv().Key

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
        local success, result = pcall(gethwid)

        if success and result and tostring(result) ~= "" then
            return tostring(result)
        end
    end

    -- get_hwid
    if type(get_hwid) == "function" then
        local success, result = pcall(get_hwid)

        if success and result and tostring(result) ~= "" then
            return tostring(result)
        end
    end

    -- syn.get_hwid
    if syn and type(syn.get_hwid) == "function" then
        local success, result = pcall(syn.get_hwid)

        if success and result and tostring(result) ~= "" then
            return tostring(result)
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
        Debug("Using request()")
        return request
    end

    if type(http_request) == "function" then
        Debug("Using http_request()")
        return http_request
    end

    if syn and type(syn.request) == "function" then
        Debug("Using syn.request()")
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

local RequestBody

local EncodeSuccess, EncodeResult = pcall(function()

    return HttpService:JSONEncode({
        key = Key,
        hwid = HWID
    })

end)

if not EncodeSuccess then
    Fail("ไม่สามารถสร้าง JSON ได้")
    return
end

RequestBody = EncodeResult

Debug("Request Body:")
print(RequestBody)

-- =========================================================
-- SEND API REQUEST
-- =========================================================

Debug("Sending request...")
Debug("API:", API_URL)

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

if not RequestSuccess then

    warn("========== NYX REQUEST ERROR ==========")
    warn(tostring(RequestResult))
    warn("=======================================")

    Fail("ส่ง Request ไป API ไม่สำเร็จ")
    return
end

if not RequestResult then
    Fail("API ไม่ส่ง Response กลับมา")
    return
end

-- =========================================================
-- READ RESPONSE
-- =========================================================

local StatusCode = RequestResult.StatusCode
local ResponseBody = RequestResult.Body

warn("========== NYX API DEBUG ==========")
warn("Status:", tostring(StatusCode))
warn("Body:")
warn(tostring(ResponseBody))
warn("===================================")

if not ResponseBody then
    Fail("API ไม่มี Response Body")
    return
end

ResponseBody = tostring(ResponseBody)

-- =========================================================
-- DECODE JSON
-- =========================================================

local DecodeSuccess, Data = pcall(function()
    return HttpService:JSONDecode(ResponseBody)
end)

if not DecodeSuccess then

    warn("========== NYX JSON ERROR ==========")
    warn("Status:", tostring(StatusCode))
    warn("Raw Body:")
    warn(ResponseBody)
    warn("====================================")

    Fail("Server ส่งข้อมูลไม่ถูกต้อง")
    return
end

if type(Data) ~= "table" then
    Fail("รูปแบบข้อมูลจาก Server ไม่ถูกต้อง")
    return
end

-- =========================================================
-- CHECK API RESULT
-- =========================================================

if Data.success ~= true then

    local Message = tostring(
        Data.message or "Whitelist verification failed"
    )

    warn("[NYX] API rejected request:")
    warn(Message)

    Fail(Message)
    return
end

-- =========================================================
-- WHITELIST SUCCESS
-- =========================================================

print("======================================")
print("[NYX] WHITELIST SUCCESS")
print("[NYX] Message:", tostring(Data.message))
print("[NYX] Expires:", tostring(Data.expires_at))
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

    warn("========== NYX UI ERROR ==========")
    warn(tostring(MacUI))
    warn("==================================")

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
-- DONE
-- =========================================================

print("======================================")
print("[NYX] Script loaded successfully!")
print("[NYX] Key:", Key)
print("[NYX] Expires:", tostring(Data.expires_at))
print("======================================")
```
