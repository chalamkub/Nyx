-- MacUI v2 : custom macOS-style UI (Luau). UI only, no game logic.
-- Red = close everything | Yellow = change UI size | Green = hide UI (open with logo button / RightShift)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local MacUI = {}

-- Theme presets (Accent is separate)
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

function MacUI.CreateWindow(opts)
	opts = opts or {}
	local WIDTH, HEIGHT, SIDE = 560, 370, 150
	local conns = {}

	----------------------------------------------------------------
	-- theme system
	----------------------------------------------------------------
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

	----------------------------------------------------------------
	-- gui root
	----------------------------------------------------------------
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

	----------------------------------------------------------------
	-- sidebar
	----------------------------------------------------------------
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

	-- traffic lights (with hover symbols like macOS)
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

	----------------------------------------------------------------
	-- top bar
	----------------------------------------------------------------
	local topbar = New("Frame", {
		Position = UDim2.new(0, SIDE, 0, 0),
		Size = UDim2.new(1, -SIDE, 0, 44),
		BackgroundTransparency = 1,
		Parent = main,
	})
	local textX = 16
	if opts.Logo then
		New("ImageLabel", {
			BackgroundTransparency = 1,
			Image = opts.Logo,
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
	}, { Round(6), New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }) }), {
		BackgroundColor3 = "Field", TextColor3 = "Text", PlaceholderColor3 = "SubText",
	})

	local pages = New("Frame", {
		Position = UDim2.new(0, SIDE, 0, 44),
		Size = UDim2.new(1, -SIDE, 1, -44),
		BackgroundTransparency = 1,
		Parent = main,
	})

	----------------------------------------------------------------
	-- open button (logo only, no background)
	----------------------------------------------------------------
	local openBtn
	if opts.Logo then
		openBtn = New("ImageButton", {
			Image = opts.Logo,
			ScaleType = Enum.ScaleType.Fit,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Position = UDim2.new(0, 16, 0.5, -26),
			Size = UDim2.fromOffset(52, 52),
			Parent = gui,
		})
	else
		openBtn = themed(New("TextButton", {
			Text = string.upper(string.sub(opts.Title or "M", 1, 1)),
			Font = Enum.Font.GothamBold,
			TextSize = 22,
			TextColor3 = Color3.new(1, 1, 1),
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 16, 0.5, -26),
			Size = UDim2.fromOffset(52, 52),
			Parent = gui,
		}, { Round(14) }), { BackgroundColor3 = "Accent" })
	end

	local function toggleMain()
		main.Visible = not main.Visible
	end

	----------------------------------------------------------------
	-- dragging (window, open button, sliders)
	----------------------------------------------------------------
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

	----------------------------------------------------------------
	-- tabs
	----------------------------------------------------------------
	local Window = {}
	local currentTab
	local order = 0
	local seenSections = {}

	local function applyFilter()
		if not currentTab then
			return
		end
		local q = string.lower(searchBox.Text)
		for _, r in ipairs(currentTab._rows) do
			r.Frame.Visible = (q == "" or string.find(r.Key, q, 1, true) ~= nil)
		end
	end
	searchBox:GetPropertyChangedSignal("Text"):Connect(applyFilter)

	local function styleTab(tab)
		local selected = (currentTab == tab)
		tab.Button.BackgroundColor3 = Theme.Selected
		local c = selected and Theme.SelectedText or Theme.SubText
		tab.Text.TextColor3 = c
		if tab.Icon and not tab.NoTint then
			if tab.Icon:IsA("ImageLabel") then
				tab.Icon.ImageColor3 = c
			else
				tab.Icon.TextColor3 = c
			end
		end
	end

	local function selectTab(tab)
		local old = currentTab
		currentTab = tab
		if old then
			old.Page.Visible = false
			tween(old.Button, { BackgroundTransparency = 1 })
			styleTab(old)
		end
		tab.Page.Visible = true
		tween(tab.Button, { BackgroundTransparency = 0 })
		styleTab(tab)
		applyFilter()
	end

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
			table.insert(tab._rows, {
				Frame = row,
				Key = string.lower((title or "") .. " " .. (desc or "")),
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
			Label({
				Text = "▾",
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Center,
				Position = UDim2.new(1, -20, 0, 0),
				Size = UDim2.fromOffset(16, 26),
				Parent = btn,
			}, "SubText")

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

	-- Icon can be: an emoji/symbol ("🌾"), an asset id ("rbxassetid://123" or "123")
	local function makeIcon(parent, icon)
		local img = icon
		if string.match(icon, "^%d+$") then
			img = "rbxassetid://134813417493601" .. icon
		end
		if string.find(img, "rbxasset") or string.find(img, "http") then
			return New("ImageLabel", {
				BackgroundTransparency = 1,
				Image = img,
				Position = UDim2.new(0, 10, 0.5, -8),
				Size = UDim2.fromOffset(16, 16),
				Parent = parent,
			})
		end
		return New("TextLabel", {
			BackgroundTransparency = 1,
			Text = icon,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Center,
			Position = UDim2.new(0, 8, 0, 0),
			Size = UDim2.fromOffset(20, 30),
			Parent = parent,
		})
	end

	function Window:AddTab(o)
		o = o or {}
		if o.Section and not seenSections[o.Section] then
			seenSections[o.Section] = true
			order += 1
			local secLabel = Label({
				Text = o.Section,
				TextSize = 11,
				Size = UDim2.new(1, 0, 0, 26),
				LayoutOrder = order,
				Parent = sideList,
			}, "SubText")
			New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingTop = UDim.new(0, 6), Parent = secLabel })
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
		local icon = o.Icon and makeIcon(btn, o.Icon) or nil
		local text = New("TextLabel", {
			BackgroundTransparency = 1,
			Text = o.Name,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0, icon and 34 or 12, 0, 0),
			Size = UDim2.new(1, -40, 1, 0),
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
			Button = btn, Text = text, Icon = icon, NoTint = o.NoTint,
			Page = page, _rows = {}, _order = 0,
		}
		function Tab:AddSection(so)
			return makeSection(Tab, so)
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

	----------------------------------------------------------------
	-- built-in settings tab (theme, accent, size)
	----------------------------------------------------------------
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
			Icon = o.Icon or "⚙",
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
				Window:Destroy()
			end,
		})
		return tab
	end

	----------------------------------------------------------------
	-- traffic light actions
	----------------------------------------------------------------
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
		main.Visible = false
	end)

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
	function Window:Toggle()
		toggleMain()
	end
	red.MouseButton1Click:Connect(function()
		Window:Destroy()
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
	Title = "My Script",
	Subtitle = "Primary",
	-- Logo = "rbxassetid://YOUR_IMAGE_ID",   -- upload your logo to Roblox and paste the id here
	-- Theme = "Dark", Accent = Color3.fromRGB(41, 148, 255),
	-- OnDestroy = function() print("script unloaded") end,
})

local Farming = Window:AddTab({ Section = "Auto Farm", Name = "Farming", Icon = "🌾" })
local Loadout = Window:AddTab({ Section = "Combat", Name = "Loadout", Icon = "🎒" })
local Movement = Window:AddTab({ Section = "Character", Name = "Movement", Icon = "🏃" })
local Equip = Window:AddTab({ Section = "Accessories", Name = "Equip", Icon = "🛡" })
local Travel = Window:AddTab({ Section = "Navigation", Name = "Travel", Icon = "🗺" })

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
