--// =========================================
--// NYX WHITELIST LOADER
--// Key + HWID Verification
--// =========================================

--// =========================
--// CONFIG
--// =========================

local API_URL = "https://zerzy.xyz/api/verify.php"

local MACUI_URL =
    "https://raw.githubusercontent.com/chalamkub/Nyx/refs/heads/main/MacUI_Library_v2.lua"


--// =========================
--// GET KEY
--// =========================

local Key = getgenv().Key

if not Key or Key == "" then
    game:GetService("Players").LocalPlayer:Kick(
        "[NYX] กรุณาใส่ Key ก่อนใช้งาน"
    )

    return
end


--// =========================
--// GET HWID
--// =========================

local function GetHWID()

    if typeof(gethwid) == "function" then
        local success, result = pcall(function()
            return gethwid()
        end)

        if success and result then
            return tostring(result)
        end
    end


    if typeof(get_hwid) == "function" then
        local success, result = pcall(function()
            return get_hwid()
        end)

        if success and result then
            return tostring(result)
        end
    end


    if syn and typeof(syn.get_hwid) == "function" then
        local success, result = pcall(function()
            return syn.get_hwid()
        end)

        if success and result then
            return tostring(result)
        end
    end


    return nil
end


local HWID = GetHWID()

if not HWID or HWID == "" then

    game:GetService("Players").LocalPlayer:Kick(
        "[NYX] ไม่สามารถตรวจสอบ HWID ได้"
    )

    return
end


--// =========================
--// GET REQUEST FUNCTION
--// =========================

local RequestFunction =
    request
    or http_request
    or (syn and syn.request)


if not RequestFunction then

    game:GetService("Players").LocalPlayer:Kick(
        "[NYX] Executor ไม่รองรับ HTTP Request"
    )

    return
end


--// =========================
--// JSON ENCODE
--// =========================

local HttpService = game:GetService("HttpService")

local RequestBody = HttpService:JSONEncode({
    key = Key,
    hwid = HWID
})


--// =========================
--// VERIFY KEY
--// =========================

local Response

local success, err = pcall(function()

    Response = RequestFunction({
        Url = API_URL,

        Method = "POST",

        Headers = {
            ["Content-Type"] = "application/json"
        },

        Body = RequestBody
    })

end)


if not success or not Response then

    game:GetService("Players").LocalPlayer:Kick(
        "[NYX] ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้"
    )

    return
end


--// =========================
--// GET RESPONSE BODY
--// =========================

local Body =
    Response.Body
    or Response.body
    or ""


if Body == "" then

    game:GetService("Players").LocalPlayer:Kick(
        "[NYX] Server ไม่ส่งข้อมูลกลับมา"
    )

    return
end


--// =========================
--// DECODE JSON
--// =========================

local Data

local DecodeSuccess, DecodeError = pcall(function()

    Data = HttpService:JSONDecode(Body)

end)


if not DecodeSuccess or not Data then

    game:GetService("Players").LocalPlayer:Kick(
        "[NYX] ข้อมูลจาก Server ไม่ถูกต้อง"
    )

    return
end


--// =========================
--// CHECK WHITELIST
--// =========================

if Data.success ~= true then

    local Message =
        Data.message
        or "Key ไม่ถูกต้อง"

    game:GetService("Players").LocalPlayer:Kick(
        "[NYX] " .. tostring(Message)
    )

    return
end


--// =========================
--// GET EXPIRE TIME
--// =========================

local ExpiresAt = Data.expires_at

if not ExpiresAt then

    game:GetService("Players").LocalPlayer:Kick(
        "[NYX] ไม่พบข้อมูลวันหมดอายุ"
    )

    return
end


--// =========================
--// CONVERT PHP DATETIME
--// =========================
--//
--// ตัวอย่าง:
--// 2026-11-01 13:58:43
--//
--// Roblox จะนำไปคำนวณเป็น Unix Timestamp
--//

local function ParseDateTime(DateString)

    local Year, Month, Day, Hour, Minute, Second =
        DateString:match(
            "(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)"
        )

    if not Year then
        return nil
    end

    return os.time({
        year = tonumber(Year),
        month = tonumber(Month),
        day = tonumber(Day),
        hour = tonumber(Hour),
        min = tonumber(Minute),
        sec = tonumber(Second)
    })
end


local ExpireTimestamp = ParseDateTime(ExpiresAt)

if not ExpireTimestamp then

    game:GetService("Players").LocalPlayer:Kick(
        "[NYX] รูปแบบวันหมดอายุไม่ถูกต้อง"
    )

    return
end


--// =========================
--// LOAD MACUI
--// =========================

local MacUI

local LoadSuccess, LoadError = pcall(function()

    MacUI = loadstring(
        game:HttpGet(MACUI_URL)
    )()

end)


if not LoadSuccess or not MacUI then

    game:GetService("Players").LocalPlayer:Kick(
        "[NYX] ไม่สามารถโหลด UI Library ได้"
    )

    return
end


--// =========================
--// CREATE WINDOW
--// =========================

local Window = MacUI:MakeWindow({

    Name = "My Premium Script",

    HidePremium = false,

    SaveConfig = true,

    ConfigFolder = "MyScriptConfig"

})


--// =========================
--// CREATE MAIN TAB
--// =========================

local MainTab = Window:MakeTab({

    Name = "Main",

    Icon = "rbxassetid://4483345998",

    PremiumOnly = false

})


--// =========================
--// PROFILE
--// =========================

--// แสดงข้อมูล Key / สถานะ / เวลาที่เหลือ

local ProfileLabel

local ProfileText =
    "Key: " .. tostring(Key) ..
    "\nสถานะ: Whitelisted"


--// =========================
--// CREATE PROFILE / INFO
--// =========================

pcall(function()

    ProfileLabel = MainTab:AddParagraph({

        Title = "Profile",

        Content = ProfileText

    })

end)


--// =========================
--// COUNTDOWN LABEL
--// =========================

local TimeLabel

pcall(function()

    TimeLabel = MainTab:AddParagraph({

        Title = "Whitelist",

        Content = "กำลังคำนวณเวลาที่เหลือ..."

    })

end)


--// =========================
--// UPDATE LABEL (แก้เพิ่มวินาที)
--// =========================

local function UpdateTimeLabel()

    local Remaining = ExpireTimestamp - os.time()

    --// หมดอายุ
    if Remaining <= 0 then
        if TimeLabel then
            pcall(function()
                TimeLabel:Set({
                    Title = "Whitelist",
                    Content = "Key หมดอายุแล้ว"
                })
            end)
        end
        return false
    end

    --// คำนวณเวลา
    local Days = math.floor(Remaining / 86400)
    local Hours = math.floor((Remaining % 86400) / 3600)
    local Minutes = math.floor((Remaining % 3600) / 60)
    local Seconds = Remaining % 60 -- คำนวณวินาที

    local Text =
        "เหลือเวลา " ..
        tostring(Days) .. " วัน " ..
        tostring(Hours) .. " ชั่วโมง " ..
        tostring(Minutes) .. " นาที " ..
        tostring(Seconds) .. " วินาที"

    --// อัปเดต UI
    if TimeLabel then
        pcall(function()
            TimeLabel:Set({
                Title = "Whitelist",
                Content = Text
            })
        end)
    end

    return true
end


--// =========================
--// FIRST UPDATE
--// =========================

UpdateTimeLabel()


--// =========================
--// COUNTDOWN LOOP (แก้เป็น 1 วิ)
--// =========================

task.spawn(function()
    while true do
        task.wait(1)
        
        local Active = UpdateTimeLabel()

        if not Active then
            break
        end
    end
end)


--// =========================
--// MAIN BUTTON
--// =========================

MainTab:AddButton({

    Name = "ฟังก์ชันทำงาน",

    Callback = function()

        print("[NYX] Script is working!")

    end

})


--// =========================
--// SUCCESS LOG
--// =========================

print(
    "[NYX] Whitelist verified successfully"
)

print(
    "[NYX] Key: " .. tostring(Key)
)

print(
    "[NYX] HWID: " .. tostring(HWID)
)

print(
    "[NYX] Expires: " .. tostring(ExpiresAt)
)
