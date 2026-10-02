--==================================================
-- NYX WHITELIST TESTER
-- Key + HWID + Expiration Countdown
--==================================================

--==================================================
-- CONFIG
--==================================================

local API_URL =
    "https://zerzy.xyz/api/verify.php"

local MACUI_URL =
    "https://raw.githubusercontent.com/chalamkub/Nyx/refs/heads/main/MacUI_Library_v2.lua"


--==================================================
-- SERVICES
--==================================================

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer


--==================================================
-- GET KEY
--==================================================

local Key = getgenv().Key

if not Key or tostring(Key) == "" then
    LocalPlayer:Kick("Whitelist Key is missing")
    return
end

Key = tostring(Key)


--==================================================
-- GET HWID
--==================================================

local function GetHWID()

    if typeof(gethwid) == "function" then
        local success, result = pcall(function()
            return gethwid()
        end)

        if success and result then
            return tostring(result)
        end
    end


    if typeof(get_hwid) == "function" then
        local success, result = pcall(function()
            return get_hwid()
        end)

        if success and result then
            return tostring(result)
        end
    end


    if syn and typeof(syn.get_hwid) == "function" then
        local success, result = pcall(function()
            return syn.get_hwid()
        end)

        if success and result then
            return tostring(result)
        end
    end


    return nil
end


local HWID = GetHWID()

if not HWID then
    LocalPlayer:Kick("Unable to get HWID")
    return
end


--==================================================
-- GET REQUEST FUNCTION
--==================================================

local RequestFunction

if typeof(request) == "function" then

    RequestFunction = request

elseif typeof(http_request) == "function" then

    RequestFunction = http_request

elseif syn and typeof(syn.request) == "function" then

    RequestFunction = syn.request

end


if not RequestFunction then
    LocalPlayer:Kick("HTTP request is not supported")
    return
end


--==================================================
-- JSON SERVICE
--==================================================

local HttpService = game:GetService("HttpService")


--==================================================
-- VERIFY WHITELIST
--==================================================

local Response

local success, errorMessage = pcall(function()

    Response = RequestFunction({

        Url = API_URL,

        Method = "POST",

        Headers = {
            ["Content-Type"] = "application/json"
        },

        Body = HttpService:JSONEncode({

            key = Key,

            hwid = HWID

        })

    })

end)


if not success or not Response then

    LocalPlayer:Kick(
        "Whitelist API connection failed"
    )

    return
end


--==================================================
-- GET RESPONSE BODY
--==================================================

local Body =
    Response.Body
    or Response.body
    or ""


local Data

local DecodeSuccess = pcall(function()

    Data = HttpService:JSONDecode(Body)

end)


if not DecodeSuccess or type(Data) ~= "table" then

    LocalPlayer:Kick(
        "Invalid API response"
    )

    return
end


--==================================================
-- CHECK API RESULT
--==================================================

if Data.success ~= true then

    LocalPlayer:Kick(
        tostring(
            Data.message
            or "Whitelist verification failed"
        )
    )

    return
end


--==================================================
-- GET EXPIRATION
--==================================================

local ExpiresAt =
    Data.expires_at


if not ExpiresAt then

    LocalPlayer:Kick(
        "API did not return expiration time"
    )

    return
end


--==================================================
-- PARSE PHP DATETIME
--
-- Format:
-- YYYY-MM-DD HH:MM:SS
--==================================================

local function ParseDateTime(DateString)

    if not DateString then
        return nil
    end


    local Year,
        Month,
        Day,
        Hour,
        Minute,
        Second =
        tostring(DateString):match(
            "(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)"
        )


    if not Year then
        return nil
    end


    return os.time({

        year = tonumber(Year),

        month = tonumber(Month),

        day = tonumber(Day),

        hour = tonumber(Hour),

        min = tonumber(Minute),

        sec = tonumber(Second)

    })

end


local ExpireTimestamp =
    ParseDateTime(ExpiresAt)


if not ExpireTimestamp then

    LocalPlayer:Kick(
        "Invalid expiration time"
    )

    return
end


--==================================================
-- LOAD MACUI
--==================================================

local MacUI

local LibrarySuccess, LibraryError =
    pcall(function()

        MacUI = loadstring(
            game:HttpGet(MACUI_URL)
        )()

    end)


if not LibrarySuccess or not MacUI then

    LocalPlayer:Kick(
        "Failed to load MacUI Library"
    )

    return
end


--==================================================
-- CREATE WINDOW
--==================================================

local Window = MacUI:MakeWindow({

    Name = "My Premium Script",

    HidePremium = false,

    SaveConfig = true,

    ConfigFolder = "MyScriptConfig"

})


--==================================================
-- CREATE MAIN TAB
--==================================================

local MainTab = Window:MakeTab({

    Name = "Main",

    Icon = "rbxassetid://4483345998",

    PremiumOnly = false

})


--==================================================
-- PROFILE
--==================================================

pcall(function()

    MainTab:AddParagraph({

        Title = "Profile",

        Content =
            "Key: " .. Key ..
            "\nสถานะ: Whitelisted"

    })

end)


--==================================================
-- COUNTDOWN UI
--
-- มุมซ้ายล่างของหน้าจอ
--==================================================

local ScreenGui = Instance.new(
    "ScreenGui"
)

ScreenGui.Name =
    "NyxWhitelistCountdown"

ScreenGui.ResetOnSpawn =
    false

ScreenGui.IgnoreGuiInset =
    true

ScreenGui.Parent =
    LocalPlayer:WaitForChild(
        "PlayerGui"
    )


--==================================================
-- COUNTDOWN LABEL
--==================================================

local CountdownLabel =
    Instance.new("TextLabel")


CountdownLabel.Name =
    "Countdown"


CountdownLabel.Parent =
    ScreenGui


CountdownLabel.AnchorPoint =
    Vector2.new(0, 1)


CountdownLabel.Position =
    UDim2.new(
        0,
        15,
        1,
        -15
    )


CountdownLabel.Size =
    UDim2.new(
        0,
        420,
        0,
        30
    )


CountdownLabel.BackgroundTransparency =
    1


CountdownLabel.BorderSizePixel =
    0


CountdownLabel.TextXAlignment =
    Enum.TextXAlignment.Left


CountdownLabel.TextYAlignment =
    Enum.TextYAlignment.Center


CountdownLabel.Font =
    Enum.Font.GothamMedium


CountdownLabel.TextSize =
    14


CountdownLabel.TextColor3 =
    Color3.fromRGB(
        255,
        255,
        255
    )


CountdownLabel.TextStrokeTransparency =
    0.5


CountdownLabel.Text =
    "เหลือเวลา: กำลังโหลด..."


--==================================================
-- FORMAT TIME
--==================================================

local function FormatRemainingTime(
    Seconds
)

    Seconds =
        math.max(
            0,
            math.floor(Seconds)
        )


    local Days =
        math.floor(
            Seconds / 86400
        )


    Seconds =
        Seconds % 86400


    local Hours =
        math.floor(
            Seconds / 3600
        )


    Seconds =
        Seconds % 3600


    local Minutes =
        math.floor(
            Seconds / 60
        )


    local RemainingSeconds =
        Seconds % 60


    return string.format(

        "%d วัน %d ชั่วโมง %d นาที %d วินาที",

        Days,

        Hours,

        Minutes,

        RemainingSeconds

    )

end


--==================================================
-- COUNTDOWN LOOP
--==================================================

task.spawn(function()

    while true do

        local Remaining =
            ExpireTimestamp - os.time()


        if Remaining <= 0 then

            CountdownLabel.Text =
                "เหลือเวลา: หมดอายุแล้ว"


            break

        end


        CountdownLabel.Text =
            "เหลือเวลา: "
            .. FormatRemainingTime(
                Remaining
            )


        task.wait(1)

    end

end)


--==================================================
-- TEST BUTTON
--==================================================

MainTab:AddButton({

    Name = "ฟังก์ชันทำงาน",

    Callback = function()

        print(
            "[NYX] Script is working!"
        )

    end

})


--==================================================
-- CONSOLE
--==================================================

print(
    "[NYX] Whitelist verified"
)

print(
    "[NYX] Key:",
    Key
)

print(
    "[NYX] HWID:",
    HWID
)

print(
    "[NYX] Expires:",
    ExpiresAt
)

print(
    "[NYX] Countdown started"
)
