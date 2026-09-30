-- โหลดไลบรารี Maclib UI 
local Maclib = loadstring(game:HttpGet("https://raw.githubusercontent.com/biggaboy212/Maclib/main/maclib.lua"))()

-- 1. สร้างหน้าต่างหลัก (Window)
local Window = Maclib:Window({
    Title = "NYX BLOX HUB",
    Subtitle = "Script Interface",
    Size = UDim2.fromOffset(868, 650),
    DragAndClose = false,
    Color = Color3.fromRGB(138, 43, 226), -- สีม่วงสไตล์ Neon
    LoadText = "Loading Interface..."
})

-- 2. สร้างกลุ่มเมนูและ Tab ด้านซ้าย (Sidebar)
local TabGroup = Window:TabGroup()

-- สร้าง Tab "Farming" และ "Loadout"
local FarmTab = TabGroup:Tab({ Name = "Farming", Icon = "rbxassetid://10888331510" })
local LoadoutTab = TabGroup:Tab({ Name = "Loadout", Icon = "rbxassetid://10888331510" })

-- 3. จัดกลุ่มเนื้อหาในหน้า Farming (Section)
local MainFarmSection = FarmTab:Section({ Name = "Auto Farm" })
local BossFarmSection = FarmTab:Section({ Name = "Bosses" })

-- 4. เพิ่มลูกเล่นต่างๆ (Elements) เข้าไปใน Section

-- Toggle เปิด/ปิด ฟาร์มปกติ
MainFarmSection:Toggle({
    Name = "Enabled",
    Description = "Turn auto-farming on or off.",
    Default = false,
    Callback = function(state)
        print("Auto Farm is now: ", state)
        -- วางลูปโค้ด Auto Farm ตรงนี้
    end
})

-- Toggle ระบบใหม่ (WIP)
MainFarmSection:Toggle({
    Name = "Auto Final Selection [WIP]",
    Description = "Travel to the Final Selection zone before its next cycle.",
    Default = false,
    Callback = function(state)
        print("Auto Final Selection: ", state)
    end
})

-- Dropdown เลือกเควสแบบมี Description
MainFarmSection:Dropdown({
    Name = "Quest Selection",
    Description = "Smart picks the best quest, or choose one.",
    Multi = false,
    Options = {"Smart", "Quest 1", "Quest 2", "Quest 3"},
    Default = "Smart",
    Callback = function(selected)
        print("Selected Quest: ", selected)
    end
})

-- Toggle สำหรับหมวดหมู่บอส
BossFarmSection:Toggle({
    Name = "Enabled",
    Description = "Turn boss farming on or off.",
    Default = true,
    Callback = function(state)
        print("Boss Farming: ", state)
    end
})

-- Dropdown สำหรับเลือกบอส
BossFarmSection:Dropdown({
    Name = "Bosses",
    Multi = false,
    Options = {"[Lv 125] [Boss] [Saneri]", "[Lv 50] [Boss] [Rui]", "[Lv 200] [Boss] [Akaza]"},
    Default = "[Lv 125] [Boss] [Saneri]",
    Callback = function(selected)
        print("Target Boss: ", selected)
    end
})

-- 5. สั่งให้ UI ทำงานและแสดงผล
Maclib:SetFolder("NYX_Settings")
Window:Notify({
    Title = "Ready",
    Description = "UI has been successfully loaded!",
    Lifetime = 3
})
