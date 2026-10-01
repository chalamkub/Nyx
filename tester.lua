-- MacUI demo / test script
-- Shows every component: tabs, sections, toggle, dropdown, slider, button, label, settings tab.
--
-- HOW TO RUN
--   A) Hosted:  put your raw link in LIB_URL below.
--   B) Local:   save MacUI.lua into your executor's workspace folder (same name) and leave
--               LIB_URL empty. The demo will use readfile("MacUI.lua").

local LIB_URL = "" -- e.g. "https://raw.githubusercontent.com/USER/REPO/main/MacUI.lua"
local LIB_FILE = "MacUI.lua"

local function loadLibrary()
	local src
	if LIB_URL ~= "" then
		src = game:HttpGet(LIB_URL)
	elseif readfile and isfile and isfile(LIB_FILE) then
		src = readfile(LIB_FILE)
	else
		error("[MacUI demo] Set LIB_URL, or put " .. LIB_FILE .. " in your executor workspace folder.")
	end
	local fn, err = loadstring(src)
	assert(fn, "[MacUI demo] Library failed to compile: " .. tostring(err))
	return fn()
end

local MacUI = loadLibrary()

local Window = MacUI.CreateWindow({
	Title = "MacUI Demo",
	Subtitle = "Primary",
	Theme = "Dark",                       -- Dark | Midnight | Mocha | Light
	Accent = Color3.fromRGB(41, 148, 255),
	Glass = 0.18,
	ToggleKey = Enum.KeyCode.RightShift,  -- show / hide the window
	ConfirmClose = true,
	-- Profile at the bottom of the sidebar (all optional):
	-- ShowUser = true, MaskName = false, UserName = "Custom name", UserImage = "rbxassetid://123",
	OnDestroy = function()
		print("[Demo] UI destroyed")
	end,
})

----------------------------------------------------------------------
-- Tab 1: controls
----------------------------------------------------------------------
-- Header test: the < > buttons next to the title go to the previous / next tab (first tab shows only >,
-- last tab shows only <). The left-most header icon collapses / expands the sidebar.
-- The avatar + name at the bottom of the sidebar is the local player.
local Home = Window:AddTab({ Section = "Demo", Name = "Controls", Icon = "home" })

local Basic = Home:AddSection({
	Title = "Basic controls",
	Desc = "Each control prints to the console.",
	Icon = "star",
	IconColor = Color3.fromRGB(255, 82, 82), -- colored section icon
})

local status -- label created below, updated by callbacks

local toggle = Basic:AddToggle({
	Name = "Example toggle",
	Desc = "Click to switch on / off.",
	Default = false,
	Callback = function(v)
		print("[Demo] toggle =", v)
		if status then
			status:Set("Toggle is now " .. (v and "ON" or "OFF"))
		end
	end,
})

local dropdown = Basic:AddDropdown({
	Name = "Example dropdown",
	Desc = "Pick one option.",
	Options = { "Option A", "Option B", "Option C", "Option D", "Option E", "Option F" },
	Default = "Option B",
	Callback = function(v)
		print("[Demo] dropdown =", v)
		if status then
			status:Set("Dropdown picked: " .. tostring(v))
		end
	end,
})

local slider = Basic:AddSlider({
	Name = "Example slider",
	Desc = "Drag it (mouse or touch).",
	Min = 0, Max = 100, Increment = 5, Default = 25, Suffix = "%",
	Callback = function(v)
		print("[Demo] slider =", v)
		if status then
			status:Set("Slider value: " .. v .. "%")
		end
	end,
})

local clicks = 0
local runButton
runButton = Basic:AddButton({
	Name = "Example button",
	Desc = "Counts clicks and changes its own text.",
	ButtonText = "Click me",
	Callback = function()
		clicks += 1
		print("[Demo] button clicked", clicks)
		runButton:SetText("Clicked " .. clicks)
		if status then
			status:Set("Button clicked " .. clicks .. " time(s)")
		end
	end,
})

local Info = Home:AddSection({
	Title = "Live status",
	Desc = "Labels can be updated from code.",
	Icon = "bolt",
	IconColor = Color3.fromRGB(41, 148, 255),
})
status = Info:AddLabel({ Name = "Last action", Value = "Nothing yet. Try the controls above." })
Info:AddLabel({
	Name = "Long text test",
	Value = "This label has a long value on purpose, to check that the text wraps onto several lines "
		.. "and the row grows instead of getting cut off with three dots.",
})

----------------------------------------------------------------------
-- Tab 2: programmatic control
----------------------------------------------------------------------
local Tools = Window:AddTab({ Section = "Demo", Name = "Programmatic", Icon = "list" })

local Api = Tools:AddSection({
	Title = "Set values from code",
	Desc = "Set() never fires the callback.",
	Icon = "gear", -- no IconColor: uses the accent color
})

Api:AddButton({
	Name = "Toggle ON + slider 80",
	Desc = "Calls toggle:Set(true) and slider:Set(80).",
	ButtonText = "Apply",
	Callback = function()
		toggle:Set(true)
		slider:Set(80)
		status:Set("Set from code: toggle ON, slider 80%")
	end,
})
Api:AddButton({
	Name = "Reset controls",
	Desc = "Toggle off, slider 25, dropdown Option B.",
	ButtonText = "Reset",
	Callback = function()
		toggle:Set(false)
		slider:Set(25)
		dropdown:Set("Option B")
		status:Set("Controls reset")
	end,
})
Api:AddButton({
	Name = "Read values",
	Desc = "Prints toggle:Get(), dropdown:Get(), slider:Get().",
	ButtonText = "Print",
	Callback = function()
		print("[Demo] toggle", toggle:Get(), "| dropdown", dropdown:Get(), "| slider", slider:Get())
	end,
})

local Look = Tools:AddSection({
	Title = "Change look from code",
	Desc = "These also update the Settings tab.",
	Icon = "eye",
})
Look:AddButton({
	Name = "Theme: Midnight",
	ButtonText = "Apply",
	Callback = function() Window:SetTheme("Midnight") end,
})
Look:AddButton({
	Name = "Theme: Light",
	ButtonText = "Apply",
	Callback = function() Window:SetTheme("Light") end,
})
Look:AddButton({
	Name = "Accent: Pink",
	ButtonText = "Apply",
	Callback = function() Window:SetAccent(Color3.fromRGB(255, 92, 160)) end,
})
Look:AddButton({
	Name = "Glass: 40%",
	ButtonText = "Apply",
	Callback = function() Window:SetGlass(0.4) end,
})

----------------------------------------------------------------------
-- Tab 3: search test (try typing "alpha" or "beta" in the search box)
----------------------------------------------------------------------
local Search = Window:AddTab({ Section = "Demo", Name = "Search test", Icon = "search" })
local S1 = Search:AddSection({ Title = "Fruit", Desc = "Used to test the search filter.", Icon = "🍎" }) -- emoji icon
S1:AddToggle({ Name = "Alpha apple", Desc = "Type 'alpha' in Search." })
S1:AddToggle({ Name = "Beta banana", Desc = "Type 'beta' in Search." })
S1:AddToggle({ Name = "Gamma grape" })
local S2 = Search:AddSection({ Title = "Numbers" })
S2:AddSlider({ Name = "Alpha level", Min = 1, Max = 10, Default = 3 })
S2:AddSlider({ Name = "Beta level", Min = 1, Max = 10, Default = 7 })

----------------------------------------------------------------------
-- Settings tab (theme / glass / accent / size / unload)
----------------------------------------------------------------------
Window:AddSettingsTab()

print("[Demo] MacUI loaded. Press RightShift to hide / show.")
