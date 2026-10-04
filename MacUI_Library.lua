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
-- Other naming styles work too:
--   Library:Window({ Title, Subtitle, Size = UDim2.fromOffset(500, 350), Theme })   (colon or dot, same as CreateWindow)
--   Window:Tab / CreateTab / MakeTab({ Name, Icon })      Tab:Section / CreateSection({ Title, Desc })
--   Controls can be called on a Section OR directly on a Tab (untitled section is created automatically):
--     Button / CreateButton, Toggle, Slider, Dropdown, Label / Paragraph, Textbox / Input, Bind / Keybind
--   Option aliases: Name/Title/Text, Desc/Description, Callback/Function/Action, CurrentValue, Values/List/Items, Content, ...
--   Textbox: { Name, Default, Placeholder, Numeric, EnterOnly, Callback(text) }   obj:Set / obj:Get
--   Bind:    { Name, Default = Enum.KeyCode.F, Callback(key), OnChange(key), Released(key) }   obj:Set / obj:Get
--   Dropdown object: :Set  :Get  :Refresh(newList)
--   Library:Notify({ Title, Content, Duration = 3, Type = "success" | "warning" | "error" })   (also Window:Notify)
--   Library:Destroy() removes every window; Window:Destroy() removes one.
--   Toggle-UI keybind: CreateWindow({ ToggleKey = Enum.KeyCode.RightShift })  (default RightShift, false = none)
--     Window:SetToggleKey(Enum.KeyCode.F1 | "F1" | false)  Window:GetToggleKey()
--     Window:Show() Hide() Toggle() SetVisible(bool) IsVisible()
--     The Settings tab has a "Toggle UI" row: click it, press a key (Backspace = none, Esc = cancel).
--
-- Supported scripting styles (arguments and names are detected automatically):
--   Rayfield  : Window:CreateTab(name, icon) / Tab:CreateSection / CreateButton, CreateToggle, CreateSlider, CreateDropdown
--               (CurrentOption table, MultipleOptions), CreateInput, CreateKeybind, CreateColorPicker, CreateLabel,
--               CreateParagraph, CreateDivider, Flag + MacUI.Flags.X.CurrentValue, ConfigurationSaving, LoadConfiguration
--   Orion     : MakeWindow / MakeTab / AddButton ... AddParagraph("title", "text"), Flag, MakeNotification, Init()
--   Kavo      : CreateLib("title", "DarkTheme") / NewTab / NewSection / NewButton(name, tip, cb) / NewSlider(name, tip, max, min, cb)
--               ... and :UpdateButton / UpdateToggle / UpdateSlider / UpdateLabel
--   Venyx     : new("title", theme) / addPage / addSection / addButton, addToggle(title, default, cb), addSlider(title, default,
--               min, max, cb), addDropdown(title, list, cb), addKeybind, addColorPicker, addTextbox / section:updateToggle(...)
--   Linoria / Obsidian : Tab:AddLeftGroupbox / AddRightGroupbox / AddTabbox, groupbox:AddToggle("Idx", { Text = .. }),
--               AddSlider, AddDropdown (Multi), AddInput, AddButton, AddLabel, AddDivider, toggle:AddKeyPicker / AddColorPicker,
--               AddDependencyBox; Toggles.Idx / Options.Idx (.Value, :SetValue, :OnChanged, :GetState)
--   Fluent    : Tab:AddToggle("Idx", { Title = .. }), AddSlider (Rounding), AddDropdown, AddInput, AddKeybind, AddColorpicker,
--               AddParagraph, MacUI.Options.Idx, Window:SelectTab, Window:Dialog, MinimizeKey, Notify with SubContent
--   Wally     : Library:CreateWindow("name") then window:Section / Toggle / Button / Slider / Dropdown / Bind / Box / ColorPicker
--               with option tables { flag = .., location = .. } (location[flag] is kept up to date)
--   Config    : Window:SaveConfig(name) / LoadConfig(name) save every control that has a flag / idx (needs writefile).
--   Any other name: method names are matched by meaning, so AddFancySwitch / CreateCheckbox / NewRangeBar / MakeGroup /
--               AddHotkey ... work too (toggle, button, slider, dropdown, textbox, bind, color picker, label, section, tab ...).
--               Dot calls without self (Tab.Button({...})) work. Unknown "AddSomething" names are ignored with one warning.
--   Not supported (accepted but ignored): key systems, loading screens, watermark, add-on managers (SaveManager,
--   ThemeManager, InterfaceManager), image / video rows.
--
-- Window buttons: red = close script (asks to confirm), yellow = 2 sizes, green = hide.
-- Built-in drawn icons: sprout, bag, arrow, shield, dumbbell, pin, gear, user, home, sword, search, list,
--   sidebar, left, right, updown, lock, star, bolt, eye, folder
-- Header: [sidebar toggle] [< back] [> forward] Title / Subtitle. (< > use built-in image ids; override with Icons = { Back = "id", Forward = "id" })
--   < and > go to the previous / next tab: both show on middle tabs, only > on the first tab, only < on the last tab.
--   Window:ToggleSidebar() collapses / expands the sidebar.
-- Profile (bottom of the sidebar): avatar + name of the local player. Options in CreateWindow:
--   ShowUser = true, UserName = "text", UserId = 123, UserImage = "rbxassetid://...", MaskName = false (true -> "iM*****")
--   Window:SetUser({ Name = "text", UserId = 123, Image = "id", Mask = true })
--   Line under the name (e.g. key time left): CreateWindow({ UserNote = "text" }) or Window:SetUserNote("Expires: 23h 53m"),
--     with a colour: Window:SetUserNote(text, Color3) ; RichText works too: 'Expires: <font color="#FF8A3D">23h 53m</font>' 
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
-- built-in image ids for the header icons (override with Icons = { Back = "id", Forward = "id" })
local DefaultUiIcons = {
	back = "96033474959771",     -- chevron-left
	forward = "73855156790773",  -- chevron-right
}

local function getConfiguredIcon(name, fallback)
	return getIconTexture(name) or DefaultUiIcons[string.lower(name)] or fallback
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
		a.line(10.2, 3.4, 5.4, 8.0, 1.6); a.line(5.4, 8.0, 10.2, 12.6, 1.6)
	end,

	right = function(a)
		a.line(5.8, 3.4, 10.6, 8.0, 1.6); a.line(10.6, 8.0, 5.8, 12.6, 1.6)
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
	cog = "gear", settings2 = "gear", player = "user", users = "user", person = "user", target = "pin",
	["map-pin"] = "pin", zap = "bolt", ["folder-open"] = "folder", unlock = "lock", key = "lock", flame = "bolt",
	sparkles = "star", ["sliders-horizontal"] = "gear", wrench = "gear", tool = "gear", house = "home",
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
	if #icon > 1 and string.match(icon, "^[%w_%-%.]+$") then
		return buildIcon("list", parent, size) -- an icon name this library does not draw (not an emoji)
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
-- ============================================================================
-- COMPATIBILITY LAYER: other naming styles, notifications, library-level destroy
-- ============================================================================
local function firstNonNil(...)
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		if v ~= nil then
			return v
		end
	end
	return nil
end

local function copyTable(t)
	local c = {}
	for k, v in pairs(t) do
		c[k] = v
	end
	return c
end

-- Enum.KeyCode.F  /  "F"  /  "RightShift"  ->  Enum.KeyCode item (nil when it is not a key)
local ENUM_ITEM = "EnumItem"
local function toKeyCode(k)
	if typeof(k) == ENUM_ITEM and k.EnumType == Enum.KeyCode then
		return k
	end
	if type(k) == "string" then
		local ok, v = pcall(function()
			return Enum.KeyCode[k]
		end)
		if ok and v then
			return v
		end
	end
	return nil
end

-- control kinds and every method name (from other UI libraries) that maps to them
local KIND_NAMES = {
	Button = { "Button", "CreateButton", "NewButton", "addButton", "MakeButton" },
	Toggle = { "Toggle", "CreateToggle", "NewToggle", "addToggle", "MakeToggle", "AddCheckbox", "Checkbox", "CreateCheckbox" },
	Slider = { "Slider", "CreateSlider", "NewSlider", "addSlider", "MakeSlider" },
	Dropdown = { "Dropdown", "CreateDropdown", "NewDropdown", "addDropdown", "MakeDropdown" },
	Label = {
		"Label", "CreateLabel", "NewLabel", "addLabel", "MakeLabel",
		"Paragraph", "AddParagraph", "CreateParagraph", "NewParagraph", "addParagraph",
	},
	Textbox = {
		"Textbox", "TextBox", "CreateTextbox", "CreateTextBox", "AddTextBox", "NewTextbox", "NewTextBox",
		"addTextbox", "addTextBox", "Input", "AddInput", "CreateInput", "Box", "CreateBox", "AddBox",
	},
	Bind = {
		"Bind", "Keybind", "KeyBind", "CreateBind", "CreateKeybind", "AddKeybind", "AddKeyBind", "NewBind",
		"NewKeybind", "addKeybind", "AddKeyPicker", "KeyPicker", "CreateKeyPicker",
	},
	ColorPicker = {
		"ColorPicker", "Colorpicker", "CreateColorPicker", "CreateColorpicker", "AddColorpicker", "NewColorPicker",
		"addColorPicker", "ColourPicker", "AddColourPicker",
	},
}
local DIVIDER_NAMES = {
	"AddDivider", "CreateDivider", "Divider", "AddSeparator", "CreateSeparator", "Separator", "NewDivider",
}
local BLANK_NAMES = { "AddBlank", "Blank", "AddSpace", "CreateSpace", "AddSpacer", "CreateSpacer", "Spacer" }
local SECTION_NAMES = {
	"AddSection", "CreateSection", "NewSection", "Section", "addSection", "MakeSection", "CreateGroup", "AddGroup",
	"AddGroupbox", "AddLeftGroupbox", "AddRightGroupbox", "CreateFolder", "AddFolder",
}
local TAB_NAMES = {
	"AddTab", "CreateTab", "MakeTab", "NewTab", "Tab", "addPage", "AddPage", "CreatePage", "NewPage", "MakePage", "Page",
}

local COLOR3, ENUMITEM = "Color3", "EnumItem"

local function hexOf(c)
	return string.format("#%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

-- accepts the option names other UI libraries use (Title/Text, CurrentValue, Values, Content, flag, list, ...)
local LOWER_KEYS = {
	flag = "Flag", default = "Default", min = "Min", max = "Max", list = "Options", location = "Location",
	precise = "Precise", name = "Name", text = "Name", callback = "Callback", value = "Value", type = "Type",
}
local function normControl(kind, o)
	if type(o) == "string" then
		o = { Name = o }
	end
	o = o or {}
	local n = copyTable(o)
	for k, v in pairs(o) do
		local c = type(k) == "string" and LOWER_KEYS[k]
		if c and n[c] == nil then
			n[c] = v
		end
	end
	n.Name = firstNonNil(n.Name, n.Title, n.Text, n.Label)
	n.Desc = firstNonNil(n.Desc, n.Description, n.Info, n.SubContent)
	n.Callback = firstNonNil(n.Callback, n.Function, n.Action, n.Func)
	if kind == "Toggle" then
		n.Default = firstNonNil(n.Default, n.CurrentValue, n.Value, n.State, n.Enabled, false)
	elseif kind == "Slider" then
		if type(n.Range) == "table" then
			n.Min = firstNonNil(n.Min, n.Range[1], n.Range.Min)
			n.Max = firstNonNil(n.Max, n.Range[2], n.Range.Max)
		end
		n.Min = firstNonNil(n.Min, n.Minimum)
		n.Max = firstNonNil(n.Max, n.Maximum)
		n.Default = firstNonNil(n.Default, n.CurrentValue, n.Value, n.Min)
		n.Increment = firstNonNil(n.Increment, n.Step)
		if n.Increment == nil and type(n.Rounding) == "number" then
			n.Increment = 10 ^ -n.Rounding
		end
		if n.Increment == nil and n.Precise then
			n.Increment = 0.01
		end
		n.Suffix = firstNonNil(n.Suffix, n.ValueName)
	elseif kind == "Dropdown" then
		n._rayfield = (o.CurrentOption ~= nil) or (o.MultipleOptions ~= nil)
		n.Options = firstNonNil(n.Options, n.Values, n.List, n.Items, n.Choices)
		n.Default = firstNonNil(n.Default, n.CurrentOption, n.Value)
		n.Multi = (firstNonNil(n.Multi, n.MultipleOptions, n.Multiple) == true)
	elseif kind == "Label" then
		n.Value = firstNonNil(n.Value, n.Content, n.Description)
		if n.Value == nil and n.Name ~= nil then
			n.Value = n.Name -- Section:Label("just text")
			n.Name = ""
		end
	elseif kind == "Textbox" then
		n.Default = firstNonNil(n.Default, n.CurrentValue, n.Value, "")
		n.Placeholder = firstNonNil(n.Placeholder, n.PlaceholderText)
		n.EnterOnly = firstNonNil(n.EnterOnly, n.Finished)
		n.ClearOnFocus = firstNonNil(n.ClearOnFocus, n.ClearTextOnFocus)
		n.ClearAfter = firstNonNil(n.ClearAfter, n.TextDisappear, n.RemoveTextAfterFocusLost)
		if n.Numeric == nil and n.Type == "number" then
			n.Numeric = true
		end
	elseif kind == "Bind" then
		n.Default = firstNonNil(n.Default, n.CurrentKeybind, n.CurrentBind, n.Key, n.Keybind, n.Value)
		n.OnChange = firstNonNil(n.OnChange, n.Changed, n.ChangedCallback, n.changedCallback)
		n.Hold = firstNonNil(n.Hold, n.HoldToInteract)
	elseif kind == "ColorPicker" then
		n.Default = firstNonNil(n.Default, n.Color, n.CurrentValue, n.CurrentColor, n.Value)
	end
	return n
end

-- Turns the arguments of any control call into one option table, whatever the library style:
--   table      Toggle({ Name = .. })                      Rayfield / Orion / Fluent
--   idx+table  AddToggle("Idx", { Text = .. })            Linoria / Fluent
--   Kavo       NewButton(name, tip, callback)  NewSlider(name, tip, max, min, callback) ...
--   Venyx      addToggle(title, default, callback)  addSlider(title, default, min, max, callback) ...
--   positional Toggle("name", { flag = .. }, callback)    Wally and similar
local IDX_KINDS = { Toggle = true, Slider = true, Dropdown = true, Textbox = true, Bind = true, ColorPicker = true }
local function parseControl(kind, nameUsed, ...)
	local a1, a2, a3, a4, a5 = ...
	local meta = {}
	if type(a1) == "table" then
		meta.native = (nameUsed == "Add" .. kind)
		return normControl(kind, a1), meta
	end
	if type(a1) ~= "string" then
		return normControl(kind, {}), meta
	end

	if string.match(nameUsed, "^New%u") then -- Kavo
		local n = { Name = a1 }
		if kind == "Button" or kind == "Toggle" or kind == "Textbox" then
			n.Callback = a3
		elseif kind == "Slider" then
			n.Max, n.Min, n.Callback, n.Default = a3, a4, a5, a4
		elseif kind == "Dropdown" then
			n.Options, n.Callback = a3, a4
		elseif kind == "Bind" or kind == "ColorPicker" then
			n.Default, n.Callback = a3, a4
		elseif kind == "Label" then
			n.Name, n.Value = "", a1
		end
		return normControl(kind, n), meta
	end

	if string.match(nameUsed, "^add%u") then -- Venyx
		local n = { Name = a1 }
		if kind == "Button" then
			n.Callback = a2
		elseif kind == "Toggle" or kind == "Textbox" or kind == "ColorPicker" then
			n.Default, n.Callback = a2, a3
		elseif kind == "Bind" then
			n.Default, n.Callback, n.OnChange = a2, a3, a4
		elseif kind == "Slider" then
			n.Default, n.Min, n.Max, n.Callback = a2, a3, a4, a5
		elseif kind == "Dropdown" then
			n.Options, n.Callback = a2, a3
		elseif kind == "Label" then
			n.Name, n.Value = "", a1
		end
		return normControl(kind, n), meta
	end

	if type(a2) == "table" and IDX_KINDS[kind] and string.match(nameUsed, "^Add") then -- Linoria / Fluent
		local n = normControl(kind, a2)
		meta.idx = a1
		n.Name = firstNonNil(n.Name, a1)
		return n, meta
	end

	-- generic positional: name first, then callback / options table / strings / booleans / numbers in any order
	local n = { Name = a1 }
	local strs, bools, nums = {}, {}, {}
	for i = 2, select("#", ...) do
		local v = select(i, ...)
		local tv = type(v)
		if tv == "function" then
			n.Callback = n.Callback or v
		elseif tv == "table" then
			if kind == "Dropdown" and v[1] ~= nil and n.Options == nil then
				n.Options = v
			else
				for k, x in pairs(v) do
					n[k] = x
				end
			end
		elseif tv == "string" then
			table.insert(strs, v)
		elseif tv == "boolean" then
			table.insert(bools, v)
		elseif tv == "number" then
			table.insert(nums, v)
		elseif typeof(v) == COLOR3 then
			n.Default = v
		elseif typeof(v) == ENUMITEM then
			n.Default = v
		end
	end
	if kind == "Label" then
		n.Value = strs[1]
	elseif kind == "Button" then
		n.Desc = strs[1]
	elseif kind == "Toggle" then
		n.Default = bools[1]
		n.Desc = strs[1]
	elseif kind == "Slider" then
		if #nums >= 3 then
			n.Min, n.Max, n.Default = nums[1], nums[2], nums[3]
		elseif #nums == 2 then
			n.Min, n.Max = nums[1], nums[2]
		elseif #nums == 1 then
			n.Max = nums[1]
		end
	elseif kind == "Textbox" then
		n.Default = strs[1]
	elseif kind == "Bind" and n.Default == nil then
		n.Default = strs[1]
	end
	return normControl(kind, n), meta
end

-- theme names of other libraries -> our preset + accent
local ThemeMap = {
	darktheme = { "Dark" }, lighttheme = { "Light" }, midnight = { "Midnight" }, mocha = { "Mocha" },
	bloodtheme = { "Dark", "Red" }, grapetheme = { "Dark", "Purple" }, ocean = { "Midnight", "Teal" },
	sentinel = { "Dark", "Blue" }, synapse = { "Dark", "Orange" },
	default = { "Dark" }, amberglow = { "Mocha", "Orange" }, amethyst = { "Midnight", "Purple" },
	bloom = { "Dark", "Pink" }, darkblue = { "Midnight", "Blue" }, green = { "Dark", "Green" },
	light = { "Light" }, serenity = { "Light", "Teal" },
	dark = { "Dark" }, darker = { "Midnight" }, aqua = { "Dark", "Teal" }, rose = { "Mocha", "Pink" },
}

local function unself(a, ...)
	if a == MacUI then
		return ...
	end
	return a, ...
end

-- ============================================================================
-- FUZZY METHOD NAMES: any method name that looks like "add / create / new / make + a control word" is understood
-- (AddFancySwitch, createcheckbox, NewRangeBar, MakeGroup ...). Unknown "AddSomething" names do nothing
-- instead of raising an error, so scripts written for other libraries keep running.
-- ============================================================================
local VERBS = { "add", "create", "new", "make", "build", "insert", "append", "register", "draw", "render", "spawn" }
local BARE = {
	toggle = 1, switch = 1, checkbox = 1, button = 1, btn = 1, slider = 1, dropdown = 1, textbox = 1, input = 1,
	keybind = 1, bind = 1, colorpicker = 1, label = 1, paragraph = 1, divider = 1, separator = 1, section = 1,
	tab = 1, page = 1, notify = 1, notification = 1, dialog = 1, window = 1,
}
-- { keyword, category, kind } - the first keyword contained in the name wins, so order matters
local KEYWORDS = {
	{ "tabbox", "tabbox" },
	{ "groupbox", "section" }, { "section", "section" }, { "group", "section" }, { "folder", "section" },
	{ "category", "section" }, { "panel", "section" }, { "card", "section" }, { "container", "section" },
	{ "colorpicker", "control", "ColorPicker" }, { "colourpicker", "control", "ColorPicker" },
	{ "color", "control", "ColorPicker" }, { "colour", "control", "ColorPicker" }, { "palette", "control", "ColorPicker" },
	{ "keybind", "control", "Bind" }, { "keypicker", "control", "Bind" }, { "hotkey", "control", "Bind" },
	{ "shortcut", "control", "Bind" }, { "bind", "control", "Bind" }, { "key", "control", "Bind" },
	{ "checkbox", "control", "Toggle" }, { "tickbox", "control", "Toggle" }, { "toggle", "control", "Toggle" },
	{ "switch", "control", "Toggle" }, { "check", "control", "Toggle" }, { "onoff", "control", "Toggle" },
	{ "enable", "control", "Toggle" },
	{ "textbox", "control", "Textbox" }, { "textinput", "control", "Textbox" }, { "input", "control", "Textbox" },
	{ "field", "control", "Textbox" }, { "entry", "control", "Textbox" }, { "editbox", "control", "Textbox" },
	{ "box", "control", "Textbox" },
	{ "slider", "control", "Slider" }, { "range", "control", "Slider" },
	{ "dropdown", "control", "Dropdown" }, { "combo", "control", "Dropdown" }, { "select", "control", "Dropdown" },
	{ "choose", "control", "Dropdown" }, { "listbox", "control", "Dropdown" }, { "menu", "control", "Dropdown" },
	{ "option", "control", "Dropdown" }, { "list", "control", "Dropdown" }, { "picker", "control", "Dropdown" },
	{ "button", "control", "Button" }, { "btn", "control", "Button" }, { "click", "control", "Button" },
	{ "action", "control", "Button" },
	{ "divider", "divider" }, { "separator", "divider" }, { "seperator", "divider" }, { "hr", "divider" },
	{ "line", "divider" }, { "rule", "divider" },
	{ "blank", "blank" }, { "spacer", "blank" }, { "space", "blank" }, { "gap", "blank" }, { "padding", "blank" },
	{ "notif", "notify" }, { "toast", "notify" }, { "alert", "notify" }, { "popup", "notify" },
	{ "dialog", "dialog" }, { "prompt", "dialog" }, { "confirm", "dialog" }, { "modal", "dialog" },
	{ "window", "window" }, { "tab", "tab" }, { "page", "tab" },
	{ "label", "control", "Label" }, { "paragraph", "control", "Label" }, { "text", "control", "Label" },
	{ "title", "control", "Label" }, { "heading", "control", "Label" }, { "info", "control", "Label" },
	{ "note", "control", "Label" }, { "status", "control", "Label" }, { "message", "control", "Label" },
	{ "content", "control", "Label" }, { "description", "control", "Label" }, { "display", "control", "Label" },
}

-- returns category, kind  (category = control / section / tabbox / divider / blank / notify / dialog / window / tab /
-- unknown) or nil when the name does not look like a builder call
local function classifyName(key)
	if type(key) ~= "string" or key == "" or string.sub(key, 1, 1) == "_" then
		return nil
	end
	local low = string.lower(key)
	local rest, hasVerb = low, false
	for _, v in ipairs(VERBS) do
		if #low > #v and string.sub(low, 1, #v) == v then
			rest, hasVerb = string.sub(low, #v + 1), true
			break
		end
	end
	rest = string.gsub(rest, "[^a-z]", "")
	if rest == "" then
		return nil
	end
	if not hasVerb and not BARE[rest] then
		return nil
	end
	for _, k in ipairs(KEYWORDS) do
		if string.find(rest, k[1], 1, true) then
			return k[2], k[3]
		end
	end
	return hasVerb and "unknown" or nil
end

-- an object that accepts any call and any field and always answers with itself (used for unknown builder names)
local Dummy
Dummy = setmetatable({}, {
	__index = function()
		return function()
			return Dummy
		end
	end,
	__call = function()
		return Dummy
	end,
})
local warnedNames = {}
local function unknownBuilder(key)
	if not warnedNames[key] then
		warnedNames[key] = true
		warn("[MacUI] '" .. tostring(key) .. "' is not supported by this library and was ignored")
	end
	return function()
		return Dummy
	end
end

-- first argument may be the object (colon call) or already the real first argument (dot call)
local function shift(self, scope, ...)
	if self == scope then
		return ...
	end
	return self, ...
end

-- makes `scope` answer unknown builder names: handlers[category](kind, key) must return the function to call
local function installFuzzy(scope, handlers)
	setmetatable(scope, {
		__index = function(t, key)
			local cat, kind = classifyName(key)
			if not cat then
				return nil
			end
			local h = handlers[cat]
			local fn = h and h(kind, key)
			if fn == nil then
				fn = unknownBuilder(key)
			end
			rawset(t, key, fn)
			return fn
		end,
	})
end

MacUI.Flags, MacUI.Options, MacUI.Toggles = {}, {}, {}
for _, t in ipairs({ MacUI.Flags, MacUI.Options, MacUI.Toggles }) do
	setmetatable(t, { __macui = true })
end
pcall(function() -- Linoria-style globals: Toggles.X / Options.X (replaced when they are left over from an older MacUI)
	local env = (getgenv and getgenv()) or _G
	for name, tbl in pairs({ Toggles = MacUI.Toggles, Options = MacUI.Options }) do
		local cur = env[name]
		local mt = type(cur) == "table" and getmetatable(cur)
		if cur == nil or (mt and mt.__macui) then
			env[name] = tbl
		end
	end
end)

MacUI._windows = {} -- every live window, so MacUI.Destroy() can remove them all
MacUI._onUnload = {}

-- notifications (bottom-right corner, stack upwards)
local notifyGui, notifyHolder
local notifyCounter = 0
local NotifyDefault = {
	Card = Color3.fromRGB(41, 45, 54), Stroke = Color3.fromRGB(60, 66, 78),
	Text = Color3.fromRGB(236, 239, 246), SubText = Color3.fromRGB(150, 157, 171),
	Accent = Color3.fromRGB(41, 148, 255),
}
local NotifyTypes = {
	success = Color3.fromRGB(52, 199, 100),
	warning = Color3.fromRGB(255, 177, 66), warn = Color3.fromRGB(255, 177, 66),
	error = Color3.fromRGB(255, 82, 82), danger = Color3.fromRGB(255, 82, 82),
}

local function ensureNotifyGui()
	if notifyGui and notifyGui.Parent then
		return
	end
	notifyGui = New("ScreenGui", {
		Name = "MacUI_Notify",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 1000,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	local ok = pcall(function()
		notifyGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
	end)
	if not ok or not notifyGui.Parent then
		notifyGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	end
	notifyHolder = New("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.new(0, 290, 1, -32),
		Parent = notifyGui,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		}),
	})
end

-- MacUI.Notify({ Title = "..", Content = "..", Duration = 3, Type = "success" | "warning" | "error" })
-- also works as Library:Notify(...) and Window:Notify(...); a plain string is the content
function MacUI.Notify(...)
	local o, b = unself(...)
	if type(o) == "string" then
		if type(b) == "string" then
			o = { Title = o, Content = b } -- Notify("title", "text")
		elseif type(b) == "number" then
			o = { Content = o, Duration = b } -- Notify("text", seconds)
		else
			o = { Content = o }
		end
	end
	o = o or {}
	local title = tostring(firstNonNil(o.Title, o.Name, "Notification"))
	local content = tostring(firstNonNil(o.Content, o.Text, o.Description, o.Desc, ""))
	if o.SubContent then
		content = content .. "\n" .. tostring(o.SubContent)
	end
	local duration = tonumber(firstNonNil(o.Duration, o.Time, 3)) or 3
	local C = MacUI._theme or NotifyDefault
	local accent = NotifyTypes[string.lower(tostring(o.Type or ""))] or C.Accent

	ensureNotifyGui()
	notifyCounter += 1
	local wrap = New("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = notifyCounter,
		Parent = notifyHolder,
	})
	local card = New("Frame", {
		BackgroundColor3 = C.Card,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0, 320, 0, 0),
		Parent = wrap,
	}, {
		Round(10),
		New("UIStroke", { Color = C.Stroke, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
	})
	New("Frame", {
		BackgroundColor3 = accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 1, 0),
		Parent = card,
	})
	local inner = New("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = card,
	}, {
		New("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }),
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
		}),
	})
	New("TextLabel", {
		BackgroundTransparency = 1,
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = C.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = 1,
		Parent = inner,
	})
	if content ~= "" then
		New("TextLabel", {
			BackgroundTransparency = 1,
			Text = content,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = C.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			LayoutOrder = 2,
			Parent = inner,
		})
	end
	local hit = New("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 5,
		Parent = card,
	})

	TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0),
	}):Play()

	local closed = false
	local function close()
		if closed then
			return
		end
		closed = true
		local tw = TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Position = UDim2.new(0, 320, 0, 0),
		})
		tw:Play()
		task.delay(0.3, function()
			wrap:Destroy()
		end)
	end
	hit.Activated:Connect(close)
	if duration > 0 and duration < math.huge then
		task.delay(duration, close)
	end
	return { Close = close }
end

-- removes every window (and notifications) created by this library
function MacUI.Destroy()
	for _, fn in ipairs(MacUI._onUnload) do
		task.spawn(fn)
	end
	MacUI._onUnload = {}
	for _, t in ipairs({ MacUI.Flags, MacUI.Options, MacUI.Toggles }) do
		for k in pairs(t) do
			t[k] = nil
		end
	end
	for _, w in ipairs(table.clone(MacUI._windows)) do
		pcall(function()
			w:Destroy()
		end)
	end
	if notifyGui then
		notifyGui:Destroy()
		notifyGui = nil
	end
end

local function buildWindow(opts)
	if type(opts) == "string" then
		opts = { Title = opts }
	end
	do -- accept other option names without touching the caller's table
		local c = copyTable(opts or {})
		c.Title = firstNonNil(c.Title, c.Name, c.Text)
		c.Subtitle = firstNonNil(c.Subtitle, c.SubTitle, c.Description)
		if c.ToggleKey == nil then
			c.ToggleKey = c.MinimizeKey -- Fluent
		end
		local th = c.Theme
		if type(th) == "table" then -- Kavo / Venyx custom theme tables
			c.Accent = c.Accent or th.SchemeColor or th.Accent or th.Glow
			c.Theme = nil
		elseif type(th) == "string" and not Presets[th] then
			local m = ThemeMap[string.lower(th)]
			if m then
				c.Theme = m[1]
				if m[2] and not c.Accent then
					c.Accent = Accents[m[2]]
				end
			else
				c.Theme = nil
			end
		end
		opts = c
	end
	registerIcons(opts.Icons)
	local WIDTH, HEIGHT, SIDE = 560, 370, 150
	local UDIM2 = "UDim2"
	if typeof(opts.Size) == UDIM2 and opts.Size.X.Offset > 0 and opts.Size.Y.Offset > 0 then
		WIDTH = math.max(430, opts.Size.X.Offset)
		HEIGHT = math.max(300, opts.Size.Y.Offset)
	end
	local PROFILE_H = (opts.ShowUser ~= false) and 54 or 0
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
		Size = UDim2.new(0, SIDE - 1, 1, -45 - PROFILE_H),
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

	-- profile: avatar + name at the bottom of the sidebar
	local applyUser = function() end
	local userInfo = {
		Name = opts.UserName, UserId = opts.UserId, Image = opts.UserImage, Mask = opts.MaskName,
		Note = opts.UserNote, NoteColor = opts.UserNoteColor,
	}
	if PROFILE_H > 0 then
		themed(New("Frame", {
			Name = "ProfileLine",
			Position = UDim2.new(0, 8, 1, -PROFILE_H),
			Size = UDim2.new(0, SIDE - 17, 0, 1),
			BorderSizePixel = 0,
			Parent = sideClip,
		}), { BackgroundColor3 = "Stroke" })
		local avatar = themed(New("Frame", {
			Name = "Avatar",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 10, 1, -PROFILE_H / 2),
			Size = UDim2.fromOffset(32, 32),
			BorderSizePixel = 0,
			Parent = sideClip,
		}, { Round(16) }), { BackgroundColor3 = "Field" })
		local letter = Label({
			Text = "?",
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromScale(1, 1),
			Parent = avatar,
		}, "SubText")
		local avatarImg = New("ImageLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScaleType = Enum.ScaleType.Crop,
			Size = UDim2.fromScale(1, 1),
			Parent = avatar,
		}, { Round(16) })
		local nameLabel = Label({
			Text = "",
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			TextTruncate = Enum.TextTruncate.AtEnd,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 48, 1, -PROFILE_H / 2),
			Size = UDim2.fromOffset(SIDE - 48 - 6, 18),
			Parent = sideClip,
		}, "Text")
		-- second line under the name (key time left, status, ...): Window:SetUserNote("text")
		local noteLabel = Label({
			Text = "",
			TextSize = 11,
			RichText = true,
			TextTruncate = Enum.TextTruncate.AtEnd,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 48, 1, -PROFILE_H / 2 + 9),
			Size = UDim2.fromOffset(SIDE - 48 - 6, 14),
			Visible = false,
			Parent = sideClip,
		}, "SubText")
		avatarImg:GetPropertyChangedSignal("IsLoaded"):Connect(function()
			if avatarImg.IsLoaded and avatarImg.Image ~= "" then
				letter.Visible = false
			end
		end)
		applyUser = function()
			local lp = Players.LocalPlayer
			local shown = userInfo.Name
			if (shown == nil or shown == "" or shown == false) and lp then
				shown = (lp.DisplayName ~= "" and lp.DisplayName) or lp.Name
			end
			shown = tostring(shown or "Player")
			nameLabel.Text = userInfo.Mask and (string.sub(shown, 1, 2) .. "*****") or shown
			letter.Text = string.upper(string.sub(shown, 1, 1))
			local img = userInfo.Image and normalizeAsset(userInfo.Image)
			if not img then
				local uid = tonumber(userInfo.UserId) or (lp and lp.UserId)
				if uid and uid > 0 then
					img = "rbxthumb://type=AvatarHeadShot&id=" .. uid .. "&w=150&h=150"
				end
			end
			-- note line: with a note the name moves up, without one the name stays centred
			local note = userInfo.Note
			note = (note ~= nil and note ~= false) and tostring(note) or ""
			if note ~= "" and typeof(userInfo.NoteColor) == COLOR3 then
				note = '<font color="' .. hexOf(userInfo.NoteColor) .. '">' .. note .. "</font>"
			end
			noteLabel.Text = note
			noteLabel.Visible = note ~= ""
			nameLabel.Position = UDim2.new(0, 48, 1, -PROFILE_H / 2 - (note ~= "" and 8 or 0))
			letter.Visible = true
			avatarImg.Image = img or ""
			if img and avatarImg.IsLoaded then
				letter.Visible = false
			end
		end
		applyUser()
	end

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
	local onToggleSidebar, navStep, updateNav -- assigned further down
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
		local ic = uiIcon(hit, key, iconName, 18)
		ic.Root.AnchorPoint = Vector2.new(0.5, 0.5)
		ic.Root.Position = UDim2.fromScale(0.5, 0.5)
		-- if an image id cannot load (wrong id / not an Image asset), fall back to the drawn icon
		local fb
		if ic.Kind == "image" then
			fb = makeIcon(hit, iconName, 18)
			fb.Root.AnchorPoint = Vector2.new(0.5, 0.5)
			fb.Root.Position = UDim2.fromScale(0.5, 0.5)
			fb.Root.Visible = false
			task.delay(5, function()
				if ic.Root.Parent and not ic.Root.IsLoaded then
					ic.Root.Visible = false
					fb.Root.Visible = true
					warn("[MacUI] Header icon '" .. tostring(key) .. "' did not load. Use an Image asset id (not a Decal id).")
				end
			end)
		end
		local enabled, hover = true, false
		local function paint()
			local c = (not enabled) and Theme.Off:Lerp(Theme.SubText, 0.5) or (hover and Theme.Accent or Theme.Text)
			tintIcon(ic, c)
			if fb then
				tintIcon(fb, c)
			end
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
			SetVisible = function(v)
				hit.Visible = v
				if not v then
					hover = false
					paint()
				end
			end,
		}
	end
	local backBtn, fwdBtn
	navButton(14, "Sidebar", "sidebar", function()
		if onToggleSidebar then
			onToggleSidebar()
		end
	end)
	backBtn = navButton(36, "Back", "left", function()
		if navStep then
			navStep(-1)
		end
	end)
	fwdBtn = navButton(57, "Forward", "right", function()
		if navStep then
			navStep(1)
		end
	end)
	backBtn.SetVisible(false)
	fwdBtn.SetVisible(false)

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

	-- toggle-UI keybind state
	local NONE_KEY = Enum.KeyCode.Unknown
	local toggleKey = NONE_KEY
	do
		local k = opts.ToggleKey
		if k == false or k == "None" then
			toggleKey = NONE_KEY -- keyboard toggle disabled (the floating button still works)
		else
			toggleKey = toKeyCode(k) or Enum.KeyCode.RightShift
		end
	end
	local bindBusy = false -- true while any Bind control is waiting for a key press
	local consumedInput -- the key press a Bind control just captured (never also toggles the UI)
	local activeBindCancel -- cancels the Bind control that is currently listening
	local toggleBindCtl -- the "Toggle UI" row in the settings tab (kept in sync)

	local refreshCurrent -- assigned after selectTab exists
	local function toggleMain()
		main.Visible = not main.Visible
		if main.Visible and refreshCurrent then
			refreshCurrent()
		end
	end

	-- dragging (window, open button, sliders)
	local dragging, dragStart, startPos = false, nil, nil
	local btnDrag = nil
	local activeSlider = nil

	local function overSearch(pos)
		for _, f in ipairs(noDrag) do
			local a, sz = f.AbsolutePosition, f.AbsoluteSize
			if f.Visible and pos.X >= a.X and pos.X <= a.X + sz.X and pos.Y >= a.Y and pos.Y <= a.Y + sz.Y then
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
			activeSlider(input.Position.X, input.Position.Y)
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
			tab.Btn.Visible = (q == "") or any
			if any and not firstMatch then
				firstMatch = tab
			end
		end

		local seenShown = false
		for _, g in ipairs(groupList) do
			local shown = false
			for _, t in ipairs(g.Tabs) do
				if t.Btn.Visible then
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

		updateNav()
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
		tab.Btn.BackgroundColor3 = Theme.Selected
		local c = selected and Theme.SelectedText or Theme.SubText
		tab.Text.TextColor3 = c
		tab.Bar.Visible = selected
		if tab.Icon and not tab.NoTint then
			tintIcon(tab.Icon, selected and c or Theme.SubText:Lerp(Theme.Text, 0.4))
		end
		-- untinted image icons: dim them when the tab is not selected
		if tab.Icon and tab.Icon.Kind == "image" and (tab.NoTint or tab.Icon.Tint == false) then
			tab.Icon.Root.ImageTransparency = selected and 0 or 0.3
		end
	end

	local function selectTab(tab, skipFilter)
		local old = currentTab
		currentTab = tab
		if old and old ~= tab then
			old.Page.Visible = false
			tween(old.Btn, { BackgroundTransparency = 1 })
			styleTab(old)
		end
		tab.Page.Visible = true
		tween(tab.Btn, { BackgroundTransparency = 0 })
		styleTab(tab)
		if not skipFilter then
			applyFilter()
		end
		updateNav()
	end
	Window._select = selectTab

	-- < / > : previous / next visible tab, one step per press.
	-- Middle tabs show both arrows; the first tab shows only > and the last tab shows only <.
	local function navList()
		local list = {}
		for _, t in ipairs(tabsList) do
			if t.Btn.Visible then
				table.insert(list, t)
			end
		end
		return list
	end
	local function navIndex(list)
		for i, t in ipairs(list) do
			if t == currentTab then
				return i
			end
		end
		return nil
	end
	updateNav = function()
		local list = navList()
		local i = navIndex(list)
		backBtn.SetVisible(i ~= nil and i > 1)
		fwdBtn.SetVisible(i ~= nil and i < #list)
	end
	navStep = function(dir)
		local list = navList()
		local i = navIndex(list)
		if i and list[i + dir] then
			selectTab(list[i + dir])
		end
	end

	-- Re-applies the current tab once the layout has settled (same effect as clicking another tab and
	-- coming back), so the first tab is usable right when the window opens. Calls are batched.
	local refreshToken = 0
	refreshCurrent = function()
		refreshToken += 1
		local my = refreshToken
		task.defer(function()
			if my ~= refreshToken or not gui.Parent or not currentTab then
				return
			end
			currentTab.Page.Visible = false
			task.wait()
			if my ~= refreshToken or not gui.Parent or not currentTab then
				return
			end
			selectTab(currentTab, false)
			task.wait(0.25)
			if my == refreshToken and gui.Parent and currentTab then
				selectTab(currentTab, false)
			end
		end)
	end

	-- ---------------------------------------------------------------- compat: value tracking, flags, config
	local flagged = {} -- { name, obj, kind } of every control that has a flag / idx
	local saveSoon = function() end -- replaced when config saving is enabled

	local function toMap(list)
		local m = {}
		for _, v in ipairs(list or {}) do
			m[v] = true
		end
		return m
	end
	local function mapToList(m, order)
		local list = {}
		if order then
			for _, v in ipairs(order) do
				if m[v] then
					table.insert(list, v)
				end
			end
		else
			for k, on in pairs(m) do
				if on then
					table.insert(list, k)
				end
			end
		end
		return list
	end

	-- wraps a raw control: other callback styles, .Value / :OnChanged / :SetValue, Flags / Options / Toggles,
	-- location[flag] writes (Wally), config saving and the helper methods other libraries give their objects
	local function wrapControl(Section, kind, n, meta, raw)
		local userCb = n.Callback
		local flag = firstNonNil(meta.idx, n.Flag)
		local location = n.Location
		local listeners = {}
		local obj
		local multi = (kind == "Dropdown" and n.Multi == true)
		local ddMode = "native" -- native: string / array, array: Rayfield, map: Linoria + Fluent
		local mode = n.Mode and string.lower(tostring(n.Mode)) or nil
		local state = (mode == "always")

		if kind == "Dropdown" then
			if n._rayfield then
				ddMode = "array"
			elseif meta.idx then
				ddMode = "map"
			end
			local list = n.Options or {}
			n.Options = list
			local d = n.Default
			local function byIndex(x)
				if type(x) == "number" and list[x] ~= nil and type(list[x]) ~= "number" then
					return list[x]
				end
				return x
			end
			if multi then
				local arr = {}
				if type(d) == "table" then
					if #d > 0 then
						for _, v in ipairs(d) do
							table.insert(arr, v)
						end
					else
						for _, v in ipairs(list) do
							if d[v] then
								table.insert(arr, v)
							end
						end
					end
				elseif d ~= nil then
					arr = { byIndex(d) }
				end
				n.Default = arr
			else
				if type(d) == "table" then
					if d[1] ~= nil then
						d = d[1]
					else
						local found
						for _, v in ipairs(list) do
							if d[v] then
								found = v
								break
							end
						end
						d = found
					end
				end
				n.Default = byIndex(d)
			end
		end

		local function ext(v) -- raw value -> what the script sees
			if kind == "Dropdown" then
				if ddMode == "array" then
					return multi and v or { v }
				elseif ddMode == "map" and multi then
					return toMap(v)
				end
			end
			return v
		end
		local function toRaw(v) -- what the script passes in -> raw value
			if kind == "Dropdown" then
				if type(v) == "table" then
					local list = (#v > 0) and v or mapToList(v, obj and obj.Values or n.Options)
					if multi then
						return list
					end
					return list[1]
				end
				return v
			elseif kind == "Bind" then
				if v == false or v == "None" then
					return false
				end
				return toKeyCode(v) or v
			end
			return v
		end
		local function setFields(v)
			if not obj then
				return
			end
			if kind == "Bind" then
				local nm = (v == nil or v == Enum.KeyCode.Unknown) and "None" or v.Name
				obj.Value, obj.CurrentKeybind = nm, nm
			elseif kind == "Dropdown" then
				local e = ext(v)
				obj.Value = e
				obj.CurrentOption = (ddMode == "array") and e or (multi and v or { v })
				if location and flag then
					location[flag] = e
				end
			elseif kind == "ColorPicker" then
				obj.Value, obj.Color, obj.CurrentValue = v, v, v
				if location and flag then
					location[flag] = v
				end
			else
				obj.Value, obj.CurrentValue = v, v
				if location and flag then
					location[flag] = v
				end
			end
		end
		local function changed(e)
			for _, fn in ipairs(listeners) do
				task.spawn(fn, e)
			end
			saveSoon()
		end

		-- callbacks the raw control will call
		if kind == "Button" then
			n.Callback = function()
				if userCb then
					task.spawn(userCb)
				end
			end
		elseif kind == "Bind" then
			local hold = (n.Hold == true)
			n.Callback = function(key)
				if mode == "always" then
					return
				end
				if mode == "toggle" then
					state = not state
				elseif mode == "hold" then
					state = true
				end
				if not userCb then
					return
				end
				if mode == "toggle" or mode == "hold" then
					task.spawn(userCb, state)
				elseif hold then
					task.spawn(userCb, true)
				else
					task.spawn(userCb, key)
				end
			end
			if hold or mode == "hold" then
				local userRel = n.Released
				n.Released = function(key)
					if mode == "hold" then
						state = false
					end
					if userCb then
						task.spawn(userCb, false)
					end
					if userRel then
						task.spawn(userRel, key)
					end
				end
			end
			local userChange = n.OnChange
			n.OnChange = function(key)
				setFields(key)
				changed(key.Name)
				if userChange then
					task.spawn(userChange, key)
				end
			end
		elseif kind ~= "Label" then
			n.Callback = function(v)
				setFields(v)
				local e = ext(v)
				for _, fn in ipairs(listeners) do
					task.spawn(fn, e)
				end
				saveSoon()
				if userCb then
					task.spawn(userCb, e)
				end
			end
		end

		obj = raw(Section, n)
		if type(obj) ~= "table" then
			return obj
		end
		obj.Type = kind
		obj.Flag = flag
		local row, titleLabel, descLabel = Section._lastRow, Section._lastTitle, Section._lastDesc
		obj.Row = row

		-- helpers every object gets
		function obj:SetName(text)
			if titleLabel then
				titleLabel.Text = tostring(text)
			end
		end
		function obj:SetDesc(text)
			text = tostring(text or "")
			if not (descLabel and row) then
				return
			end
			descLabel.Text = text
			if kind ~= "Label" then
				local has = text ~= ""
				descLabel.Visible = has
				row.Size = UDim2.new(1, 0, 0, has and 52 or 40)
				titleLabel.Position = UDim2.new(0, 14, 0, has and 9 or 0)
				titleLabel.Size = has and UDim2.new(1, -200, 0, 18) or UDim2.new(1, -200, 1, 0)
			end
		end
		function obj:SetVisible(v)
			if row then
				row.Visible = v ~= false
			end
		end
		function obj:Destroy()
			if row then
				row:Destroy()
			end
			if flag ~= nil then
				if MacUI.Flags[flag] == obj then
					MacUI.Flags[flag] = nil
				end
				if MacUI.Options[flag] == obj then
					MacUI.Options[flag] = nil
				end
				if MacUI.Toggles[flag] == obj then
					MacUI.Toggles[flag] = nil
				end
				for i, f in ipairs(flagged) do
					if f.obj == obj then
						table.remove(flagged, i)
						break
					end
				end
			end
		end
		obj.Remove = obj.Destroy
		-- Kavo-style updaters
		function obj:UpdateButton(t)
			obj:SetName(t)
		end
		function obj:UpdateToggle(t, st)
			if t ~= nil and t ~= "" then
				obj:SetName(t)
			end
			if st ~= nil and obj.SetSilent then
				obj:SetSilent(st)
			end
		end
		function obj:UpdateSlider(t, v)
			if t ~= nil and t ~= "" then
				obj:SetName(t)
			end
			if v ~= nil and obj.SetSilent then
				obj:SetSilent(v)
			end
		end
		function obj:UpdateDropdown(t)
			obj:SetName(t)
		end
		obj.UpdateTextBox, obj.UpdateKeybind, obj.UpdateColorPicker = obj.UpdateDropdown, obj.UpdateDropdown, obj.UpdateDropdown
		function obj:UpdateLabel(t)
			if kind == "Label" then
				obj:Set(t)
			else
				obj:SetName(t)
			end
		end
		-- Linoria: Toggle:AddColorPicker / AddKeyPicker, Button:AddButton (each becomes its own row)
		function obj:AddColorPicker(...)
			return Section:AddColorPicker(...)
		end
		function obj:AddKeyPicker(...)
			return Section:AddKeyPicker(...)
		end
		if kind == "Button" then
			function obj:AddButton(...)
				return Section:AddButton(...)
			end
			function obj:Set(text) -- Rayfield: ButtonObject:Set("new name")
				obj:SetName(text)
			end
			return obj
		elseif kind == "Label" then
			local rawLabelSet = obj.Set
			function obj:Set(v)
				if type(v) == "table" then
					if v.Title then
						obj:SetName(v.Title)
					end
					v = firstNonNil(v.Content, v.Text, "")
				end
				rawLabelSet(obj, tostring(v))
			end
			obj.SetText, obj.SetValue = obj.Set, obj.Set
			return obj
		end

		-- value controls
		local rawSet, rawGet = obj.Set, obj.Get
		local fires = not meta.native -- native Set is silent; the other libraries' Set runs the callback
		local function applyValue(v, fire)
			if kind == "Bind" and type(v) == "table" and typeof(v) ~= ENUMITEM then
				if v[2] then
					mode = string.lower(tostring(v[2]))
				end
				v = v[1]
			end
			rawSet(obj, toRaw(v))
			local cur = rawGet(obj)
			setFields(cur)
			if fire then
				if kind == "Bind" then
					changed(cur and cur.Name or "None")
				else
					local e = ext(cur)
					changed(e)
					if userCb then
						task.spawn(userCb, e)
					end
				end
			end
		end
		function obj:Set(v)
			applyValue(v, fires)
		end
		function obj:SetValue(v)
			applyValue(v, true)
		end
		function obj:SetSilent(v)
			applyValue(v, false)
		end
		obj.Fire = obj.SetValue
		obj.GetValue = rawGet
		function obj:OnChanged(fn)
			table.insert(listeners, fn)
			return {
				Disconnect = function()
					local i = table.find(listeners, fn)
					if i then
						table.remove(listeners, i)
					end
				end,
			}
		end
		if kind == "Dropdown" then
			local rawRefresh = obj.Refresh
			obj.Values = n.Options
			function obj:Refresh(list, keep)
				obj.Values = list or {}
				rawRefresh(obj, list, keep)
				setFields(rawGet(obj))
			end
			obj.SetOptions, obj.SetValues = obj.Refresh, obj.Refresh
		elseif kind == "Bind" then
			obj.Mode = mode
			function obj:GetState()
				return mode == "always" or state
			end
		end
		if kind == "Toggle" or kind == "Slider" or kind == "Dropdown" then
			obj.SetText = obj.SetName
		end

		setFields(rawGet(obj))
		if flag ~= nil then
			MacUI.Flags[flag] = obj
			MacUI.Options[flag] = obj
			if kind == "Toggle" then
				MacUI.Toggles[flag] = obj
			end
			table.insert(flagged, { name = tostring(flag), obj = obj, kind = kind })
		end
		return obj
	end

	local function makeSection(tab, o)
		o = o or {}
		local Section = { _count = 0, _rowLog = {} }
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
			Section._titleLabel = Label({
				Text = o.Title,
				Font = Enum.Font.GothamBold,
				AutomaticSize = Enum.AutomaticSize.Y,
				Position = UDim2.fromOffset(24, 0),
				Size = UDim2.new(1, -24, 0, 18),
				TextWrapped = true,
				Parent = head,
			}, "Text")
		elseif o.Title then
			Section._titleLabel = Label({
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
			refreshCurrent()
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
			local titleLabel = Label({
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
			Section._lastRow, Section._lastTitle, Section._lastDesc = row, titleLabel, descLabel
			table.insert(Section._rowLog, row)
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
			local multi = d.Multi == true
			local value -- a string, or an array of strings when Multi = true
			if multi then
				value = {}
				if type(d.Default) == "table" then
					for _, v in ipairs(d.Default) do
						table.insert(value, v)
					end
				elseif d.Default ~= nil then
					value = { d.Default }
				end
			else
				value = d.Default or options[1]
			end
			local function display(v)
				if multi then
					return (#v == 0) and "None" or table.concat(v, ", ")
				end
				return tostring(v)
			end
			local function isSel(opt)
				if multi then
					return table.find(value, opt) ~= nil
				end
				return opt == value
			end

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
				Text = display(value),
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
				if multi then
					local copy = {}
					for _, x in ipairs(v or {}) do
						table.insert(copy, x)
					end
					v = copy
				end
				value = v
				valueLabel.Text = display(v)
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
						TextColor3 = isSel(opt) and Theme.Accent or Theme.Text,
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
						if multi then
							local on = table.find(value, opt) ~= nil
							local cur = {}
							for _, o2 in ipairs(options) do
								local keep
								if o2 == opt then
									keep = not on
								else
									keep = table.find(value, o2) ~= nil
								end
								if keep then
									table.insert(cur, o2)
								end
							end
							set(cur)
							item.TextColor3 = isSel(opt) and Theme.Accent or Theme.Text
						else
							set(opt)
							close()
						end
					end)
				end
			end)

			function obj:Set(v)
				if multi and type(v) ~= "table" then
					v = { v }
				end
				set(v, true)
			end
			function obj:Get()
				if multi then
					return table.clone(value)
				end
				return value
			end
			-- replace the option list (value is kept when it is still in the list)
			function obj:Refresh(list, keepValue)
				options = list or {}
				if multi then
					local keep = {}
					for _, v in ipairs(value) do
						if table.find(options, v) then
							table.insert(keep, v)
						end
					end
					set(keep, true)
				elseif not keepValue and not table.find(options, value) then
					set(options[1], true)
				end
			end
			obj.SetOptions = obj.Refresh
			obj.SetValues = obj.Refresh
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
			if l.Name == nil or l.Name == "" then
				row.Size = UDim2.new(1, 0, 0, 40)
				descLabel.Position = UDim2.new(0, 14, 0, 10)
			end
			local obj = {}
			function obj:Set(text)
				descLabel.Text = tostring(text)
			end
			return obj
		end

		function Section:AddTextbox(t)
			local row = newRow(t.Name, t.Desc)
			local box = themed(New("TextBox", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 0.5, 0),
				Size = UDim2.fromOffset(math.clamp(tonumber(t.Width) or 150, 60, 170), 26),
				Text = tostring(t.Default or ""),
				PlaceholderText = tostring(t.Placeholder or ""),
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ClearTextOnFocus = t.ClearOnFocus == true,
				ClipsDescendants = true,
				BorderSizePixel = 0,
				Parent = row,
			}, {
				Round(6),
				Stroke("Stroke"),
				New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }),
			}), {
				BackgroundColor3 = "Field", BackgroundTransparency = "GlassField",
				TextColor3 = "Text", PlaceholderColor3 = "SubText",
			})
			local stroke = box:FindFirstChildOfClass("UIStroke")
			box.Focused:Connect(function()
				if stroke then
					stroke.Color = Theme.Accent
				end
			end)
			if t.Numeric then
				box:GetPropertyChangedSignal("Text"):Connect(function()
					local f = string.gsub(box.Text, "[^%d%.%-]", "")
					if f ~= box.Text then
						box.Text = f
					end
				end)
			end
			-- fires when the user presses Enter or clicks away (EnterOnly = true -> only on Enter)
			box.FocusLost:Connect(function(enterPressed)
				if stroke then
					stroke.Color = Theme.Stroke
				end
				if t.EnterOnly and not enterPressed then
					return
				end
				if t.Callback then
					task.spawn(t.Callback, box.Text)
				end
				if t.ClearAfter then
					box.Text = ""
				end
			end)
			local obj = { Instance = box }
			function obj:Set(v)
				box.Text = tostring(v)
			end
			function obj:Get()
				return box.Text
			end
			return obj
		end

		function Section:AddBind(b)
			local row = newRow(b.Name, b.Desc)
			local NONE = Enum.KeyCode.Unknown
			local toKey = toKeyCode
			local key
			if b.Default == false or b.Default == "None" then
				key = NONE
			else
				key = toKey(b.Default) or Enum.KeyCode.RightControl
			end
			local listening = false

			local btn = themed(New("TextButton", {
				Text = "",
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				AutoButtonColor = false,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 0.5, 0),
				Size = UDim2.fromOffset(96, 26),
				BorderSizePixel = 0,
				Parent = row,
			}, { Round(6), Stroke("Stroke") }), {
				BackgroundColor3 = "Field", BackgroundTransparency = "GlassField", TextColor3 = "Text",
			})
			local function paint()
				btn.Text = listening and "..." or (key == NONE and "None" or key.Name)
				btn.TextColor3 = listening and Theme.Accent or Theme.Text
			end
			paint()
			local cancelListen
			local function stopListening()
				listening = false
				paint()
				if activeBindCancel == cancelListen then
					activeBindCancel = nil
					task.defer(function() -- after this input event, so the key just captured never toggles the UI
						if not activeBindCancel then
							bindBusy = false
						end
					end)
				end
			end
			cancelListen = stopListening
			btn.Activated:Connect(function()
				if listening then
					stopListening()
				else
					if activeBindCancel then
						activeBindCancel()
					end
					listening = true
					activeBindCancel = cancelListen
					bindBusy = true
					paint()
				end
			end)

			-- click the box, then press a key (Esc cancels, Backspace clears)
			table.insert(conns, UIS.InputBegan:Connect(function(input, processed)
				if input.UserInputType ~= Enum.UserInputType.Keyboard then
					return
				end
				if listening then
					consumedInput = input
					if input.KeyCode ~= Enum.KeyCode.Escape then
						key = (input.KeyCode == Enum.KeyCode.Backspace) and NONE or input.KeyCode
						if b.OnChange then
							task.spawn(b.OnChange, key)
						end
					end
					stopListening()
					return
				end
				if processed or key == NONE then
					return
				end
				if input.KeyCode == key and b.Callback then
					task.spawn(b.Callback, key)
				end
			end))
			if b.Released then
				table.insert(conns, UIS.InputEnded:Connect(function(input)
					if not listening and key ~= NONE and input.KeyCode == key then
						task.spawn(b.Released, key)
					end
				end))
			end

			local obj = {}
			function obj:Set(k)
				if k == false then
					key = NONE
				else
					key = toKey(k) or key
				end
				paint()
			end
			function obj:Get()
				return key
			end
			return obj
		end

		function Section:AddColorPicker(c)
			local row = newRow(c.Name, c.Desc)
			local value = c.Default
			if typeof(value) ~= COLOR3 then
				value = Color3.new(1, 1, 1)
			end
			local swatch = New("TextButton", {
				Text = "",
				AutoButtonColor = false,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 0.5, 0),
				Size = UDim2.fromOffset(46, 22),
				BackgroundColor3 = value,
				BorderSizePixel = 0,
				Parent = row,
			}, { Round(6), Stroke("Stroke") })
			local function set(v, silent)
				value = v
				swatch.BackgroundColor3 = v
				if not silent and c.Callback then
					task.spawn(c.Callback, v)
				end
			end

			swatch.Activated:Connect(function()
				local catcher = New("TextButton", {
					Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 50, Parent = gui,
				})
				local popW, popH = 190, 176
				local abs, size = swatch.AbsolutePosition, swatch.AbsoluteSize
				local screen = gui.AbsoluteSize
				local x = math.clamp(abs.X + size.X - popW, 4, math.max(4, screen.X - popW - 4))
				local y = abs.Y + size.Y + 4
				if y + popH > screen.Y - 4 then
					y = math.max(4, abs.Y - popH - 4)
				end
				local pop = New("Frame", {
					Position = UDim2.fromOffset(x, y),
					Size = UDim2.fromOffset(popW, popH),
					BackgroundColor3 = Theme.Field,
					BorderSizePixel = 0,
					ZIndex = 51,
					Parent = gui,
				}, {
					Round(8),
					New("UIStroke", { Color = Theme.Stroke, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
				})
				local h, sat, val = value:ToHSV()
				local sv = New("TextButton", {
					Text = "", AutoButtonColor = false,
					Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(170, 100),
					BackgroundColor3 = Color3.fromHSV(h, 1, 1), BorderSizePixel = 0, ZIndex = 52, Parent = pop,
				}, { Round(4) })
				New("Frame", {
					Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
					ZIndex = 53, Parent = sv,
				}, { Round(4), New("UIGradient", { Transparency = NumberSequence.new(0, 1) }) })
				New("Frame", {
					Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0,
					ZIndex = 54, Parent = sv,
				}, { Round(4), New("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }) })
				local svCur = New("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(10, 10),
					BackgroundTransparency = 1, ZIndex = 55, Parent = sv,
				}, { Round(5), New("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2 }) })

				local stops = {}
				for i = 0, 6 do
					table.insert(stops, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(math.min(i / 6, 0.999), 1, 1)))
				end
				local hue = New("TextButton", {
					Text = "", AutoButtonColor = false,
					Position = UDim2.fromOffset(10, 118), Size = UDim2.fromOffset(170, 12),
					BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 52, Parent = pop,
				}, { Round(6), New("UIGradient", { Color = ColorSequence.new(stops) }) })
				local hueCur = New("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(4, 16),
					BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 53, Parent = hue,
				}, { Round(2), New("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1 }) })

				local hex = New("TextBox", {
					Position = UDim2.fromOffset(10, 140), Size = UDim2.fromOffset(170, 26),
					Text = hexOf(value), Font = Enum.Font.GothamMedium, TextSize = 13,
					TextColor3 = Theme.Text, BackgroundColor3 = Theme.Card, ClearTextOnFocus = false,
					BorderSizePixel = 0, ZIndex = 52, Parent = pop,
				}, { Round(6) })

				local function place()
					sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
					svCur.Position = UDim2.fromScale(sat, 1 - val)
					hueCur.Position = UDim2.fromScale(h, 0.5)
				end
				local function refresh()
					place()
					local col = Color3.fromHSV(h, sat, val)
					hex.Text = hexOf(col)
					set(col)
				end
				place()
				local function fromSV(px, py)
					local a, sz = sv.AbsolutePosition, sv.AbsoluteSize
					sat = math.clamp((px - a.X) / math.max(sz.X, 1), 0, 1)
					val = 1 - math.clamp((py - a.Y) / math.max(sz.Y, 1), 0, 1)
					refresh()
				end
				local function fromHue(px)
					local a, sz = hue.AbsolutePosition, hue.AbsoluteSize
					h = math.clamp((px - a.X) / math.max(sz.X, 1), 0, 0.999)
					refresh()
				end
				sv.InputBegan:Connect(function(input)
					if isPress(input) then
						activeSlider = fromSV
						fromSV(input.Position.X, input.Position.Y)
					end
				end)
				hue.InputBegan:Connect(function(input)
					if isPress(input) then
						activeSlider = fromHue
						fromHue(input.Position.X)
					end
				end)
				hex.FocusLost:Connect(function()
					local r, g, b = string.match(hex.Text, "^#?(%x%x)(%x%x)(%x%x)$")
					if r then
						local col = Color3.fromRGB(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16))
						h, sat, val = col:ToHSV()
						refresh()
					else
						hex.Text = hexOf(value)
					end
				end)
				catcher.Activated:Connect(function()
					activeSlider = nil
					catcher:Destroy()
					pop:Destroy()
				end)
			end)

			local obj = {}
			function obj:Set(v)
				if typeof(v) == COLOR3 then
					set(v, true)
				elseif type(v) == "table" and v.R then
					set(Color3.fromRGB(v.R, v.G or 0, v.B or 0), true)
				end
			end
			function obj:Get()
				return value
			end
			return obj
		end

		local function addDivider()
			Section._count += 1
			local row = New("Frame", {
				BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 10), LayoutOrder = Section._count, Parent = card,
			})
			themed(New("Frame", {
				AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 14, 0.5, 0),
				Size = UDim2.new(1, -28, 0, 1), BorderSizePixel = 0, Parent = row,
			}), { BackgroundColor3 = "Stroke" })
			table.insert(Section._rowLog, row)
			return { Row = row, Destroy = function() row:Destroy() end }
		end
		local function addBlank(_, h)
			Section._count += 1
			local row = New("Frame", {
				BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, tonumber(h) or 8),
				LayoutOrder = Section._count, Parent = card,
			})
			table.insert(Section._rowLog, row)
			return { Row = row, Destroy = function() row:Destroy() end }
		end
		for _, nm in ipairs(DIVIDER_NAMES) do
			Section[nm] = addDivider
		end
		for _, nm in ipairs(BLANK_NAMES) do
			Section[nm] = addBlank
		end
		-- Rayfield: SectionObject:Set("new name")
		function Section:Set(text)
			if Section._titleLabel then
				Section._titleLabel.Text = tostring(text)
			end
		end

		-- every control answers to every naming / argument style (see KIND_NAMES and parseControl)
		local rawControls = {}
		for kind in pairs(KIND_NAMES) do
			rawControls[kind] = Section["Add" .. kind]
		end
		local function dispatch(kind, nameUsed, ...)
			local n, meta = parseControl(kind, nameUsed, ...)
			return wrapControl(Section, kind, n, meta, rawControls[kind])
		end
		for kind, names in pairs(KIND_NAMES) do
			local function install(nm)
				Section[nm] = function(self, ...)
					return dispatch(kind, nm, shift(self, Section, ...))
				end
			end
			install("Add" .. kind)
			for _, nm in ipairs(names) do
				install(nm)
			end
		end

		-- Venyx updaters: section:updateToggle(control, title, value) ...
		local function rename(ctl, title)
			if type(ctl) == "table" and title ~= nil and ctl.SetName then
				ctl:SetName(title)
			end
		end
		function Section:updateButton(ctl, title)
			rename(ctl, title)
		end
		function Section:updateToggle(ctl, title, value)
			rename(ctl, title)
			if value ~= nil and ctl and ctl.SetSilent then
				ctl:SetSilent(value)
			end
		end
		function Section:updateSlider(ctl, title, value)
			rename(ctl, title)
			if value ~= nil and ctl and ctl.SetSilent then
				ctl:SetSilent(value)
			end
		end
		function Section:updateDropdown(ctl, title, list)
			rename(ctl, title)
			if list and ctl and ctl.Refresh then
				ctl:Refresh(list)
			end
		end
		function Section:updateKeybind(ctl, title, key)
			rename(ctl, title)
			if key ~= nil and ctl and ctl.SetSilent then
				ctl:SetSilent(key)
			end
		end
		function Section:updateColorPicker(ctl, title, color)
			rename(ctl, title)
			if color ~= nil and ctl and ctl.SetSilent then
				ctl:SetSilent(color)
			end
		end

		-- Linoria / Obsidian: groupbox:AddDependencyBox() + box:SetupDependencies({ { Toggles.X, true } })
		function Section:AddDependencyBox()
			local rows = {}
			local box = {}
			setmetatable(box, {
				__index = function(_, k)
					local f = Section[k]
					if type(f) ~= "function" then
						return nil
					end
					return function(_, ...)
						local before = #Section._rowLog
						local r = f(Section, ...)
						for i = before + 1, #Section._rowLog do
							table.insert(rows, Section._rowLog[i])
						end
						return r
					end
				end,
			})
			function box:SetupDependencies(deps)
				local function eval()
					local show = true
					for _, d in ipairs(deps or {}) do
						if d[1] and d[1].Value ~= d[2] then
							show = false
						end
					end
					for _, r in ipairs(rows) do
						r.Visible = show
					end
				end
				for _, d in ipairs(deps or {}) do
					if d[1] and d[1].OnChanged then
						d[1]:OnChanged(eval)
					end
				end
				eval()
			end
			return box
		end
		-- media rows have no equivalent here: accepted and ignored
		function Section:AddImage()
			return {}
		end
		Section.AddVideo = Section.AddImage

		installFuzzy(Section, {
			control = function(kind)
				return function(self, ...)
					return Section["Add" .. kind](Section, shift(self, Section, ...))
				end
			end,
			divider = function()
				return function()
					return Section.AddDivider(Section)
				end
			end,
			blank = function()
				return function(self, ...)
					return Section.AddBlank(Section, shift(self, Section, ...))
				end
			end,
			section = function() -- nested groups are not supported: the call returns this section
				return function()
					return Section
				end
			end,
			notify = function()
				return function(self, ...)
					return MacUI.Notify(shift(self, Section, ...))
				end
			end,
		})
		return Section
	end

	function Window:AddTab(o, icon2)
		if type(o) == "string" then
			o = { Name = o }
			if icon2 ~= nil and type(icon2) ~= "table" then
				o.Icon = icon2
			end
		end
		o = copyTable(o or {})
		if type(o.Icon) == "number" then
			o.Icon = tostring(o.Icon)
		end
		o.Name = tostring(firstNonNil(o.Name, o.Title, o.Text, "Tab"))
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
			Name = o.Name, Btn = btn, Text = text, Icon = icon, Bar = bar, NoTint = o.NoTint,
			Page = page, _sections = {}, _order = 0, HasMatch = true,
		}
		function Tab:AddSection(so, icon2)
			if type(so) == "string" then
				so = { Title = so }
				if type(icon2) == "string" then
					so.Icon = icon2
				end
			end
			local c = copyTable(so or {})
			c.Title = firstNonNil(c.Title, c.Name, c.Text)
			c.Desc = firstNonNil(c.Desc, c.Description)
			local sec = makeSection(Tab, c)
			Tab._current = sec
			return sec
		end
		do
			local rawAddSection = Tab.AddSection
			Tab.AddSection = function(self, ...)
				return rawAddSection(Tab, shift(self, Tab, ...))
			end
		end
		for _, nm in ipairs(SECTION_NAMES) do
			Tab[nm] = Tab.AddSection
		end

		-- Linoria: Tab:AddTabbox() / tabbox:AddTab("name") -> one section per tab
		local function newTabbox()
			local tb = { Tabs = {} }
			function tb:AddTab(name)
				local sec = Tab:AddSection({ Title = tostring(name) })
				tb.Tabs[name] = sec
				return sec
			end
			return tb
		end
		Tab.AddTabbox, Tab.AddLeftTabbox, Tab.AddRightTabbox = newTabbox, newTabbox, newTabbox

		-- controls called on the tab itself go into the newest section (Rayfield: CreateSection then CreateButton ...)
		local function current()
			if not Tab._current then
				Tab._current = makeSection(Tab, {})
			end
			return Tab._current
		end
		local function route(nm)
			Tab[nm] = function(self, ...)
				local sec = current()
				return sec[nm](sec, shift(self, Tab, ...))
			end
		end
		for kind, names in pairs(KIND_NAMES) do
			route("Add" .. kind)
			for _, nm in ipairs(names) do
				route(nm)
			end
		end
		for _, nm in ipairs(DIVIDER_NAMES) do
			route(nm)
		end
		for _, nm in ipairs(BLANK_NAMES) do
			route(nm)
		end
		installFuzzy(Tab, {
			control = function(kind)
				return function(self, ...)
					local sec = current()
					return sec["Add" .. kind](sec, shift(self, Tab, ...))
				end
			end,
			divider = function()
				return function()
					return current():AddDivider()
				end
			end,
			blank = function()
				return function(self, ...)
					return current():AddBlank(shift(self, Tab, ...))
				end
			end,
			section = function()
				return function(self, ...)
					return Tab.AddSection(Tab, shift(self, Tab, ...))
				end
			end,
			tabbox = function()
				return newTabbox
			end,
			notify = function()
				return function(self, ...)
					return MacUI.Notify(shift(self, Tab, ...))
				end
			end,
		})
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
		updateNav()
		refreshCurrent()
		return Tab
	end
	do
		local rawAddTab = Window.AddTab
		Window.AddTab = function(self, ...)
			return rawAddTab(Window, shift(self, Window, ...))
		end
	end
	for _, nm in ipairs(TAB_NAMES) do
		Window[nm] = Window.AddTab
	end

	-- Window:Section(...) without a tab: goes into an automatic "Main" tab
	local defaultTab
	local function defTab()
		if not defaultTab then
			defaultTab = Window:AddTab({ Name = opts.DefaultTabName or "Main", Icon = "home" })
		end
		return defaultTab
	end
	for _, nm in ipairs(SECTION_NAMES) do
		Window[nm] = function(self, ...)
			local so, icon2 = shift(self, Window, ...)
			return defTab():AddSection(so, icon2)
		end
	end
	-- controls called on the window itself (Wally style: window:Toggle(...), window:Button(...)) go into the
	-- automatic tab, under the newest section
	local function routeWin(nm)
		if Window[nm] ~= nil or nm == "Toggle" then
			return
		end
		Window[nm] = function(self, ...)
			local t = defTab()
			return t[nm](t, shift(self, Window, ...))
		end
	end
	for kind, names in pairs(KIND_NAMES) do
		routeWin("Add" .. kind)
		for _, nm in ipairs(names) do
			routeWin(nm)
		end
	end
	for _, nm in ipairs(DIVIDER_NAMES) do
		routeWin(nm)
	end
	for _, nm in ipairs(BLANK_NAMES) do
		routeWin(nm)
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
		toggleBindCtl = win:AddBind({
			Name = "Toggle UI",
			Desc = "Click, then press a key. Backspace = none.",
			Default = (toggleKey ~= NONE_KEY) and toggleKey or false,
			OnChange = function(k)
				toggleKey = k
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
		for i, w in ipairs(MacUI._windows) do
			if w == Window then
				table.remove(MacUI._windows, i)
				break
			end
		end
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
	function Window:Toggle(...)
		if select("#", ...) > 0 then -- Window:Toggle("name", ...) is a switch control (Wally style)
			local t = defTab()
			return t:Toggle(...)
		end
		toggleMain()
		return nil
	end
	function Window:SetVisible(v)
		if main.Visible ~= (v == true) then
			toggleMain()
		end
	end
	function Window:Show()
		Window:SetVisible(true)
	end
	function Window:Hide()
		Window:SetVisible(false)
	end
	function Window:IsVisible()
		return main.Visible
	end
	-- Window:SetToggleKey(Enum.KeyCode.F1) / ("F1") / (false = no keyboard shortcut)
	function Window:SetToggleKey(k)
		if k == false or k == "None" then
			toggleKey = NONE_KEY
		else
			toggleKey = toKeyCode(k) or toggleKey
		end
		if toggleBindCtl then
			toggleBindCtl:Set((toggleKey ~= NONE_KEY) and toggleKey or false)
		end
	end
	function Window:GetToggleKey()
		return toggleKey
	end

	-- Window:SelectTab(2) / ("name") / (tab)   (also SelectPage)
	function Window:SelectTab(x)
		local tab
		if type(x) == "number" then
			tab = tabsList[x]
		elseif type(x) == "string" then
			for _, t in ipairs(tabsList) do
				if t.Name == x then
					tab = t
				end
			end
		elseif type(x) == "table" then
			tab = x
		end
		if tab and tab.Page then
			selectTab(tab)
		end
	end
	Window.SelectPage = Window.SelectTab
	function Window:Minimize()
		toggleMain()
	end

	-- Fluent: Window:Dialog({ Title, Content, Buttons = { { Title, Callback }, ... } })
	function Window:Dialog(o)
		o = o or {}
		local overlay = New("TextButton", {
			Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5,
			BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 200, Parent = gui,
		})
		local card = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(300, 0), AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.Card, BorderSizePixel = 0, ZIndex = 201, Parent = overlay,
		}, {
			Round(10),
			New("UIStroke", { Color = Theme.Stroke, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
			New("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }),
			New("UIPadding", {
				PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16),
				PaddingTop = UDim.new(0, 16), PaddingBottom = UDim.new(0, 16),
			}),
		})
		local function text(str, size, color, font, order)
			New("TextLabel", {
				BackgroundTransparency = 1, Text = tostring(str), Font = font, TextSize = size, TextColor3 = color,
				TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0), LayoutOrder = order, ZIndex = 202, Parent = card,
			})
		end
		text(firstNonNil(o.Title, o.Name, "Dialog"), 15, Theme.Text, Enum.Font.GothamBold, 1)
		local body = firstNonNil(o.Content, o.Text, o.Description)
		if body then
			text(body, 13, Theme.SubText, Enum.Font.Gotham, 2)
		end
		local buttons = o.Buttons or { { Title = "OK" } }
		local rowFrame = New("Frame", {
			BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 3, ZIndex = 202, Parent = card,
		}, {
			New("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})
		local w = math.floor((268 - 8 * (#buttons - 1)) / math.max(#buttons, 1))
		for i, b in ipairs(buttons) do
			local btn = New("TextButton", {
				Text = tostring(firstNonNil(b.Title, b.Name, b.Text, "OK")), Font = Enum.Font.GothamMedium, TextSize = 13,
				TextColor3 = (i == 1) and Color3.new(1, 1, 1) or Theme.Text,
				BackgroundColor3 = (i == 1) and Theme.Accent or Theme.Field, AutoButtonColor = false,
				BorderSizePixel = 0, Size = UDim2.fromOffset(w, 30), LayoutOrder = i, ZIndex = 203, Parent = rowFrame,
			}, { Round(6) })
			btn.Activated:Connect(function()
				overlay:Destroy()
				local cb = firstNonNil(b.Callback, b.Function, b.Func)
				if cb then
					task.spawn(cb)
				end
			end)
		end
		return { Close = function() overlay:Destroy() end }
	end

	-- config files (Rayfield ConfigurationSaving / Orion SaveConfig): every control with a flag / idx is saved
	local cfg = opts.ConfigurationSaving
	local cfgOn = (type(cfg) == "table" and cfg.Enabled == true) or opts.SaveConfig == true
	Window._cfgOn = cfgOn
	local function configFile(name)
		local folder = tostring(firstNonNil(type(cfg) == "table" and cfg.FolderName or nil, opts.ConfigFolder, "MacUI"))
		local file = tostring(name or firstNonNil(type(cfg) == "table" and cfg.FileName or nil, opts.Title, "config"))
		file = string.gsub(file, "[^%w%-_ ]", "_")
		return folder, folder .. "/" .. file .. ".json"
	end
	local function encodeValue(kind, v)
		if kind == "ColorPicker" and v then
			return { R = math.floor(v.R * 255 + 0.5), G = math.floor(v.G * 255 + 0.5), B = math.floor(v.B * 255 + 0.5) }
		elseif kind == "Bind" then
			return (not v or v == Enum.KeyCode.Unknown) and "None" or v.Name
		end
		return v
	end
	local function decodeValue(kind, v)
		if kind == "ColorPicker" and type(v) == "table" then
			return Color3.fromRGB(v.R or 255, v.G or 255, v.B or 255)
		elseif kind == "Bind" then
			return (v ~= "None") and toKeyCode(v) or false
		end
		return v
	end
	function Window:SaveConfig(name)
		if not writefile then
			return false
		end
		local data = {}
		for _, f in ipairs(flagged) do
			data[f.name] = encodeValue(f.kind, f.obj:Get())
		end
		return (pcall(function()
			local folder, path = configFile(name)
			if makefolder and isfolder and not isfolder(folder) then
				makefolder(folder)
			end
			writefile(path, game:GetService("HttpService"):JSONEncode(data))
		end))
	end
	function Window:LoadConfig(name)
		if not (readfile and isfile) then
			return false
		end
		local ok, data = pcall(function()
			local _, path = configFile(name)
			if not isfile(path) then
				return nil
			end
			return game:GetService("HttpService"):JSONDecode(readfile(path))
		end)
		if not ok or type(data) ~= "table" then
			return false
		end
		for _, f in ipairs(flagged) do
			local v = data[f.name]
			if v ~= nil then
				pcall(function()
					f.obj:SetValue(decodeValue(f.kind, v))
				end)
			end
		end
		return true
	end
	if cfgOn then
		local token = 0
		saveSoon = function()
			token += 1
			local my = token
			task.delay(0.4, function()
				if my == token and not destroyed then
					Window:SaveConfig()
				end
			end)
		end
	end

	function Window:SetUser(t)
		for k, v in pairs(t or {}) do
			userInfo[k] = v
		end
		applyUser()
	end
	-- text under the name at the bottom of the sidebar. Window:SetUserNote("Expires: 23h 53m")
	-- colour for the whole line: SetUserNote(text, Color3); part of it: RichText such as <font color="#FF8A3D">23h</font>
	-- SetUserNote("") or SetUserNote(nil) removes the line again
	function Window:SetUserNote(text, color)
		userInfo.Note = text
		userInfo.NoteColor = color
		applyUser()
	end
	function Window:GetUserNote()
		return userInfo.Note
	end
	function Window:ToggleSidebar()
		onToggleSidebar()
	end
	function Window.Notify(a, ...)
		if a == Window then
			return MacUI.Notify(...)
		end
		return MacUI.Notify(a, ...)
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

	-- toggle-UI shortcut: ignored while typing in a text box or while a Bind control is waiting for a key
	table.insert(conns, UIS.InputBegan:Connect(function(input, processed)
		if processed or bindBusy or input == consumedInput or toggleKey == NONE_KEY then
			return
		end
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == toggleKey then
			toggleMain()
		end
	end))

	installFuzzy(Window, {
		tab = function()
			return function(self, ...)
				return Window.AddTab(Window, shift(self, Window, ...))
			end
		end,
		section = function()
			return function(self, ...)
				local so, icon2 = shift(self, Window, ...)
				return defTab():AddSection(so, icon2)
			end
		end,
		tabbox = function()
			return function()
				return defTab():AddTabbox()
			end
		end,
		control = function(kind)
			return function(self, ...)
				local t = defTab()
				return t["Add" .. kind](t, shift(self, Window, ...))
			end
		end,
		divider = function()
			return function()
				return defTab():AddDivider()
			end
		end,
		blank = function()
			return function(self, ...)
				return defTab():AddBlank(shift(self, Window, ...))
			end
		end,
		notify = function()
			return function(self, ...)
				return MacUI.Notify(shift(self, Window, ...))
			end
		end,
		dialog = function()
			return function(self, ...)
				return Window.Dialog(Window, shift(self, Window, ...))
			end
		end,
	})
	table.insert(MacUI._windows, Window)
	MacUI._theme = Theme -- live table, used by notifications
	return Window
end

-- Library.CreateWindow(opts) / Library:CreateWindow(opts) / Library:Window(opts) all work
function MacUI.CreateWindow(...)
	local a, b = unself(...)
	local o
	if type(a) == "table" then
		o = a
	elseif type(a) == "string" then -- CreateLib("Title", "Theme") / new("Title", themeTable) / CreateWindow("Title")
		o = { Title = a }
		if b ~= nil and type(b) ~= "function" then
			o.Theme = b
		end
	else
		o = {}
	end
	return buildWindow(o)
end
for _, n in ipairs({ "Window", "MakeWindow", "NewWindow", "Create", "CreateLib", "new", "New" }) do
	MacUI[n] = MacUI.CreateWindow
end

local function lastWindow()
	return MacUI._windows[#MacUI._windows]
end
-- config: Orion Init(), Rayfield LoadConfiguration(), SaveConfiguration()
function MacUI.LoadConfiguration()
	for _, w in ipairs(MacUI._windows) do
		if w._cfgOn then
			w:LoadConfig()
		end
	end
end
function MacUI.SaveConfiguration()
	for _, w in ipairs(MacUI._windows) do
		if w._cfgOn then
			w:SaveConfig()
		end
	end
end
function MacUI.Init()
	MacUI.LoadConfiguration()
end
MacUI.MakeNotification = MacUI.Notify
function MacUI.Unload()
	MacUI.Destroy()
end
function MacUI.OnUnload(...)
	local fn = unself(...)
	if type(fn) == "function" then
		table.insert(MacUI._onUnload, fn)
	end
end
function MacUI.Toggle()
	local w = lastWindow()
	if w then
		w:Toggle()
	end
end
function MacUI.SetVisibility(...)
	local v = unself(...)
	local w = lastWindow()
	if w then
		w:SetVisible(v ~= false)
	end
end
function MacUI.IsVisible()
	local w = lastWindow()
	return w ~= nil and w:IsVisible()
end
function MacUI.SetTheme(...)
	local name = unself(...)
	local w = lastWindow()
	if w and type(name) == "string" then
		local m = ThemeMap[string.lower(name)]
		w:SetTheme((m and m[1]) or name)
		if m and m[2] then
			w:SetAccent(Accents[m[2]])
		end
	end
end
-- cosmetic features of other libraries that have no equivalent here: accepted and ignored
for _, n in ipairs({
	"SetWatermark", "SetWatermarkVisibility", "SetFont", "SetLoadingText", "UpdateColorsUsingRegistry",
	"RefreshConfigList", "SetKeybindFrame", "ToggleKeybindFrame",
}) do
	MacUI[n] = function() end
end
MacUI.KeybindFrame = { Visible = false }
MacUI.Watermark = { Visible = false }
MacUI.Unloaded = false

installFuzzy(MacUI, {
	window = function()
		return MacUI.CreateWindow
	end,
	notify = function()
		return MacUI.Notify
	end,
})

return MacUI
