-- [[ NYX STORE - NINJA LEGENDS (MOBILE & PC UNIVERSAL V3) ]] --
-- Logo ID: 134813417493601
-- Theme: Neon Mint Emerald & Dark Charcoal
-- Font: LINE Seed Sans TH (with Fallback)
-- Added: Fast Auto Boss Farm (Godmode Overhead), Fast Pet EXP Booster, Auto All Pet Evolutions (Max Stats)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ลบ UI ตัวเก่าออกหากเคยรันอยู่
if game:GetService("CoreGui"):FindFirstChild("NyxStoreUniversalNinja") then
    game:GetService("CoreGui").NyxStoreUniversalNinja:Destroy()
end

-- ==================== THEME & FONTS ==================== --
local C = {
    BG = Color3.fromRGB(10, 16, 14),
    Sidebar = Color3.fromRGB(14, 24, 20),
    Card = Color3.fromRGB(18, 32, 26),
    CardInner = Color3.fromRGB(13, 22, 18),
    Border = Color3.fromRGB(32, 60, 48),
    Accent = Color3.fromRGB(43, 240, 153),
    AccentHover = Color3.fromRGB(65, 255, 175),
    Text = Color3.fromRGB(240, 255, 248),
    Muted = Color3.fromRGB(120, 165, 145),
    ToggleOff = Color3.fromRGB(28, 44, 38)
}

local function applyFont(instance, isBold)
    local weight = isBold and Enum.FontWeight.Bold or Enum.FontWeight.Medium
    local ok = pcall(function()
        instance.FontFace = Font.fromName("LINE Seed Sans TH", weight)
    end)
    if not ok or not instance.FontFace or instance.FontFace.Family == "" then
        instance.Font = isBold and Enum.Font.GothamBold or Enum.Font.GothamMedium
    end
end

-- ==================== SCREEN GUI ==================== --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NyxStoreUniversalNinja"
ScreenGui.ResetOnSpawn = false
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

-- ==================== DRAGGABLE SYSTEM ==================== --
local function makeDraggable(targetFrame, handle)
    handle = handle or targetFrame
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ==================== FLOATING LOGO TOGGLE BUTTON ==================== --
local FloatBtn = Instance.new("ImageButton")
FloatBtn.Name = "NYX_FloatToggle"
FloatBtn.Size = UDim2.new(0, 48, 0, 48)
FloatBtn.Position = UDim2.new(0, 15, 0.4, 0)
FloatBtn.BackgroundColor3 = C.Card
FloatBtn.Image = "rbxassetid://134813417493601"
FloatBtn.AutoButtonColor = false
FloatBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = C.Accent
FloatStroke.Thickness = 2
FloatStroke.Parent = FloatBtn
makeDraggable(FloatBtn)

-- ==================== MAIN WINDOW ==================== --
local Main = Instance.new("Frame")
Main.Name = "MainWindow"
Main.BackgroundColor3 = C.BG
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = C.Border
MainStroke.Thickness = 1.2
MainStroke.Parent = Main

local function updateLayoutSize()
    local vp = Camera.ViewportSize
    local isMobile = vp.X < 850 or vp.Y < 550
    if isMobile then
        local w = math.clamp(vp.X * 0.94, 310, 600)
        local h = math.clamp(vp.Y * 0.88, 260, 390)
        Main.Size = UDim2.new(0, w, 0, h)
        Main.Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2)
    else
        Main.Size = UDim2.new(0, 720, 0, 440)
        Main.Position = UDim2.new(0.5, -360, 0.5, -220)
    end
end
updateLayoutSize()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateLayoutSize)

FloatBtn.Activated:Connect(function()
    Main.Visible = not Main.Visible
end)

-- ==================== SIDEBAR ==================== --
local SidebarWidth = 160
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, SidebarWidth, 1, 0)
Sidebar.BackgroundColor3 = C.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

local EdgeFix = Instance.new("Frame")
EdgeFix.Size = UDim2.new(0, 10, 1, 0)
EdgeFix.Position = UDim2.new(1, -10, 0, 0)
EdgeFix.BackgroundColor3 = C.Sidebar
EdgeFix.BorderSizePixel = 0
EdgeFix.Parent = Sidebar

local BrandIcon = Instance.new("ImageLabel")
BrandIcon.Size = UDim2.new(0, 32, 0, 32)
BrandIcon.Position = UDim2.new(0, 10, 0, 10)
BrandIcon.BackgroundTransparency = 1
BrandIcon.Image = "rbxassetid://134813417493601"
BrandIcon.Parent = Sidebar

local BrandIconCorner = Instance.new("UICorner")
BrandIconCorner.CornerRadius = UDim.new(1, 0)
BrandIconCorner.Parent = BrandIcon

local BrandName = Instance.new("TextLabel")
BrandName.Position = UDim2.new(0, 48, 0, 10)
BrandName.Size = UDim2.new(1, -52, 0, 16)
BrandName.Text = "NYX STORE"
BrandName.TextColor3 = C.Text
BrandName.TextSize = 13
BrandName.TextXAlignment = Enum.TextXAlignment.Left
BrandName.BackgroundTransparency = 1
applyFont(BrandName, true)
BrandName.Parent = Sidebar

local BrandSub = Instance.new("TextLabel")
BrandSub.Position = UDim2.new(0, 48, 0, 26)
BrandSub.Size = UDim2.new(1, -52, 0, 14)
BrandSub.Text = "Ninja Legends"
BrandSub.TextColor3 = C.Accent
BrandSub.TextSize = 9.5
BrandSub.TextXAlignment = Enum.TextXAlignment.Left
BrandSub.BackgroundTransparency = 1
applyFont(BrandSub, false)
BrandSub.Parent = Sidebar

local NavList = Instance.new("ScrollingFrame")
NavList.Position = UDim2.new(0, 6, 0, 52)
NavList.Size = UDim2.new(1, -12, 1, -100)
NavList.BackgroundTransparency = 1
NavList.BorderSizePixel = 0
NavList.ScrollBarThickness = 2
NavList.ScrollBarImageColor3 = C.Accent
NavList.AutomaticCanvasSize = Enum.AutomaticSize.Y
NavList.Parent = Sidebar

local NavLayout = Instance.new("UIListLayout")
NavLayout.Padding = UDim.new(0, 4)
NavLayout.Parent = NavList

local UserCard = Instance.new("Frame")
UserCard.Size = UDim2.new(1, -16, 0, 40)
UserCard.Position = UDim2.new(0, 8, 1, -48)
UserCard.BackgroundColor3 = C.Card
UserCard.BorderSizePixel = 0
UserCard.Parent = Sidebar

local UserCardCorner = Instance.new("UICorner")
UserCardCorner.CornerRadius = UDim.new(0, 8)
UserCardCorner.Parent = UserCard

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0, 26, 0, 26)
Avatar.Position = UDim2.new(0, 6, 0.5, -13)
Avatar.BackgroundColor3 = C.BG
Avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
Avatar.Parent = UserCard

local AvCorner = Instance.new("UICorner")
AvCorner.CornerRadius = UDim.new(1, 0)
AvCorner.Parent = Avatar

local NameText = Instance.new("TextLabel")
NameText.Position = UDim2.new(0, 38, 0, 4)
NameText.Size = UDim2.new(1, -42, 0, 14)
NameText.Text = LocalPlayer.DisplayName
NameText.TextColor3 = C.Text
NameText.TextSize = 10
NameText.TextTruncate = Enum.TextTruncate.AtEnd
NameText.TextXAlignment = Enum.TextXAlignment.Left
NameText.BackgroundTransparency = 1
applyFont(NameText, true)
NameText.Parent = UserCard

local DeviceText = Instance.new("TextLabel")
DeviceText.Position = UDim2.new(0, 38, 0, 20)
DeviceText.Size = UDim2.new(1, -42, 0, 12)
DeviceText.Text = UserInputService.TouchEnabled and "📱 Mobile Mode" or "💻 PC Mode"
DeviceText.TextColor3 = C.Accent
DeviceText.TextSize = 9
DeviceText.TextXAlignment = Enum.TextXAlignment.Left
DeviceText.BackgroundTransparency = 1
applyFont(DeviceText, false)
DeviceText.Parent = UserCard

-- ==================== CONTENT WRAPPER ==================== --
local ContentWrapper = Instance.new("Frame")
ContentWrapper.Size = UDim2.new(1, -SidebarWidth, 1, 0)
ContentWrapper.Position = UDim2.new(0, SidebarWidth, 0, 0)
ContentWrapper.BackgroundTransparency = 1
ContentWrapper.Parent = Main

local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, 0, 0, 48)
Topbar.BackgroundTransparency = 1
Topbar.Parent = ContentWrapper
makeDraggable(Main, Topbar)

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Position = UDim2.new(0, 14, 0, 8)
HeaderTitle.Size = UDim2.new(0.7, 0, 0, 18)
HeaderTitle.Text = "Auto Farm"
HeaderTitle.TextColor3 = C.Text
HeaderTitle.TextSize = 14
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.BackgroundTransparency = 1
applyFont(HeaderTitle, true)
HeaderTitle.Parent = Topbar

local HeaderSubtitle = Instance.new("TextLabel")
HeaderSubtitle.Position = UDim2.new(0, 14, 0, 26)
HeaderSubtitle.Size = UDim2.new(0.7, 0, 0, 14)
HeaderSubtitle.Text = "ระบบฟาร์ม, ซื้อของทุกเกาะ, และขายเกาะสูงสุด"
HeaderSubtitle.TextColor3 = C.Muted
HeaderSubtitle.TextSize = 9.5
HeaderSubtitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderSubtitle.BackgroundTransparency = 1
applyFont(HeaderSubtitle, false)
HeaderSubtitle.Parent = Topbar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -34, 0, 11)
CloseBtn.BackgroundColor3 = C.Card
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(240, 85, 85)
CloseBtn.TextSize = 11
applyFont(CloseBtn, true)
CloseBtn.Parent = Topbar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.Activated:Connect(function()
    Main.Visible = false
end)

local PagesFolder = Instance.new("Folder")
PagesFolder.Name = "Pages"
PagesFolder.Parent = ContentWrapper

local tabs = {}
local function switchTab(tabName, titleText, descText)
    for name, page in pairs(tabs) do
        local isCurrent = (name == tabName)
        page.Frame.Visible = isCurrent
        TweenService:Create(page.Button, TweenInfo.new(0.18), {
            BackgroundColor3 = isCurrent and C.Card or Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = isCurrent and 0 or 1
        }):Play()
        page.Button.TextColor3 = isCurrent and C.Accent or C.Muted
        if isCurrent then
            HeaderTitle.Text = titleText
            HeaderSubtitle.Text = descText
        end
    end
end

local function createTab(tabName, iconText, titleText, descText)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 32)
    TabButton.BackgroundColor3 = C.Card
    TabButton.BackgroundTransparency = 1
    TabButton.Text = "  " .. iconText .. "  " .. tabName
    TabButton.TextColor3 = C.Muted
    TabButton.TextSize = 10.5
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    applyFont(TabButton, true)
    TabButton.Parent = NavList

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabButton

    local PageFrame = Instance.new("Frame")
    PageFrame.Name = tabName .. "_Page"
    PageFrame.Size = UDim2.new(1, -20, 1, -54)
    PageFrame.Position = UDim2.new(0, 10, 0, 48)
    PageFrame.BackgroundTransparency = 1
    PageFrame.Visible = false
    PageFrame.Parent = PagesFolder

    tabs[tabName] = {
        Button = TabButton,
        Frame = PageFrame
    }

    TabButton.Activated:Connect(function()
        switchTab(tabName, titleText, descText)
    end)
    return PageFrame
end

-- ==================== COMPONENT BUILDERS ==================== --
local function createColumnCard(parent, title, posXScale, widthScale)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(widthScale or 0.485, 0, 1, -6)
    Card.Position = UDim2.new(posXScale or 0, 0, 0, 0)
    Card.BackgroundColor3 = C.Card
    Card.BorderSizePixel = 0
    Card.Parent = parent

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 9)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = C.Border
    CardStroke.Thickness = 1
    CardStroke.Parent = Card

    local CardHeader = Instance.new("Frame")
    CardHeader.Size = UDim2.new(1, 0, 0, 28)
    CardHeader.BackgroundTransparency = 1
    CardHeader.Parent = Card

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 5, 0, 5)
    Dot.Position = UDim2.new(0, 10, 0.5, -2.5)
    Dot.BackgroundColor3 = C.Accent
    Dot.Parent = CardHeader

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot

    local CardTitle = Instance.new("TextLabel")
    CardTitle.Position = UDim2.new(0, 20, 0, 0)
    CardTitle.Size = UDim2.new(1, -25, 1, 0)
    CardTitle.Text = title
    CardTitle.TextColor3 = C.Text
    CardTitle.TextSize = 11
    CardTitle.TextXAlignment = Enum.TextXAlignment.Left
    CardTitle.BackgroundTransparency = 1
    applyFont(CardTitle, true)
    CardTitle.Parent = CardHeader

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Position = UDim2.new(0, 5, 0, 28)
    Scroll.Size = UDim2.new(1, -10, 1, -34)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 3
    Scroll.ScrollBarImageColor3 = C.Accent
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.Parent = Card

    local List = Instance.new("UIListLayout")
    List.Padding = UDim.new(0, 5)
    List.HorizontalAlignment = Enum.HorizontalAlignment.Center
    List.Parent = Scroll

    return Scroll
end

local function addToggle(parent, title, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -2, 0, 36)
    Frame.BackgroundColor3 = C.CardInner
    Frame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.Size = UDim2.new(0.68, 0, 1, 0)
    Label.Text = title
    Label.TextColor3 = C.Text
    Label.TextSize = 10
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    applyFont(Label, false)
    Label.Parent = Frame

    local Switch = Instance.new("TextButton")
    Switch.Position = UDim2.new(1, -38, 0.5, -9)
    Switch.Size = UDim2.new(0, 32, 0, 18)
    Switch.BackgroundColor3 = default and C.Accent or C.ToggleOff
    Switch.Text = ""
    Switch.AutoButtonColor = false
    Switch.Parent = Frame

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = default and UDim2.new(1, -15, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Knob.BackgroundColor3 = default and C.BG or Color3.fromRGB(150, 175, 165)
    Knob.BorderSizePixel = 0
    Knob.Parent = Switch

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local active = default
    local function toggle()
        active = not active
        callback(active)
        TweenService:Create(Switch, TweenInfo.new(0.16), {
            BackgroundColor3 = active and C.Accent or C.ToggleOff
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.16), {
            Position = active and UDim2.new(1, -15, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
            BackgroundColor3 = active and C.BG or Color3.fromRGB(150, 175, 165)
        }):Play()
    end

    Switch.Activated:Connect(toggle)
    local ClickDetector = Instance.new("TextButton")
    ClickDetector.Size = UDim2.new(1, -40, 1, 0)
    ClickDetector.BackgroundTransparency = 1
    ClickDetector.Text = ""
    ClickDetector.Parent = Frame
    ClickDetector.Activated:Connect(toggle)
end

local function addSlider(parent, title, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -2, 0, 46)
    Frame.BackgroundColor3 = C.CardInner
    Frame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Position = UDim2.new(0, 8, 0, 4)
    Label.Size = UDim2.new(0.65, 0, 0, 14)
    Label.Text = title
    Label.TextColor3 = C.Text
    Label.TextSize = 10
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    applyFont(Label, false)
    Label.Parent = Frame

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Position = UDim2.new(1, -50, 0, 4)
    ValLabel.Size = UDim2.new(0, 42, 0, 14)
    ValLabel.Text = tostring(default)
    ValLabel.TextColor3 = C.Accent
    ValLabel.TextSize = 10.5
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.BackgroundTransparency = 1
    applyFont(ValLabel, true)
    ValLabel.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -16, 0, 6)
    Bar.Position = UDim2.new(0, 8, 0, 28)
    Bar.BackgroundColor3 = Color3.fromRGB(24, 38, 32)
    Bar.BorderSizePixel = 0
    Bar.Parent = Frame

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = Bar

    local Fill = Instance.new("Frame")
    local initRatio = math.clamp((default - min) / (max - min), 0, 1)
    Fill.Size = UDim2.new(initRatio, 0, 1, 0)
    Fill.BackgroundColor3 = C.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local isDragging = false
    local function updateValue(inputX)
        local barX = Bar.AbsolutePosition.X
        local barW = Bar.AbsoluteSize.X
        local ratio = math.clamp((inputX - barX) / barW, 0, 1)
        Fill.Size = UDim2.new(ratio, 0, 1, 0)
        local value = math.floor(min + (max - min) * ratio)
        ValLabel.Text = tostring(value)
        callback(value)
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            updateValue(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input.Position.X)
        end
    end)
end

local function addButton(parent, title, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -2, 0, 32)
    Button.BackgroundColor3 = C.CardInner
    Button.Text = title
    Button.TextColor3 = C.Accent
    Button.TextSize = 10.5
    applyFont(Button, true)
    Button.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = C.Border
    Stroke.Thickness = 1
    Stroke.Parent = Button

    Button.Activated:Connect(callback)
end

local function addDropdown(parent, title, listItems, defaultItem, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -2, 0, 36)
    Container.BackgroundColor3 = C.CardInner
    Container.ClipsDescendants = true
    Container.Parent = parent

    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 7)
    ContainerCorner.Parent = Container

    local SelectedBtn = Instance.new("TextButton")
    SelectedBtn.Size = UDim2.new(1, 0, 0, 36)
    SelectedBtn.BackgroundTransparency = 1
    SelectedBtn.Text = "  " .. title .. ": " .. defaultItem
    SelectedBtn.TextColor3 = C.Text
    SelectedBtn.TextSize = 10
    SelectedBtn.TextXAlignment = Enum.TextXAlignment.Left
    applyFont(SelectedBtn, true)
    SelectedBtn.Parent = Container

    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 20, 0, 36)
    Arrow.Position = UDim2.new(1, -24, 0, 0)
    Arrow.Text = "▼"
    Arrow.TextColor3 = C.Accent
    Arrow.TextSize = 9
    Arrow.BackgroundTransparency = 1
    Arrow.Parent = Container

    local DropScroll = Instance.new("ScrollingFrame")
    DropScroll.Position = UDim2.new(0, 4, 0, 36)
    DropScroll.Size = UDim2.new(1, -8, 0, 105)
    DropScroll.BackgroundColor3 = C.BG
    DropScroll.BorderSizePixel = 0
    DropScroll.ScrollBarThickness = 3
    DropScroll.ScrollBarImageColor3 = C.Accent
    DropScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    DropScroll.Parent = Container

    local DropLayout = Instance.new("UIListLayout")
    DropLayout.Padding = UDim.new(0, 2)
    DropLayout.Parent = DropScroll

    local isOpen = false
    SelectedBtn.Activated:Connect(function()
        isOpen = not isOpen
        Arrow.Text = isOpen and "▲" or "▼"
        TweenService:Create(Container, TweenInfo.new(0.18), {
            Size = isOpen and UDim2.new(1, -2, 0, 145) or UDim2.new(1, -2, 0, 36)
        }):Play()
    end)

    for _, item in ipairs(listItems) do
        local ItemBtn = Instance.new("TextButton")
        ItemBtn.Size = UDim2.new(1, 0, 0, 24)
        ItemBtn.BackgroundColor3 = C.Card
        ItemBtn.Text = "  " .. item
        ItemBtn.TextColor3 = C.Muted
        ItemBtn.TextSize = 9.5
        ItemBtn.TextXAlignment = Enum.TextXAlignment.Left
        applyFont(ItemBtn, false)
        ItemBtn.Parent = DropScroll

        local ItemCorner = Instance.new("UICorner")
        ItemCorner.CornerRadius = UDim.new(0, 5)
        ItemCorner.Parent = ItemBtn

        ItemBtn.Activated:Connect(function()
            SelectedBtn.Text = "  " .. title .. ": " .. item
            callback(item)
            isOpen = false
            Arrow.Text = "▼"
            TweenService:Create(Container, TweenInfo.new(0.18), {
                Size = UDim2.new(1, -2, 0, 36)
            }):Play()
        end)
    end
end

-- ==================== DATA & PROGRESSION ==================== --
local Flags = {
    AutoSwing = false,
    AutoSellMax = false,
    AutoBuyAllSwords = false,
    AutoBuyAllBelts = false,
    AutoBuyAllSkills = false,
    AutoBuyNextClass = false,
    AutoFarmChi = false,
    AutoOpenCrystal = false,
    SelectedCrystal = "Blue Crystal",
    -- Boss Farming Flags
    AutoBossFarm = false,
    SelectedBoss = "All Bosses",
    BossAttackSpeed = 5,
    -- Pets & Glitch Level / Stats Flags
    FastPetLevelBoost = false,
    AutoMaxPetUpgrades = false,
    -- Movement Flags
    WalkSpeedEnabled = false,
    WalkSpeedValue = 16,
    FlyEnabled = false,
    FlySpeed = 50,
    InfJump = false
}

local BossOptions = {
    "All Bosses",
    "Robot Boss",
    "Eternal Boss",
    "Ancient Magma Boss"
}

local OrderedRanks = {
    { name = "Rookie", cost = 0 },
    { name = "Grasshopper", cost = 2e6 },
    { name = "Apprentice", cost = 1.5e8 },
    { name = "Samurai", cost = 1.1e10 },
    { name = "Assassin", cost = 8.5e11 },
    { name = "Shadow", cost = 6.3e13 },
    { name = "Ninja", cost = 4.75e14 },
    { name = "Master Ninja", cost = 3.5e15 },
    { name = "Sensei", cost = 2.6e16 },
    { name = "Master Sensei", cost = 2e17 },
    { name = "Ninja Legend", cost = 1.5e18 },
    { name = "Master Of Shadows", cost = 2.5e20 },
    { name = "Immortal Assassin", cost = 2.5e21 },
    { name = "Eternity Hunter", cost = 9.25e23 },
    { name = "Shadow Legend", cost = 2.5e26 },
    { name = "Dragon Warrior", cost = 1.5e28 },
    { name = "Dragon Master", cost = 3.5e29 },
    { name = "Chaos Sensei", cost = 5e30 },
    { name = "Chaos Legend", cost = 6e31 },
    { name = "Master Of Elements", cost = 8e32 },
    { name = "Elemental Legend", cost = 6e33 },
    { name = "Ancient Battle Master", cost = 8.5e35 },
    { name = "Ancient Battle Legend", cost = 9e36 },
    { name = "Legendary Shadow Duelist", cost = 3.5e38 },
    { name = "Master Legend Assassin", cost = 7e39 },
    { name = "Mythic Shadowmaster", cost = 7e41 },
    { name = "Legendary Shadowmaster", cost = 2.6e43 },
    { name = "Awakened Scythemaster", cost = 2e45 },
    { name = "Awakened Scythe Legend", cost = 1e47 },
    { name = "Master Legend Zephyr", cost = 7e49 },
    { name = "Golden Sun Shuriken Master", cost = 7e50 },
    { name = "Golden Sun Shuriken Legend", cost = 1e52 },
    { name = "Dark Sun Samurai Legend", cost = 9.5e54 },
    { name = "Dragon Evolution Form I", cost = 9e56 },
    { name = "Dragon Evolution Form II", cost = 1.62e58 },
    { name = "Dragon Evolution Form III", cost = 1.872e59 },
    { name = "Dragon Evolution Form IV", cost = 4e60 },
    { name = "Dragon Evolution Form V", cost = 8e61 },
    { name = "Cybernetic Electro Master", cost = 4e62 },
    { name = "Cybernetic Electro Legend", cost = 4.8e64 },
    { name = "Shadow Chaos Assassin", cost = 6.4e66 },
    { name = "Shadow Chaos Legend", cost = 2.4e68 },
    { name = "Infinity Sensei", cost = 4.8e69 },
    { name = "Infinity Legend", cost = 1.6e72 },
    { name = "Aether Genesis Master Ninja", cost = 5.6e75 }
}

local SuffixMap = {
    k = 1e3, m = 1e6, b = 1e9, t = 1e12,
    qa = 1e15, qi = 1e18, si = 1e21, sp = 1e24, oc = 1e27, n = 1e30,
    dc = 1e33, un = 1e36, duo = 1e39, tre = 1e42, qua = 1e45, qui = 1e48,
    se = 1e51, sp2 = 1e54, oc2 = 1e57, nv = 1e60, vig = 1e63, ce = 1e66,
    trv = 1e69, qtu = 1e72, spz = 1e75, cjx = 1e78, vnu = 1e81
}

local function parseNumber(val)
    if type(val) == "number" then return val end
    if type(val) ~= "string" then return 0 end
    val = val:gsub(",", ""):gsub("%s+", "")
    local num, suffix = val:match("^([%d%.]+)%s*([%a]*)$")
    if num then
        local n = tonumber(num) or 0
        if suffix and suffix ~= "" then
            local mult = SuffixMap[suffix:lower()]
            if mult then return n * mult end
        end
        return n
    end
    return tonumber(val) or 0
end

local function getPlayerCoins()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats and leaderstats:FindFirstChild("Coins") then
        return parseNumber(leaderstats.Coins.Value)
    end
    return 0
end

local function getPlayerRank()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats and leaderstats:FindFirstChild("Rank") then
        return tostring(leaderstats.Rank.Value)
    end
    return ""
end

local IslandData = {
    { name = "Ground (พื้นดิน)", cf = CFrame.new(25, 3, 130) },
    { name = "Astral Island", cf = CFrame.new(206, 2014, 237) },
    { name = "Mystic Island", cf = CFrame.new(171, 4047, 52) },
    { name = "Space Island", cf = CFrame.new(148, 5657, 73) },
    { name = "Tundra Island", cf = CFrame.new(148, 9285, 73) },
    { name = "Eternal Island", cf = CFrame.new(148, 13685, 73) },
    { name = "Sandstorm Island", cf = CFrame.new(148, 17685, 73) },
    { name = "Thunder Island", cf = CFrame.new(148, 24085, 73) },
    { name = "Ancient Inferno Island", cf = CFrame.new(148, 28285, 73) },
    { name = "Midnight Shadow Island", cf = CFrame.new(148, 33285, 73) },
    { name = "Mythical Souls Island", cf = CFrame.new(148, 39385, 73) },
    { name = "Winter Wonder Island", cf = CFrame.new(148, 46085, 73) },
    { name = "Golden Master Island", cf = CFrame.new(148, 52685, 73) },
    { name = "Dragon Legend Island", cf = CFrame.new(148, 59585, 73) },
    { name = "Cybernetic Legends Island", cf = CFrame.new(148, 66685, 73) },
    { name = "Chaos Legends Island", cf = CFrame.new(148, 74485, 73) },
    { name = "Soul Combustion Island", cf = CFrame.new(148, 82585, 73) },
    { name = "Legendary Shadow Island", cf = CFrame.new(148, 90985, 73) },
    { name = "Wonder Island", cf = CFrame.new(148, 99985, 73) },
    { name = "Midnight Island", cf = CFrame.new(148, 109985, 73) },
    { name = "Blazing Vortex Island", cf = CFrame.new(148, 120985, 73) }
}

local ShopIslands = {
    "Ground", "Astral Island", "Mystic Island", "Space Island", "Tundra Island",
    "Eternal Island", "Sandstorm Island", "Thunder Island", "Ancient Inferno Island",
    "Midnight Shadow Island", "Mythical Souls Island", "Winter Wonder Island",
    "Golden Master Island", "Dragon Legend Island", "Cybernetic Legends Island",
    "Chaos Legends Island", "Soul Combustion Island", "Legendary Shadow Island",
    "Wonder Island", "Midnight Island", "Blazing Vortex Island"
}

local CrystalsList = {
    "Blue Crystal", "Purple Crystal", "Orange Crystal", "Enchanted Crystal",
    "Astral Crystal", "Golden Crystal", "Inferno Crystal", "Galaxy Crystal",
    "Frozen Crystal", "Eternal Crystal", "Storm Crystal", "Thunder Crystal",
    "Ancient Crystal", "Midnight Shadow Crystal", "Secret Shadows Crystal",
    "Electro Legends Crystal", "Mystic Crystal", "Dragon Legend Crystal",
    "Cybernetic Legends Crystal", "Chaos Legends Crystal", "Soul Combustion Crystal",
    "Blazing Vortex Crystal"
}

local function getAllShopIslands()
    local result = {}
    local seen = {}
    if Workspace:FindFirstChild("islandUnlockParts") then
        for _, p in ipairs(Workspace.islandUnlockParts:GetChildren()) do
            if not seen[p.Name:lower()] then
                seen[p.Name:lower()] = true
                table.insert(result, p.Name)
            end
        end
    end
    for _, name in ipairs(ShopIslands) do
        if not seen[name:lower()] then
            seen[name:lower()] = true
            table.insert(result, name)
        end
    end
    return result
end

-- ==================== TABS CONTENT ==================== --
-- TAB 1: AUTO FARM & SHOP
local farmPage = createTab("Auto Farm", "⚔️", "Auto Farm & Shop", "ระบบฟาร์ม, ซื้อของทุกเกาะ, และขายเกาะสูงสุด")
local leftColFarm = createColumnCard(farmPage, "Ninja Farming (ระบบฟาร์ม)", 0, 0.485)
local rightColFarm = createColumnCard(farmPage, "Shop & Ranks (ซื้ออัตโนมัติ)", 0.515, 0.485)

addToggle(leftColFarm, "⚡ Auto Swing (ฟันดาบออโต้)", false, function(v)
    Flags.AutoSwing = v
end)

addToggle(leftColFarm, "💎 Auto Sell Max Island (ขายคูณสูงสุด)", false, function(v)
    Flags.AutoSellMax = v
end)

addToggle(leftColFarm, "☯️ Auto Farm Chi (ฟาร์มหยินหยาง)", false, function(v)
    Flags.AutoFarmChi = v
end)

addButton(leftColFarm, "🎁 Claim All Chi Chests (รับกล่อง Chi)", function()
    pcall(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and firetouchinterest then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "chest") or string.find(string.lower(obj.Name), "circleinner")) then
                    firetouchinterest(hrp, obj, 0)
                    task.wait(0.01)
                    firetouchinterest(hrp, obj, 1)
                end
            end
        end
    end)
end)

addButton(leftColFarm, "☁️ Unlock All Islands (เปิดทุกเกาะ)", function()
    pcall(function()
        if Workspace:FindFirstChild("islandUnlockParts") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            for _, part in ipairs(Workspace.islandUnlockParts:GetChildren()) do
                if part:IsA("BasePart") and firetouchinterest then
                    firetouchinterest(hrp, part, 0)
                    task.wait(0.01)
                    firetouchinterest(hrp, part, 1)
                end
            end
        end
    end)
end)

addToggle(leftColFarm, "🦘 Infinite Jump (กระโดดไม่จำกัด)", false, function(v)
    Flags.InfJump = v
end)

addToggle(rightColFarm, "👑 Auto Buy Next Class (ตังถึงซื้อเลย)", false, function(v)
    Flags.AutoBuyNextClass = v
end)

addToggle(rightColFarm, "🗡️ Auto Buy Swords (ดาบทุกเกาะ)", false, function(v)
    Flags.AutoBuyAllSwords = v
end)

addToggle(rightColFarm, "🥋 Auto Buy Belts (เข็มขัดทุกเกาะ)", false, function(v)
    Flags.AutoBuyAllBelts = v
end)

addToggle(rightColFarm, "📜 Auto Buy Skills (สกิลทุกเกาะ)", false, function(v)
    Flags.AutoBuyAllSkills = v
end)

-- TAB 2: BOSS FARM (ฟาร์มบอส ตีเร็ว ลอยตัวเหนือหัวอมตะ)
local bossPage = createTab("Boss Farm", "👹", "Auto Boss Farm", "ระบบฟาร์มบอสความเร็วสูง ตีรัวเหนือหัวบอสแบบอมตะ 100%")
local bossCol1 = createColumnCard(bossPage, "Boss Automation (ตั้งค่าบอส)", 0, 0.485)
local bossCol2 = createColumnCard(bossPage, "Quick Boss Teleport (วาร์ปบอส)", 0.515, 0.485)

addDropdown(bossCol1, "เลือกบอส", BossOptions, "All Bosses", function(selected)
    Flags.SelectedBoss = selected
end)

addToggle(bossCol1, "🔥 Auto Farm Boss (ฟาร์มบอสอัตโนมัติ)", false, function(v)
    Flags.AutoBossFarm = v
end)

addSlider(bossCol1, "Attack Burst (ความเร็วรอบตี)", 1, 10, 5, function(val)
    Flags.BossAttackSpeed = val
end)

-- TAB 3: PETS & STATS BOOSTER (สุ่มสัตว์, เร่งเวลตันไว, อัปเกรดสเตตัสสูงสุด)
local petPage = createTab("Pets & Stats", "🐾", "Pets & Stats Boost", "สุ่มไข่, เร่ง EXP สัตว์ตันไว, และอัปเกรดสเตตัสขั้นสูงสุด")
local petCol1 = createColumnCard(petPage, "Crystal Selector (เลือกตู้สุ่ม)", 0, 0.485)
local petCol2 = createColumnCard(petPage, "Stats & Level Glitch (อัปสเตตัส)", 0.515, 0.485)

addDropdown(petCol1, "ตู้ที่เลือก", CrystalsList, "Blue Crystal", function(selected)
    Flags.SelectedCrystal = selected
end)

addToggle(petCol1, "✨ Auto Open Crystal (เปิดตู้อัตโนมัติ)", false, function(v)
    Flags.AutoOpenCrystal = v
end)

addToggle(petCol2, "🚀 Fast Pet Level Boost (เร่ง EXP สัตว์ตัน)", false, function(v)
    Flags.FastPetLevelBoost = v
end)

addToggle(petCol2, "👑 Auto Max Upgrades (วนอัปสเตตัสสูงสุด)", false, function(v)
    Flags.AutoMaxPetUpgrades = v
end)

addButton(petCol2, "🧬 Auto Evolve Pets (ขั้นวิวัฒนาการ)", function()
    pcall(function()
        if LocalPlayer:FindFirstChild("ninjaEvent") then
            LocalPlayer.ninjaEvent:FireServer("autoEvolvePets")
        end
    end)
end)

addButton(petCol2, "🔮 Auto Eternalize Pets (ขั้นนิรันดร์)", function()
    pcall(function()
        if LocalPlayer:FindFirstChild("ninjaEvent") then
            LocalPlayer.ninjaEvent:FireServer("autoEternalizePets")
        end
    end)
end)

addButton(petCol2, "⚡ Auto Immortalize Pets (ขั้นอมตะ)", function()
    pcall(function()
        if LocalPlayer:FindFirstChild("ninjaEvent") then
            LocalPlayer.ninjaEvent:FireServer("autoImmortalizePets")
        end
    end)
end)

addButton(petCol2, "🌟 Auto Legend Pets (ขั้นตำนาน)", function()
    pcall(function()
        if LocalPlayer:FindFirstChild("ninjaEvent") then
            LocalPlayer.ninjaEvent:FireServer("autoLegendPets")
        end
    end)
end)

addButton(petCol2, "🔥 Auto Elementalize Pets (ขั้นมหาธาตุ)", function()
    pcall(function()
        if LocalPlayer:FindFirstChild("ninjaEvent") then
            LocalPlayer.ninjaEvent:FireServer("autoElementalizePets")
        end
    end)
end)

-- TAB 4: TELEPORT ISLANDS
local tpPage = createTab("Teleport", "🌌", "Island Teleport", "เทเลพอร์ตไปยังเกาะต่างๆ ทันที")
local tpCol1 = createColumnCard(tpPage, "Lower & Mid (เกาะ 1 - 10)", 0, 0.485)
local tpCol2 = createColumnCard(tpPage, "High & Legendary (เกาะระดับสูง)", 0.515, 0.485)

local function teleportToIsland(cf, islandName)
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local targetPart = nil
            if Workspace:FindFirstChild("islandUnlockParts") then
                for _, p in ipairs(Workspace.islandUnlockParts:GetChildren()) do
                    if string.find(string.lower(p.Name), string.lower(islandName)) then
                        targetPart = p
                        break
                    end
                end
            end
            if targetPart then
                hrp.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
            else
                hrp.CFrame = cf + Vector3.new(0, 5, 0)
            end
        end
    end)
end

for idx, data in ipairs(IslandData) do
    local targetCol = (idx <= 10) and tpCol1 or tpCol2
    addButton(targetCol, "📍 " .. data.name, function()
        teleportToIsland(data.cf, data.name)
    end)
end

-- TAB 5: MOVEMENT & FLY
local movePage = createTab("Movement", "⚡", "Speed & Fly Hacks", "ระบบปรับความเร็วการเดิน และบินปรับสปีดได้")
local moveCol1 = createColumnCard(movePage, "WalkSpeed (เดินเร็ว)", 0, 0.485)
local moveCol2 = createColumnCard(movePage, "Fly System (ระบบบิน)", 0.515, 0.485)

addToggle(moveCol1, "🏃 Enable WalkSpeed (เปิดเดินเร็ว)", false, function(v)
    Flags.WalkSpeedEnabled = v
    if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
    end
end)

addSlider(moveCol1, "Speed Multiplier", 16, 350, 16, function(val)
    Flags.WalkSpeedValue = val
    if Flags.WalkSpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val
    end
end)

addToggle(moveCol2, "🕊️ Enable Fly (เปิดระบบบิน)", false, function(v)
    Flags.FlyEnabled = v
end)

addSlider(moveCol2, "Fly Speed", 20, 300, 50, function(val)
    Flags.FlySpeed = val
end)

-- ==================== BACKGROUND ENGINES ==================== --

-- 1. Auto Swing (ฟันดาบ)
task.spawn(function()
    while true do
        if Flags.AutoSwing then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if not tool then
                        local backpackTool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                        if backpackTool then
                            backpackTool.Parent = char
                        end
                    end
                    if LocalPlayer:FindFirstChild("ninjaEvent") then
                        LocalPlayer.ninjaEvent:FireServer("swingKatana")
                    end
                end
            end)
        end
        task.wait(0.08)
    end
end)

-- 2. Auto Sell Max (ขายที่จุดคูณสูงที่สุด)
local function getMaxSellCircle()
    local bestCircle = nil
    local maxY = -99999
    pcall(function()
        if Workspace:FindFirstChild("sellAreaCircles") then
            for _, circle in ipairs(Workspace.sellAreaCircles:GetChildren()) do
                local inner = circle:FindFirstChild("circleInner")
                if inner and inner:IsA("BasePart") then
                    if inner.Position.Y > maxY then
                        maxY = inner.Position.Y
                        bestCircle = inner
                    end
                end
            end
        end
    end)
    return bestCircle
end

task.spawn(function()
    while true do
        if Flags.AutoSellMax then
            pcall(function()
                local circle = getMaxSellCircle()
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if circle and hrp and firetouchinterest then
                    firetouchinterest(hrp, circle, 0)
                    task.wait(0.01)
                    firetouchinterest(hrp, circle, 1)
                end
            end)
        end
        task.wait(0.35)
    end
end)

-- 3. Auto Farm Chi (ฟาร์มหยินหยาง)
task.spawn(function()
    while true do
        if Flags.AutoFarmChi then
            pcall(function()
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and firetouchinterest then
                    if Workspace:FindFirstChild("spawnedCoins") then
                        for _, obj in ipairs(Workspace.spawnedCoins:GetDescendants()) do
                            if not Flags.AutoFarmChi then break end
                            if obj:IsA("BasePart") then
                                local parentName = obj.Parent and obj.Parent.Name or ""
                                if string.find(string.lower(obj.Name), "chi") or string.find(string.lower(parentName), "chi") then
                                    firetouchinterest(hrp, obj, 0)
                                    task.wait()
                                    firetouchinterest(hrp, obj, 1)
                                end
                            end
                        end
                    end

                    if Workspace:FindFirstChild("Hoops") then
                        for _, hoop in ipairs(Workspace.Hoops:GetChildren()) do
                            if not Flags.AutoFarmChi then break end
                            local touchPart = hoop:FindFirstChild("touchPart") or hoop:FindFirstChildWhichIsA("BasePart")
                            if touchPart then
                                firetouchinterest(hrp, touchPart, 0)
                                task.wait()
                                firetouchinterest(hrp, touchPart, 1)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.4)
    end
end)

-- 4. Auto Buy Next Class (ตังถึงซื้อเลย)
task.spawn(function()
    while true do
        if Flags.AutoBuyNextClass then
            pcall(function()
                if LocalPlayer:FindFirstChild("ninjaEvent") then
                    local currentCoins = getPlayerCoins()
                    local currentRank = getPlayerRank()
                    
                    local currentIndex = 0
                    for idx, rankInfo in ipairs(OrderedRanks) do
                        if string.lower(rankInfo.name) == string.lower(currentRank) then
                            currentIndex = idx
                            break
                        end
                    end

                    local nextRank = OrderedRanks[currentIndex + 1]
                    if nextRank then
                        if currentCoins >= nextRank.cost then
                            LocalPlayer.ninjaEvent:FireServer("buyRank", nextRank.name)
                        end
                    else
                        for _, r in ipairs(OrderedRanks) do
                            if currentCoins >= r.cost and r.cost > 0 then
                                LocalPlayer.ninjaEvent:FireServer("buyRank", r.name)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

-- 5. Auto Buy Swords ทุกเกาะ
task.spawn(function()
    while true do
        if Flags.AutoBuyAllSwords then
            pcall(function()
                if LocalPlayer:FindFirstChild("ninjaEvent") then
                    local islands = getAllShopIslands()
                    for _, island in ipairs(islands) do
                        if not Flags.AutoBuyAllSwords then break end
                        LocalPlayer.ninjaEvent:FireServer("buyAllSwords", island)
                        task.wait(0.04)
                    end
                end
            end)
        end
        task.wait(0.8)
    end
end)

-- 6. Auto Buy Belts ทุกเกาะ
task.spawn(function()
    while true do
        if Flags.AutoBuyAllBelts then
            pcall(function()
                if LocalPlayer:FindFirstChild("ninjaEvent") then
                    local islands = getAllShopIslands()
                    for _, island in ipairs(islands) do
                        if not Flags.AutoBuyAllBelts then break end
                        LocalPlayer.ninjaEvent:FireServer("buyAllBelts", island)
                        task.wait(0.04)
                    end
                end
            end)
        end
        task.wait(0.8)
    end
end)

-- 7. Auto Buy Skills ทุกเกาะ
task.spawn(function()
    while true do
        if Flags.AutoBuyAllSkills then
            pcall(function()
                if LocalPlayer:FindFirstChild("ninjaEvent") then
                    local islands = getAllShopIslands()
                    for _, island in ipairs(islands) do
                        if not Flags.AutoBuyAllSkills then break end
                        LocalPlayer.ninjaEvent:FireServer("buyAllSkills", island)
                        task.wait(0.04)
                    end
                end
            end)
        end
        task.wait(1)
    end
end)

-- 8. Auto Open Selected Crystal
task.spawn(function()
    while true do
        if Flags.AutoOpenCrystal then
            pcall(function()
                if LocalPlayer:FindFirstChild("ninjaEvent") and Flags.SelectedCrystal then
                    LocalPlayer.ninjaEvent:FireServer("openCrystal", Flags.SelectedCrystal)
                end
            end)
        end
        task.wait(0.65)
    end
end)

-- ==================== BOSS FARM ENGINE ==================== --
local function findBossModel(name)
    local targetNames = {}
    if name == "Robot Boss" then
        targetNames = { "robotboss", "robot" }
    elseif name == "Eternal Boss" then
        targetNames = { "eternalboss", "eternal" }
    elseif name == "Ancient Magma Boss" then
        targetNames = { "ancientmagmaboss", "magmaboss", "ancientboss" }
    end

    local function checkMatch(obj)
        if obj:IsA("Model") then
            local objName = string.lower(obj.Name)
            for _, t in ipairs(targetNames) do
                if string.find(objName, t) then
                    return true
                end
            end
        end
        return false
    end

    if Workspace:FindFirstChild("bossFolder") then
        for _, b in ipairs(Workspace.bossFolder:GetChildren()) do
            if checkMatch(b) then return b end
        end
    end
    for _, b in ipairs(Workspace:GetChildren()) do
        if checkMatch(b) then return b end
    end
    return nil
end

local function getTargetBoss()
    if Flags.SelectedBoss == "All Bosses" then
        local order = { "Ancient Magma Boss", "Eternal Boss", "Robot Boss" }
        for _, bName in ipairs(order) do
            local model = findBossModel(bName)
            if model then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    return model
                end
            end
        end
        return nil
    else
        local model = findBossModel(Flags.SelectedBoss)
        if model then
            local hum = model:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                return model
            end
        end
        return nil
    end
end

-- Boss TP Buttons in UI
addButton(bossCol2, "📍 TP to Robot Boss", function()
    local b = findBossModel("Robot Boss")
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if b and hrp then
        local bHrp = b:FindFirstChild("HumanoidRootPart") or b:FindFirstChildWhichIsA("BasePart")
        if bHrp then hrp.CFrame = bHrp.CFrame + Vector3.new(0, 15, 0) end
    end
end)

addButton(bossCol2, "📍 TP to Eternal Boss", function()
    local b = findBossModel("Eternal Boss")
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if b and hrp then
        local bHrp = b:FindFirstChild("HumanoidRootPart") or b:FindFirstChildWhichIsA("BasePart")
        if bHrp then hrp.CFrame = bHrp.CFrame + Vector3.new(0, 15, 0) end
    end
end)

addButton(bossCol2, "📍 TP to Magma Boss", function()
    local b = findBossModel("Ancient Magma Boss")
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if b and hrp then
        local bHrp = b:FindFirstChild("HumanoidRootPart") or b:FindFirstChildWhichIsA("BasePart")
        if bHrp then hrp.CFrame = bHrp.CFrame + Vector3.new(0, 15, 0) end
    end
end)

-- Main Boss Loop (ฟาร์มเร็ว ตีรัว ลอยตัวเหนือหัวบอสแบบอมตะ 100%)
task.spawn(function()
    while true do
        if Flags.AutoBossFarm then
            pcall(function()
                local boss = getTargetBoss()
                local char = LocalPlayer.Character
                if boss and char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    local bHrp = boss:FindFirstChild("HumanoidRootPart") or boss:FindFirstChild("UpperTorso") or boss:FindFirstChild("Head") or boss:FindFirstChildWhichIsA("BasePart")
                    
                    if bHrp then
                        -- ล็อกตำแหน่งลอยเหนือหัวบอส 14 studs เพื่อให้ไม่โดนดาเมจตีสวน
                        hrp.CFrame = CFrame.new(bHrp.Position + Vector3.new(0, 14, 0), bHrp.Position)
                        hrp.Velocity = Vector3.new(0, 0, 0)

                        -- ถืออาวุธอัตโนมัติ
                        local tool = char:FindFirstChildOfClass("Tool")
                        if not tool then
                            local backpackTool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            if backpackTool then backpackTool.Parent = char end
                        end

                        -- ยิงคำสั่งโจมตีรัวๆ ตามระดับ Attack Burst
                        if LocalPlayer:FindFirstChild("ninjaEvent") then
                            for _ = 1, math.clamp(Flags.BossAttackSpeed, 1, 10) do
                                LocalPlayer.ninjaEvent:FireServer("swingKatana")
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.06)
    end
end)

-- ==================== PET EXP & STATS BOOST ENGINE ==================== --
-- เร่งเลเวลสัตว์เลี้ยงตันไว: ยิงคำสั่งแกว่งดาบและกิน Chi รัวๆ เพื่อปั๊ม EXP ให้สัตว์ที่ใส่อยู่เลเวล 100 ไวที่สุด
task.spawn(function()
    while true do
        if Flags.FastPetLevelBoost then
            pcall(function()
                local char = LocalPlayer.Character
                if char and LocalPlayer:FindFirstChild("ninjaEvent") then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if not tool then
                        local backpackTool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                        if backpackTool then backpackTool.Parent = char end
                    end
                    for _ = 1, 4 do
                        LocalPlayer.ninjaEvent:FireServer("swingKatana")
                    end
                end
            end)
        end
        task.wait(0.05)
    end
end)

-- วนอัปเกรดเลื่อนขั้นสเตตัสสัตว์เลี้ยงทุกระดับอัตโนมัติ (Evolve -> Eternal -> Immortal -> Legend -> Elemental)
task.spawn(function()
    while true do
        if Flags.AutoMaxPetUpgrades then
            pcall(function()
                if LocalPlayer:FindFirstChild("ninjaEvent") then
                    LocalPlayer.ninjaEvent:FireServer("autoEvolvePets")
                    task.wait(0.1)
                    LocalPlayer.ninjaEvent:FireServer("autoEternalizePets")
                    task.wait(0.1)
                    LocalPlayer.ninjaEvent:FireServer("autoImmortalizePets")
                    task.wait(0.1)
                    LocalPlayer.ninjaEvent:FireServer("autoLegendPets")
                    task.wait(0.1)
                    LocalPlayer.ninjaEvent:FireServer("autoElementalizePets")
                end
            end)
        end
        task.wait(1.5)
    end
end)

-- ==================== MOVEMENT ENGINE ==================== --
RunService.Stepped:Connect(function()
    if Flags.WalkSpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Flags.WalkSpeedValue
    end
end)

local flyBV, flyBG
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChildOfClass("Humanoid") then return end
    local hrp = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid")

    if Flags.FlyEnabled then
        if not flyBV or flyBV.Parent ~= hrp then
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBV.Velocity = Vector3.new(0, 0, 0)
            flyBV.Parent = hrp
        end
        if not flyBG or flyBG.Parent ~= hrp then
            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBG.CFrame = hrp.CFrame
            flyBG.Parent = hrp
        end

        hum.PlatformStand = true
        local cam = Workspace.CurrentCamera
        local moveDir = hum.MoveDirection

        if moveDir.Magnitude > 0 then
            flyBV.Velocity = (cam.CFrame.LookVector * (moveDir.Z < 0 and 1 or (moveDir.Z > 0 and -1 or 0))
                + cam.CFrame.RightVector * (moveDir.X > 0 and 1 or (moveDir.X < 0 and -1 or 0))).Unit * Flags.FlySpeed
        else
            flyBV.Velocity = Vector3.new(0, 0, 0)
        end
        flyBG.CFrame = cam.CFrame
    else
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
        hum.PlatformStand = false
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Flags.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- เปิดแท็บแรกเป็นค่าเริ่มต้น
switchTab("Auto Farm", "Auto Farm & Shop", "ฟาร์มดาบ, หยินหยาง (Chi), ซื้อทุกเกาะ และขายเกาะสูงสุด")
