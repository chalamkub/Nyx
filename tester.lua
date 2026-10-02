-- ==========================================
-- WHITELIST COUNTDOWN
-- ==========================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WhitelistCountdown"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Countdown = Instance.new("TextLabel")
Countdown.Name = "Countdown"
Countdown.Parent = ScreenGui

Countdown.AnchorPoint = Vector2.new(0, 1)
Countdown.Position = UDim2.new(0, 15, 1, -15)
Countdown.Size = UDim2.new(0, 320, 0, 30)

Countdown.BackgroundTransparency = 1
Countdown.TextXAlignment = Enum.TextXAlignment.Left
Countdown.TextYAlignment = Enum.TextYAlignment.Center

Countdown.Font = Enum.Font.GothamMedium
Countdown.TextSize = 14
Countdown.TextColor3 = Color3.fromRGB(255, 255, 255)

Countdown.Text = "เหลือเวลา: กำลังโหลด..."

-- ==========================================
-- PARSE EXPIRES_AT
-- ==========================================

local function ParseDateTime(dateString)
    if not dateString then
        return nil
    end

    local year, month, day, hour, minute, second =
        dateString:match(
            "(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)"
        )

    if not year then
        return nil
    end

    return os.time({
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = tonumber(hour),
        min = tonumber(minute),
        sec = tonumber(second)
    })
end

local ExpireTime = ParseDateTime(Data.expires_at)

-- ==========================================
-- UPDATE COUNTDOWN
-- ==========================================

task.spawn(function()
    while true do
        if ExpireTime then
            local Remaining = ExpireTime - os.time()

            if Remaining <= 0 then
                Countdown.Text = "เหลือเวลา: หมดอายุแล้ว"
                break
            end

            local Days = math.floor(Remaining / 86400)
            Remaining = Remaining % 86400

            local Hours = math.floor(Remaining / 3600)
            Remaining = Remaining % 3600

            local Minutes = math.floor(Remaining / 60)
            local Seconds = Remaining % 60

            Countdown.Text = string.format(
                "เหลือเวลา: %d วัน %d ชั่วโมง %d นาที %d วินาที",
                Days,
                Hours,
                Minutes,
                Seconds
            )
        else
            Countdown.Text = "เหลือเวลา: ไม่ทราบข้อมูล"
        end

        task.wait(1)
    end
end)
