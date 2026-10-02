--==================================================
-- NYX WHITELIST (รองรับคีย์ถาวร + แสดงเวลาในโปรไฟล์ MacUI V3)
--==================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local API_URL = "https://zerzy.xyz/api/verify.php"
local MACUI_URL = "https://raw.githubusercontent.com/chalamkub/Nyx/refs/heads/main/MacUI_Library_v2.lua"

--================ KEY ================
local Key = getgenv().Key
if not Key or tostring(Key) == "" then
    LocalPlayer:Kick("Whitelist Key is missing")
    return
end
Key = tostring(Key)

--================ HWID ================
local function GetHWID()
    local fns = { gethwid, get_hwid, syn and syn.get_hwid }
    for _, fn in ipairs(fns) do
        if typeof(fn) == "function" then
            local ok, result = pcall(fn)
            if ok and result then
                return tostring(result)
            end
        end
    end
    return nil
end

local HWID = GetHWID()
if not HWID then
    LocalPlayer:Kick("Unable to get HWID")
    return
end

--================ REQUEST ================
local RequestFunction = (typeof(request) == "function" and request)
    or (typeof(http_request) == "function" and http_request)
    or (syn and typeof(syn.request) == "function" and syn.request)

if not RequestFunction then
    LocalPlayer:Kick("HTTP request is not supported")
    return
end

--================ VERIFY ================
local Response
local ok = pcall(function()
    Response = RequestFunction({
        Url = API_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode({ key = Key, hwid = HWID })
    })
end)

if not ok or not Response then
    LocalPlayer:Kick("Whitelist API connection failed")
    return
end

local Body = Response.Body or Response.body or ""
local Data
local DecodeOK = pcall(function()
    Data = HttpService:JSONDecode(Body)
end)

if not DecodeOK or type(Data) ~= "table" then
    LocalPlayer:Kick("Invalid API response")
    return
end

if Data.success ~= true then
    LocalPlayer:Kick(tostring(Data.message or "Whitelist verification failed"))
    return
end

--================ EXPIRATION ================
local IsLifetime = Data.lifetime == true
local ExpiresAt = Data.expires_at or "Lifetime"
local ExpireTimestamp

if not IsLifetime then
    if type(Data.expires_in) ~= "number" then
        LocalPlayer:Kick("Expiration time missing")
        return
    end
    ExpireTimestamp = os.time() + Data.expires_in
end

--================ LOAD MACUI ================
local success, result = pcall(function()
    return game:HttpGet(MACUI_URL)
end)

if not success or not result or result:match("404: Not Found") then
    LocalPlayer:Kick("Failed to download MacUI Library")
    return
end

local loadedFunc, loadErr = loadstring(result)
if type(loadedFunc) ~= "function" then
    LocalPlayer:Kick("Failed to compile MacUI: " .. tostring(loadErr))
    return
end

local LibraryOK, MacUI = pcall(loadedFunc)
if not LibraryOK or not MacUI then
    LocalPlayer:Kick("Error running MacUI Library")
    return
end

--================ WINDOW / TAB ================
local Window = MacUI:MakeWindow({
    Name = "My Premium Script",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MyScriptConfig"
})

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

pcall(function()
    MainTab:AddParagraph({
        Title = "Profile",
        Content = "Key: " .. Key .. "\nสถานะ: Whitelisted"
    })
end)


--==================================================
-- ค้นหาป้ายชื่อโปรไฟล์ (SMART SCANNER)
--==================================================

local function FindProfileLabel()
    local pName = LocalPlayer.Name
    local pDisp = LocalPlayer.DisplayName
    
    -- รูปแบบชื่อที่เป็นไปได้ใน UI
    local checkTexts = { 
        pName, 
        pDisp, 
        "@" .. pName, 
        pDisp .. " (@" .. pName .. ")" 
    }
    
    -- ค้นหาครอบคลุมทุกที่ที่ Executor มักจะนำ UI ไปซ่อนไว้ (รองรับ Delta)
    local containers = {}
    if typeof(gethui) == "function" then table.insert(containers, gethui()) end
    table.insert(containers, game:GetService("CoreGui"))
    if LocalPlayer:FindFirstChild("PlayerGui") then table.insert(containers, LocalPlayer.PlayerGui) end

    for _, container in ipairs(containers) do
        for _, gui in ipairs(container:GetDescendants()) do
            if gui:IsA("TextLabel") then
                for _, textToMatch in ipairs(checkTexts) do
                    if gui.Text == textToMatch then
                        return gui
                    end
                end
            end
        end
    end
    return nil
end

-- วนลูปค้นหาป้ายชื่อ สูงสุด 5 วินาที (รอ UI โหลด)
local ProfileNameLabel = nil
for i = 1, 10 do
    ProfileNameLabel = FindProfileLabel()
    if ProfileNameLabel then break end
    task.wait(0.5)
end

local OriginalNameText = LocalPlayer.DisplayName

if ProfileNameLabel then
    OriginalNameText = ProfileNameLabel.Text
    ProfileNameLabel.RichText = true
    ProfileNameLabel.TextScaled = false
    
    -- ขยายกล่องข้อความลงมา 18 พิกเซล เพื่อกันไม่ให้บรรทัดเวลาโดนตัดทิ้ง
    pcall(function()
        ProfileNameLabel.Size = UDim2.new(
            ProfileNameLabel.Size.X.Scale, ProfileNameLabel.Size.X.Offset,
            ProfileNameLabel.Size.Y.Scale, ProfileNameLabel.Size.Y.Offset + 18
        )
    end)
end


--================ FALLBACK UI ================
local CountdownLabel
if not ProfileNameLabel then
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NyxCountdownGui"

    local targetParent = (typeof(gethui) == "function" and gethui())
        or game:GetService("CoreGui")
        or LocalPlayer:WaitForChild("PlayerGui")

    pcall(function() ScreenGui.Parent = targetParent end)

    local ProfileContainer = Instance.new("Frame")
    ProfileContainer.Name = "NyxProfileCountdown"
    ProfileContainer.Parent = ScreenGui
    ProfileContainer.AnchorPoint = Vector2.new(0, 1)
    ProfileContainer.Position = UDim2.new(0, 15, 1, -15)
    ProfileContainer.Size = UDim2.new(0, 300, 0, 45)
    ProfileContainer.BackgroundTransparency = 1
    
    CountdownLabel = Instance.new("TextLabel")
    CountdownLabel.Name = "NyxCountdown"
    CountdownLabel.Parent = ProfileContainer
    CountdownLabel.BackgroundTransparency = 1
    CountdownLabel.BorderSizePixel = 0
    CountdownLabel.Size = UDim2.new(1, -10, 0, 30)
    CountdownLabel.Position = UDim2.new(0, 5, 1, -30)
    CountdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    CountdownLabel.TextYAlignment = Enum.TextYAlignment.Center
    CountdownLabel.Font = Enum.Font.GothamMedium
    CountdownLabel.TextSize = 13
    CountdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    CountdownLabel.TextStrokeTransparency = 0.6
    CountdownLabel.Text = "กำลังโหลด..."
end


--================ FORMAT TIME ================
local function FormatTime(seconds)
    seconds = math.max(0, math.floor(seconds))
    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60
    
    if days > 0 then
        return string.format("%d วัน %d ชม. %d นาที", days, hours, minutes)
    else
        return string.format("%d ชม. %d นาที %d วิ", hours, minutes, secs)
    end
end


--================ COUNTDOWN LOGIC ================
task.spawn(function()
    if IsLifetime then
        if ProfileNameLabel then
            ProfileNameLabel.Text = OriginalNameText .. "\n<font color='rgb(170,170,170)' size='11'>สถานะ: ถาวร</font>"
        else
            CountdownLabel.Text = "เหลือเวลา: ถาวร"
        end
        return
    end

    while true do
        local remaining = ExpireTimestamp - os.time()
        local isExpired = remaining <= 0
        local timeStr = isExpired and "หมดอายุแล้ว" or FormatTime(remaining)
        
        if ProfileNameLabel then
            ProfileNameLabel.Text = OriginalNameText .. "\n<font color='rgb(170,170,170)' size='11'>⏳ " .. timeStr .. "</font>"
        else
            CountdownLabel.Text = "เหลือเวลา: " .. timeStr
        end

        if isExpired then break end
        task.wait(1)
    end
end)

--================ BUTTON ================
MainTab:AddButton({
    Name = "ฟังก์ชันทำงาน",
    Callback = function()
        print("[NYX] Script is working!")
    end
})

--================ DEBUG ================
print("[NYX] Whitelist verified")
print("[NYX] Key:", Key)
print("[NYX] HWID:", HWID)
print("[NYX] Expires:", ExpiresAt)
print("[NYX] Devices:", tostring(Data.devices) .. "/" .. tostring(Data.max_devices))
