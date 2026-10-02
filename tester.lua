--========================================================--
--                    NYX WHITELIST                       --
--========================================================--

print("========================================")
print("[NYX] Tester starting...")
print("========================================")

--========================================================--
-- SERVICES
--========================================================--

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--========================================================--
-- CONFIG
--========================================================--

local API_URL = "https://zerzy.xyz/api/verify.php"

local UI_LIBRARY_URL =
    "https://raw.githubusercontent.com/chalamkub/Nyx/refs/heads/main/MacUI_Library_v2.lua"

--========================================================--
-- SAFE PRINT
--========================================================--

local function Log(...)
    print("[NYX]", ...)
end

local function Warn(...)
    warn("[NYX]", ...)
end

--========================================================--
-- ERROR HANDLER
--========================================================--

local function StopScript(message)

    Warn("========================================")
    Warn("SCRIPT STOPPED")
    Warn(tostring(message))
    Warn("========================================")

    if LocalPlayer then
        pcall(function()
            LocalPlayer:Kick(
                "NYX Whitelist\n" ..
                tostring(message)
            )
        end)
    end
end

--========================================================--
-- GET KEY
--========================================================--

Log("Reading Key...")

local Key

local KeySuccess, KeyResult = pcall(function()

    if type(getgenv) ~= "function" then
        error("getgenv is not available")
    end

    return getgenv().Key

end)

if not KeySuccess then
    StopScript("ไม่สามารถอ่าน Key ได้")
    return
end

Key = KeyResult

if Key == nil then
    StopScript("ไม่พบ getgenv().Key")
    return
end

Key = tostring(Key)

if Key == "" then
    StopScript("Key เป็นค่าว่าง")
    return
end

Log("Key:", Key)

--========================================================--
-- GET HWID
--========================================================--

Log("Reading HWID...")

local function GetHWID()

    -- gethwid
    if type(gethwid) == "function" then

        local Success, Result = pcall(function()
            return gethwid()
        end)

        if Success and Result then

            Result = tostring(Result)

            if Result ~= "" and Result ~= "nil" then
                return Result, "gethwid"
            end

        end

    end

    -- get_hwid
    if type(get_hwid) == "function" then

        local Success, Result = pcall(function()
            return get_hwid()
        end)

        if Success and Result then

            Result = tostring(Result)

            if Result ~= "" and Result ~= "nil" then
                return Result, "get_hwid"
            end

        end

    end

    -- syn.get_hwid
    if syn and type(syn.get_hwid) == "function" then

        local Success, Result = pcall(function()
            return syn.get_hwid()
        end)

        if Success and Result then

            Result = tostring(Result)

            if Result ~= "" and Result ~= "nil" then
                return Result, "syn.get_hwid"
            end

        end

    end

    return nil, nil
end

local HWID, HWIDSource = GetHWID()

if not HWID then
    StopScript("ไม่สามารถอ่าน HWID ได้")
    return
end

Log("HWID source:", HWIDSource)
Log("HWID:", HWID)

--========================================================--
-- GET REQUEST FUNCTION
--========================================================--

Log("Checking HTTP request...")

local Request

if type(request) == "function" then

    Request = request
    Log("HTTP method: request")

elseif type(http_request) == "function" then

    Request = http_request
    Log("HTTP method: http_request")

elseif syn and type(syn.request) == "function" then

    Request = syn.request
    Log("HTTP method: syn.request")

end

if not Request then
    StopScript("ไม่พบ HTTP request function")
    return
end

--========================================================--
-- CREATE JSON
--========================================================--

Log("Creating JSON...")

local EncodeSuccess, RequestBody = pcall(function()

    return HttpService:JSONEncode({
        key = Key,
        hwid = HWID
    })

end)

if not EncodeSuccess then
    StopScript("สร้าง JSON ไม่สำเร็จ: " .. tostring(RequestBody))
    return
end

Log("Request body:")
print(RequestBody)

--========================================================--
-- SEND API REQUEST
--========================================================--

Log("========================================")
Log("Sending whitelist request...")
Log("API:", API_URL)
Log("========================================")

local RequestSuccess, Response = pcall(function()

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

--========================================================--
-- REQUEST ERROR
--========================================================--

if not RequestSuccess then

    Warn("========================================")
    Warn("HTTP REQUEST ERROR")
    Warn("========================================")
    Warn(tostring(Response))
    Warn("========================================")

    StopScript("ส่งข้อมูลไป API ไม่สำเร็จ")
    return
end

if Response == nil then
    StopScript("API ไม่ส่ง Response กลับมา")
    return
end

--========================================================--
-- READ STATUS
--========================================================--

local StatusCode = Response.StatusCode
local Status = Response.Status

Log("========================================")
Log("API RESPONSE")
Log("========================================")

Log("StatusCode:", tostring(StatusCode))
Log("Status:", tostring(Status))

--========================================================--
-- READ BODY
--========================================================--

local ResponseBody = Response.Body

if ResponseBody == nil then

    -- บาง environment อาจใช้ Body เป็นข้อมูลอื่น
    Warn("Response.Body is nil")

    -- ลองดู response ทั้งหมด
    Warn("Response type:", type(Response))

    StopScript("API ไม่มี Response Body")
    return
end

ResponseBody = tostring(ResponseBody)

Log("Body:")
print(ResponseBody)

Log("========================================")

--========================================================--
-- HTTP STATUS CHECK
--========================================================--

if StatusCode and tonumber(StatusCode) ~= 200 then

    Warn("API returned HTTP status:", tostring(StatusCode))

    -- พยายามอ่าน JSON ต่อก่อน
    -- เพราะบาง API สามารถส่ง JSON error พร้อม 4xx ได้
end

--========================================================--
-- CHECK EMPTY RESPONSE
--========================================================--

if ResponseBody == "" then
    StopScript("API ส่ง Response ว่าง")
    return
end

--========================================================--
-- DECODE JSON
--========================================================--

Log("Decoding JSON...")

local DecodeSuccess, Data = pcall(function()

    return HttpService:JSONDecode(ResponseBody)

end)

if not DecodeSuccess then

    Warn("========================================")
    Warn("JSON DECODE ERROR")
    Warn("========================================")

    Warn("Raw API Response:")
    Warn(ResponseBody)

    Warn("========================================")

    StopScript("Server ส่งข้อมูลไม่ใช่ JSON")
    return
end

if type(Data) ~= "table" then
    StopScript("รูปแบบ JSON จาก Server ไม่ถูกต้อง")
    return
end

--========================================================--
-- READ API DATA
--========================================================--

local APISuccess = Data.success
local APIMessage = tostring(Data.message or "")
local ExpiresAt = tostring(Data.expires_at or "")

Log("API success:", tostring(APISuccess))
Log("API message:", APIMessage)
Log("API expires:", ExpiresAt)

--========================================================--
-- WHITELIST FAILED
--========================================================--

if APISuccess ~= true then

    Warn("========================================")
    Warn("WHITELIST FAILED")
    Warn("========================================")

    Warn("Message:", APIMessage)

    Warn("========================================")

    StopScript(
        APIMessage ~= ""
        and APIMessage
        or "Whitelist verification failed"
    )

    return
end

--========================================================--
-- WHITELIST SUCCESS
--========================================================--

Log("========================================")
Log("WHITELIST SUCCESS")
Log("========================================")

Log("Key:", Key)
Log("HWID:", HWID)
Log("Expires:", ExpiresAt)

Log("========================================")

--========================================================--
-- LOAD UI LIBRARY
--========================================================--

Log("Loading MacUI Library...")

local UILoadSuccess, MacUI = pcall(function()

    local Source = game:HttpGet(UI_LIBRARY_URL)

    if not Source or Source == "" then
        error("UI Library source is empty")
    end

    Log("UI source downloaded:", #Source, "characters")

    local Loader = loadstring(Source)

    if type(Loader) ~= "function" then
        error("loadstring did not return function")
    end

    return Loader()

end)

if not UILoadSuccess then

    Warn("========================================")
    Warn("UI LIBRARY ERROR")
    Warn("========================================")

    Warn(tostring(MacUI))

    Warn("========================================")

    StopScript("โหลด UI Library ไม่สำเร็จ")
    return
end

if type(MacUI) ~= "table" then
    StopScript("MacUI Library ไม่ได้ส่ง table กลับมา")
    return
end

Log("MacUI Library loaded")

--========================================================--
-- CREATE WINDOW
--========================================================--

Log("Creating Window...")

local WindowSuccess, Window = pcall(function()

    return MacUI:MakeWindow({

        Name = "My Premium Script",

        HidePremium = false,

        SaveConfig = true,

        ConfigFolder = "MyScriptConfig"

    })

end)

if not WindowSuccess then

    Warn("MakeWindow error:")
    Warn(tostring(Window))

    StopScript("สร้าง Window ไม่สำเร็จ")
    return
end

if not Window then
    StopScript("MakeWindow ไม่ได้ส่ง Window กลับมา")
    return
end

Log("Window created")

--========================================================--
-- CREATE TAB
--========================================================--

Log("Creating Main Tab...")

local TabSuccess, MainTab = pcall(function()

    return Window:MakeTab({

        Name = "Main",

        Icon = "rbxassetid://4483345998",

        PremiumOnly = false

    })

end)

if not TabSuccess then

    Warn("MakeTab error:")
    Warn(tostring(MainTab))

    StopScript("สร้าง Tab ไม่สำเร็จ")
    return
end

if not MainTab then
    StopScript("MakeTab ไม่ได้ส่ง Tab กลับมา")
    return
end

Log("Main Tab created")

--========================================================--
-- ADD BUTTON
--========================================================--

Log("Creating button...")

local ButtonSuccess, ButtonResult = pcall(function()

    return MainTab:AddButton({

        Name = "ฟังก์ชันทำงาน",

        Callback = function()

            print("========================================")
            print("[NYX] Script is working!")
            print("[NYX] Whitelist: ACTIVE")
            print("[NYX] Expires:", ExpiresAt)
            print("========================================")

        end

    })

end)

if not ButtonSuccess then

    Warn("AddButton error:")
    Warn(tostring(ButtonResult))

    StopScript("สร้างปุ่มไม่สำเร็จ")
    return
end

--========================================================--
-- FINISHED
--========================================================--

print("")
print("========================================")
print("[NYX] SCRIPT LOADED SUCCESSFULLY")
print("========================================")
print("Whitelist : ACTIVE")
print("Key       :", Key)
print("Expires   :", ExpiresAt)
print("========================================")
