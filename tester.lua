--==================================================
-- NYX WHITELIST LOADER
-- Key + HWID + PHP API
--==================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--==================================================
-- CONFIG
--==================================================

local API_URL = "https://zerzy.com/api/verify.php"

local UI_LIBRARY_URL =
    "https://raw.githubusercontent.com/chalamkub/Nyx/refs/heads/main/MacUI_Library_v2.lua"

--==================================================
-- GET KEY
--==================================================

local Key = getgenv().Key

if not Key or tostring(Key) == "" then
    LocalPlayer:Kick("Whitelist: กรุณาใส่ Key ก่อนรันสคริปต์")
    return
end

Key = tostring(Key)

--==================================================
-- HWID
--==================================================

local function GetHWID()

    -- บาง environment ใช้ gethwid()
    if type(gethwid) == "function" then
        local success, result = pcall(gethwid)

        if success and result and tostring(result) ~= "" then
            return tostring(result)
        end
    end

    -- บาง environment ใช้ get_hwid()
    if type(get_hwid) == "function" then
        local success, result = pcall(get_hwid)

        if success and result and tostring(result) ~= "" then
            return tostring(result)
        end
    end

    -- บาง environment มี syn.get_hwid()
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
    LocalPlayer:Kick(
        "Whitelist: ไม่พบ HWID API ของ environment นี้"
    )
    return
end

--==================================================
-- HTTP REQUEST
--==================================================

local function GetRequestFunction()

    if type(request) == "function" then
        return request
    end

    if type(http_request) == "function" then
        return http_request
    end

    if syn and type(syn.request) == "function" then
        return syn.request
    end

    return nil
end

local Request = GetRequestFunction()

if not Request then
    LocalPlayer:Kick(
        "Whitelist: Environment ไม่มี HTTP Request API"
    )
    return
end

--==================================================
-- CREATE REQUEST
--==================================================

local RequestBody = HttpService:JSONEncode({
    key = Key,
    hwid = HWID
})

local RequestResult

local RequestSuccess, RequestError = pcall(function()

    RequestResult = Request({
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

    LocalPlayer:Kick(
        "Whitelist: เชื่อมต่อ API ไม่สำเร็จ"
    )

    warn(
        "[NYX WHITELIST] Request Error:",
        RequestError
    )

    return
end

if not RequestResult then

    LocalPlayer:Kick(
        "Whitelist: API ไม่ส่งข้อมูลกลับมา"
    )

    return
end

--==================================================
-- READ RESPONSE
--==================================================

local ResponseBody = RequestResult.Body

if not ResponseBody then

    LocalPlayer:Kick(
        "Whitelist: Response ไม่มี Body"
    )

    return
end

local DecodeSuccess, Data = pcall(function()
    return HttpService:JSONDecode(ResponseBody)
end)

if not DecodeSuccess then

    warn(
        "[NYX WHITELIST] Invalid JSON:",
        ResponseBody
    )

    LocalPlayer:Kick(
        "Whitelist: Server ส่งข้อมูลไม่ถูกต้อง"
    )

    return
end

--==================================================
-- CHECK RESULT
--==================================================

if not Data.success then

    local Message = tostring(
        Data.message or "Key ไม่ถูกต้อง"
    )

    LocalPlayer:Kick(
        "Whitelist: " .. Message
    )

    return
end

--==================================================
-- WHITELIST SUCCESS
--==================================================

print("================================")
print("NYX WHITELIST")
print("Status : VERIFIED")
print("Key    :", Key)
print("HWID   :", HWID)

if Data.expires_at then
    print("Expire :", Data.expires_at)
end

print("================================")

--==================================================
-- LOAD UI LIBRARY
--==================================================

local UISuccess, MacUI = pcall(function()

    return loadstring(
        game:HttpGet(UI_LIBRARY_URL)
    )()

end)

if not UISuccess or not MacUI then

    warn(
        "[NYX] MacUI Library Load Failed:",
        MacUI
    )

    LocalPlayer:Kick(
        "Whitelist ผ่านแล้ว แต่โหลด UI ไม่สำเร็จ"
    )

    return
end

--==================================================
-- CREATE WINDOW
--==================================================

local Window = MacUI:MakeWindow({

    Name = "My Premium Script",

    HidePremium = false,

    SaveConfig = true,

    ConfigFolder = "MyScriptConfig"

})

--==================================================
-- MAIN TAB
--==================================================

local MainTab = Window:MakeTab({

    Name = "Main",

    Icon = "rbxassetid://4483345998",

    PremiumOnly = false

})

--==================================================
-- TEST BUTTON
--==================================================

MainTab:AddButton({

    Name = "ฟังก์ชันทำงาน",

    Callback = function()

        print(
            "[NYX] Script is working!"
        )

    end

})

--==================================================
-- FINISHED
--==================================================

print("[NYX] Script loaded successfully.")
