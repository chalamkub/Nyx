--[[
    Blox Fruits GUI Template (Roblox Lua)
    - โลโก้: rbxassetid://134813417493601
    - ปุ่มเปิด/ปิด GUI (ลอยอยู่มุมจอ) + ปุ่ม Toggle ในเมนู
    - ใส่โค้ดฟีเจอร์ของคุณเองได้ในส่วน FEATURES

    วิธีใช้: วางไว้ใน StarterPlayerScripts (LocalScript) ของเกม/แมพของคุณ
    หมายเหตุ: สคริปต์นี้เป็นโครง UI ที่ทำงานได้จริง ไม่มีโค้ดโกงเกมของผู้อื่น
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local LOGO_ID = "rbxassetid://134813417493601"

----------------------------------------------------------------
-- THEME
----------------------------------------------------------------
local THEME = {
    bg       = Color3.fromRGB(18, 20, 28),
    panel    = Color3.fromRGB(26, 29, 40),
    stroke   = Color3.fromRGB(58, 64, 84),
    accent   = Color3.fromRGB(0, 200, 160),
    off      = Color3.fromRGB(70, 75, 95),
    text     = Color3.fromRGB(235, 238, 245),
    subtext  = Color3.fromRGB(150, 158, 178),
}

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or THEME.stroke
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

----------------------------------------------------------------
-- ROOT
----------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "BloxFruitsHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- ปุ่มเปิด/ปิดเมนู (ไอคอนโลโก้ลอยอยู่)
local openBtn = Instance.new("ImageButton")
openBtn.Name = "OpenButton"
openBtn.Size = UDim2.fromOffset(54, 54)
openBtn.Position = UDim2.new(0, 20, 0.5, -27)
openBtn.BackgroundColor3 = THEME.panel
openBtn.Image = LOGO_ID
openBtn.ScaleType = Enum.ScaleType.Fit
openBtn.AutoButtonColor = true
openBtn.Parent = gui
corner(openBtn, 14)
stroke(openBtn, THEME.accent, 1.5)

-- หน้าต่างหลัก
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(380, 300)
main.Position = UDim2.new(0.5, -190, 0.5, -150)
main.BackgroundColor3 = THEME.bg
main.BorderSizePixel = 0
main.Visible = false
main.Active = true
main.Draggable = true -- ลากย้ายได้
main.Parent = gui
corner(main, 14)
stroke(main)

-- แถบหัว + โลโก้
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 56)
header.BackgroundColor3 = THEME.panel
header.BorderSizePixel = 0
header.Parent = main
corner(header, 14)

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 14)
headerFix.Position = UDim2.new(0, 0, 1, -14)
headerFix.BackgroundColor3 = THEME.panel
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.fromOffset(36, 36)
logo.Position = UDim2.new(0, 12, 0, 10)
logo.BackgroundTransparency = 1
logo.Image = LOGO_ID
logo.ScaleType = Enum.ScaleType.Fit
logo.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -110, 0, 22)
title.Position = UDim2.new(0, 58, 0, 10)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = THEME.text
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "BLOX FRUITS HUB"
title.Parent = header

local subtitle = title:Clone()
subtitle.Size = UDim2.new(1, -110, 0, 16)
subtitle.Position = UDim2.new(0, 58, 0, 31)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 12
subtitle.TextColor3 = THEME.subtext
subtitle.Text = "v1.0 • กด RightShift เพื่อเปิด/ปิด"
subtitle.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 13)
closeBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 66)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = THEME.text
closeBtn.Text = "X"
closeBtn.Parent = header
corner(closeBtn, 8)

-- พื้นที่เนื้อหา (เลื่อนได้)
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -20, 1, -72)
content.Position = UDim2.new(0, 10, 0, 64)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = THEME.accent
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = main

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 8)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = content

----------------------------------------------------------------
-- TOGGLE COMPONENT
----------------------------------------------------------------
local function createToggle(name, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = THEME.panel
    row.BorderSizePixel = 0
    row.Parent = content
    corner(row, 10)
    stroke(row)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextColor3 = THEME.text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = name
    label.Parent = row

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.fromOffset(46, 24)
    switch.Position = UDim2.new(1, -60, 0.5, -12)
    switch.BackgroundColor3 = default and THEME.accent or THEME.off
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.Parent = row
    corner(switch, 12)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18, 18)
    knob.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = switch
    corner(knob, 9)

    local state = default
    local function render()
        TweenService:Create(switch, TweenInfo.new(0.15), {
            BackgroundColor3 = state and THEME.accent or THEME.off,
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        }):Play()
    end

    switch.MouseButton1Click:Connect(function()
        state = not state
        render()
        local ok, err = pcall(callback, state)
        if not ok then warn("[Hub] " .. name .. ": " .. tostring(err)) end
    end)

    if default then
        task.spawn(function() pcall(callback, true) end)
    end

    return {
        Set = function(v) state = v; render(); pcall(callback, v) end,
        Get = function() return state end,
    }
end

local function createButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = THEME.panel
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextColor3 = THEME.text
    btn.Text = name
    btn.Parent = content
    corner(btn, 10)
    stroke(btn)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

----------------------------------------------------------------
-- OPEN / CLOSE
----------------------------------------------------------------
local function setOpen(open)
    if open then
        main.Visible = true
        main.Size = UDim2.fromOffset(380, 0)
        TweenService:Create(main, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {
            Size = UDim2.fromOffset(380, 300),
        }):Play()
    else
        local t = TweenService:Create(main, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
            Size = UDim2.fromOffset(380, 0),
        })
        t.Completed:Connect(function() main.Visible = false end)
        t:Play()
    end
end

openBtn.MouseButton1Click:Connect(function() setOpen(not main.Visible) end)
closeBtn.MouseButton1Click:Connect(function() setOpen(false) end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        setOpen(not main.Visible)
    end
end)

----------------------------------------------------------------
-- FEATURES (ใส่โค้ดของคุณในนี้)
----------------------------------------------------------------
local character = player.Character or player.CharacterAdded:Wait()
player.CharacterAdded:Connect(function(c) character = c end)

local function humanoid()
    return character and character:FindFirstChildOfClass("Humanoid")
end

-- ตัวอย่าง 1: เดินเร็ว (ทำงานในแมพที่คุณเป็นเจ้าของ)
local walkLoop
createToggle("Walk Speed x2", false, function(on)
    if walkLoop then walkLoop:Disconnect(); walkLoop = nil end
    local h = humanoid()
    if on then
        walkLoop = RunService.Heartbeat:Connect(function()
            local hh = humanoid()
            if hh then hh.WalkSpeed = 32 end
        end)
    elseif h then
        h.WalkSpeed = 16
    end
end)

-- ตัวอย่าง 2: กระโดดสูง
createToggle("High Jump", false, function(on)
    local h = humanoid()
    if h then h.JumpPower = on and 100 or 50 end
end)

-- ตัวอย่าง 3: ปุ่มกด
createButton("Reset Character", function()
    local h = humanoid()
    if h then h.Health = 0 end
end)

-- เพิ่มฟีเจอร์เพิ่มเติมได้ตามต้องการ:
-- createToggle("ชื่อฟีเจอร์", false, function(on) --[[ โค้ดของคุณ ]] end)
-- createButton("ชื่อปุ่ม", function() --[[ โค้ดของคุณ ]] end)

print("[Blox Fruits Hub] โหลดสำเร็จ — กด RightShift หรือไอคอนโลโก้เพื่อเปิดเมนู")
