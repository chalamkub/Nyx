-- MacUI Library : macOS-style UI for Roblox (Luau). UI only, no game logic.
-- This file is an EMPTY window library: no tabs, no demo. It returns the library table.
--
-- LOAD (upload this file to GitHub/Pastebin/etc, then replace the URL with your raw link):
--   local MacUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/USER/REPO/main/MacUI.lua"))()
--
-- USE:
--   MacUI.SetIcons({ Farming = "123456789" })   -- optional, icon image ids by tab name (call before AddTab)
--   local Window = MacUI.CreateWindow({
--       Title = "My Hub", Subtitle = "v1.0",
--       Logo = "rbxassetid://123",          -- only used on the floating open button
--       Theme = "Dark",                      -- Dark | Midnight | Mocha | Light
--       Accent = Color3.fromRGB(41, 148, 255),
--       Glass = 0.18,                        -- 0 = solid, up to 0.6 = very see-through
--       Icons = { Farming = "123456789" },   -- same as MacUI.SetIcons
--       ToggleKey = Enum.KeyCode.RightShift,
--       ConfirmClose = true,                 -- false = red button closes without asking
--       OnDestroy = function() end,
--   })
--   local Tab = Window:AddTab({ Section = "Main", Name = "Home", Icon = "home" })
--   local Sec = Tab:AddSection({ Title = "General", Desc = "..." })
--   Sec:AddToggle / AddDropdown / AddSlider / AddButton / AddLabel   (see the example file)
--   Window:AddSettingsTab()   -- optional ready-made theme / glass / size settings
--   Window:Toggle()  Window:Destroy()  Window:SetTheme(n)  Window:SetAccent(c)  Window:SetScale(n)  Window:SetGlass(n)
--
-- Window buttons: red = close script (asks to confirm), yellow = 2 sizes, green = hide.
-- Built-in drawn icons: sprout, bag, arrow, shield, dumbbell, pin, gear, user, home, sword, search, list,
--   sidebar, left, right, updown, lock, star, bolt, eye, folder
-- Header: [sidebar toggle] [< back] [> forward] Title / Subtitle. Back/forward walk through the tabs you visited.
--   Window:ToggleSidebar() collapses / expands the sidebar.
-- Section icons: Tab:AddSection({ Title = "Bosses", Desc = "...", Icon = "star", IconColor = Color3.fromRGB(255, 82, 82) })
--   Icon can be a built-in name, an image id, or an emoji (emoji keep their own colors).
-- Icon values may also be an image id: "123" / "rbxassetid://123" / { Id = "123", Tint = false, Recolor = false }

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local AssetService = game:GetService("AssetService")

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

-- fires on the very first press (no need to click twice)
local function onPress(btn, fn)
	btn.InputBegan:Connect(function(input)
		if isPress(input) then
			fn()
		end
	end)
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
-- ICON TEXTURES  (set with MacUI.SetIcons or CreateWindow({ Icons = {...} }))
--   Farming = "123456789"                        -> tinted with the theme color
--   Farming = { Id = "123456789", Tint = false } -> shown as-is (colored / black icons)
-- Keys are tab names (not case sensitive). You can add your own tab names too.
-- Search / Chevron / Close / List are the small icons used inside the UI.
----------------------------------------------------------------------
local TINT_IMAGE_ICONS = true -- default for icons that do not set Tint themselves

-- Black / dark icons cannot take the theme color (ImageColor3 multiplies: black x any color = black).
-- With RECOLOR_ICONS = true the script tries to turn the icon pixels white at runtime (keeping the
-- transparency) so it matches the built-in icons. This needs EditableImage access, which some
-- executors / assets do not allow. If it fails you get a warning in the console and the icon stays
-- as uploaded; in that case upload a white version of the icon instead.
-- Set Recolor = false on a single icon ({ Id = "123", Recolor = false }) or here to turn it off.
local RECOLOR_ICONS = true

-- icon ids by tab name (not case sensitive); filled by MacUI.SetIcons / CreateWindow({ Icons = ... })
-- Search / Chevron / Close are the small icons used inside the UI and can be replaced the same way.
local TextureIndex = {}

local function registerIcons(tbl)
	for k, v in pairs(tbl or {}) do
		if v ~= nil and v ~= "" then
			TextureIndex[string.lower(k)] = v
		end
	end
end

function MacUI.SetIcons(tbl)
	registerIcons(tbl)
end

local function getIconTexture(name)
	if type(name) ~= "string" then
		return nil
	end
	return TextureIndex[string.lower(name)]
end

-- returns the configured texture for `name`, otherwise `fallback`
local function getConfiguredIcon(name, fallback)
	return getIconTexture(name) or fallback
end

local function isAssetLike(x)
	if type(x) == "table" then
		return x.Id ~= nil
	end
	if type(x) ~= "string" then
		return false
	end
	local str = tostring(x)
	return string.match(str, "^%d+$") ~= nil
		or string.find(str, "rbxasset", 1, true) ~= nil
		or string.find(str, "http", 1, true) ~= nil
end

----------------------------------------------------------------------
-- drawn icons (16x16 grid) - used when no texture id is set
----------------------------------------------------------------------
local IconDefs = {
	home = function(a)
		a.line(2.4, 7.1, 8, 2.5, 1.2); a.line(8, 2.5, 13.6, 7.1, 1.2)
		a.line(3.5, 6.4, 3.5, 13.6, 1.2); a.line(12.5, 6.4, 12.5, 13.6, 1.2)
		a.line(3.5, 13.6, 12.5, 13.6, 1.2); a.line(6.4, 13.6, 6.4, 9.5, 1.2); a.line(6.4, 9.5, 9.6, 9.5, 1.2); a.line(9.6, 9.5, 9.6, 13.6, 1.2)
	end,

	sprout = function(a)
		a.fill(2.2, 9.8, 2.2, 3.6, 0.7)
		a.fill(5.4, 7.2, 2.2, 6.2, 0.7)
		a.fill(8.6, 4.6, 2.2, 8.8, 0.7)
		a.line(11.2, 13.4, 13.6, 11.0, 1.15)
	end,

	bag = function(a)
		a.outline(3.0, 5.0, 10.0, 9.0, 2.0, 1.2)
		a.line(5.3, 5.0, 5.3, 3.7, 1.15); a.line(10.7, 5.0, 10.7, 3.7, 1.15); a.line(5.3, 3.7, 10.7, 3.7, 1.15)
		a.line(3.2, 8.0, 12.8, 8.0, 1.0)
	end,

	arrow = function(a)
		a.ring(8.8, 2.2, 3.0, 3.0, 1.5, 1.15)
		a.line(8.0, 6.0, 6.0, 9.0, 1.25)
		a.line(6.0, 9.0, 9.0, 10.2, 1.25)
		a.line(6.0, 8.8, 3.6, 11.8, 1.2)
		a.line(9.0, 10.2, 12.5, 12.8, 1.2)
		a.line(7.0, 7.1, 11.6, 6.2, 1.15)
	end,

	shield = function(a)
		a.line(8, 1.9, 12.5, 4.0, 1.2); a.line(12.5, 4.0, 11.7, 10.2, 1.2); a.line(11.7, 10.2, 8, 14.0, 1.2)
		a.line(8, 14.0, 4.3, 10.2, 1.2); a.line(4.3, 10.2, 3.5, 4.0, 1.2); a.line(3.5, 4.0, 8, 1.9, 1.2)
		a.line(6.0, 8.0, 7.3, 9.3, 1.1); a.line(7.3, 9.3, 10.2, 6.4, 1.1)
	end,

	dumbbell = function(a)
		a.ring(4.5, 4.0, 4.2, 7.0, 2.1, 1.15); a.ring(7.3, 4.0, 4.2, 7.0, 2.1, 1.15)
		a.line(8.0, 6.0, 8.0, 9.0, 1.15)
		a.line(2.4, 5.0, 2.4, 10.0, 1.15); a.line(13.6, 5.0, 13.6, 10.0, 1.15)
	end,

	pin = function(a)
		a.ring(3.2, 1.8, 9.6, 9.6, 4.8, 1.2)
		a.line(5.0, 9.5, 8.0, 14.0, 1.2); a.line(11.0, 9.5, 8.0, 14.0, 1.2)
		a.ring(6.6, 5.2, 2.8, 2.8, 1.4, 1.05)
	end,

	gear = function(a)
		a.ring(3.0, 3.0, 10.0, 10.0, 5.0, 1.2); a.ring(6.0, 6.0, 4.0, 4.0, 2.0, 1.1)
		a.line(8, 0.9, 8, 2.7, 1.15); a.line(8, 13.3, 8, 15.1, 1.15); a.line(0.9, 8, 2.7, 8, 1.15); a.line(13.3, 8, 15.1, 8, 1.15)
	end,

	user = function(a)
		a.ring(5.0, 1.8, 6.0, 6.0, 3.0, 1.2); a.ring(2.4, 9.0, 11.2, 6.0, 5.0, 1.2)
	end,

	sword = function(a)
		a.line(3.0, 13.0, 12.8, 3.2, 1.2); a.line(2.6, 10.1, 5.9, 13.4, 1.1); a.line(10.6, 5.4, 13.2, 2.8, 1.1)
	end,

	search = function(a)
		a.ring(1.9, 1.9, 8.6, 8.6, 4.3, 1.2); a.line(9.5, 9.5, 13.9, 13.9, 1.2)
	end,

	chevron = function(a)
		a.line(4.0, 5.8, 8.0, 9.9, 1.15); a.line(8.0, 9.9, 12.0, 5.8, 1.15)
	end,

	close = function(a)
		a.line(4.2, 4.2, 11.8, 11.8, 1.2); a.line(11.8, 4.2, 4.2, 11.8, 1.2)
	end,

	sidebar = function(a)
		a.outline(1.8, 3.0, 12.4, 10.0, 2.4, 1.2)
		a.line(6.2, 3.6, 6.2, 12.4, 1.1)
	end,

	left = function(a)
		a.line(10.2, 3.4, 5.4, 8.0, 1.3); a.line(5.4, 8.0, 10.2, 12.6, 1.3)
	end,

	right = function(a)
		a.line(5.8, 3.4, 10.6, 8.0, 1.3); a.line(10.6, 8.0, 5.8, 12.6, 1.3)
	end,

	updown = function(a)
		a.line(5.0, 6.4, 8.0, 3.6, 1.2); a.line(8.0, 3.6, 11.0, 6.4, 1.2)
		a.line(5.0, 9.6, 8.0, 12.4, 1.2); a.line(8.0, 12.4, 11.0, 9.6, 1.2)
	end,

	lock = function(a)
		a.outline(3.4, 7.0, 9.2, 6.8, 2.0, 1.2)
		a.line(5.6, 7.0, 5.6, 4.8, 1.2); a.line(10.4, 7.0, 10.4, 4.8, 1.2)
		a.line(5.6, 4.8, 6.6, 3.2, 1.2); a.line(6.6, 3.2, 9.4, 3.2, 1.2); a.line(9.4, 3.2, 10.4, 4.8, 1.2)
		a.fill(7.3, 9.2, 1.4, 2.2, 0.7)
	end,

	star = function(a)
		a.line(8, 1.8, 10, 6, 1.1); a.line(10, 6, 14.4, 6.5, 1.1); a.line(14.4, 6.5, 11.2, 9.5, 1.1)
		a.line(11.2, 9.5, 12, 14, 1.1); a.line(12, 14, 8, 11.8, 1.1); a.line(8, 11.8, 4, 14, 1.1)
		a.line(4, 14, 4.8, 9.5, 1.1); a.line(4.8, 9.5, 1.6, 6.5, 1.1); a.line(1.6, 6.5, 6, 6, 1.1); a.line(6, 6, 8, 1.8, 1.1)
	end,

	bolt = function(a)
		a.line(9.2, 1.8, 4.4, 9.0, 1.15); a.line(4.4, 9.0, 8.0, 9.0, 1.15); a.line(8.0, 9.0, 6.8, 14.2, 1.15)
		a.line(6.8, 14.2, 11.6, 7.0, 1.15); a.line(11.6, 7.0, 8.0, 7.0, 1.15); a.line(8.0, 7.0, 9.2, 1.8, 1.15)
	end,

	eye = function(a)
		a.ring(1.4, 4.4, 13.2, 7.2, 3.6, 1.2); a.ring(6.0, 6.2, 4.0, 4.0, 2.0, 1.1)
	end,

	folder = function(a)
		a.outline(2.0, 4.6, 12.0, 8.6, 2.0, 1.2)
		a.line(3.0, 4.6, 3.0, 3.6, 1.1); a.line(3.0, 3.6, 6.2, 3.6, 1.1); a.line(6.2, 3.6, 7.4, 4.6, 1.1)
	end,

	list = function(a)
		a.fill(2.0, 3.0, 2.0, 2.0, 0.8); a.fill(2.0, 7.0, 2.0, 2.0, 0.8); a.fill(2.0, 11.0, 2.0, 2.0, 0.8)
		a.line(6.0, 4.0, 13.5, 4.0, 1.1); a.line(6.0, 8.0, 13.5, 8.0, 1.1); a.line(6.0, 12.0, 13.5, 12.0, 1.1)
	end,
}

local IconAlias = {
	farming = "sprout", loadout = "bag", backpack = "bag", movement = "arrow", run = "arrow",
	equip = "shield", training = "dumbbell", travel = "pin", map = "pin", settings = "gear",
	character = "user", combat = "sword", swords = "sword",
	locked = "lock", favorite = "star", power = "bolt", visual = "eye", esp = "eye", files = "folder",
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
		ClipsDescendants = false,
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
	api.outline = api.ring
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

-- Turns every pixel of an icon white (alpha untouched) so ImageColor3 can tint it.
-- Result is cached per image; returns a Content for ImageLabel.ImageContent, or nil on failure.
local RecolorCache = {}
local function getWhiteContent(assetUrl)
	local cached = RecolorCache[assetUrl]
	if cached == "pending" then
		while RecolorCache[assetUrl] == "pending" do
			task.wait(0.05)
		end
		cached = RecolorCache[assetUrl]
	elseif cached == nil then
		RecolorCache[assetUrl] = "pending"
		local ok, result = pcall(function()
			local assetId = tonumber(string.match(assetUrl, "%d+"))
			local content = Content.fromAssetId(assetId)
			local img = AssetService:CreateEditableImageAsync(content)
			local size = img.Size
			local buf = img:ReadPixelsBuffer(Vector2.zero, size)
			local len = buffer.len(buf)
			for i = 0, len - 4, 4 do
				buffer.writeu8(buf, i, 255)
				buffer.writeu8(buf, i + 1, 255)
				buffer.writeu8(buf, i + 2, 255)
				if i % 262144 == 0 then
					task.wait()
				end
			end
			img:WritePixelsBuffer(Vector2.zero, size, buf)
			return img
		end)
		if ok and result then
			RecolorCache[assetUrl] = result
		else
			RecolorCache[assetUrl] = false
			warn("[MacUI] Could not recolor icon " .. tostring(assetUrl)
				.. " (EditableImage blocked or not allowed for this asset). "
				.. "Upload a white version of the icon, or set Tint = false. Reason: " .. tostring(result))
		end
		cached = RecolorCache[assetUrl]
	end
	if cached then
		return Content.fromObject(cached)
	end
	return nil
end

-- icon can be: texture id string / rbxassetid / { Id = , Tint = , Recolor = } / built-in name / emoji text
local function makeIcon(parent, icon, size)
	size = size or 16

	if isAssetLike(icon) then
		local id, tint, recolor
		if type(icon) == "table" then
			id, tint, recolor = normalizeAsset(icon.Id), icon.Tint, icon.Recolor
		else
			id = normalizeAsset(icon)
		end
		if tint == nil then
			tint = TINT_IMAGE_ICONS
		end
		if recolor == nil then
			recolor = RECOLOR_ICONS
		end
		local image = New("ImageLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = id,
			ImageColor3 = Color3.new(1, 1, 1),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromOffset(size, size),
			Parent = parent,
		})
		if tint and recolor then
			task.spawn(function()
				local content = getWhiteContent(id)
				if content and image.Parent then
					image.ImageContent = content
				end
			end)
		end
		return { Kind = "image", Root = image, Tint = tint }
	end

	if type(icon) ~= "string" then
		icon = "list"
	end
	local name = resolveIconName(icon)
	if name then
		return buildIcon(name, parent, size)
	end

	return {
		Kind = "text",
		Root = New("TextLabel", {
			Name = "Icon",
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
	if not ic then
		return
	end
	if ic.Kind == "drawn" then
		for _, p in ipairs(ic.Parts) do
			if p.Kind == "fill" then
				p.Inst.BackgroundColor3 = color
			else
				p.Inst.Color = color
			end
		end
	elseif ic.Kind == "image" then
		-- ImageColor3 multiplies the image color: a white icon takes the theme color,
		-- a black icon stays black. Use Tint = false for colored / black icons.
		if ic.Tint ~= false then
			ic.Root.ImageColor3 = color
		end
	else
		ic.Root.TextColor3 = color
	end
end

----------------------------------------------------------------------
function MacUI.CreateWindow(opts)
	opts = opts or {}
	registerIcons(opts.Icons)
	local WIDTH, HEIGHT, SIDE = 560, 370, 150
	local conns = {}

	-- theme system
	local Theme = {}
	local hooks = {}

	-- glass: 0 = solid window, higher = more see-through
	local glassAmount = (opts.Glass ~= nil) and opts.Glass or 0.18
	local glassOn = glassAmount > 0
	if not glassOn then
		glassAmount = 0.18
	end

	local function derive()
		Theme.Selected = Theme.Accent:Lerp(Color3.new(1, 1, 1), 0.45)
		Theme.SelectedText = Color3.fromRGB(18, 24, 36)
		local g = Theme.Glass or 0
		Theme.GlassMain = g
		Theme.GlassSide = g * 0.6
		Theme.GlassCard = g * 0.7
		Theme.GlassField = g * 0.35
	end
	local function loadPreset(name)
		for k, v in pairs(Presets[name]) do
			Theme[k] = v
		end
	end
	loadPreset((opts.Theme and Presets[opts.Theme]) and opts.Theme or "Dark")
	Theme.Accent = opts.Accent or Accents.Blue
	Theme.Glass = glassOn and glassAmount or 0
	derive()

	local function applyTheme()
		for _, h in ipairs(hooks) do
			h()
		end
	end
	local function refreshGlass()
		Theme.Glass = glassOn and glassAmount or 0
		derive()
		applyTheme()
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

	-- small UI icons (search / chevron / close) also use IconTextures when set
	local function uiIcon(parent, key, fallbackName, size)
		return makeIcon(parent, getConfiguredIcon(key, fallbackName), size)
	end

	-- gui root
	local gui = New("ScreenGui", {
		Name = "MacUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 999,
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
	}, { Round(12), Stroke("Stroke") }), { BackgroundColor3 = "Window", BackgroundTransparency = "GlassMain" })

	-- two sizes (yellow button), always limited to what fits on screen
	local scaleObj = New("UIScale", { Scale = 1, Parent = main })
	local currentScale = 1
	local scaleSlider
	local fitMax = 1.5
	do
		local cam = workspace.CurrentCamera
		if cam then
			local vp = cam.ViewportSize
			fitMax = math.min(vp.X / (WIDTH + 30), vp.Y / (HEIGHT + 30))
		end
		if fitMax < 1 then
			currentScale = math.max(fitMax, 0.5)
		end
		scaleObj.Scale = currentScale
	end
	local SIZE_SMALL = math.max(0.5, math.min(0.85, fitMax))
	local SIZE_LARGE = math.max(0.5, math.min(1.15, fitMax))
	local function setScale(v)
		v = math.clamp(v, 0.5, 1.5)
		currentScale = v
		tween(scaleObj, { Scale = v }, 0.15)
		if scaleSlider then
			scaleSlider:Set(v)
		end
	end

	-- sidebar: clipped container, so only the left corners are round and nothing overlaps
	local sideClip = New("Frame", {
		Size = UDim2.new(0, SIDE, 1, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = main,
	})
	themed(New("Frame", {
		Size = UDim2.new(0, SIDE + 12, 1, 0),
		BorderSizePixel = 0,
		Parent = sideClip,
	}, { Round(12) }), { BackgroundColor3 = "Sidebar", BackgroundTransparency = "GlassSide" })
	themed(New("Frame", {
		Position = UDim2.new(1, -1, 0, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BorderSizePixel = 0,
		Parent = sideClip,
	}), { BackgroundColor3 = "Stroke" })

	local sideList = New("ScrollingFrame", {
		Position = UDim2.new(0, 0, 0, 45),
		Size = UDim2.new(0, SIDE - 1, 1, -45),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = sideClip,
	}, {
		New("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
		}),
	})

	-- drag strip next to the traffic lights (the lights themselves never start a drag)
	local dragStrip = New("Frame", {
		Position = UDim2.fromOffset(84, 0),
		Size = UDim2.new(1, -85, 0, 44),
		BackgroundTransparency = 1,
		Parent = sideClip,
	})

	-- traffic lights: large invisible hit area, action on the first press
	local lights = {}
	local function light(dotX, color, glyph)
		local hit = New("TextButton", {
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(dotX - 4, 9),
			Size = UDim2.fromOffset(21, 26),
			ZIndex = 10,
			Parent = main,
		})
		local dot = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(13, 13),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Parent = hit,
		}, { Round(7) })
		local g = New("TextLabel", {
			BackgroundTransparency = 1,
			Text = "",
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			TextColor3 = Color3.fromRGB(60, 24, 20),
			Size = UDim2.fromScale(1, 1),
			Parent = dot,
		})
		table.insert(lights, { Glyph = glyph, Label = g })
		hit.MouseEnter:Connect(function()
			for _, o in ipairs(lights) do
				o.Label.Text = o.Glyph
			end
		end)
		hit.MouseLeave:Connect(function()
			for _, o in ipairs(lights) do
				o.Label.Text = ""
			end
		end)
		return hit
	end
	local red = light(14, Color3.fromRGB(255, 95, 87), "×")
	local yellow = light(35, Color3.fromRGB(254, 188, 46), "+")
	local green = light(56, Color3.fromRGB(40, 200, 64), "–")

	-- top bar (the logo is only shown on the floating open button)
	local topbar = New("Frame", {
		Position = UDim2.new(0, SIDE, 0, 0),
		Size = UDim2.new(1, -SIDE, 0, 44),
		BackgroundTransparency = 1,
		Parent = main,
	})
	local noDrag = {} -- header controls that must not start a window drag
	local history, histIdx = {}, 0
	local navSelect, onToggleSidebar -- assigned further down
	local headLeft = New("Frame", {
		Name = "HeadLeft",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, -170, 1, 0),
		Parent = topbar,
	})
	local function navButton(x, key, iconName, onClick)
		local hit = New("TextButton", {
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(x, 8),
			Size = UDim2.fromOffset(22, 28),
			Parent = headLeft,
		})
		local ic = uiIcon(hit, key, iconName, 16)
		ic.Root.AnchorPoint = Vector2.new(0.5, 0.5)
		ic.Root.Position = UDim2.fromScale(0.5, 0.5)
		local enabled, hover = true, false
		local function paint()
			tintIcon(ic, (not enabled) and Theme.Off or (hover and Theme.Text or Theme.SubText))
		end
		table.insert(hooks, paint)
		paint()
		hit.MouseEnter:Connect(function()
			hover = true
			paint()
		end)
		hit.MouseLeave:Connect(function()
			hover = false
			paint()
		end)
		onPress(hit, function()
			if enabled then
				onClick()
			end
		end)
		table.insert(noDrag, hit)
		return {
			SetEnabled = function(v)
				enabled = v
				paint()
			end,
		}
	end
	local backBtn, fwdBtn
	local function updateNav()
		backBtn.SetEnabled(histIdx > 1)
		fwdBtn.SetEnabled(histIdx < #history)
	end
	navButton(14, "Sidebar", "sidebar", function()
		if onToggleSidebar then
			onToggleSidebar()
		end
	end)
	backBtn = navButton(36, "Back", "left", function()
		if histIdx > 1 then
			histIdx -= 1
			navSelect(history[histIdx], false, true)
			updateNav()
		end
	end)
	fwdBtn = navButton(57, "Forward", "right", function()
		if histIdx < #history then
			histIdx += 1
			navSelect(history[histIdx], false, true)
			updateNav()
		end
	end)
	updateNav()

	Label({
		Text = opts.Title or "My Script",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Position = UDim2.fromOffset(88, 6),
		Size = UDim2.new(1, -88, 0, 18),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = headLeft,
	}, "Text")
	Label({
		Text = opts.Subtitle or "Primary",
		TextSize = 11,
		Position = UDim2.fromOffset(88, 23),
		Size = UDim2.new(1, -88, 0, 14),
		Parent = headLeft,
	}, "SubText")

	-- divider between the header (title / subtitle / search) and the content
	themed(New("Frame", {
		Name = "HeaderLine",
		Position = UDim2.fromOffset(0, 44),
		Size = UDim2.new(1, 0, 0, 1),
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = main,
	}), { BackgroundColor3 = "Stroke" })

	-- search: frame holds icon + text box + clear button; the text is clipped inside the frame
	local searchFrame = themed(New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(150, 28),
		BorderSizePixel = 0,
		Parent = topbar,
	}, { Round(7) }), { BackgroundColor3 = "Field", BackgroundTransparency = "GlassField" })
	table.insert(noDrag, searchFrame)
	do
		local si = uiIcon(searchFrame, "Search", "search", 14)
		si.Root.AnchorPoint = Vector2.new(0, 0.5)
		si.Root.Position = UDim2.fromOffset(9, 14)
		themedIcon(si, "SubText")
	end
	local searchBox = themed(New("TextBox", {
		Text = "",
		PlaceholderText = "Search",
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextWrapped = false,
		ClipsDescendants = true,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(30, 0),
		Size = UDim2.new(1, -54, 1, 0),
		Parent = searchFrame,
	}), { TextColor3 = "Text", PlaceholderColor3 = "SubText" })
	local clearBtn = New("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -4, 0.5, 0),
		Size = UDim2.fromOffset(20, 20),
		Visible = false,
		Parent = searchFrame,
	})
	do
		local ci = uiIcon(clearBtn, "Close", "close", 12)
		ci.Root.AnchorPoint = Vector2.new(0.5, 0.5)
		ci.Root.Position = UDim2.fromScale(0.5, 0.5)
		themedIcon(ci, "SubText")
	end
	onPress(clearBtn, function()
		searchBox.Text = ""
	end)
	onPress(searchFrame, function()
		searchBox:CaptureFocus()
	end)

	local pages = New("Frame", {
		Position = UDim2.new(0, SIDE, 0, 45),
		Size = UDim2.new(1, -SIDE, 1, -45),
		BackgroundTransparency = 1,
		Parent = main,
	})
	local sideOpen = true
	local LIGHTS_W = 74 -- room for the traffic lights when the sidebar is collapsed
	onToggleSidebar = function()
		sideOpen = not sideOpen
		local w = sideOpen and SIDE or 0
		local lx = sideOpen and 0 or LIGHTS_W
		tween(sideClip, { Size = UDim2.new(0, w, 1, 0) }, 0.2)
		tween(topbar, { Position = UDim2.new(0, w, 0, 0), Size = UDim2.new(1, -w, 0, 44) }, 0.2)
		tween(pages, { Position = UDim2.new(0, w, 0, 45), Size = UDim2.new(1, -w, 1, -45) }, 0.2)
		tween(headLeft, { Position = UDim2.fromOffset(lx, 0), Size = UDim2.new(1, -170 - lx, 1, 0) }, 0.2)
	end

	local noResults = Label({
		Text = "No results",
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = pages,
	}, "SubText")

	-- open button: logo only, no background (letter fallback if the image fails to load)
	local logoId = normalizeAsset(opts.Logo)
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

	local function overSearch(pos)
		for _, f in ipairs(noDrag) do
			local a, sz = f.AbsolutePosition, f.AbsoluteSize
			if pos.X >= a.X and pos.X <= a.X + sz.X and pos.Y >= a.Y and pos.Y <= a.Y + sz.Y then
				return true
			end
		end
		return false
	end
	local function makeDraggable(handle)
		handle.InputBegan:Connect(function(input)
			if isPress(input) and not overSearch(input.Position) then
				dragging, dragStart, startPos = true, input.Position, main.Position
			end
		end)
	end
	makeDraggable(topbar)
	makeDraggable(dragStrip)

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
			local d = (input.Position - dragStart) / currentScale
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
		clearBtn.Visible = (searchBox.Text ~= "")
		local firstMatch
		for _, tab in ipairs(tabsList) do
			local any = false
			for _, sec in ipairs(tab._sections) do
				local secAny = false
				for _, r in ipairs(sec.Rows) do
					local m = (q == "") or (string.find(r.Key, q, 1, true) ~= nil)
					r.Frame.Visible = m
					if m then
						if r.Div then
							r.Div.Visible = secAny
						end
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
			Window._select(firstMatch, true, true)
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
		-- untinted image icons: dim them when the tab is not selected
		if tab.Icon and tab.Icon.Kind == "image" and (tab.NoTint or tab.Icon.Tint == false) then
			tab.Icon.Root.ImageTransparency = selected and 0 or 0.3
		end
	end

	local function selectTab(tab, skipFilter, noHistory)
		local old = currentTab
		if not noHistory and old ~= tab then
			for i = #history, histIdx + 1, -1 do
				history[i] = nil
			end
			table.insert(history, tab)
			histIdx = #history
			updateNav()
		end
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
	navSelect = selectTab

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

		if o.Title and o.Icon then
			local head = New("Frame", {
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 18),
				LayoutOrder = 1,
				Parent = holder,
			})
			local sic = makeIcon(head, o.Icon, 16)
			sic.Root.AnchorPoint = Vector2.new(0, 0.5)
			sic.Root.Position = UDim2.fromOffset(0, 9)
			if o.IconColor then
				tintIcon(sic, o.IconColor)
			else
				themedIcon(sic, "Accent")
			end
			Label({
				Text = o.Title,
				Font = Enum.Font.GothamBold,
				AutomaticSize = Enum.AutomaticSize.Y,
				Position = UDim2.fromOffset(24, 0),
				Size = UDim2.new(1, -24, 0, 18),
				TextWrapped = true,
				Parent = head,
			}, "Text")
		elseif o.Title then
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
			BackgroundColor3 = "Card", BackgroundTransparency = "GlassCard",
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
			local div
			if Section._count > 1 then
				div = themed(New("Frame", {
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
				Div = div,
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
			track.Activated:Connect(function()
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
			}, { Round(6), Stroke("Stroke") }), { BackgroundColor3 = "Field", BackgroundTransparency = "GlassField" })
			local valueLabel = Label({
				Text = tostring(value),
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Position = UDim2.fromOffset(10, 0),
				Size = UDim2.new(1, -30, 1, 0),
				Parent = btn,
			}, "Text")
			local chev = uiIcon(btn, "Chevron", "updown", 14)
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

			btn.Activated:Connect(function()
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
				catcher.Activated:Connect(close)
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
					item.Activated:Connect(function()
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
				local span = max - min
				fill.Size = UDim2.fromScale(span > 0 and (value - min) / span or 0, 1)
				valueLabel.Text = tostring(value) .. (s.Suffix or "")
			end
			render()

			local function fromX(x)
				local a = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
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
			}, { Round(6), Stroke("Stroke") }), {
				BackgroundColor3 = "Field", BackgroundTransparency = "GlassField", TextColor3 = "Text",
			})
			btn.MouseEnter:Connect(function()
				tween(btn, { BackgroundColor3 = Theme.Off })
			end)
			btn.MouseLeave:Connect(function()
				tween(btn, { BackgroundColor3 = Theme.Field })
			end)
			btn.Activated:Connect(function()
				if b.Callback then
					task.spawn(b.Callback)
				end
			end)
			local obj = { Instance = btn }
			function obj:SetText(text)
				btn.Text = tostring(text)
			end
			return obj
		end

		function Section:AddLabel(l)
			local row, descLabel = newRow(l.Name, l.Value or " ")
			row.AutomaticSize = Enum.AutomaticSize.Y
			descLabel.TextTruncate = Enum.TextTruncate.None
			descLabel.TextWrapped = true
			descLabel.TextYAlignment = Enum.TextYAlignment.Top
			descLabel.AutomaticSize = Enum.AutomaticSize.Y
			descLabel.Size = UDim2.new(1, -28, 0, 16)
			New("UIPadding", { PaddingBottom = UDim.new(0, 10), Parent = descLabel })
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

		-- icon priority: explicit asset id > IconTextures[tab name] > IconTextures[icon name] > built-in drawn icon
		local iconSource
		if isAssetLike(o.Icon) then
			iconSource = o.Icon
		else
			iconSource = getIconTexture(o.Name) or getIconTexture(o.Icon) or o.Icon
		end
		local icon
		if iconSource then
			icon = makeIcon(btn, iconSource, 17)
			icon.Root.AnchorPoint = Vector2.new(0, 0.5)
			icon.Root.Position = UDim2.new(0, 11, 0.5, 0)
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
				PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 14),
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

		btn.Activated:Connect(function()
			selectTab(Tab)
		end)
		if not currentTab then
			selectTab(Tab)
		else
			styleTab(Tab)
		end
		return Tab
	end

	-- settings tab (theme, glass, accent, size)
	local ui: any = {} -- settings-tab controls, kept in sync with the Window:Set* functions
	function Window:SetTheme(name)
		if Presets[name] then
			loadPreset(name)
			derive()
			applyTheme()
			if ui.theme then
				ui.theme:Set(name)
			end
		end
	end
	function Window:SetAccent(color)
		Theme.Accent = color
		derive()
		applyTheme()
		if ui.accent then
			local nm = "Custom"
			for n, c in pairs(Accents) do
				if c == color then
					nm = n
				end
			end
			ui.accent:Set(nm)
			ui.r:Set(math.floor(color.R * 255 + 0.5))
			ui.g:Set(math.floor(color.G * 255 + 0.5))
			ui.b:Set(math.floor(color.B * 255 + 0.5))
		end
	end
	function Window:SetScale(v)
		setScale(v)
	end
	function Window:SetGlass(amount)
		amount = math.clamp(amount or 0, 0, 0.6)
		glassOn = amount > 0
		if glassOn then
			glassAmount = amount
		end
		refreshGlass()
		if ui.glassToggle then
			ui.glassToggle:Set(glassOn)
			ui.glassSlider:Set(glassOn and math.floor(glassAmount * 100 + 0.5) or 0)
		end
	end

	function Window:AddSettingsTab(o)
		o = o or {}
		local tab = Window:AddTab({
			Section = o.Section or "Settings",
			Name = o.Name or "Settings",
			Icon = o.Icon or "gear",
		})

		local look = tab:AddSection({ Title = "Appearance", Desc = "Change the UI color tone." })
		ui.theme = look:AddDropdown({
			Name = "Theme",
			Desc = "Base colors of the window.",
			Options = PresetNames,
			Default = (opts.Theme and Presets[opts.Theme]) and opts.Theme or "Dark",
			Callback = function(v)
				Window:SetTheme(v)
			end,
		})
		ui.glassToggle = look:AddToggle({
			Name = "Glass background",
			Desc = "See-through window.",
			Default = glassOn,
			Callback = function(v)
				glassOn = v
				refreshGlass()
				ui.glassSlider:Set(v and math.floor(glassAmount * 100 + 0.5) or 0)
			end,
		})
		ui.glassSlider = look:AddSlider({
			Name = "Glass amount",
			Desc = "How see-through the window is.",
			Min = 0, Max = 60, Increment = 5, Suffix = "%",
			Default = glassOn and math.floor(glassAmount * 100 + 0.5) or 0,
			Callback = function(v)
				if v <= 0 then
					glassOn = false
				else
					glassOn = true
					glassAmount = v / 100
				end
				refreshGlass()
				ui.glassToggle:Set(glassOn)
			end,
		})

		local r, g, b
		local function fromSliders()
			Window:SetAccent(Color3.fromRGB(r:Get(), g:Get(), b:Get()))
		end

		local startC = Theme.Accent
		local startAccent = "Custom"
		for n, c in pairs(Accents) do
			if c == startC then
				startAccent = n
			end
		end
		ui.accent = look:AddDropdown({
			Name = "Accent color",
			Desc = "Switches, sliders and highlights.",
			Options = AccentNames,
			Default = startAccent,
			Callback = function(v)
				Window:SetAccent(Accents[v])
			end,
		})
		r = look:AddSlider({ Name = "Accent red", Min = 0, Max = 255, Default = math.floor(startC.R * 255 + 0.5), Callback = fromSliders })
		g = look:AddSlider({ Name = "Accent green", Min = 0, Max = 255, Default = math.floor(startC.G * 255 + 0.5), Callback = fromSliders })
		b = look:AddSlider({ Name = "Accent blue", Min = 0, Max = 255, Default = math.floor(startC.B * 255 + 0.5), Callback = fromSliders })
		ui.r, ui.g, ui.b = r, g, b

		local win = tab:AddSection({ Title = "Window", Desc = "Size and controls." })
		scaleSlider = win:AddSlider({
			Name = "UI size",
			Desc = "The yellow button switches 2 sizes.",
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
	function Window:ToggleSidebar()
		onToggleSidebar()
	end

	onPress(red, function()
		Window:ConfirmClose()
	end)
	onPress(yellow, function()
		local mid = (SIZE_SMALL + SIZE_LARGE) / 2
		if currentScale >= mid then
			setScale(SIZE_SMALL)
		else
			setScale(SIZE_LARGE)
		end
	end)
	onPress(green, function()
		confirm.Visible = false
		main.Visible = false
	end)
	onPress(cancelBtn, function()
		confirm.Visible = false
	end)
	onPress(closeBtn, function()
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

return MacUI
