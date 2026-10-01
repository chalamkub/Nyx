--[[
    MacUI Library v2.0
    Window > Tab > Section > Elements
    Elements: Label, Button, Toggle, Slider, Dropdown, Textbox, Bind, Divider
    ระบบ: Notify, Destroy, ปุ่มซ่อน/แสดง UI, Flags + SaveConfig/LoadConfig, นามแฝงทุกชื่อ
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local Library = { Flags = {}, Setters = {}, Version = "2.0", GuiName = "MacUI_ScreenGui" }
local Window, Tab, Section = {}, {}, {}
Window.__index, Tab.__index, Section.__index = Window, Tab, Section

local Theme = {
    Background = Color3.fromRGB(30, 30, 33),
    Sidebar = Color3.fromRGB(38, 38, 42),
    Section = Color3.fromRGB(42, 42, 47),
    Element = Color3.fromRGB(54, 54, 60),
    Off = Color3.fromRGB(80, 80, 88),
    Accent = Color3.fromRGB(10, 132, 255),
    Text = Color3.fromRGB(245, 245, 247),
    SubText = Color3.fromRGB(160, 160, 170),
    Red = Color3.fromRGB(255, 95, 86),
    Yellow = Color3.fromRGB(255, 189, 46),
    Green = Color3.fromRGB(39, 201, 63),
}
Library.Theme = Theme

-- ========== ตัวช่วย ==========
local connections = {}
local Gui, NotifyHolder

local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end

local function Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    return inst
end

local function Round(r) return Create("UICorner", { CornerRadius = UDim.new(0, r) }) end
local function Pad(n)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, n), PaddingBottom = UDim.new(0, n),
        PaddingLeft = UDim.new(0, n), PaddingRight = UDim.new(0, n),
    })
end
local function List(pad)
    return Create("UIListLayout", { Padding = UDim.new(0, pad), SortOrder = Enum.SortOrder.LayoutOrder })
end
local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad), props):Play()
end
local function safe(f, ...)
    if type(f) ~= "function" then return end
    local ok, err = pcall(f, ...)
    if not ok then warn("[MacUI] " .. tostring(err)) end
end
local function norm(o)
    if type(o) == "string" then return { Name = o } end
    return o or {}
end
local function pick(o, ...)
    for _, k in ipairs({ ... }) do
        if o[k] ~= nil then return o[k] end
    end
end
local function newLabel(props)
    props.BackgroundTransparency = 1
    props.Font = props.Font or Enum.Font.Gotham
    props.TextSize = props.TextSize or 14
    props.TextColor3 = props.TextColor3 or Theme.Text
    return Create("TextLabel", props)
end

local function getGui()
    if Gui and Gui.Parent then return Gui end
    local parent
    pcall(function() parent = (gethui and gethui()) or CoreGui end)
    local player = Players.LocalPlayer
    if not parent and player then parent = player:WaitForChild("PlayerGui") end
    local old = parent and parent:FindFirstChild(Library.GuiName)
    if old then old:Destroy() end

    Gui = Create("ScreenGui", {
        Name = Library.GuiName, ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true,
    })
    if not pcall(function() Gui.Parent = parent end) then
        Gui.Parent = player:WaitForChild("PlayerGui")
    end

    NotifyHolder = Create("Frame", {
        AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -12, 1, -12),
        Size = UDim2.new(0, 280, 1, -24), BackgroundTransparency = 1, ZIndex = 50, Parent = Gui,
    }, { Create("UIListLayout", {
        Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
    }) })
    return Gui
end

local function makeDraggable(handle, target)
    local dragging, dragStart, startPos
    connect(handle.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, i.Position, target.Position
        end
    end)
    connect(UIS.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    connect(UIS.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function setFlag(flag, v)
    if flag then Library.Flags[flag] = v end
end
local function regFlag(flag, setter)
    if flag then Library.Setters[flag] = setter end
end

-- ========== Library ==========
function Library:CreateWindow(o)
    o = norm(o)
    local gui = getGui()
    local title = pick(o, "Name", "Title", "Text") or "MacUI"
    local normalSize = o.Size or UDim2.new(0, 560, 0, 360)
    local bigSize = UDim2.new(0, 720, 0, 460)
    local toggleKey = o.ToggleKey or Enum.KeyCode.RightControl

    local main = Create("Frame", {
        Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = normalSize, BackgroundColor3 = Theme.Background, ClipsDescendants = true, Parent = gui,
    }, { Round(10), Create("UIStroke", { Color = Color3.fromRGB(70, 70, 78), Thickness = 1 }) })

    local bar = Create("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Sidebar, BorderSizePixel = 0, Parent = main })
    newLabel({ Size = UDim2.new(1, 0, 1, 0), Text = title, Font = Enum.Font.GothamBold, TextSize = 14, Parent = bar })

    local body = Create("Frame", { Position = UDim2.new(0, 0, 0, 36), Size = UDim2.new(1, 0, 1, -36), BackgroundTransparency = 1, Parent = main })
    local sidebar = Create("ScrollingFrame", {
        Size = UDim2.new(0, 140, 1, 0), BackgroundColor3 = Theme.Sidebar, BorderSizePixel = 0,
        ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Parent = body,
    }, { Pad(8), List(4) })
    local pages = Create("Frame", { Position = UDim2.new(0, 140, 0, 0), Size = UDim2.new(1, -140, 1, 0), BackgroundTransparency = 1, Parent = body })

    local self = setmetatable({ Tabs = {}, Main = main, Gui = gui, _Sidebar = sidebar, _Pages = pages }, Window)

    local minimized, big = false, false
    local function applySize()
        local s = big and bigSize or normalSize
        body.Visible = not minimized
        tween(main, { Size = minimized and UDim2.new(s.X.Scale, s.X.Offset, 0, 36) or s }, 0.2)
    end
    local function light(x, color, fn)
        local b = Create("TextButton", {
            Position = UDim2.new(0, x, 0.5, -6), Size = UDim2.new(0, 12, 0, 12),
            BackgroundColor3 = color, Text = "", AutoButtonColor = false, Parent = bar,
        }, { Round(6) })
        connect(b.MouseButton1Click, fn)
    end
    light(12, Theme.Red, function() Library:Destroy() end)
    light(32, Theme.Yellow, function() minimized = not minimized; applySize() end)
    light(52, Theme.Green, function() big = not big; minimized = false; applySize() end)

    makeDraggable(bar, main)
    connect(UIS.InputBegan, function(i, gp)
        if not gp and i.KeyCode == toggleKey then main.Visible = not main.Visible end
    end)
    return self
end
function Library.new(o) return Library:CreateWindow(o) end

function Library:Notify(o)
    o = norm(o)
    local title = pick(o, "Title", "Name") or "แจ้งเตือน"
    local content = pick(o, "Content", "Text") or ""
    local duration = o.Duration or 3
    getGui()

    local wrap = Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = NotifyHolder })
    local card = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.new(1, 40, 0, 0),
        BackgroundColor3 = Theme.Background, Parent = wrap,
    }, { Round(10), Create("UIStroke", { Color = Theme.Accent, Thickness = 1 }), Pad(10), List(2) })
    newLabel({ Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Text = title, Font = Enum.Font.GothamBold,
        TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1, Parent = card })
    if content ~= "" then
        newLabel({ Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Text = content, TextSize = 13,
            TextColor3 = Theme.SubText, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, Parent = card })
    end
    tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.3)
    task.delay(duration, function()
        if not card.Parent then return end
        tween(card, { Position = UDim2.new(1, 40, 0, 0) }, 0.3)
        task.wait(0.35)
        wrap:Destroy()
    end)
end

function Library:Destroy()
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    table.clear(connections)
    if Gui then Gui:Destroy() end
    Gui, NotifyHolder = nil, nil
end

function Library:SaveConfig(name)
    if not writefile then return false end
    return pcall(function()
        writefile("MacUI_" .. (name or "default") .. ".json", HttpService:JSONEncode(Library.Flags))
    end)
end
function Library:LoadConfig(name)
    local file = "MacUI_" .. (name or "default") .. ".json"
    if not (readfile and isfile and isfile(file)) then return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(file)) end)
    if not ok then return false end
    for flag, value in pairs(data) do
        if Library.Setters[flag] then safe(Library.Setters[flag], value) end
    end
    return true
end

-- ========== Window ==========
function Window:AddTab(o)
    o = norm(o)
    local name = pick(o, "Name", "Title", "Text") or "Tab"
    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1,
        Text = name, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.SubText,
        AutoButtonColor = false, Parent = self._Sidebar,
    }, { Round(6) })
    local page = Create("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
        AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Visible = false, Parent = self._Pages,
    }, { Pad(10), List(8) })
    local t = setmetatable({ Window = self, Name = name, Page = page, TabButton = btn, _n = 0 }, Tab)
    table.insert(self.Tabs, t)
    connect(btn.MouseButton1Click, function() self:SelectTab(t) end)
    if #self.Tabs == 1 then self:SelectTab(t) end
    return t
end

function Window:SelectTab(t)
    for _, x in ipairs(self.Tabs) do
        local on = x == t
        x.Page.Visible = on
        x.TabButton.TextColor3 = on and Theme.Text or Theme.SubText
        tween(x.TabButton, { BackgroundTransparency = on and 0 or 1 })
    end
    self.ActiveTab = t
end

function Window:AddSection(o)
    local t = self.Tabs[1] or self:AddTab({ Name = "Main" })
    return t:AddSection(o)
end
function Window:SetVisible(v) self.Main.Visible = v end
function Window:Toggle() self.Main.Visible = not self.Main.Visible end
function Window:Notify(o) return Library:Notify(o) end
function Window:Destroy() Library:Destroy() end

-- ========== Tab ==========
function Tab:AddSection(o)
    o = norm(o)
    local title = pick(o, "Name", "Title", "Text") or "Section"
    self._n += 1
    local f = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.Section,
        BorderSizePixel = 0, LayoutOrder = self._n, Parent = self.Page,
    }, { Round(8), Pad(8), List(6) })
    if title ~= "" then
        newLabel({ Size = UDim2.new(1, 0, 0, 18), Text = title, Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 0, Parent = f })
    end
    return setmetatable({ Frame = f, Tab = self, _n = 0 }, Section)
end
function Tab:_Default()
    if not self._def then self._def = self:AddSection({ Name = "" }) end
    return self._def
end

-- ========== Section ==========
function Section:_Row(h)
    self._n += 1
    return Create("Frame", {
        Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = Theme.Element, BorderSizePixel = 0,
        LayoutOrder = self._n, Parent = self.Frame,
    }, { Round(6) })
end

local function rowLabel(row, text, widthOffset)
    return newLabel({
        Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, widthOffset or -24, 0, 32), Text = text,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
    })
end

function Section:AddLabel(o)
    o = norm(o)
    local row = self:_Row(26)
    row.BackgroundTransparency = 1
    local l = newLabel({ Size = UDim2.new(1, -8, 1, 0), Position = UDim2.new(0, 4, 0, 0), Text = pick(o, "Name", "Title", "Text") or "",
        TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local api = {}
    function api:Set(t) l.Text = tostring(t) end
    function api:Destroy() row:Destroy() end
    return api
end

function Section:AddDivider()
    local row = self:_Row(1)
    row.BackgroundColor3 = Theme.Off
    return { Destroy = function() row:Destroy() end }
end

function Section:AddButton(o)
    o = norm(o)
    local cb = o.Callback
    local row = self:_Row(32)
    local btn = Create("TextButton", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = pick(o, "Name", "Title", "Text") or "Button",
        Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.Text, AutoButtonColor = false, Parent = row,
    })
    connect(btn.MouseEnter, function() tween(row, { BackgroundColor3 = Theme.Accent }) end)
    connect(btn.MouseLeave, function() tween(row, { BackgroundColor3 = Theme.Element }) end)
    connect(btn.MouseButton1Click, function() safe(cb) end)
    local api = {}
    function api:SetText(t) btn.Text = t end
    function api:Destroy() row:Destroy() end
    return api
end

function Section:AddToggle(o)
    o = norm(o)
    local cb, flag = o.Callback, o.Flag
    local state = (o.Default or o.Value) and true or false
    local row = self:_Row(32)
    rowLabel(row, pick(o, "Name", "Title", "Text") or "Toggle", -64)
    local track = Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0, 40, 0, 20),
        BackgroundColor3 = Theme.Off, Parent = row,
    }, { Round(10) })
    local knob = Create("Frame", { Position = UDim2.new(0, 2, 0.5, -8), Size = UDim2.new(0, 16, 0, 16), BackgroundColor3 = Color3.new(1, 1, 1), Parent = track }, { Round(8) })
    local click = Create("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Parent = row })

    local api = {}
    local function render()
        tween(track, { BackgroundColor3 = state and Theme.Accent or Theme.Off })
        tween(knob, { Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) })
    end
    function api:Set(v, silent)
        state = v and true or false
        render(); setFlag(flag, state)
        if not silent then safe(cb, state) end
    end
    function api:Get() return state end
    function api:Destroy() row:Destroy() end
    connect(click.MouseButton1Click, function() api:Set(not state) end)
    render(); setFlag(flag, state); regFlag(flag, function(v) api:Set(v) end)
    return api
end

function Section:AddSlider(o)
    o = norm(o)
    local min, max = o.Min or 0, o.Max or 100
    local inc = o.Increment or o.Step or 1
    local suffix = o.Suffix or ""
    local cb, flag = o.Callback, o.Flag
    local value = o.Default or o.Value or min
    local row = self:_Row(46)
    newLabel({ Position = UDim2.new(0, 12, 0, 6), Size = UDim2.new(1, -90, 0, 16), Text = pick(o, "Name", "Title", "Text") or "Slider",
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local valLbl = newLabel({ AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 6), Size = UDim2.new(0, 70, 0, 16),
        TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Right, Parent = row })
    local bar = Create("Frame", { Position = UDim2.new(0, 12, 0, 30), Size = UDim2.new(1, -24, 0, 6), BackgroundColor3 = Theme.Off, Parent = row }, { Round(3) })
    local fill = Create("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Accent, Parent = bar }, { Round(3) })
    local hit = Create("TextButton", { Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 1, -22), BackgroundTransparency = 1, Text = "", Parent = row })

    local api = {}
    function api:Set(v, silent)
        v = math.clamp(tonumber(v) or min, min, max)
        v = math.floor((v - min) / inc + 0.5) * inc + min
        v = math.clamp(tonumber(string.format("%.4f", v)), min, max)
        value = v
        valLbl.Text = tostring(v) .. suffix
        tween(fill, { Size = UDim2.new((v - min) / math.max(max - min, 1e-9), 0, 1, 0) }, 0.08)
        setFlag(flag, v)
        if not silent then safe(cb, v) end
    end
    function api:Get() return value end
    function api:Destroy() row:Destroy() end

    local dragging = false
    local function update(x)
        local pct = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        api:Set(min + (max - min) * pct)
    end
    connect(hit.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(i.Position.X)
        end
    end)
    connect(UIS.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
    connect(UIS.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    api:Set(value, true); regFlag(flag, function(v) api:Set(v) end)
    return api
end

function Section:AddDropdown(o)
    o = norm(o)
    local list = o.Options or o.Values or o.List or {}
    local multi = o.Multi or o.Multiple or false
    local cb, flag = o.Callback, o.Flag
    local row = self:_Row(32)
    row.ClipsDescendants = true
    local head = Create("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Text = "", Parent = row })
    newLabel({ Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(0.5, -12, 0, 32), Text = pick(o, "Name", "Title", "Text") or "Dropdown",
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = head })
    local valLbl = newLabel({ Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0.5, -28, 0, 32), TextColor3 = Theme.SubText,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd, Parent = head })
    local arrow = newLabel({ AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 0), Size = UDim2.new(0, 14, 0, 32),
        Text = "▾", TextColor3 = Theme.SubText, Parent = head })
    local holder = Create("Frame", { Position = UDim2.new(0, 6, 0, 36), Size = UDim2.new(1, -12, 0, 0), BackgroundTransparency = 1, Parent = row },
        { Create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }) })

    local sel = multi and {} or nil
    local buttons, open, api = {}, false, {}
    local function isSel(v) if multi then return sel[v] == true end return sel == v end
    local function value()
        if multi then
            local t = {}
            for _, v in ipairs(list) do if sel[v] then t[#t + 1] = v end end
            return t
        end
        return sel
    end
    local function paint()
        if multi then
            local t = {}
            for _, v in ipairs(value()) do t[#t + 1] = tostring(v) end
            valLbl.Text = #t > 0 and table.concat(t, ", ") or "-"
        else
            valLbl.Text = sel ~= nil and tostring(sel) or "-"
        end
        for v, b in pairs(buttons) do b.BackgroundColor3 = isSel(v) and Theme.Accent or Theme.Background end
    end
    local function resize()
        tween(row, { Size = UDim2.new(1, 0, 0, open and (40 + #list * 28) or 32) })
        tween(arrow, { Rotation = open and 180 or 0 })
    end
    local function fire()
        paint()
        local v = value()
        setFlag(flag, v)
        safe(cb, v)
    end
    local function build()
        for _, b in pairs(buttons) do b:Destroy() end
        buttons = {}
        for idx, v in ipairs(list) do
            local b = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Theme.Background, Text = tostring(v), Font = Enum.Font.Gotham,
                TextSize = 13, TextColor3 = Theme.Text, AutoButtonColor = false, LayoutOrder = idx, Parent = holder,
            }, { Round(5) })
            buttons[v] = b
            connect(b.MouseButton1Click, function()
                if multi then sel[v] = (not sel[v]) or nil else sel = v; open = false; resize() end
                fire()
            end)
        end
        paint(); resize()
    end

    function api:Set(v, silent)
        if multi then
            sel = {}
            for _, x in ipairs(type(v) == "table" and v or {}) do sel[x] = true end
        else
            sel = v
        end
        paint(); setFlag(flag, value())
        if not silent then safe(cb, value()) end
    end
    function api:Get() return value() end
    function api:Refresh(newList)
        list = newList or {}
        sel = multi and {} or nil
        build()
    end
    function api:Destroy() row:Destroy() end

    connect(head.MouseButton1Click, function() open = not open; resize() end)
    build()
    if o.Default ~= nil then api:Set(o.Default, true) end
    setFlag(flag, value()); regFlag(flag, function(v) api:Set(v) end)
    return api
end

function Section:AddTextbox(o)
    o = norm(o)
    local cb, flag = o.Callback, o.Flag
    local row = self:_Row(32)
    rowLabel(row, pick(o, "Name", "Title", "Text") or "Textbox", -24).Size = UDim2.new(0.45, -12, 0, 32)
    local box = Create("TextBox", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0.55, -14, 0, 22),
        BackgroundColor3 = Theme.Background, Text = o.Default or "", PlaceholderText = o.Placeholder or "",
        PlaceholderColor3 = Theme.SubText, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 13,
        ClearTextOnFocus = o.ClearOnFocus or false, ClipsDescendants = true, Parent = row,
    }, { Round(5) })
    connect(box:GetPropertyChangedSignal("Text"), function()
        if o.Numeric then
            local f = box.Text:gsub("[^%d%.%-]", "")
            if f ~= box.Text then box.Text = f end
        end
    end)
    connect(box.FocusLost, function(enter)
        setFlag(flag, box.Text)
        if enter or o.CallbackOnBlur then safe(cb, box.Text) end
    end)
    local api = {}
    function api:Set(t, silent) box.Text = tostring(t); setFlag(flag, box.Text); if not silent then safe(cb, box.Text) end end
    function api:Get() return box.Text end
    function api:Destroy() row:Destroy() end
    setFlag(flag, box.Text); regFlag(flag, function(v) api:Set(v) end)
    return api
end

function Section:AddBind(o)
    o = norm(o)
    local cb, changed, flag = o.Callback, o.ChangedCallback or o.OnChange, o.Flag
    local key = o.Default or Enum.KeyCode.Unknown
    if type(key) == "string" then key = Enum.KeyCode[key] or Enum.KeyCode.Unknown end
    local row = self:_Row(32)
    rowLabel(row, pick(o, "Name", "Title", "Text") or "Keybind", -100)
    local btn = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0, 80, 0, 22),
        BackgroundColor3 = Theme.Background, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Text,
        AutoButtonColor = false, Text = "", Parent = row,
    }, { Round(5) })
    local listening = false
    local api = {}
    local function refresh() btn.Text = key == Enum.KeyCode.Unknown and "None" or key.Name end
    function api:Set(k, silent)
        if type(k) == "string" then k = Enum.KeyCode[k] or Enum.KeyCode.Unknown end
        key = k; refresh(); setFlag(flag, key.Name)
        if not silent then safe(changed, key) end
    end
    function api:Get() return key end
    function api:Destroy() row:Destroy() end

    connect(btn.MouseButton1Click, function() listening = true; btn.Text = "..." end)
    connect(UIS.InputBegan, function(i, gp)
        if listening then
            if i.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                api:Set(i.KeyCode == Enum.KeyCode.Escape and Enum.KeyCode.Unknown or i.KeyCode)
            end
            return
        end
        if not gp and key ~= Enum.KeyCode.Unknown and i.KeyCode == key then safe(cb, key) end
    end)
    refresh(); setFlag(flag, key.Name); regFlag(flag, function(v) api:Set(v) end)
    return api
end

-- Tab ส่งต่อ element ไปยัง section เริ่มต้น (เรียก Tab:AddButton ได้เลยโดยไม่ต้องสร้าง Section)
local ELEMENTS = { "Label", "Button", "Toggle", "Slider", "Dropdown", "Textbox", "Bind", "Divider" }
for _, n in ipairs(ELEMENTS) do
    local fname = "Add" .. n
    Tab[fname] = function(self, ...)
        local s = self:_Default()
        return s[fname](s, ...)
    end
end

-- ========== นามแฝง (Aliases) ==========
Window.CreateTab, Window.MakeTab, Window.NewTab, Window.Tab = Window.AddTab, Window.AddTab, Window.AddTab, Window.AddTab
Window.CreateSection, Window.Section = Window.AddSection, Window.AddSection
Tab.CreateSection, Tab.Section = Tab.AddSection, Tab.AddSection
Library.MakeWindow, Library.Window, Library.NewWindow = Library.CreateWindow, Library.CreateWindow, Library.CreateWindow

for _, n in ipairs(ELEMENTS) do
    for _, class in ipairs({ Section, Tab }) do
        class["Create" .. n] = class["Add" .. n]
        class[n] = class["Add" .. n]
    end
end
for _, class in ipairs({ Section, Tab }) do
    class.AddKeybind, class.CreateKeybind, class.Keybind = class.AddBind, class.AddBind, class.AddBind
    class.CreateBind = class.AddBind
    class.AddInput, class.CreateInput, class.Input = class.AddTextbox, class.AddTextbox, class.AddTextbox
end

return Library
