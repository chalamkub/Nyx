-- โหลด UI Library จากลิงก์
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/chalamkub/Nyx/refs/heads/main/MacUI_Library.lua"))()

-- 1. สร้างหน้าต่างหลัก (Window)
local Window = Library:Window({
    Title = "สคริปต์ทดสอบ MacUI",
    Subtitle = "Test Script",
    Size = UDim2.fromOffset(500, 350), -- ขนาดของ UI
    DragMode = 2,
    Theme = "Dark"
})

-- 2. สร้างหน้าแท็บ (Tab)
local MainTab = Window:Tab({
    Name = "เมนูหลัก",
    Icon = "rbxassetid://11433532654" -- ID ของไอคอน (ถ้ามี)
})

local PlayerTab = Window:Tab({
    Name = "ผู้เล่น",
    Icon = "rbxassetid://11433532654"
})

-- 3. สร้างฟังก์ชันต่างๆ ในเมนูหลัก (MainTab)

-- ปุ่มกด (Button)
MainTab:Button({
    Name = "พิมพ์ข้อความ",
    Callback = function()
        print("คุณกดปุ่มใน UI แล้ว!")
    end
})

-- สวิตช์เปิด-ปิด (Toggle)
MainTab:Toggle({
    Name = "ออโต้คลิก (Auto Click)",
    Default = false,
    Callback = function(Value)
        print("สถานะออโต้คลิก:", Value)
        -- ใส่โค้ดออโต้คลิกของคุณตรงนี้ โดยใช้ if Value then ...
    end
})

-- ดรอปดาวน์ (Dropdown)
MainTab:Dropdown({
    Name = "เลือกไอเทม",
    Options = {"ดาบไม้", "ดาบเหล็ก", "ดาบเพชร"},
    Default = "ดาบไม้",
    Callback = function(Value)
        print("คุณเลือก:", Value)
    end
})

-- 4. สร้างฟังก์ชันในหน้าผู้เล่น (PlayerTab)

-- สไลเดอร์ปรับค่า (Slider) สำหรับความเร็ววิ่ง
PlayerTab:Slider({
    Name = "ความเร็ววิ่ง (WalkSpeed)",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = Value
        end
    end
})

-- สไลเดอร์ปรับค่า (Slider) สำหรับพลังกระโดด
PlayerTab:Slider({
    Name = "พลังกระโดด (JumpPower)",
    Min = 50,
    Max = 200,
    Default = 50,
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = Value
        end
    end
})
