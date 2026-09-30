-- โหลด Maclib ตามเอกสาร
local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()

local Window = MacLib:Window({
	Title = "Map Script",
	Subtitle = "ตัวอย่าง UI ด้วย Maclib",
	Size = UDim2.fromOffset(650, 480),
	DragStyle = 1, -- 1 = PC, 2 = Mobile
	DisabledWindowControls = {},
	ShowUserInfo = true,
	Keybind = Enum.KeyCode.RightControl,
	AcrylicBlur = true, -- หมายเหตุ: อาจถูก detect ได้
})

-- Global settings ตัวอย่าง
Window:GlobalSetting({
	Name = "UI Blur",
	Default = Window:GetAcrylicBlurState(),
	Callback = function(bool)
		Window:SetAcrylicBlurState(bool)
		Window:Notify({
			Title = "Map Script",
			Description = bool and "เปิด UI Blur แล้ว" or "ปิด UI Blur แล้ว",
			Lifetime = 3
		})
	end,
})

local tabGroup = Window:TabGroup()

local mainTab = tabGroup:Tab({
	Name = "หลัก",
	Image = "rbxassetid://18821914323" -- เปลี่ยนได้ตามต้องการ
})

local settingsTab = tabGroup:Tab({
	Name = "ตั้งค่า",
	Image = "rbxassetid://10734950309"
})

local leftSection = mainTab:Section({ Side = "Left" })

leftSection:Header({
	Name = "ฟีเจอร์หลัก"
})

leftSection:Toggle({
	Name = "เปิดฟีเจอร์ตัวอย่าง",
	Default = false,
	Callback = function(value)
		Window:Notify({
			Title = "Map Script",
			Description = value and "เปิดใช้งานแล้ว" or "ปิดใช้งานแล้ว",
			Lifetime = 3
		})
		-- ใส่ logic ของคุณตรงนี้ (ไม่รวม anti-ban/anti-kick)
	end,
}, "ExampleToggle")

leftSection:Slider({
	Name = "ความเร็ว",
	Default = 16,
	Minimum = 1,
	Maximum = 50,
	DisplayMethod = "Value",
	Precision = 0,
	Callback = function(value)
		-- ตัวอย่างเท่านั้น
		print("Speed set to:", value)
	end,
}, "SpeedSlider")

leftSection:Button({
	Name = "ทดสอบปุ่ม",
	Callback = function()
		Window:Notify({
			Title = "Map Script",
			Description = "กดปุ่มสำเร็จ",
			Lifetime = 3
		})
	end,
})

leftSection:Divider()

leftSection:Paragraph({
	Header = "คำอธิบาย",
	Body = "นี่เป็นตัวอย่างโครงสร้าง UI ด้วย Maclib เท่านั้น ไม่รวมระบบหลบแบนหรือกันเตะ"
})

-- Config section
MacLib:SetFolder("MapScriptConfigs")
settingsTab:InsertConfigSection("Left")

Window.onUnloaded(function()
	print("UI ถูกปิดแล้ว")
end)

mainTab:Select()
MacLib:LoadAutoLoadConfig()
