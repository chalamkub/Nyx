--==================================================
-- NYX WHITELIST TESTER
-- Key + HWID + Profile Countdown + Safe UI Load
--==================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--==================================================
-- CONFIG
--==================================================

local API_URL = "https://zerzy.xyz/api/verify.php"

local MACUI_URL =
    "https://raw.githubusercontent.com/chalamkub/Nyx/refs/heads/main/MacUI_Library_v2.lua"


--==================================================
-- KEY
--==================================================

local Key = getgenv().Key

if not Key or tostring(Key) == "" then
    LocalPlayer:Kick("Whitelist Key is missing")
    return
end

Key = tostring(Key)


--==================================================
-- HWID
--==================================================

local function GetHWID()

    if typeof(gethwid) == "function" then
        local ok, result = pcall(gethwid)

        if ok and result then
            return tostring(result)
        end
    end

    if typeof(get_hwid) == "function" then
        local ok, result = pcall(get_hwid)

        if ok and result then
            return tostring(result)
        end
    end

    if syn and typeof(syn.get_hwid) == "function" then
        local ok, result = pcall(syn.get_hwid)

        if ok and result then
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
-- REQUEST
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
-- VERIFY
--==================================================

local Response

local ok, err = pcall(function()

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


if not ok or not Response then
    LocalPlayer:Kick("Whitelist API connection failed")
    return
end


--==================================================
-- RESPONSE
--==================================================

local Body =
    Response.Body
    or Response.body
    or ""


local Data

local DecodeOK = pcall(function()
    Data = HttpService:JSONDecode(Body)
end)


if not DecodeOK or type(Data) ~= "table" then
    LocalPlayer:Kick("Invalid API response")
    return
end


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
-- EXPIRES AT
--==================================================

local ExpiresAt = Data.expires_at

if not ExpiresAt then
    LocalPlayer:Kick("Expiration time missing")
    return
end


--==================================================
-- DATE PARSER
--==================================================

local function ParseDateTime(value)

    local y, mo, d, h, mi, s =
        tostring(value):match(
            "(%d+)%-(%d+)%-(%d+) (%d+):(%d+):(%d+)"
        )

    if not y then
        return nil
    end

    return os.time({
        year = tonumber(y),
        month = tonumber(mo),
        day = tonumber(d),
        hour = tonumber(h),
        min = tonumber(mi),
        sec = tonumber(s)
    })
end


local ExpireTimestamp =
    ParseDateTime(ExpiresAt)


if not ExpireTimestamp then
    LocalPlayer:Kick("Invalid expiration time")
    return
end


--==================================================
-- LOAD MACUI (FIXED - แบบปลอดภัยป้องกัน nil)
--==================================================

local MacUI

local success, result = pcall(function()
    return game:HttpGet(MACUI_URL)
end)

if not success or not result or result:match("404: Not Found") then
    LocalPlayer:Kick("Failed to download MacUI Library: ลิงก์เสียหรือเน็ตมีปัญหา")
    return
end

local loadedFunc, loadErr = loadstring(result)
if type(loadedFunc) ~= "function" then
    LocalPlayer:Kick("Failed to compile MacUI: โค้ดในลิงก์ไม่ถูกต้อง (" .. tostring(loadErr) .. ")")
    return
end

local LibraryOK, UIResult = pcall(function()
    return loadedFunc()
end)

if not LibraryOK then
    LocalPlayer:Kick("Error running MacUI Library")
    return
end

MacUI = UIResult


--==================================================
-- WINDOW
--==================================================

local Window = MacUI:MakeWindow({
    Name = "My Premium Script",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MyScriptConfig"
})


--==================================================
-- TAB
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
-- WAIT FOR UI
--==================================================

task.wait(0.5)


--==================================================
-- FIND PROFILE UI
--==================================================

local function FindProfileContainer()
    local PlayerGui =
        LocalPlayer:WaitForChild("PlayerGui")

    local PossibleNames = {
        "Profile", "profile",
        "User", "user",
        "UserProfile", "UserInfo",
        "Player", "PlayerProfile",
        "ProfileFrame", "UserFrame",
        "Account", "AccountFrame"
    }

    for _, gui in ipairs(PlayerGui:GetDescendants()) do
        if gui:IsA("Frame") or gui:IsA("ScrollingFrame") or gui:IsA("CanvasGroup") then
            for _, name in ipairs(PossibleNames) do
                if gui.Name == name then
                    return gui
                end
            end
        end
    end

    for _, gui in ipairs(PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") or gui:IsA("TextButton") then
            local text = string.lower(tostring(gui.Text or ""))
            if text:find("profile") or text:find("user") then
                local parent = gui.Parent
                if parent then
                    return parent
                end
            end
        end
    end

    return nil
end


--==================================================
-- CREATE COUNTDOWN
--==================================================

local ProfileContainer = FindProfileContainer()


--==================================================
-- FALLBACK (FIXED - สร้าง ScreenGui)
--==================================================

if not ProfileContainer then
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
        
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NyxCountdownGui"
    
    local targetParent = (typeof(gethui) == "function" and gethui()) 
        or game:GetService("CoreGui") 
        or PlayerGui
        
    pcall(function() ScreenGui.Parent = targetParent end)

    ProfileContainer = Instance.new("Frame")
    ProfileContainer.Name = "NyxProfileCountdown"
    ProfileContainer.Parent = ScreenGui
    ProfileContainer.AnchorPoint = Vector2.new(0, 1)
    ProfileContainer.Position = UDim2.new(0, 15, 1, -15)
    ProfileContainer.Size = UDim2.new(0, 300, 0, 45)
    ProfileContainer.BackgroundTransparency = 1
end


--==================================================
-- COUNTDOWN LABEL
--==================================================

local CountdownLabel = Instance.new("TextLabel")
CountdownLabel.Name = "NyxCountdown"
CountdownLabel.Parent = ProfileContainer
CountdownLabel.BackgroundTransparency = 1
CountdownLabel.BorderSizePixel = 0
CountdownLabel.Size = UDim2.new(1, -10, 0, 30)
CountdownLabel.Position = UDim2.new(0, 5, 1, -30)
CountdownLabel.AnchorPoint = Vector2.new(0, 0)
CountdownLabel.TextXAlignment = Enum.TextXAlignment.Left
CountdownLabel.TextYAlignment = Enum.TextYAlignment.Center
CountdownLabel.Font = Enum.Font.GothamMedium
CountdownLabel.TextSize = 13
CountdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CountdownLabel.TextStrokeTransparency = 0.6
CountdownLabel.Text = "เหลือเวลา: กำลังโหลด..."


--==================================================
-- FORMAT
--==================================================

local function FormatTime(seconds)
    seconds = math.max(0, math.floor(seconds))
    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60

    return string.format(
        "%d วัน %d ชั่วโมง %d นาที %d วินาที",
        days, hours, minutes, secs
    )
end


--==================================================
-- COUNTDOWN
--==================================================

task.spawn(function()
    while true do
        local remaining = ExpireTimestamp - os.time()

        if remaining <= 0 then
            CountdownLabel.Text = "เหลือเวลา: หมดอายุแล้ว"
            break
        end

        CountdownLabel.Text = "เหลือเวลา: " .. FormatTime(remaining)
        task.wait(1)
    end
end)


--==================================================
-- BUTTON
--==================================================

MainTab:AddButton({
    Name = "ฟังก์ชันทำงาน",
    Callback = function()
        print("[NYX] Script is working!")
    end
})


--==================================================
-- DEBUG
--==================================================

print("[NYX] Whitelist verified")
print("[NYX] Key:", Key)
print("[NYX] HWID:", HWID)
print("[NYX] Expires:", ExpiresAt)
print("[NYX] Countdown:", FormatTime(ExpireTimestamp - os.time()))
