-- MacUI v3 : custom macOS-style UI (Luau). UI only, no game logic.
-- Red    = close script (asks to confirm)
-- Yellow = change UI size
-- Green  = hide UI (open again with the logo button or RightShift)
--
-- Built-in icons (drawn from shapes, no asset ids needed, they follow the theme color):
--   sprout, bag, arrow, shield, dumbbell, pin, gear, user, home, sword, search, list
--   aliases: farming, loadout, movement, equip, training, travel, settings, character, combat
-- Icon can also be an asset id: "rbxassetid://123" or just "123".

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local MacUI = {}

local Presets = {
	Dark = {
		Window = Color3.fromRGB(30, 33, 40), Sidebar = Color3.fromRGB(37, 41, 50),
		Card = Color3.fromRGB(41, 45, 54), Field = Color3.fromRGB(52, 57, 68),
		Stroke = Color3.fromRGB(60, 66, 78), Text = Color3.fromRGB(236, 239, 246),
		SubText = Color3.fromRGB(150, 157, 171), Off = Color3.fromRGB(72, 78, 92),
	},
	Midnight = {
		Window = Color3.fromRGB(14, 17, 26), Sidebar = Color3.fromRGB(19, 23, 35),
		Card = Color3.fromRGB(24, 29, 43), Field = Color3.fromRGB(33, 39, 57),
		Stroke = Color3.fromRGB(40, 47, 68), Text = Color3.fromRGB(230, 235, 248),
		SubText = Color3.fromRGB(134, 144, 170), Off = Color3.fromRGB(52, 60, 84),
	},
	Mocha = {
		Window = Color3.fromRGB(36, 31, 31), Sidebar = Color3.fromRGB(43, 37, 37),
		Card = Color3.fromRGB(50, 43, 43), Field = Color3.fromRGB(63, 54, 54),
		Stroke = Color3.fromRGB(72, 62, 62), Text = Color3.fromRGB(242, 235, 230),
		SubText = Color3.fromRGB(170, 158, 150), Off = Color3.fromRGB(88, 76, 76),
	},
	Light = {
		Window = Color3.fromRGB(244, 245, 248), Sidebar = Color3.fromRGB(231, 234, 240),
		Card = Color3.fromRGB(255, 255, 255), Field = Color3.fromRGB(236, 239, 244),
		Stroke = Color3.fromRGB(210, 215, 224), Text = Color3.fromRGB(28, 32, 40),
		SubText = Color3.fromRGB(110, 118, 132), Off = Color3.fromRGB(198, 204, 214),
	},
}
local PresetNames = { "Dark", "Midnight", "Mocha", "Light" }

local Accents = {
	Blue = Color3.fromRGB(41, 148, 255), Purple = Color3.fromRGB(150, 98, 255),
	Pink = Color3.fromRGB(255, 92, 160), Red = Color3.fromRGB(255, 82, 82),
	Orange = Color3.fromRGB(255, 150, 50), Green = Color3.fromRGB(52, 199, 100),
	Teal = Color3.fromRGB(40, 200, 200),
}
local AccentNames = { "Blue", "Purple", "Pink", "Red", "Orange", "Green", "Teal" }

local function tween(inst, props, t)
	TweenService:Create(inst, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function New(className, props, children)
	local inst = Instance.new(className)
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then
			parent = v
		else
			inst[k] = v
		end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local function Round(r)
	return New("UICorner", { CornerRadius = UDim.new(0, r) })
end

local function isPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
end

local function normalizeAsset(id)
	if id == nil or id == "" then
		return nil
	end
	id = tostring(id)
	if string.match(id, "^%d+$") then
		return "rbxassetid://" .. id
	end
	return id
end

----------------------------------------------------------------------
-- drawn icons (16x16 grid)
----------------------------------------------------------------------
local IconDefs = {
	sprout = function(a)
		a.line(8, 15, 8, 7.5, 1.6)
		a.fill(2.2, 4.3, 6, 3.4, 1.7, -30)
		a.fill(8, 2.6, 6, 3.4, 1.7, 30)
	end,
	bag = function(a)
		a.ring(5, 1.5, 6, 8, 3, 1.5)
		a.fill(2.5, 6, 11, 8.5, 2.5)
	end,
	arrow = function(a)
		a.line(2.5, 8, 13, 8, 1.7)
		a.line(13, 8, 8.5, 3.5, 1.7)
		a.line(13, 8, 8.5, 12.5, 1.7)
	end,
	shield = function(a)
		a.ring(3, 1.5, 10, 12.5, 5, 1.6)
		a.line(8, 4.5, 8, 10, 1.4)
	end,
	dumbbell = function(a)
		a.line(4.5, 8, 11.5, 8, 1.6)
		a.fill(2.5, 4.5, 2.2, 7, 1)
		a.fill(11.3, 4.5, 2.2, 7, 1)
		a.fill(0.5, 6, 2, 4, 0.8)
		a.fill(13.5, 6, 2, 4, 0.8)
	end,
	pin = function(a)
		a.ring(4, 1.2, 8, 8, 4, 1.6)
		a.line(5, 8.3, 8, 14.5, 1.6)
		a.line(11, 8.3, 8, 14.5, 1.6)
	end,
	gear = function(a)
		a.ring(3.5, 3.5, 9, 9, 4.5, 2.2)
		a.fill(6.9, 0.8, 2.2, 3, 1)
		a.fill(6.9, 12.2, 2.2, 3, 1)
		a.fill(0.8, 6.9, 3, 2.2, 1)
		a.fill(12.2, 6.9, 3, 2.2, 1)
	end,
	user = function(a)
		a.fill(5, 1.5, 6, 6, 3)
		a.fill(2.5, 9.5, 11, 9, 5)
	end,
	home = function(a)
		a.line(1.5, 8, 8, 2.5, 1.6)
		a.line(14.5, 8, 8, 2.5, 1.6)
		a.ring(3.2, 7.2, 9.6, 7, 1.5, 1.5)
		a.fill(7, 10.5, 2, 3.7, 0.5)
	end,
	sword = function(a)
		a.line(3, 13, 12.5, 3.5, 1.8)
		a.line(3.3, 9.3, 6.7, 12.7, 1.6)
		a.fill(1.8, 12, 2.4, 2.4, 1.2)
	end,
	search = function(a)
		a.ring(2, 2, 9, 9, 4.5, 1.6)
		a.line(9.5, 9.5, 14, 14, 1.8)
	end,
	chevron = function(a)
		a.line(3.5, 6, 8, 10.5, 1.6)
		a.line(12.5, 6, 8, 10.5, 1.6)
	end,
	list = function(a)
		a.line(3, 4.5, 13, 4.5, 1.6)
		a.line(3, 8, 13, 8, 1.6)
		a.line(3, 11.5, 13, 11.5, 1.6)
	end,
}
local IconAlias = {
	farming = "sprout", loadout = "bag", backpack = "bag", movement = "arrow", run = "arrow",
	equip = "shield", training = "dumbbell", travel = "pin", map = "pin", settings = "gear",
	character = "user", combat = "sword", swords = "sword",
}

local function resolveIconName(s)
	s = string.lower(s)
	if IconDefs[s] then
		return s
	end
	return IconAlias[s]
end

local function buildIcon(name, parent, size)
	local s = size or 16
	local k = s / 16
	local root = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(s, s),
		ClipsDescendants = true,
		Parent = parent,
	})
	local parts = {}
	local api = {}

	function api.fill(x, y, w, h, radius, rot)
		local f = New("Frame", {
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(x * k, y * k),
			Size = UDim2.fromOffset(w * k, h * k),
			Rotation = rot or 0,
			Parent = root,
		}, { Round((radius or 0) * k) })
		table.insert(parts, { Inst = f, Kind = "fill" })
	end
	function api.ring(x, y, w, h, radius, thick)
		local f = New("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(x * k, y * k),
			Size = UDim2.fromOffset(w * k, h * k),
			Parent = root,
		}, { Round(radius * k) })
		local st = New("UIStroke", {
			Thickness = thick * k,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = f,
		})
		table.insert(parts, { Inst = st, Kind = "stroke" })
	end
	function api.line(x1, y1, x2, y2, t)
		local dx, dy = x2 - x1, y2 - y1
		local len = math.sqrt(dx * dx + dy * dy)
		local f = New("Frame", {
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset((x1 + x2) / 2 * k, (y1 + y2) / 2 * k),
			Size = UDim2.fromOffset(len * k, t * k),
			Rotation = math.deg(math.atan2(dy, dx)),
			Parent = root,
		}, { Round(t * k / 2) })
		table.insert(parts, { Inst = f, Kind = "fill" })
	end

	IconDefs[name](api)
	return { Root = root, Parts = parts, Kind = "drawn" }
end

local function makeIcon(parent, icon, size)
	size = size or 16
	local name = resolveIconName(icon)
	if name then
		return buildIcon(name, parent, size)
	end
	local img = normalizeAsset(icon)
	if string.find(img, "rbxasset") or string.find(img, "http") then
		return {
			Kind = "image",
			Root = New("ImageLabel", {
				BackgroundTransparency = 1,
				Image = img,
				Size = UDim2.fromOffset(size, size),
				Parent = parent,
			}),
		}
	end
	return {
		Kind = "text",
		Root = New("TextLabel", {
			BackgroundTransparency = 1,
			Text = icon,
			Font = Enum.Font.Gotham,
			TextSize = size - 2,
			Size = UDim2.fromOffset(size, size),
			Parent = parent,
		}),
	}
end

local function tintIcon(ic, color)
	if ic.Kind == "drawn" then
		for _, p in ipairs(ic.Parts) do
			if p.Kind == "fill" then
				p.Inst.BackgroundColor3 = color
			else
				p.Inst.Color = color
			end
		end
	elseif ic.Kind == "image" then
		ic.Root.ImageColor3 = color
	else
		ic.Root.TextColor3 = color
	end
end

----------------------------------------------------------------------
function MacUI.CreateWindow(opts)
	opts = opts or {}
	local WIDTH, HEIGHT, SIDE = 560, 370, 150
	local conns = {}

	-- theme system
	local Theme = {}
	local hooks = {}

	local function derive()
		Theme.Selected = Theme.Accent:Lerp(Color3.new(1, 1, 1), 0.45)
		Theme.SelectedText = Color3.fromRGB(18, 24, 36)
	end
	local function loadPreset(name)
		for k, v in pairs(Presets[name]) do
			Theme[k] = v
		end
	end
	loadPreset((opts.Theme and Presets[opts.Theme]) and opts.Theme or "Dark")
	Theme.Accent = opts.Accent or Accents.Blue
	derive()

	local function applyTheme()
		for _, h in ipairs(hooks) do
			h()
		end
	end
	local function themed(inst, map)
		local function h()
			for prop, key in pairs(map) do
				inst[prop] = Theme[key]
			end
		end
		h()
		table.insert(hooks, h)
		return inst
	end
	local function themedIcon(ic, key)
		local function h()
			tintIcon(ic, Theme[key])
		end
		h()
		table.insert(hooks, h)
	end
	local function Stroke(key)
		return themed(New("UIStroke", {
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}), { Color = key or "Stroke" })
	end
	local function Label(props, key)
		local base = {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}
		for k, v in pairs(props) do
			base[k] = v
		end
		return themed(New("TextLabel", base), { TextColor3 = key or "Text" })
	end

	-- gui root
	local gui = New("ScreenGui", {
		Name = "MacUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	local ok = pcall(function()
		gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
	end)
	if not ok or not gui.Parent then
		gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	end

	local main = themed(New("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(WIDTH, HEIGHT),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = gui,
	}, { Round(12), Stroke("Stroke") }), { BackgroundColor3 = "Window" })

	local scaleObj = New("UIScale", { Scale = 1, Parent = main })
	local currentScale = 1
	local scaleSlider
	do
		local cam = workspace.CurrentCamera
		if cam then
			local vp = cam.ViewportSize
			local fit = math.min(vp.X / (WIDTH + 30), vp.Y / (HEIGHT + 30))
			if fit < 1 then
				currentScale = math.max(fit, 0.5)
			end
		end
		scaleObj.Scale = currentScale
	end
	local function setScale(v)
		v = math.clamp(v, 0.5, 1.5)
		currentScale = v
		tween(scaleObj, { Scale = v }, 0.15)
		if scaleSlider then
			scaleSlider:Set(v)
		end
	end

	-- sidebar
	local sidebar = themed(New("Frame", {
		Size = UDim2.new(0, SIDE, 1, 0),
		BorderSizePixel = 0,
		Parent = main,
	}, { Round(12) }), { BackgroundColor3 = "Sidebar" })
	themed(New("Frame", {
		Size = UDim2.new(0, 12, 1, 0),
		Position = UDim2.new(1, -12, 0, 0),
		BorderSizePixel = 0,
		Parent = sidebar,
	}), { BackgroundColor3 = "Sidebar" })
	themed(New("Frame", {
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, -1, 0, 0),
		BorderSizePixel = 0,
		Parent = sidebar,
	}), { BackgroundColor3 = "Stroke" })

	local sideList = New("ScrollingFrame", {
		Position = UDim2.new(0, 0, 0, 44),
		Size = UDim2.new(1, -1, 1, -44),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = sidebar,
	}, {
		New("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
		}),
	})

	-- traffic lights
	local lights = {}
	local function light(x, color, glyph)
		local b = New("TextButton", {
			Text = "",
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			TextColor3 = Color3.fromRGB(60, 24, 20),
			AutoButtonColor = false,
			Position = UDim2.fromOffset(x, 16),
			Size = UDim2.fromOffset(13, 13),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Parent = sidebar,
		}, { Round(7) })
		table.insert(lights, { Button = b, Glyph = glyph })
		return b
	end
	local red = light(14, Color3.fromRGB(255, 95, 87), "×")
	local yellow = light(35, Color3.fromRGB(254, 188, 46), "+")
	local green = light(56, Color3.fromRGB(40, 200, 64), "–")
	for _, l in ipairs(lights) do
		l.Button.MouseEnter:Connect(function()
			for _, o in ipairs(lights) do
				o.Button.Text = o.Glyph
			end
		end)
		l.Button.MouseLeave:Connect(function()
			for _, o in ipairs(lights) do
				o.Button.Text = ""
			end
		end)
	end

	-- top bar
	local topbar = New("Frame", {
		Position = UDim2.new(0, SIDE, 0, 0),
		Size = UDim2.new(1, -SIDE, 0, 44),
		BackgroundTransparency = 1,
		Parent = main,
	})
	local logoId = normalizeAsset(opts.Logo)
	local textX = 16
	if logoId then
		New("ImageLabel", {
			BackgroundTransparency = 1,
			Image = logoId,
			ScaleType = Enum.ScaleType.Fit,
			Position = UDim2.fromOffset(14, 8),
			Size = UDim2.fromOffset(28, 28),
			Parent = topbar,
		})
		textX = 52
	end
	Label({
		Text = opts.Title or "My Script",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Position = UDim2.fromOffset(textX, 6),
		Size = UDim2.new(1, -textX - 170, 0, 18),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = topbar,
	}, "Text")
	Label({
		Text = opts.Subtitle or "Primary",
		TextSize = 11,
		Position = UDim2.fromOffset(textX, 23),
		Size = UDim2.new(1, -textX - 170, 0, 14),
		Parent = topbar,
	}, "SubText")

	local searchBox = themed(New("TextBox", {
		Text = "",
		PlaceholderText = "Search",
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(150, 26),
		BorderSizePixel = 0,
		Parent = topbar,
	}, { Round(6), New("UIPadding", { PaddingLeft = UDim.new(0, 28), PaddingRight = UDim.new(0, 8) }) }), {
		BackgroundColor3 = "Field", TextColor3 = "Text", PlaceholderColor3 = "SubText",
	})
	do
		local si = buildIcon("search", searchBox, 14)
		si.Root.Position = UDim2.fromOffset(-20, 6)
		themedIcon(si, "SubText")
	end

	local pages = New("Frame", {
		Position = UDim2.new(0, SIDE, 0, 44),
		Size = UDim2.new(1, -SIDE, 1, -44),
		BackgroundTransparency = 1,
		Parent = main,
	})
	local noResults = Label({
		Text = "No results",
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = pages,
	}, "SubText")

	-- open button: logo only, no background (fallback letter if the image fails to load)
	local openBtn = New("TextButton", {
		Name = "OpenButton",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 16, 0.5, -26),
		Size = UDim2.fromOffset(52, 52),
		Parent = gui,
	})
	local fallback = themed(New("TextLabel", {
		Text = string.upper(string.sub(opts.Title or "M", 1, 1)),
		Font = Enum.Font.GothamBold,
		TextSize = 22,
		TextColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Visible = (logoId == nil),
		Parent = openBtn,
	}, { Round(14) }), { BackgroundColor3 = "Accent" })
	if logoId then
		local img = New("ImageLabel", {
			BackgroundTransparency = 1,
			Image = logoId,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(1, 1),
			Parent = openBtn,
		})
		img:GetPropertyChangedSignal("IsLoaded"):Connect(function()
			if img.IsLoaded then
				fallback.Visible = false
			end
		end)
		task.delay(5, function()
			if img.Parent and not img.IsLoaded then
				fallback.Visible = true
				warn("[MacUI] Logo did not load, check the image id: " .. tostring(opts.Logo))
			end
		end)
	end

	local function toggleMain()
		main.Visible = not main.Visible
	end

	-- dragging (window, open button, sliders)
	local dragging, dragStart, startPos = false, nil, nil
	local btnDrag = nil
	local activeSlider = nil

	local function makeDraggable(handle)
		handle.InputBegan:Connect(function(input)
			if isPress(input) then
				dragging, dragStart, startPos = true, input.Position, main.Position
			end
		end)
	end
	makeDraggable(topbar)
	makeDraggable(sidebar)

	openBtn.InputBegan:Connect(function(input)
		if isPress(input) then
			btnDrag = { start = input.Position, pos = openBtn.Position, moved = false }
		end
	end)

	table.insert(conns, UIS.InputChanged:Connect(function(input)
		if not isMove(input) then
			return
		end
		if dragging then
			local d = input.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		elseif btnDrag then
			local d = input.Position - btnDrag.start
			if d.Magnitude > 6 then
				btnDrag.moved = true
			end
			if btnDrag.moved then
				openBtn.Position = UDim2.new(
					btnDrag.pos.X.Scale, btnDrag.pos.X.Offset + d.X,
					btnDrag.pos.Y.Scale, btnDrag.pos.Y.Offset + d.Y
				)
			end
		elseif activeSlider then
			activeSlider(input.Position.X)
		end
	end))
	table.insert(conns, UIS.InputEnded:Connect(function(input)
		if isPress(input) then
			dragging = false
			activeSlider = nil
			if btnDrag then
				if not btnDrag.moved then
					toggleMain()
				end
				btnDrag = nil
			end
		end
	end))

	-- close confirmation dialog
	local confirm = New("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 100,
		Parent = main,
	}, { Round(12) })
	local dlg = themed(New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(280, 150),
		BorderSizePixel = 0,
		Parent = confirm,
	}, { Round(12), Stroke("Stroke") }), { BackgroundColor3 = "Card" })
	Label({
		Text = "Close script?",
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		Position = UDim2.fromOffset(20, 16),
		Size = UDim2.new(1, -40, 0, 20),
		Parent = dlg,
	}, "Text")
	Label({
		Text = "This turns off everything and removes the UI. You will need to run the script again to use it.",
		TextSize = 12,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		Position = UDim2.fromOffset(20, 42),
		Size = UDim2.new(1, -40, 0, 50),
		Parent = dlg,
	}, "SubText")
	local cancelBtn = themed(New("TextButton", {
		Text = "Cancel",
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		AutoButtonColor = false,
		Position = UDim2.fromOffset(20, 104),
		Size = UDim2.fromOffset(115, 30),
		BorderSizePixel = 0,
		Parent = dlg,
	}, { Round(7), Stroke("Stroke") }), { BackgroundColor3 = "Field", TextColor3 = "Text" })
	local closeBtn = New("TextButton", {
		Text = "Close",
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = Color3.new(1, 1, 1),
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(255, 95, 87),
		Position = UDim2.fromOffset(145, 104),
		Size = UDim2.fromOffset(115, 30),
		BorderSizePixel = 0,
		Parent = dlg,
	}, { Round(7) })

	----------------------------------------------------------------
	-- tabs, groups, search
	----------------------------------------------------------------
	local Window = {}
	local currentTab
	local order = 0
	local tabsList = {}
	local groups, groupList = {}, {}

	local function applyFilter()
		local q = string.lower(searchBox.Text)
		q = string.gsub(q, "^%s+", "")
		q = string.gsub(q, "%s+$", "")
		local firstMatch
		for _, tab in ipairs(tabsList) do
			local any = false
			for _, sec in ipairs(tab._sections) do
				local secAny = false
				for _, r in ipairs(sec.Rows) do
					local m = (q == "") or (string.find(r.Key, q, 1, true) ~= nil)
					r.Frame.Visible = m
					if m then
						secAny = true
					end
				end
				sec.Holder.Visible = (q == "") or secAny
				if secAny then
					any = true
				end
			end
			tab.HasMatch = any
			tab.Button.Visible = (q == "") or any
			if any and not firstMatch then
				firstMatch = tab
			end
		end

		local seenShown = false
		for _, g in ipairs(groupList) do
			local shown = false
			for _, t in ipairs(g.Tabs) do
				if t.Button.Visible then
					shown = true
				end
			end
			g.Label.Visible = shown
			if g.Divider then
				g.Divider.Visible = shown and seenShown
			end
			if shown then
				seenShown = true
			end
		end

		if q ~= "" and not firstMatch then
			noResults.Visible = true
			if currentTab then
				currentTab.Page.Visible = false
			end
			return
		end
		noResults.Visible = false
		if q ~= "" and currentTab and not currentTab.HasMatch and firstMatch then
			Window._select(firstMatch, true)
		elseif currentTab then
			currentTab.Page.Visible = true
		end
	end
	searchBox:GetPropertyChangedSignal("Text"):Connect(applyFilter)

	local function styleTab(tab)
		local selected = (currentTab == tab)
		tab.Button.BackgroundColor3 = Theme.Selected
		local c = selected and Theme.SelectedText or Theme.SubText
		tab.Text.TextColor3 = c
		tab.Bar.Visible = selected
		if tab.Icon and not tab.NoTint then
			tintIcon(tab.Icon, c)
		end
	end

	local function selectTab(tab, skipFilter)
		local old = currentTab
		currentTab = tab
		if old and old ~= tab then
			old.Page.Visible = false
			tween(old.Button, { BackgroundTransparency = 1 })
			styleTab(old)
		end
		tab.Page.Visible = true
		tween(tab.Button, { BackgroundTransparency = 0 })
		styleTab(tab)
		if not skipFilter then
			applyFilter()
		end
	end
	Window._select = selectTab

	local function makeSection(tab, o)
		o = o or {}
		local Section = { _count = 0 }
		tab._order += 1

		local holder = New("Frame", {
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			LayoutOrder = tab._order,
			Parent = tab.Page,
		}, { New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })
		local secEntry = { Holder = holder, Rows = {} }
		table.insert(tab._sections, secEntry)

		if o.Title then
			Label({
				Text = o.Title,
				Font = Enum.Font.GothamBold,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				TextWrapped = true,
				LayoutOrder = 1,
				Parent = holder,
			}, "Text")
		end
		if o.Desc then
			Label({
				Text = o.Desc,
				TextSize = 12,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				TextWrapped = true,
				LayoutOrder = 2,
				Parent = holder,
			}, "SubText")
		end

		local card = themed(New("Frame", {
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			LayoutOrder = 3,
			Parent = holder,
		}, { Round(8), Stroke("Stroke"), New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) }), {
			BackgroundColor3 = "Card",
		})

		local function newRow(title, desc)
			Section._count += 1
			local hasDesc = desc ~= nil and desc ~= ""
			local row = New("Frame", {
				Name = title or "Row",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, hasDesc and 52 or 40),
				LayoutOrder = Section._count,
				Parent = card,
			})
			if Section._count > 1 then
				themed(New("Frame", {
					Position = UDim2.fromOffset(14, 0),
					Size = UDim2.new(1, -28, 0, 1),
					BorderSizePixel = 0,
					Parent = row,
				}), { BackgroundColor3 = "Stroke" })
			end
			Label({
				Text = title or "",
				Font = Enum.Font.GothamMedium,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Position = UDim2.new(0, 14, 0, hasDesc and 9 or 0),
				Size = hasDesc and UDim2.new(1, -200, 0, 18) or UDim2.new(1, -200, 1, 0),
				Parent = row,
			}, "Text")
			local descLabel = Label({
				Text = desc or "",
				TextSize = 12,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Visible = hasDesc,
				Position = UDim2.new(0, 14, 0, 28),
				Size = UDim2.new(1, -200, 0, 16),
				Parent = row,
			}, "SubText")
			table.insert(secEntry.Rows, {
				Frame = row,
				Key = string.lower(table.concat({
					tab.Name or "", o.Title or "", o.Desc or "", title or "", desc or "",
				}, " ")),
			})
			return row, descLabel
		end

		function Section:AddToggle(t)
			local row = newRow(t.Name, t.Desc)
			local state = t.Default == true
			local track = New("TextButton", {
				Text = "",
				AutoButtonColor = false,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 0.5, 0),
				Size = UDim2.fromOffset(40, 22),
				BackgroundColor3 = state and Theme.Accent or Theme.Off,
				BorderSizePixel = 0,
				Parent = row,
			}, { Round(11) })
			local knob = New("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
				Size = UDim2.fromOffset(16, 16),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
				Parent = track,
			}, { Round(8) })
			table.insert(hooks, function()
				track.BackgroundColor3 = state and Theme.Accent or Theme.Off
			end)

			local obj = {}
			local function set(v, silent)
				state = v
				tween(track, { BackgroundColor3 = v and Theme.Accent or Theme.Off })
				tween(knob, { Position = v and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) })
				if not silent and t.Callback then
					task.spawn(t.Callback, v)
				end
			end
			track.MouseButton1Click:Connect(function()
				set(not state)
			end)
			function obj:Set(v)
				set(v, true)
			end
			function obj:Get()
				return state
			end
			return obj
		end

		function Section:AddDropdown(d)
			local row = newRow(d.Name, d.Desc)
			local options = d.Options or {}
			local value = d.Default or options[1]

			local btn = themed(New("TextButton", {
				Text = "",
				AutoButtonColor = false,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 0.5, 0),
				Size = UDim2.fromOffset(150, 26),
				BorderSizePixel = 0,
				Parent = row,
			}, { Round(6), Stroke("Stroke") }), { BackgroundColor3 = "Field" })
			local valueLabel = Label({
				Text = tostring(value),
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Position = UDim2.fromOffset(10, 0),
				Size = UDim2.new(1, -30, 1, 0),
				Parent = btn,
			}, "Text")
			local chev = buildIcon("chevron", btn, 14)
			chev.Root.AnchorPoint = Vector2.new(1, 0.5)
			chev.Root.Position = UDim2.new(1, -6, 0.5, 0)
			themedIcon(chev, "SubText")

			local obj = {}
			local function set(v, silent)
				value = v
				valueLabel.Text = tostring(v)
				if not silent and d.Callback then
					task.spawn(d.Callback, v)
				end
			end

			btn.MouseButton1Click:Connect(function()
				local catcher = New("TextButton", {
					Text = "",
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					ZIndex = 50,
					Parent = gui,
				})
				local popW = 170
				local popH = math.min(#options * 26 + 8, 170)
				local abs, size = btn.AbsolutePosition, btn.AbsoluteSize
				local screen = gui.AbsoluteSize
				local x = math.clamp(abs.X + size.X - popW, 4, math.max(4, screen.X - popW - 4))
				local y = abs.Y + size.Y + 4
				if y + popH > screen.Y - 4 then
					y = math.max(4, abs.Y - popH - 4)
				end
				local pop = New("ScrollingFrame", {
					Position = UDim2.fromOffset(x, y),
					Size = UDim2.fromOffset(popW, popH),
					BackgroundColor3 = Theme.Field,
					BorderSizePixel = 0,
					ScrollBarThickness = 3,
					CanvasSize = UDim2.new(),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ZIndex = 51,
					Parent = gui,
				}, {
					Round(8),
					New("UIStroke", { Color = Theme.Stroke, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
					New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
					New("UIPadding", {
						PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
						PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
					}),
				})
				local function close()
					catcher:Destroy()
					pop:Destroy()
				end
				catcher.MouseButton1Click:Connect(close)
				for i, opt in ipairs(options) do
					local item = New("TextButton", {
						Text = tostring(opt),
						Font = Enum.Font.Gotham,
						TextSize = 13,
						TextColor3 = (opt == value) and Theme.Accent or Theme.Text,
						TextXAlignment = Enum.TextXAlignment.Left,
						AutoButtonColor = false,
						BackgroundColor3 = Theme.Selected,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 26),
						LayoutOrder = i,
						ZIndex = 52,
						Parent = pop,
					}, { Round(5), New("UIPadding", { PaddingLeft = UDim.new(0, 8) }) })
					item.MouseEnter:Connect(function()
						item.BackgroundTransparency = 0.75
					end)
					item.MouseLeave:Connect(function()
						item.BackgroundTransparency = 1
					end)
					item.MouseButton1Click:Connect(function()
						set(opt)
						close()
					end)
				end
			end)

			function obj:Set(v)
				set(v, true)
			end
			function obj:Get()
				return value
			end
			return obj
		end

		function Section:AddSlider(s)
			local row = newRow(s.Name, s.Desc)
			local min, max, inc = s.Min or 0, s.Max or 100, s.Increment or 1
			local value = math.clamp(s.Default or min, min, max)

			local valueLabel = Label({
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Right,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 0.5, 0),
				Size = UDim2.fromOffset(46, 20),
				Parent = row,
			}, "SubText")
			local hit = New("TextButton", {
				Text = "",
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -66, 0.5, 0),
				Size = UDim2.fromOffset(110, 22),
				Parent = row,
			})
			local bar = themed(New("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 0, 6),
				BorderSizePixel = 0,
				Parent = hit,
			}, { Round(3) }), { BackgroundColor3 = "Off" })
			local fill = themed(New("Frame", {
				Size = UDim2.fromScale(0, 1),
				BorderSizePixel = 0,
				Parent = bar,
			}, { Round(3) }), { BackgroundColor3 = "Accent" })

			local function render()
				fill.Size = UDim2.fromScale((value - min) / (max - min), 1)
				valueLabel.Text = tostring(value) .. (s.Suffix or "")
			end
			render()

			local function fromX(x)
				local a = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
				local v = min + (max - min) * a
				v = math.floor(v / inc + 0.5) * inc
				v = math.clamp(tonumber(string.format("%.4f", v)), min, max)
				if v ~= value then
					value = v
					render()
					if s.Callback then
						task.spawn(s.Callback, v)
					end
				end
			end

			hit.InputBegan:Connect(function(input)
				if isPress(input) then
					activeSlider = fromX
					fromX(input.Position.X)
				end
			end)

			local obj = {}
			function obj:Set(v)
				value = math.clamp(tonumber(string.format("%.4f", v)), min, max)
				render()
			end
			function obj:Get()
				return value
			end
			return obj
		end

		function Section:AddButton(b)
			local row = newRow(b.Name, b.Desc)
			local btn = themed(New("TextButton", {
				Text = b.ButtonText or "Run",
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				AutoButtonColor = false,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 0.5, 0),
				Size = UDim2.fromOffset(80, 26),
				BorderSizePixel = 0,
				Parent = row,
			}, { Round(6), Stroke("Stroke") }), { BackgroundColor3 = "Field", TextColor3 = "Text" })
			btn.MouseEnter:Connect(function()
				tween(btn, { BackgroundColor3 = Theme.Off })
			end)
			btn.MouseLeave:Connect(function()
				tween(btn, { BackgroundColor3 = Theme.Field })
			end)
			btn.MouseButton1Click:Connect(function()
				if b.Callback then
					task.spawn(b.Callback)
				end
			end)
		end

		function Section:AddLabel(l)
			local _, descLabel = newRow(l.Name, l.Value or " ")
			local obj = {}
			function obj:Set(text)
				descLabel.Text = text
			end
			return obj
		end

		return Section
	end

	function Window:AddTab(o)
		o = o or {}
		local group
		if o.Section then
			group = groups[o.Section]
			if not group then
				group = { Tabs = {} }
				groups[o.Section] = group
				if #groupList > 0 then
					order += 1
					group.Divider = themed(New("Frame", {
						Size = UDim2.new(1, 0, 0, 1),
						BorderSizePixel = 0,
						LayoutOrder = order,
						Parent = sideList,
					}), { BackgroundColor3 = "Stroke" })
				end
				order += 1
				group.Label = Label({
					Text = o.Section,
					TextSize = 11,
					Size = UDim2.new(1, 0, 0, 26),
					LayoutOrder = order,
					Parent = sideList,
				}, "SubText")
				New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingTop = UDim.new(0, 6), Parent = group.Label })
				table.insert(groupList, group)
			end
		end

		order += 1
		local btn = New("TextButton", {
			Name = o.Name,
			Text = "",
			AutoButtonColor = false,
			BackgroundColor3 = Theme.Selected,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			LayoutOrder = order,
			Parent = sideList,
		}, { Round(6) })
		local bar = themed(New("Frame", {
			Position = UDim2.new(0, 3, 0.5, -7),
			Size = UDim2.fromOffset(3, 14),
			BorderSizePixel = 0,
			Visible = false,
			Parent = btn,
		}, { Round(2) }), { BackgroundColor3 = "Accent" })

		local icon
		if o.Icon then
			icon = makeIcon(btn, o.Icon, 16)
			icon.Root.Position = UDim2.new(0, 12, 0.5, -8)
		end
		local text = New("TextLabel", {
			BackgroundTransparency = 1,
			Text = o.Name,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0, icon and 36 or 14, 0, 0),
			Size = UDim2.new(1, -42, 1, 0),
			Parent = btn,
		})

		local page = New("ScrollingFrame", {
			Name = o.Name,
			Visible = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ScrollBarThickness = 3,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Parent = pages,
		}, {
			New("UIListLayout", { Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder }),
			New("UIPadding", {
				PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 14),
				PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
			}),
		})
		themed(page, { ScrollBarImageColor3 = "Off" })

		local Tab = {
			Name = o.Name, Button = btn, Text = text, Icon = icon, Bar = bar, NoTint = o.NoTint,
			Page = page, _sections = {}, _order = 0, HasMatch = true,
		}
		function Tab:AddSection(so)
			return makeSection(Tab, so)
		end
		table.insert(tabsList, Tab)
		if group then
			table.insert(group.Tabs, Tab)
		end
		table.insert(hooks, function()
			styleTab(Tab)
		end)

		btn.MouseButton1Click:Connect(function()
			selectTab(Tab)
		end)
		if not currentTab then
			selectTab(Tab)
		else
			styleTab(Tab)
		end
		return Tab
	end

	-- settings tab (theme, accent, size)
	function Window:SetTheme(name)
		if Presets[name] then
			loadPreset(name)
			derive()
			applyTheme()
		end
	end
	function Window:SetAccent(color)
		Theme.Accent = color
		derive()
		applyTheme()
	end
	function Window:SetScale(v)
		setScale(v)
	end

	function Window:AddSettingsTab(o)
		o = o or {}
		local tab = Window:AddTab({
			Section = o.Section or "Settings",
			Name = o.Name or "Settings",
			Icon = o.Icon or "gear",
		})

		local look = tab:AddSection({ Title = "Appearance", Desc = "Change the UI color tone." })
		look:AddDropdown({
			Name = "Theme",
			Desc = "Base colors of the window.",
			Options = PresetNames,
			Default = opts.Theme or "Dark",
			Callback = function(v)
				Window:SetTheme(v)
			end,
		})

		local r, g, b
		local function updateSliders(c)
			r:Set(math.floor(c.R * 255 + 0.5))
			g:Set(math.floor(c.G * 255 + 0.5))
			b:Set(math.floor(c.B * 255 + 0.5))
		end
		local function fromSliders()
			Window:SetAccent(Color3.fromRGB(r:Get(), g:Get(), b:Get()))
		end

		look:AddDropdown({
			Name = "Accent color",
			Desc = "Switches, sliders and highlights.",
			Options = AccentNames,
			Default = "Blue",
			Callback = function(v)
				Window:SetAccent(Accents[v])
				updateSliders(Accents[v])
			end,
		})
		local startC = Theme.Accent
		r = look:AddSlider({ Name = "Accent red", Min = 0, Max = 255, Default = math.floor(startC.R * 255 + 0.5), Callback = fromSliders })
		g = look:AddSlider({ Name = "Accent green", Min = 0, Max = 255, Default = math.floor(startC.G * 255 + 0.5), Callback = fromSliders })
		b = look:AddSlider({ Name = "Accent blue", Min = 0, Max = 255, Default = math.floor(startC.B * 255 + 0.5), Callback = fromSliders })

		local win = tab:AddSection({ Title = "Window", Desc = "Size and controls." })
		scaleSlider = win:AddSlider({
			Name = "UI size",
			Desc = "Also changed by the yellow button.",
			Min = 0.5, Max = 1.5, Default = currentScale, Increment = 0.05, Suffix = "x",
			Callback = function(v)
				currentScale = v
				tween(scaleObj, { Scale = v }, 0.1)
			end,
		})
		win:AddButton({
			Name = "Unload script",
			Desc = "Same as the red button.",
			ButtonText = "Unload",
			Callback = function()
				Window:ConfirmClose()
			end,
		})
		return tab
	end

	-- window controls
	local destroyed = false
	function Window:Destroy()
		if destroyed then
			return
		end
		destroyed = true
		for _, c in ipairs(conns) do
			c:Disconnect()
		end
		gui:Destroy()
		if opts.OnDestroy then
			task.spawn(opts.OnDestroy)
		end
	end
	function Window:ConfirmClose()
		if opts.ConfirmClose == false then
			Window:Destroy()
		else
			main.Visible = true
			confirm.Visible = true
		end
	end
	function Window:Toggle()
		toggleMain()
	end

	red.MouseButton1Click:Connect(function()
		Window:ConfirmClose()
	end)
	cancelBtn.MouseButton1Click:Connect(function()
		confirm.Visible = false
	end)
	closeBtn.MouseButton1Click:Connect(function()
		Window:Destroy()
	end)

	local SIZE_STEPS = { 0.75, 1, 1.25 }
	yellow.MouseButton1Click:Connect(function()
		local nextScale
		for _, s in ipairs(SIZE_STEPS) do
			if s > currentScale + 0.01 then
				nextScale = s
				break
			end
		end
		setScale(nextScale or SIZE_STEPS[1])
	end)
	green.MouseButton1Click:Connect(function()
		confirm.Visible = false
		main.Visible = false
	end)

	local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
	table.insert(conns, UIS.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == toggleKey then
			toggleMain()
		end
	end))

	return Window
end

------------------------------------------------------------------
-- DEMO (replace the print callbacks with your own logic)
------------------------------------------------------------------
local Window = MacUI.CreateWindow({
	Title = "Nyx Hub",
	Subtitle = "Primary",
    Logo = "rbxassetid://134813417493601",
	-- Put your logo id INSIDE this table, between the braces, with a comma at the end:
	-- Theme = "Dark",
	-- OnDestroy = function() print("script unloaded") end,
})

local Farming = Window:AddTab({ Section = "Auto Farm", Name = "Farming", Icon = "sprout" })
local Loadout = Window:AddTab({ Section = "Combat", Name = "Loadout", Icon = "bag" })
local Movement = Window:AddTab({ Section = "Character", Name = "Movement", Icon = "arrow" })
local Equip = Window:AddTab({ Section = "Accessories", Name = "Equip", Icon = "shield" })
local Travel = Window:AddTab({ Section = "Navigation", Name = "Travel", Icon = "pin" })

local General = Farming:AddSection({ Title = "General", Desc = "Main toggles for this tab." })
General:AddToggle({
	Name = "Enabled",
	Desc = "Turn the feature on or off.",
	Default = false,
	Callback = function(v) print("Enabled:", v) end,
})
General:AddLabel({ Name = "Next Event", Value = "80:34" })
General:AddDropdown({
	Name = "Quest Selection",
	Desc = "Smart picks the best quest, or choose one.",
	Options = { "Smart", "Quest 1", "Quest 2", "Quest 3" },
	Default = "Smart",
	Callback = function(v) print("Quest:", v) end,
})

local Bosses = Farming:AddSection({ Title = "Bosses", Desc = "Farms every boss selected below." })
Bosses:AddToggle({
	Name = "Enabled",
	Desc = "Turn boss farming on or off.",
	Default = true,
	Callback = function(v) print("Boss farming:", v) end,
})
Bosses:AddDropdown({
	Name = "Bosses",
	Options = { "[Lv 125] [Boss] Saneri", "[Lv 100] [Boss] Example" },
	Callback = function(v) print("Boss:", v) end,
})

local Move = Movement:AddSection({ Title = "Movement" })
Move:AddSlider({
	Name = "Walk speed",
	Min = 16, Max = 100, Default = 16, Increment = 1,
	Callback = function(v) print("Speed:", v) end,
})
Move:AddButton({
	Name = "Reset character",
	ButtonText = "Reset",
	Callback = function() print("Reset clicked") end,
})

Loadout:AddSection({ Title = "Loadout", Desc = "Empty tab, add your own rows." })
Equip:AddSection({ Title = "Equip", Desc = "Empty tab, add your own rows." })
Travel:AddSection({ Title = "Travel", Desc = "Empty tab, add your own rows." })

Window:AddSettingsTab()
