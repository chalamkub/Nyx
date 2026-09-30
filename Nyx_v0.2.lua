local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- โหลดไลบรารี
local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()

-- 1. สร้างหน้าต่างหลัก
local Window = MacLib:Window({
    Title = "NYX BLOX HUB",
    Subtitle = "Blade Ball Interface",
    Size = UDim2.fromOffset(600, 450), -- ปรับขนาดให้เล็กลงนิดหน่อยเพื่อให้พอดีกับจอมือถือ
    DragAndClose = false,
    Color = Color3.fromRGB(57, 255, 20),
    LoadText = "Loading NYX HUB..."
})

-- 2. สร้างกลุ่ม Tab และหมวดหมู่
local TabGroup = Window:TabGroup()
local CombatTab = TabGroup:Tab({ Name = "Combat", Icon = "rbxassetid://10888331510" })
local ParrySection = CombatTab:Section({ Name = "Auto Parry System" })

ParrySection:Toggle({
    Name = "Enable Auto Parry",
    Description = "Automatically blocks the ball when it targets you.",
    Default = false,
    Callback = function(state)
        print("Auto Parry state: ", state)
    end
})

ParrySection:Slider({
    Name = "Parry Distance",
    Description = "Adjust distance for parrying.",
    Default = 15,
    Minimum = 5,
    Maximum = 50,
    Callback = function(value)
        print("Parry Distance: ", value)
    end
})

-- 3. โหลด UI
MacLib:SetFolder("NYX_BladeBall")
Window:Notify({
    Title = "Loaded",
    Description = "Support PC & Mobile!",
    Lifetime = 3
})

-- ==========================================
-- ระบบปุ่มลอยสำหรับมือถือ (Mobile Toggle)
-- ==========================================

-- เช็คว่าเป็นมือถือ (มีระบบ Touch และไม่มี Keyboard แบบ Hardware)
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NYX_MobileToggle"
    -- พยายามใส่ใน CoreGui เพื่อป้องกันสคริปต์กันโปรของเกมลบ
    local success = pcall(function() ScreenGui.Parent = CoreGui end)
    if not success then ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") end

    -- สร้างปุ่มเปิด/ปิด
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = ScreenGui
    ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ToggleBtn.Text = "NYX"
    ToggleBtn.TextColor3 = Color3.fromRGB(57, 255, 20)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 14
    ToggleBtn.BorderSizePixel = 2
    ToggleBtn.BorderColor3 = Color3.fromRGB(57, 255, 20)
    
    -- ทำให้ปุ่มเป็นวงกลม
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = ToggleBtn

    -- สคริปต์สำหรับกดเปิด/ปิด UI Maclib
    -- หมายเหตุ: Maclib มักจะผูกปุ่ม RightControl ไว้ซ่อน UI เราจะจำลองการกด หรือสั่งผ่านฟังก์ชัน
    ToggleBtn.MouseButton1Click:Connect(function()
        -- สำหรับ Maclib ถ้าไม่มี API Toggle ให้ใช้ VirtualInput กดปุ่ม RightControl แทน
        local vim = game:GetService("VirtualInputManager")
        vim:SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
        vim:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
    end)

    -- สคริปต์ลากปุ่ม (Draggable)
    local dragging, dragInput, dragStart, startPos
    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = ToggleBtn.Position
        end
    end)
    ToggleBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta = input.Position - dragStart
                ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
end
