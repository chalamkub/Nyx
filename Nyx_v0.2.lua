--// Open Sea For Animals
--// UI VERSION
--// Tabs / dropdowns / toggles / sliders are UI-only.
--// No Auto Farm, Teleport, RemoteEvent, or game automation is included.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local LOGO_ID = "rbxassetid://134813417493601"

local DESIGN_W = 700
local DESIGN_H = 480

local COLORS = {
    Main = Color3.fromRGB(13, 21, 27),
    Sidebar = Color3.fromRGB(15, 25, 31),
    Panel = Color3.fromRGB(18, 29, 36),
    Input = Color3.fromRGB(25, 38, 45),
    InputHover = Color3.fromRGB(30, 46, 52),
    Border = Color3.fromRGB(30, 45, 52),
    Accent = Color3.fromRGB(76, 193, 184),
    AccentDark = Color3.fromRGB(18, 45, 48),
    Text = Color3.fromRGB(225, 235, 238),
    Text2 = Color3.fromRGB(164, 176, 180),
    Muted = Color3.fromRGB(92, 108, 114),
    Muted2 = Color3.fromRGB(80, 94, 101),
    White = Color3.fromRGB(235, 240, 238),
}

--==================================================
-- SCREEN GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OpenSeaUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

--==================================================
-- MAIN WINDOW
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(DESIGN_W, DESIGN_H)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.BackgroundColor3 = COLORS.Main
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 9)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(5, 10, 14)
MainStroke.Thickness = 2
MainStroke.Transparency = 0.1
MainStroke.Parent = Main

local MainScale = Instance.new("UIScale")
MainScale.Parent = Main

--==================================================
-- RESPONSIVE SCALE
-- Fits desktop, tablet and mobile without changing
-- the internal design coordinates.
--==================================================

local function updateScale()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local viewport = camera.ViewportSize
    local margin = UserInputService.TouchEnabled and 22 or 36

    local scaleX = (viewport.X - margin) / DESIGN_W
    local scaleY = (viewport.Y - margin) / DESIGN_H

    local scale = math.min(scaleX, scaleY)
    scale = math.clamp(scale, 0.48, 1.35)

    MainScale.Scale = scale
end

task.defer(updateScale)

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    task.defer(updateScale)
end)

--==================================================
-- UTILITY
--==================================================

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or COLORS.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local function label(parent, text, position, size, textSize, color, font)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Position = position
    l.Size = size
    l.Text = text
    l.TextColor3 = color or COLORS.Text2
    l.TextSize = textSize or 10
    l.Font = font or Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Parent = parent
    return l
end

local function image(parent, imageId, position, size, imageColor)
    local i = Instance.new("ImageLabel")
    i.BackgroundTransparency = 1
    i.Position = position
    i.Size = size
    i.Image = imageId
    i.ImageColor3 = imageColor or COLORS.Text2
    i.ScaleType = Enum.ScaleType.Fit
    i.Parent = parent
    return i
end

local function button(parent, position, size, text, textSize)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.BackgroundTransparency = 1
    b.Position = position
    b.Size = size
    b.Text = text or ""
    b.TextSize = textSize or 10
    b.Font = Enum.Font.Gotham
    b.TextColor3 = COLORS.Text2
    b.BorderSizePixel = 0
    b.Parent = parent
    return b
end

local function tween(instance, properties, duration)
    TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        properties
    ):Play()
end

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.fromOffset(185, DESIGN_H)
Sidebar.BackgroundColor3 = COLORS.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SideCorner = corner(Sidebar, 9)

local SideFix = Instance.new("Frame")
SideFix.Size = UDim2.fromOffset(15, DESIGN_H)
SideFix.Position = UDim2.new(1, -15, 0, 0)
SideFix.BackgroundColor3 = COLORS.Sidebar
SideFix.BorderSizePixel = 0
SideFix.Parent = Sidebar

--==================================================
-- LOGO + TITLE
--==================================================

local LogoHolder = Instance.new("ImageButton")
LogoHolder.Name = "Logo"
LogoHolder.AutoButtonColor = false
LogoHolder.BackgroundTransparency = 1
LogoHolder.Position = UDim2.fromOffset(14, 10)
LogoHolder.Size = UDim2.fromOffset(38, 38)
LogoHolder.Image = LOGO_ID
LogoHolder.ScaleType = Enum.ScaleType.Fit
LogoHolder.Parent = Sidebar

local LogoFallback = label(
    Sidebar,
    "3",
    UDim2.fromOffset(17, 9),
    UDim2.fromOffset(35, 40),
    31,
    COLORS.Accent,
    Enum.Font.GothamBold
)
LogoFallback.Visible = false

local Title = label(
    Sidebar,
    "Open Sea For Animals",
    UDim2.fromOffset(52, 10),
    UDim2.fromOffset(126, 23),
    13,
    COLORS.Text,
    Enum.Font.GothamBold
)

local Subtitle = label(
    Sidebar,
    "ปลดล็อคความสนุก!",
    UDim2.fromOffset(52, 31),
    UDim2.fromOffset(120, 17),
    8,
    COLORS.Muted
)

--==================================================
-- ICON ASSETS
-- These are Roblox image assets. ImageLabel is used
-- instead of Unicode symbols so icons render reliably.
--==================================================

local ICONS = {
    Home = "rbxassetid://6031075938",
    Settings = "rbxassetid://6031280882",
    Search = "rbxassetid://6031154871",
    Player = "rbxassetid://6034281935",
    World = "rbxassetid://6026568213",
    Quest = "rbxassetid://6031068421",
    Misc = "rbxassetid://6031280883",
    Upgrade = "rbxassetid://6034503369",
    Close = "rbxassetid://6031094678",
}

--==================================================
-- SIDEBAR LABELS
--==================================================

label(
    Sidebar,
    "MAIN",
    UDim2.fromOffset(20, 72),
    UDim2.fromOffset(150, 18),
    9,
    COLORS.Muted2,
    Enum.Font.GothamBold
)

label(
    Sidebar,
    "OTHER",
    UDim2.fromOffset(20, 313),
    UDim2.fromOffset(150, 18),
    9,
    COLORS.Muted2,
    Enum.Font.GothamBold
)

--==================================================
-- PAGE SYSTEM
--==================================================

local Pages = Instance.new("Folder")
Pages.Name = "Pages"
Pages.Parent = Main

local SidebarButtons = {}
local CurrentPage = nil

local function createPage(name)
    local page = Instance.new("Frame")
    page.Name = name
    page.Size = UDim2.new(1, -185, 1, 0)
    page.Position = UDim2.fromOffset(185, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = Pages
    return page
end

--==================================================
-- SIDEBAR BUTTON
--==================================================

local function createSideButton(name, iconId, y)
    local holder = Instance.new("Frame")
    holder.Name = name .. "Button"
    holder.Size = UDim2.fromOffset(163, 39)
    holder.Position = UDim2.fromOffset(10, y)
    holder.BackgroundColor3 = COLORS.Sidebar
    holder.BorderSizePixel = 0
    holder.Parent = Sidebar
    corner(holder, 6)

    local hit = button(holder, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), "")

    local icon = image(
        holder,
        iconId,
        UDim2.fromOffset(9, 8),
        UDim2.fromOffset(23, 23),
        COLORS.Muted
    )
    icon.ZIndex = 3

    local text = label(
        holder,
        name,
        UDim2.fromOffset(40, 4),
        UDim2.fromOffset(115, 31),
        10,
        COLORS.Text2,
        Enum.Font.GothamMedium
    )
    text.ZIndex = 3

    SidebarButtons[name] = {
        Holder = holder,
        Hit = hit,
        Icon = icon,
        Text = text,
    }

    hit.MouseEnter:Connect(function()
        if CurrentPage ~= name then
            tween(holder, {BackgroundColor3 = Color3.fromRGB(19, 32, 38)}, 0.12)
        end
    end)

    hit.MouseLeave:Connect(function()
        if CurrentPage ~= name then
            tween(holder, {BackgroundColor3 = COLORS.Sidebar}, 0.12)
        end
    end)

    hit.Activated:Connect(function()
        if Pages:FindFirstChild(name) then
            local target = Pages:FindFirstChild(name)
            for _, page in ipairs(Pages:GetChildren()) do
                if page:IsA("Frame") then
                    page.Visible = (page == target)
                end
            end

            for pageName, data in pairs(SidebarButtons) do
                local selected = pageName == name
                tween(
                    data.Holder,
                    {
                        BackgroundColor3 = selected and COLORS.AccentDark or COLORS.Sidebar
                    },
                    0.12
                )
                data.Icon.ImageColor3 = selected and COLORS.Accent or COLORS.Muted
                data.Text.TextColor3 = selected and COLORS.Text or COLORS.Text2
            end

            CurrentPage = name
        end
    end)

    return holder
end

createSideButton("Home", ICONS.Home, 94)
createSideButton("Auto Farm", ICONS.World, 136)
createSideButton("Gym", ICONS.Player, 178)
createSideButton("Upgrades & Progression", ICONS.Upgrade, 220)
createSideButton("Quests & Boosts", ICONS.Quest, 262)
createSideButton("Misc", ICONS.Misc, 332)
createSideButton("Settings", ICONS.Settings, 374)

--==================================================
-- USER CARD
--==================================================

local UserLine = Instance.new("Frame")
UserLine.Size = UDim2.fromOffset(155, 1)
UserLine.Position = UDim2.fromOffset(15, 420)
UserLine.BackgroundColor3 = Color3.fromRGB(38, 51, 57)
UserLine.BorderSizePixel = 0
UserLine.Parent = Sidebar

local UserAvatar = Instance.new("ImageLabel")
UserAvatar.Size = UDim2.fromOffset(28, 28)
UserAvatar.Position = UDim2.fromOffset(16, 437)
UserAvatar.BackgroundColor3 = Color3.fromRGB(230, 232, 229)
UserAvatar.BorderSizePixel = 0
UserAvatar.Image = LOGO_ID
UserAvatar.ScaleType = Enum.ScaleType.Fit
UserAvatar.Parent = Sidebar
corner(UserAvatar, 100)

label(
    Sidebar,
    Player.DisplayName or "Player",
    UDim2.fromOffset(52, 434),
    UDim2.fromOffset(112, 16),
    9,
    COLORS.Text,
    Enum.Font.GothamBold
)

label(
    Sidebar,
    "UI Preview",
    UDim2.fromOffset(52, 451),
    UDim2.fromOffset(105, 14),
    8,
    COLORS.Muted
)

--==================================================
-- PAGE HEADER
--==================================================

local function createPageHeader(page, titleText, subtitleText, iconId)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, -30, 0, 65)
    header.Position = UDim2.fromOffset(15, 5)
    header.BackgroundTransparency = 1
    header.Parent = page

    image(
        header,
        iconId,
        UDim2.fromOffset(0, 14),
        UDim2.fromOffset(22, 22),
        COLORS.Accent
    )

    label(
        header,
        titleText,
        UDim2.fromOffset(29, 7),
        UDim2.fromOffset(330, 24),
        17,
        COLORS.Text,
        Enum.Font.GothamBold
    )

    label(
        header,
        subtitleText,
        UDim2.fromOffset(29, 30),
        UDim2.fromOffset(450, 20),
        8,
        COLORS.Muted
    )

    return header
end

--==================================================
-- TOP BUTTONS
--==================================================

local SearchOverlay = Instance.new("Frame")
SearchOverlay.Name = "SearchOverlay"
SearchOverlay.Size = UDim2.fromOffset(190, 32)
SearchOverlay.Position = UDim2.new(1, -292, 0, 21)
SearchOverlay.BackgroundColor3 = COLORS.Input
SearchOverlay.BorderSizePixel = 0
SearchOverlay.Visible = false
SearchOverlay.ZIndex = 30
SearchOverlay.Parent = Main
corner(SearchOverlay, 6)
stroke(SearchOverlay, COLORS.Border, 1, 0.2)

image(
    SearchOverlay,
    ICONS.Search,
    UDim2.fromOffset(8, 7),
    UDim2.fromOffset(18, 18),
    COLORS.Muted
).ZIndex = 31

local SearchBox = Instance.new("TextBox")
SearchBox.BackgroundTransparency = 1
SearchBox.Position = UDim2.fromOffset(32, 0)
SearchBox.Size = UDim2.new(1, -38, 1, 0)
SearchBox.PlaceholderText = "Search..."
SearchBox.PlaceholderColor3 = COLORS.Muted
SearchBox.Text = ""
SearchBox.TextColor3 = COLORS.Text
SearchBox.TextSize = 9
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.ZIndex = 31
SearchBox.Parent = SearchOverlay

local TopSearch = button(
    Main,
    UDim2.new(1, -108, 0, 16),
    UDim2.fromOffset(30, 30),
    "",
    10
)
TopSearch.BackgroundTransparency = false
TopSearch.BackgroundColor3 = Color3.fromRGB(22, 34, 41)
TopSearch.ZIndex = 20
corner(TopSearch, 5)

local TopSearchIcon = image(
    TopSearch,
    ICONS.Search,
    UDim2.fromOffset(7, 7),
    UDim2.fromOffset(16, 16),
    COLORS.Text2
)
TopSearchIcon.ZIndex = 21

local TopSettings = button(
    Main,
    UDim2.new(1, -73, 0, 16),
    UDim2.fromOffset(30, 30),
    "",
    10
)
TopSettings.BackgroundTransparency = false
TopSettings.BackgroundColor3 = Color3.fromRGB(22, 34, 41)
TopSettings.ZIndex = 20
corner(TopSettings, 5)

local TopSettingsIcon = image(
    TopSettings,
    ICONS.Settings,
    UDim2.fromOffset(7, 7),
    UDim2.fromOffset(16, 16),
    COLORS.Text2
)
TopSettingsIcon.ZIndex = 21

local TopClose = button(
    Main,
    UDim2.new(1, -38, 0, 16),
    UDim2.fromOffset(30, 30),
    "",
    15
)
TopClose.BackgroundTransparency = false
TopClose.BackgroundColor3 = Color3.fromRGB(22, 34, 41)
TopClose.Text = "−"
TopClose.TextColor3 = COLORS.Text2
TopClose.ZIndex = 20
corner(TopClose, 5)

TopSearch.MouseEnter:Connect(function()
    tween(TopSearch, {BackgroundColor3 = COLORS.InputHover}, 0.12)
end)
TopSearch.MouseLeave:Connect(function()
    tween(TopSearch, {BackgroundColor3 = Color3.fromRGB(22, 34, 41)}, 0.12)
end)

TopSettings.MouseEnter:Connect(function()
    tween(TopSettings, {BackgroundColor3 = COLORS.InputHover}, 0.12)
end)
TopSettings.MouseLeave:Connect(function()
    tween(TopSettings, {BackgroundColor3 = Color3.fromRGB(22, 34, 41)}, 0.12)
end)

TopSearch.Activated:Connect(function()
    SearchOverlay.Visible = not SearchOverlay.Visible
    if SearchOverlay.Visible then
        SearchBox:CaptureFocus()
    end
end)

TopSettings.Activated:Connect(function()
    local target = Pages:FindFirstChild("Settings")
    if target then
        for _, page in ipairs(Pages:GetChildren()) do
            if page:IsA("Frame") then
                page.Visible = (page == target)
            end
        end
        for name, data in pairs(SidebarButtons) do
            local selected = name == "Settings"
            tween(data.Holder, {
                BackgroundColor3 = selected and COLORS.AccentDark or COLORS.Sidebar
            }, 0.12)
            data.Icon.ImageColor3 = selected and COLORS.Accent or COLORS.Muted
            data.Text.TextColor3 = selected and COLORS.Text or COLORS.Text2
        end
        CurrentPage = "Settings"
    end
end)

--==================================================
-- OPEN / CLOSE
--==================================================

local OpenButton = Instance.new("ImageButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.fromOffset(48, 48)
OpenButton.AnchorPoint = Vector2.new(1, 1)
OpenButton.Position = UDim2.new(1, -18, 1, -18)
OpenButton.BackgroundColor3 = COLORS.Panel
OpenButton.BorderSizePixel = 0
OpenButton.AutoButtonColor = false
OpenButton.Image = LOGO_ID
OpenButton.ScaleType = Enum.ScaleType.Fit
OpenButton.Visible = false
OpenButton.Parent = ScreenGui
corner(OpenButton, 12)
stroke(OpenButton, COLORS.Border, 1, 0.1)

TopClose.Activated:Connect(function()
    Main.Visible = false
    OpenButton.Visible = true
end)

OpenButton.Activated:Connect(function()
    Main.Visible = true
    OpenButton.Visible = false
    updateScale()
end)

--==================================================
-- PANEL HELPERS
--==================================================

local function createPanel(parent, position, size, titleText, iconId)
    local panel = Instance.new("Frame")
    panel.Size = size
    panel.Position = position
    panel.BackgroundColor3 = COLORS.Panel
    panel.BorderSizePixel = 0
    panel.Parent = parent
    corner(panel, 7)
    stroke(panel, COLORS.Border, 1, 0.25)

    image(
        panel,
        iconId,
        UDim2.fromOffset(10, 8),
        UDim2.fromOffset(18, 18),
        COLORS.Accent
    )

    label(
        panel,
        titleText,
        UDim2.fromOffset(34, 5),
        UDim2.new(1, -65, 0, 25),
        11,
        COLORS.Text,
        Enum.Font.GothamBold
    )

    local arrow = label(
        panel,
        "⌄",
        UDim2.new(1, -28, 0, 7),
        UDim2.fromOffset(18, 18),
        12,
        COLORS.Muted,
        Enum.Font.GothamBold
    )
    arrow.TextXAlignment = Enum.TextXAlignment.Center

    return panel
end

local function createText(parent, textValue, x, y, width)
    return label(
        parent,
        textValue,
        UDim2.fromOffset(x, y),
        UDim2.fromOffset(width or 190, 18),
        9,
        COLORS.Text2
    )
end

--==================================================
-- DROPDOWN
--==================================================

local function createDropdown(parent, y, currentText, options)
    local drop = Instance.new("Frame")
    drop.Size = UDim2.fromOffset(198, 29)
    drop.Position = UDim2.fromOffset(20, y)
    drop.BackgroundColor3 = COLORS.Input
    drop.BorderSizePixel = 0
    drop.ClipsDescendants = false
    drop.ZIndex = 5
    drop.Parent = parent
    corner(drop, 5)

    local hit = button(drop, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), "")
    hit.ZIndex = 7

    local value = label(
        drop,
        currentText,
        UDim2.fromOffset(10, 0),
        UDim2.new(1, -38, 1, 0),
        9,
        COLORS.Text2
    )
    value.ZIndex = 8

    local arrow = label(
        drop,
        "⌄",
        UDim2.new(1, -27, 0, 4),
        UDim2.fromOffset(18, 20),
        11,
        COLORS.Muted,
        Enum.Font.GothamBold
    )
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    arrow.ZIndex = 8

    local menu = Instance.new("Frame")
    menu.Size = UDim2.fromOffset(198, math.min(#options, 5) * 26 + 4)
    menu.Position = UDim2.fromOffset(0, 31)
    menu.BackgroundColor3 = COLORS.Input
    menu.BorderSizePixel = 0
    menu.Visible = false
    menu.ZIndex = 50
    menu.Parent = drop
    corner(menu, 5)
    stroke(menu, COLORS.Border, 1, 0.1)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 1)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = menu

    for _, option in ipairs(options) do
        local opt = button(menu, UDim2.fromOffset(3, 0), UDim2.new(1, -6, 0, 25), option, 9)
        opt.BackgroundTransparency = false
        opt.BackgroundColor3 = COLORS.Input
        opt.TextColor3 = COLORS.Text2
        opt.TextXAlignment = Enum.TextXAlignment.Left
        opt.ZIndex = 51
        corner(opt, 4)

        opt.MouseEnter:Connect(function()
            tween(opt, {BackgroundColor3 = COLORS.AccentDark}, 0.1)
        end)
        opt.MouseLeave:Connect(function()
            tween(opt, {BackgroundColor3 = COLORS.Input}, 0.1)
        end)

        opt.Activated:Connect(function()
            value.Text = option
            menu.Visible = false
            arrow.Text = "⌄"
        end)
    end

    hit.MouseEnter:Connect(function()
        tween(drop, {BackgroundColor3 = COLORS.InputHover}, 0.1)
    end)
    hit.MouseLeave:Connect(function()
        tween(drop, {BackgroundColor3 = COLORS.Input}, 0.1)
    end)

    hit.Activated:Connect(function()
        menu.Visible = not menu.Visible
        arrow.Text = menu.Visible and "⌃" or "⌄"
    end)

    return drop
end

--==================================================
-- TOGGLE (UI ONLY)
--==================================================

local function createToggle(parent, textValue, y)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.fromOffset(198, 26)
    holder.Position = UDim2.fromOffset(20, y)
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local hit = button(holder, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), "")
    hit.ZIndex = 5

    local track = Instance.new("Frame")
    track.Size = UDim2.fromOffset(28, 15)
    track.Position = UDim2.fromOffset(0, 5)
    track.BackgroundColor3 = Color3.fromRGB(39, 53, 59)
    track.BorderSizePixel = 0
    track.Parent = holder
    corner(track, 20)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(11, 11)
    knob.Position = UDim2.fromOffset(2, 2)
    knob.BackgroundColor3 = COLORS.Muted
    knob.BorderSizePixel = 0
    knob.Parent = track
    corner(knob, 20)

    local textLabel = label(
        holder,
        textValue,
        UDim2.fromOffset(38, 0),
        UDim2.fromOffset(155, 25),
        9,
        COLORS.Text2
    )

    local state = false

    hit.Activated:Connect(function()
        -- UI interaction only; no actual game function.
        state = not state

        tween(
            track,
            {BackgroundColor3 = state and COLORS.AccentDark or Color3.fromRGB(39, 53, 59)},
            0.12
        )
        tween(
            knob,
            {
                Position = state and UDim2.fromOffset(15, 2) or UDim2.fromOffset(2, 2),
                BackgroundColor3 = state and COLORS.Accent or COLORS.Muted
            },
            0.12
        )
    end)

    return holder
end

--==================================================
-- SLIDER (UI ONLY)
--==================================================

local function createSlider(parent, y, valueText, percent)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.fromOffset(218, 31)
    holder.Position = UDim2.fromOffset(20, y)
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local track = Instance.new("Frame")
    track.Size = UDim2.fromOffset(198, 5)
    track.Position = UDim2.fromOffset(0, 17)
    track.BackgroundColor3 = Color3.fromRGB(36, 48, 54)
    track.BorderSizePixel = 0
    track.Parent = holder
    corner(track, 10)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(percent, 0, 1, 0)
    fill.BackgroundColor3 = COLORS.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    corner(fill, 10)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(12, 12)
    knob.Position = UDim2.new(percent, -6, 0.5, -6)
    knob.BackgroundColor3 = COLORS.White
    knob.BorderSizePixel = 0
    knob.Parent = track
    corner(knob, 20)

    local value = label(
        holder,
        valueText,
        UDim2.fromOffset(198, 0),
        UDim2.fromOffset(25, 18),
        9,
        COLORS.Text
    )
    value.TextXAlignment = Enum.TextXAlignment.Right

    local drag = false

    local function setPercent(x)
        local relative = math.clamp(
            (x - track.AbsolutePosition.X) / track.AbsoluteSize.X,
            0,
            1
        )

        fill.Size = UDim2.new(relative, 0, 1, 0)
        knob.Position = UDim2.new(relative, -6, 0.5, -6)

        -- UI-only value preview.
        value.Text = tostring(math.floor(relative * 10 + 0.5))
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            setPercent(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if drag and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            setPercent(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)

    return holder
end

--==================================================
-- HOME PAGE
--==================================================

local HomePage = createPage("Home")

createPageHeader(
    HomePage,
    "Home",
    "Open Sea For Animals interface",
    ICONS.Home
)

local HomePanel = createPanel(
    HomePage,
    UDim2.fromOffset(15, 70),
    UDim2.new(1, -30, 0, 365),
    "Welcome",
    ICONS.Home
)

image(
    HomePanel,
    LOGO_ID,
    UDim2.new(0.5, -45, 0, 55),
    UDim2.fromOffset(90, 90),
    COLORS.White
)

local welcome = label(
    HomePanel,
    "Open Sea For Animals",
    UDim2.fromOffset(0, 155),
    UDim2.new(1, 0, 0, 28),
    18,
    COLORS.Text,
    Enum.Font.GothamBold
)
welcome.TextXAlignment = Enum.TextXAlignment.Center

local welcomeSub = label(
    HomePanel,
    "UI preview — features are intentionally not connected yet.",
    UDim2.fromOffset(0, 187),
    UDim2.new(1, 0, 0, 20),
    9,
    COLORS.Muted,
    Enum.Font.Gotham
)
welcomeSub.TextXAlignment = Enum.TextXAlignment.Center

--==================================================
-- AUTO FARM PAGE
--==================================================

local FarmPage = createPage("Auto Farm")

createPageHeader(
    FarmPage,
    "Auto Farm",
    "Sea harvesting, item, vacuum, and plot automation",
    ICONS.World
)

local FarmPanel = createPanel(
    FarmPage,
    UDim2.fromOffset(15, 70),
    UDim2.fromOffset(238, 365),
    "Auto Farm",
    ICONS.World
)

createText(FarmPanel, "Auto Wave Harvest", 20, 39)

createText(FarmPanel, "Wave Power", 20, 62)
createSlider(FarmPanel, 62, "5", 0.90)

createText(FarmPanel, "Cycle Interval", 20, 98)
createSlider(FarmPanel, 98, "3s", 0.14)

createText(FarmPanel, "Auto Pickup Nearby Items", 20, 133)

local Pickup = button(
    FarmPanel,
    UDim2.fromOffset(20, 153),
    UDim2.fromOffset(198, 29),
    "Pickup Nearest Item Now",
    9
)
Pickup.BackgroundTransparency = false
Pickup.BackgroundColor3 = COLORS.Input
Pickup.TextColor3 = COLORS.Text2
corner(Pickup, 5)
Pickup.MouseEnter:Connect(function()
    tween(Pickup, {BackgroundColor3 = COLORS.InputHover}, 0.1)
end)
Pickup.MouseLeave:Connect(function()
    tween(Pickup, {BackgroundColor3 = COLORS.Input}, 0.1)
end)

createText(FarmPanel, "Filter: Animal Name", 20, 190)
createDropdown(FarmPanel, 210, "All Animals", {
    "All Animals", "Dog", "Cat", "Bird", "Rabbit"
})

createText(FarmPanel, "Filter: Egg Name", 20, 246)
createDropdown(FarmPanel, 266, "All Eggs", {
    "All Eggs", "Common Egg", "Rare Egg", "Legendary Egg"
})

createText(FarmPanel, "Filter: Rarity", 20, 302)
createDropdown(FarmPanel, 322, "All Rarities", {
    "All Rarities", "Common", "Rare", "Epic", "Legendary"
})

createText(FarmPanel, "Filter: Mutation", 20, 358)
createDropdown(FarmPanel, 378, "All Mutations", {
    "All Mutations", "Normal", "Gold", "Rainbow"
})

local PlotPanel = createPanel(
    FarmPage,
    UDim2.fromOffset(263, 70),
    UDim2.fromOffset(223, 300),
    "Plot Automation",
    ICONS.World
)

createText(PlotPanel, "Auto Place Eggs", 20, 40)

createText(PlotPanel, "Filter: Egg Name", 20, 63)
createDropdown(PlotPanel, 83, "All Eggs", {
    "All Eggs", "Common Egg", "Rare Egg", "Legendary Egg"
})

createText(PlotPanel, "Filter: Rarity", 20, 119)
createDropdown(PlotPanel, 139, "All Rarities", {
    "All Rarities", "Common", "Rare", "Epic", "Legendary"
})

createText(PlotPanel, "Filter: Mutation", 20, 175)
createDropdown(PlotPanel, 195, "All Mutations", {
    "All Mutations", "Normal", "Gold", "Rainbow"
})

createToggle(PlotPanel, "Auto Hatch Eggs", 226)
createToggle(PlotPanel, "Auto Equip Best Animals", 248)

createText(PlotPanel, "Equip Interval", 20, 270)
createSlider(PlotPanel, 270, "6s", 0.23)

local SellPanel = createPanel(
    FarmPage,
    UDim2.fromOffset(263, 380),
    UDim2.fromOffset(223, 120),
    "Auto Sell Animals",
    ICONS.World
)

createToggle(SellPanel, "Auto Sell Animals", 39)

createText(SellPanel, "Sell Below (S/s)", 20, 61)
createSlider(SellPanel, 61, "0/s", 0.02)

--==================================================
-- OTHER PAGES
--==================================================

local function createSimplePage(name, titleText, subtitleText, iconId)
    local page = createPage(name)

    createPageHeader(page, titleText, subtitleText, iconId)

    local panel = createPanel(
        page,
        UDim2.fromOffset(15, 70),
        UDim2.new(1, -30, 0, 365),
        titleText,
        iconId
    )

    image(
        panel,
        iconId,
        UDim2.new(0.5, -28, 0, 90),
        UDim2.fromOffset(56, 56),
        COLORS.Accent
    )

    local title = label(
        panel,
        titleText,
        UDim2.fromOffset(0, 165),
        UDim2.new(1, 0, 0, 26),
        16,
        COLORS.Text,
        Enum.Font.GothamBold
    )
    title.TextXAlignment = Enum.TextXAlignment.Center

    local desc = label(
        panel,
        "This tab is ready for UI controls. No game functionality is connected yet.",
        UDim2.fromOffset(25, 198),
        UDim2.new(1, -50, 0, 35),
        9,
        COLORS.Muted
    )
    desc.TextXAlignment = Enum.TextXAlignment.Center
    desc.TextWrapped = true

    return page
end

local GymPage = createSimplePage(
    "Gym",
    "Gym",
    "Training and progression UI",
    ICONS.Player
)

local UpgradePage = createSimplePage(
    "Upgrades & Progression",
    "Upgrades & Progression",
    "Upgrade interface",
    ICONS.Upgrade
)

local QuestPage = createSimplePage(
    "Quests & Boosts",
    "Quests & Boosts",
    "Quest and boost interface",
    ICONS.Quest
)

local MiscPage = createSimplePage(
    "Misc",
    "Misc",
    "Miscellaneous interface",
    ICONS.Misc
)

local SettingsPage = createSimplePage(
    "Settings",
    "Settings",
    "Interface settings",
    ICONS.Settings
)

--==================================================
-- SETTINGS PAGE EXTRA UI
--==================================================

createToggle(SettingsPage:FindFirstChildWhichIsA("Frame"), "UI Animation", 245)

--==================================================
-- INITIAL PAGE
--==================================================

local function selectPage(name)
    local target = Pages:FindFirstChild(name)
    if not target then
        return
    end

    for _, page in ipairs(Pages:GetChildren()) do
        if page:IsA("Frame") then
            page.Visible = (page == target)
        end
    end

    for pageName, data in pairs(SidebarButtons) do
        local selected = pageName == name

        data.Holder.BackgroundColor3 = selected
            and COLORS.AccentDark
            or COLORS.Sidebar

        data.Icon.ImageColor3 = selected
            and COLORS.Accent
            or COLORS.Muted

        data.Text.TextColor3 = selected
            and COLORS.Text
            or COLORS.Text2
    end

    CurrentPage = name
end

selectPage("Auto Farm")

--==================================================
-- CLOSE SEARCH WHEN CLICKING OUTSIDE
--==================================================

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        if SearchOverlay.Visible then
            local mousePos = input.Position
            local pos = SearchOverlay.AbsolutePosition
            local size = SearchOverlay.AbsoluteSize

            local inside =
                mousePos.X >= pos.X and
                mousePos.X <= pos.X + size.X and
                mousePos.Y >= pos.Y and
                mousePos.Y <= pos.Y + size.Y

            if not inside then
                SearchOverlay.Visible = false
            end
        end
    end
end)

--==================================================
-- TOP EDGE ACCENT
--==================================================

local TopAccent = Instance.new("Frame")
TopAccent.Size = UDim2.new(1, 0, 0, 2)
TopAccent.Position = UDim2.fromOffset(0, 0)
TopAccent.BackgroundColor3 = COLORS.Accent
TopAccent.BackgroundTransparency = 0.25
TopAccent.BorderSizePixel = 0
TopAccent.ZIndex = 100
TopAccent.Parent = Main

--==================================================
-- DONE
--==================================================
