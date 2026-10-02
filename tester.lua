local inputKey = getgenv().Key

if not inputKey or inputKey == "" then
    game.Players.LocalPlayer:Kick("กรุณาใส่ Key ก่อนรันสคริปต์!")
    return
end

-- ต้องแทนที่ด้วย identifier/HWID ที่ environment ของคุณรองรับ
local hwid = get_hwid_somehow()

local payload = {
    key = inputKey,
    hwid = hwid
}

local body = game:GetService("HttpService"):JSONEncode(payload)

local response = request({
    Url = "https://YOUR-DOMAIN.com/api/verify.php",
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json"
    },
    Body = body
})

if not response then
    game.Players.LocalPlayer:Kick("ไม่สามารถเชื่อมต่อ Whitelist Server ได้")
    return
end

local data = game:GetService("HttpService"):JSONDecode(response.Body)

if not data.success then
    game.Players.LocalPlayer:Kick(data.message or "Key ไม่ถูกต้อง")
    return
end

print("Whitelist OK")
print("หมดอายุ:", data.expires_at)

-- ==========================================
-- ผ่าน Whitelist แล้วค่อยโหลด UI
-- ==========================================

local successUI, MacUI = pcall(function()
    return loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/chalamkub/Nyx/refs/heads/main/MacUI_Library_v2.lua"
    ))()
end)

if not successUI or not MacUI then
    warn("โหลด UI ไม่สำเร็จ")
    return
end

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
