local inputKey = getgenv().Key

if not inputKey or inputKey == "" then
    game.Players.LocalPlayer:Kick("❌ กรุณาใส่ Key ก่อนรันสคริปต์!")
    return
end

-- 1. ฟังก์ชันดึง HWID (รองรับ Executor ทั่วไป)
local hwid = ""
pcall(function()
    hwid = gethwid()
end)
if hwid == "" then hwid = "UNKNOWN_HWID" end

-- 2. ตั้งค่า Request ให้รองรับทุกค่าย (Synapse, Krnl, Delta, Codex ฯลฯ)
local http_request = (syn and syn.request) or (http and http.request) or http_request or request or fluxus.request

if not http_request then
    game.Players.LocalPlayer:Kick("❌ ตัวรันของคุณไม่รองรับคำสั่ง http_request")
    return
end

local HttpService = game:GetService("HttpService")
local payload = {
    key = inputKey,
    hwid = hwid
}
local body = HttpService:JSONEncode(payload)

local response = http_request({
    Url = "https://YOUR-DOMAIN.com/api/verify.php", -- เปลี่ยนเป็น URL ของคุณ
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json"
    },
    Body = body
})

if not response or response.StatusCode ~= 200 then
    game.Players.LocalPlayer:Kick("❌ ไม่สามารถเชื่อมต่อ Whitelist Server ได้ หรือเซิร์ฟเวอร์มีปัญหา")
    return
end

-- 3. ป้องกันบัคตอนแปลง JSON
local successDecode, data = pcall(function()
    return HttpService:JSONDecode(response.Body)
end)

if not successDecode or type(data) ~= "table" then
    game.Players.LocalPlayer:Kick("❌ เซิร์ฟเวอร์ตอบกลับข้อมูลผิดพลาด (API Error)")
    return
end

if not data.success then
    game.Players.LocalPlayer:Kick("❌ " .. (data.message or "Key ไม่ถูกต้อง"))
    return
end

print("✅ Whitelist OK")
print("⏳ หมดอายุ:", data.expires_at or "ถาวร")

-- ==========================================
-- โหลด UI (เมื่อผ่าน Whitelist แล้ว)
-- ==========================================

local successUI, MacUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/chalamkub/Nyx/refs/heads/main/MacUI_Library_v2.lua"))()
end)

if not successUI or not MacUI then
    warn("❌ โหลด UI ไม่สำเร็จ! ลิ้งค์อาจจะมีปัญหาหรือเข้าถึงไม่ได้")
    return
end

-- สร้างหน้าต่าง UI
local Window = MacUI:MakeWindow({
    Name = "My Premium Script",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MyScriptConfig"
})

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddButton({
    Name = "ฟังก์ชันทำงาน",
    Callback = function()
        print("สคริปต์รันแล้ว!")
    end
})
