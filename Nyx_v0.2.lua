-- [[ Nexus Hub - Fisch System Script ]] --
-- รองรับการปรับแต่ง Logo, คีย์ลัดเปิด/ปิดเมนู, และฟังก์ชันพื้นฐาน

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // CONFIGURATION // --
local CONFIG = {
    HubName = "NYX HUB - FISCH",
    LogoId = "rbxassetid://134813417493601", -- เปลี่ยนเป็น Asset ID โลโก้ของคุณได้ที่นี่
    ToggleKey = Enum.KeyCode.RightControl, -- ปุ่มเปิด/ปิดเมนู
    AutoCast = false,
    AutoShake = false,
    AutoReel = false,
    FishESP = false
}

-- // CREATE SCREEN GUI // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexusHub_Fisch"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- // FLOATING TOGGLE BUTTON // --
local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name = "LogoToggleButton"
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ToggleBtn.Image = CONFIG.LogoId
ToggleBtn.Parent = ScreenGui

local ToggleBtnCorner = Instance.new("UICorner")
ToggleBtnCorner.CornerRadius = UDim.new(0, 12)
ToggleBtnCorner.Parent = ToggleBtn

local ToggleBtnStroke = Instance.new("UIStroke")
ToggleBtnStroke.Color = Color3.fromRGB(0, 170, 255)
ToggleBtnStroke.Thickness = 2
ToggleBtnStroke.Parent = ToggleBtn

-- // MAIN FRAME // --
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 55)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- // TOP BAR // --
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local HubLogo = Instance.new("ImageLabel")
HubLogo.Name = "HubLogo"
HubLogo.Size = UDim2.new(0, 32, 0, 32)
HubLogo.Position = UDim2.new(0, 10, 0, 6)
HubLogo.BackgroundTransparency = 1
HubLogo.Image = CONFIG.LogoId
HubLogo.Parent = TopBar

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 6)
LogoCorner.Parent = HubLogo

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0, 250, 1, 0)
Title.Position = UDim2.new(0, 50, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = CONFIG.HubName
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- // DRAGGABLE LOGIC // --
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- // CONTENT LIST // --
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Name = "ContentScroll"
ContentScroll.Size = UDim2.new(1, -20, 1, -55)
ContentScroll.Position = UDim2.new(0, 10, 0, 50)
ContentScroll.BackgroundTransparency = 1
ContentScroll.ScrollBarThickness = 4
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 350)
ContentScroll.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ContentScroll

-- // FUNCTION HELPER: CREATE TOGGLE // --
local function CreateToggle(name, defaultState, callback)
    local state = defaultState
    local Button = Instance.new("TextButton")
    Button.Name = name .. "Toggle"
    Button.Size = UDim2.new(1, -10, 0, 42)
    Button.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    Button.AutoButtonColor = false
    Button.Text = ""
    Button.Parent = ContentScroll

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamMedium
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Button

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 44, 0, 22)
    Indicator.Position = UDim2.new(1, -54, 0.5, -11)
    Indicator.BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 60)
    Indicator.Parent = Button

    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(1, 0)
    IndCorner.Parent = Indicator

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 16, 0, 16)
    Dot.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dot.Parent = Indicator

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot

    Button.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 60)
        local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)

        TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = targetPos}):Play()

        callback(state)
    end)
end

-- // CREATE TOGGLES // --
CreateToggle("Auto Cast (เหวี่ยงเบ็ดอัตโนมัติ)", CONFIG.AutoCast, function(val)
    CONFIG.AutoCast = val
    if val then
        task.spawn(function()
            while CONFIG.AutoCast do
                local char = LocalPlayer.Character
                local rod = char and char:FindFirstChildOfClass("Tool")
                if rod and rod:FindFirstChild("values") and rod.values:FindFirstChild("casted") then
                    if not rod.values.casted.Value then
                        rod:Activate()
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

CreateToggle("Auto Shake (เขย่าเบ็ดอัตโนมัติ)", CONFIG.AutoShake, function(val)
    CONFIG.AutoShake = val
    if val then
        task.spawn(function()
            while CONFIG.AutoShake do
                local shakeUI = PlayerGui:FindFirstChild("shake") or PlayerGui:FindFirstChild("ShakeUI")
                if shakeUI and shakeUI.Enabled then
                    local button = shakeUI:FindFirstChildWhichIsA("ImageButton", true)
                    if button and button.Visible then
                        pcall(function()
                            button.Position = UDim2.new(0.5, 0, 0.5, 0)
                            VirtualInputManager:SendMouseButtonEvent(button.AbsolutePosition.X + 10, button.AbsolutePosition.Y + 10, 0, true, game, 0)
                            VirtualInputManager:SendMouseButtonEvent(button.AbsolutePosition.X + 10, button.AbsolutePosition.Y + 10, 0, false, game, 0)
                        end)
                    end
                end
                task.wait(0.05)
            end
        end)
    end
end)

CreateToggle("Auto Reel (ดึงปลาอัตโนมัติ)", CONFIG.AutoReel, function(val)
    CONFIG.AutoReel = val
    if val then
        task.spawn(function()
            while CONFIG.AutoReel do
                local reelUI = PlayerGui:FindFirstChild("reel") or PlayerGui:FindFirstChild("ReelUI")
                if reelUI and reelUI.Enabled then
                    local bar = reelUI:FindFirstChild("Bar", true)
                    local target = reelUI:FindFirstChild("Fish", true)
                    if bar and target then
                        bar.Position = target.Position
                    end
                end
                task.wait(0.05)
            end
        end)
    end
end)

CreateToggle("Fishing Zone ESP (แสดงจุดตกปลา)", CONFIG.FishESP, function(val)
    CONFIG.FishESP = val
    local zones = workspace:FindFirstChild("zones") or workspace:FindFirstChild("FishingSpots")
    if zones then
        for _, zone in pairs(zones:GetChildren()) do
            if zone:IsA("BasePart") then
                local highlight = zone:FindFirstChild("ZoneESP")
                if val and not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ZoneESP"
                    highlight.FillColor = Color3.fromRGB(0, 170, 255)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Parent = zone
                elseif not val and highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end)

-- // TOGGLE MENU VISIBILITY // --
local function ToggleMenu()
    MainFrame.Visible = not MainFrame.Visible
end

CloseBtn.MouseButton1Click:Connect(ToggleMenu)
ToggleBtn.MouseButton1Click:Connect(ToggleMenu)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == CONFIG.ToggleKey then
        ToggleMenu()
    end
end)

print("[Nexus Hub]: Fisch Script Loaded Successfully!")
