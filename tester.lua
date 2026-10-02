-- ==========================================
-- สคริปต์ส่วนนี้คือตัวที่อยู่บน https://cdn.maruhub.online/s/mobile
-- ==========================================

-- 1. ดึงค่า Key ที่ผู้เล่นใส่ไว้ใน Loader มาใช้งาน
local inputKey = getgenv().Key

-- 2. เช็คเบื้องต้นว่าผู้เล่นได้ใส่ Key มาไหม
if not inputKey or inputKey == "" then
    game.Players.LocalPlayer:Kick("❌ กรุณาใส่ Key ก่อนรันสคริปต์!")
    return -- หยุดการทำงานทันที
end

-- 3. นำ inputKey ไปตรวจสอบกับระบบคีย์ที่คุณทำไว้ (เช่น เช็คผ่าน API/Database ของคุณ)
local function VerifyKeyAndHWID(key)
    -- *** ใส่โค้ดระบบเช็คคีย์ที่คุณทำไว้ตรงนี้ ***
    -- สมมติว่าเช็คแล้วผ่าน คืนค่าเป็น true
    
    local isValid = true -- สมมติว่าคีย์ถูก
    
    if isValid then
        return true
    else
        return false
    end
end

-- 4. ประมวลผลการเข้าถึง
if VerifyKeyAndHWID(inputKey) then
    print("✅ คีย์ถูกต้อง! กำลังโหลดสคริปต์...")
    
    -- ==========================================
    -- 5. โหลด UI Library และสร้างโปรแกรม (เมื่อคีย์ถูกเท่านั้น)
    -- ==========================================
    local successUI, MacUI = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/chalamkub/Nyx/refs/heads/main/MacUI_Library_v2.lua"))()
    end)

    if successUI and MacUI then
        -- สร้าง UI ของคุณต่อได้เลย
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
    else
        warn("โหลด UI ไม่สำเร็จ")
    end

else
    -- ถ้าคีย์ผิด หรือ HWID ไม่ตรง ให้เตะออก
    game.Players.LocalPlayer:Kick("❌ Key ไม่ถูกต้อง หรือ หมดอายุ!")
end
