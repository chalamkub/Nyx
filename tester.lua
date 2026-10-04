-- Demo: MacUI + KeyTimer from your GitHub (chalamkub/Nyx).
-- It fakes a key check that says "this key has 1d 02h 03m 04s left", so you can see the countdown
-- without a real key. Set USE_FAKE_KEY = false to use your real key system instead (then run your own
-- key check where the marked line is).

local USE_FAKE_KEY = true

local TIMER_URL = "https://raw.githubusercontent.com/chalamkub/Nyx/refs/heads/main/KeyTimer.lua"
local LIB_URL = "https://raw.githubusercontent.com/chalamkub/Nyx/refs/heads/main/MacUI_Library.lua"

local HttpService = game:GetService("HttpService")
local env = getgenv()

-- ---------------------------------------------------------------- fake API (demo only)
local realRequest = env.request
local REMAINING = 1 * 86400 + 2 * 3600 + 3 * 60 + 4 -- 1d 02h 03m 04s

if USE_FAKE_KEY then
    env.request = function(opts)
        if type(opts) == "table" and string.find(tostring(opts.Url or ""), "verify.php", 1, true) then
            return {
                StatusCode = 200,
                Headers = { Date = os.date("!%a, %d %b %Y %H:%M:%S GMT") }, -- the "server" clock
                Body = HttpService:JSONEncode({ success = true, message = "ok", expires_at = os.time() + REMAINING }),
            }
        end
        return realRequest(opts)
    end
end

-- ---------------------------------------------------------------- 1) the timer goes first
loadstring(game:HttpGet(TIMER_URL))()

-- ---------------------------------------------------------------- 2) your main script: key check, then the UI
if USE_FAKE_KEY then
    -- stands in for the key check of the main script (request to verify.php)
    env.request({ Url = "https://zerzy.xyz/api/verify.php", Method = "POST" })
end
-- (with a real key system, your normal key check happens here instead)

local MacUI = loadstring(game:HttpGet(LIB_URL))()

local Window = MacUI.CreateWindow({
    Title = "Nyx Demo",
    Subtitle = "KeyTimer test",
    MaskName = true, -- shows the name like "iM*****"
})

local Home = Window:AddTab({ Section = "Demo", Name = "Home", Icon = "home" })
local Sec = Home:AddSection({ Title = "Key", Desc = "The countdown is under your name, bottom left.", Icon = "lock" })
Sec:AddLabel({ Name = "Look at the bottom left", Value = "Days, hours, minutes and seconds count down every second." })
Sec:AddButton({
    Name = "Notification",
    ButtonText = "Show",
    Callback = function()
        Window:Notify({ Title = "Nyx Demo", Content = "Timer is running.", Type = "success" })
    end,
})
Sec:AddToggle({ Name = "Example toggle", Default = false, Callback = function(v) print("toggle", v) end })

Window:AddSettingsTab()

-- restore the real request function after the demo's key check (the timer already has what it needs)
if USE_FAKE_KEY then
    env.request = realRequest
end
