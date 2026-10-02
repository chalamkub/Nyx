local HttpService = game:GetService("HttpService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local API_URL = "https://zerzy.xyz/api/verify.php"

local Key = getgenv().Key
if not Key or tostring(Key) == "" then
    LocalPlayer:Kick("Whitelist Key is missing")
    return
end
Key = tostring(Key)

local function GetHWID()
    local fns = { gethwid, get_hwid, syn and syn.get_hwid }
    for _, fn in ipairs(fns) do
        if typeof(fn) == "function" then
            local ok, result = pcall(fn)
            if ok and result then return tostring(result) end
        end
    end
end

local HWID = GetHWID()
if not HWID then
    LocalPlayer:Kick("Unable to get HWID")
    return
end

local RequestFunction = request or http_request or (syn and syn.request)
if typeof(RequestFunction) ~= "function" then
    LocalPlayer:Kick("HTTP request is not supported")
    return
end

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

local Data
local DecodeOK = pcall(function()
    Data = HttpService:JSONDecode(Response.Body or Response.body or "")
end)
if not DecodeOK or type(Data) ~= "table" then
    LocalPlayer:Kick("Invalid API response")
    return
end

if Data.success ~= true then
    LocalPlayer:Kick(tostring(Data.message or "Whitelist verification failed"))
    return
end

print("Whitelist verified!")

local RemainingSeconds = tonumber(
    Data.key and Data.key.remaining_seconds
)

local function FormatTime(seconds)
    seconds = math.max(0, math.floor(seconds))

    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400

    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600

    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60

    if days > 0 then
        return string.format("%dd %02dh %02dm", days, hours, minutes)
    elseif hours > 0 then
        return string.format("%dh %02dm", hours, minutes)
    elseif minutes > 0 then
        return string.format("%dm %02ds", minutes, secs)
    else
        return string.format("%ds", secs)
    end
end

-- ใส่โค้ดสคริปต์หลักของคุณต่อจากตรงนี้

--[[
    ==============================================================================
    2K SCRIPT — FISCH (MacUI Edition - Fixed Tab Error)
    Edition: High-Performance Automation & Exploitation Hub
    Theme: MacUI Glassmorphism
    ==============================================================================
]]

-- ── 1. STRICT AUTO-CLEANUP ───────────────────────────────────────────────────────
if _G.FischCleanup then pcall(_G.FischCleanup) end
if _G.FischMinGui then pcall(function() _G.FischMinGui:Destroy() end) end
_G.FischRunning = false

local HttpService       = game:GetService("HttpService")
local RunService        = game:GetService("RunService")
local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")
local CoreGui           = game:GetService("CoreGui")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local RS                = game:GetService("ReplicatedStorage")
local VIM               = game:GetService("VirtualInputManager")

local thisRunId         = HttpService:GenerateGUID(false)
_G.FischRunId           = thisRunId
_G.FischRunning         = true

local _conns = {}
_G.FischCleanup = function()
    _G.FischRunning = false
    _G.FischRunId   = nil
    for _, c in ipairs(_conns) do pcall(function() c:Disconnect() end) end
    table.clear(_conns)
    if _G.FischMinGui then
        pcall(function() _G.FischMinGui:Destroy() end)
        _G.FischMinGui = nil
    end
    local oldP = Workspace:FindFirstChild("2K_WaterWalk")
    if oldP then oldP:Destroy() end
end

-- ── 2. SERVICES, REMOTES & LIBRARIES (FIXED INFINITE YIELD) ───────────────────
if not game:IsLoaded() then game.Loaded:Wait() end 

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

local EventsFolder = RS:WaitForChild("events", 5) 

local ReelFinishedEvent    = EventsFolder and EventsFolder:FindFirstChild("reelfinished")
local SellEverythingFunc   = EventsFolder and EventsFolder:FindFirstChild("selleverything")
local SellSingleFunc       = EventsFolder and EventsFolder:FindFirstChild("Sell")
local VirtualUser          = game:GetService("VirtualUser")

local fishLib = nil
pcall(function() fishLib = require(RS.shared.modules.library.fish) end)

-- ── 3. STATE & CONFIGURATION ─────────────────────────────
local State = {
    AntiAFK             = true,
    FullAutoFish        = false,
    AutoCast            = false,
    CastPower           = 100,
    AutoShake           = false,
    AutoReel            = false,
    ReelDelay           = 0.6,
    AutoEquipRod        = false,
    AutoSell            = false,
    SellInterval        = 30,
    SellAllBypass       = false,
    SelectedRarities    = {
        ["Trash"] = true, ["Common"] = true, ["Uncommon"] = true, ["Unusual"] = true,
        ["Rare"] = false, ["Legendary"] = false, ["Mythical"] = false, ["Exotic"] = false, ["Secret"] = false,
    },
    WalkSpeed           = 16,
    JumpPower           = 50,
    InfJump             = false,
    Noclip              = false,
    WalkOnWater         = false,
    Fullbright          = false,
    SelectedIsland      = "Moosewood (ท่าตกปลา Pier)",
    ReelDebounce        = false,
    CastDebounce        = false,
    SellDebounce        = false,
}

-- ── 4. ISLAND TELEPORT COORDINATES ───────────────────────────────────────────────
local IslandData = {
    ["Moosewood (ท่าตกปลา Pier)"]            = {pos = Vector3.new(357.46, 133.68, 238.47), look = Vector3.new(-0.959, 0, -0.281)},
    ["Moosewood (หมู่บ้านเริ่มต้น)"]           = {pos = Vector3.new(495, 150, 230)},
    ["Roslit Bay (อ่าวรอสลิต)"]                = {pos = Vector3.new(-1480, 133, 715)},
    ["Sunstone Island (เกาะซันสโตน)"]          = {pos = Vector3.new(-935, 132, -1125)},
    ["Terrapin Island (เกาะเต่า)"]             = {pos = Vector3.new(-170, 145, 1930)},
    ["Snowcap Island (เกาะหิมะ)"]              = {pos = Vector3.new(2620, 145, 2370)},
    ["Mushgrove Swamp (บึงเห็ด)"]              = {pos = Vector3.new(2430, 135, -680)},
    ["Forsaken Shores (ชายหาดร้าง)"]           = {pos = Vector3.new(-2485, 135, 1560)},
    ["Ancient Isle (เกาะโบราณ)"]               = {pos = Vector3.new(5880, 155, 340)},
    ["Statue of Sovereignty (รูปปั้น)"]        = {pos = Vector3.new(28, 135, -840)},
    ["The Depths (ใต้บาดาล)"]                  = {pos = Vector3.new(954, -710, 1218)},
    ["Vertigo (เกาะเวอร์ติโก)"]                = {pos = Vector3.new(-118, -488, 1019)},
    ["Desolate Deep (ห้วงลึก)"]                = {pos = Vector3.new(-1655, -235, -2845)},
    ["คนรับซื้อปลา Moosewood (Merchant)"]     = {pos = Vector3.new(465, 151, 235)},
    ["ห้องมนตรา (Enchant Room)"]              = {pos = Vector3.new(1316, -401, -44)},
}

local function teleportTo(entry)
    pcall(function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos = typeof(entry) == "table" and entry.pos or entry
            local look = typeof(entry) == "table" and entry.look
            if look then
                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 1.5, 0), pos + look)
            else
                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 1.5, 0))
            end
        end
    end)
end

-- ── 5. FISHING & SELLING AUTOMATION ENGINE ───────────────────────────────────────
local function isRodTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if tool:FindFirstChild("values") and tool.values:FindFirstChild("casted") then return true end
    if string.find(string.lower(tool.Name), "rod") then return true end
    return false
end

local function getRod()
    if LP.Character then
        for _, v in ipairs(LP.Character:GetChildren()) do
            if isRodTool(v) then return v end
        end
    end
    for _, v in ipairs(LP.Backpack:GetChildren()) do
        if isRodTool(v) then return v end
    end
    return nil
end

local function getFishRarity(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    if fishLib and fishLib[tool.Name] and fishLib[tool.Name].Rarity then return fishLib[tool.Name].Rarity end
    local rAttr = tool:GetAttribute("Rarity")
    if rAttr then return tostring(rAttr) end
    local rVal = tool:FindFirstChild("Rarity")
    if rVal and rVal:IsA("StringValue") then return rVal.Value end
    return nil
end

local function isRarityAllowedToSell(rarity)
    if not rarity then return false end
    if State.SellAllBypass then return true end
    if type(State.SelectedRarities) == "table" then
        if State.SelectedRarities[rarity] == true then return true end
        for k, v in pairs(State.SelectedRarities) do
            if (v == true and tostring(k) == tostring(rarity)) or (tostring(v) == tostring(rarity)) then
                return true
            end
        end
    end
    return false
end

local function executeSell()
    if State.SellDebounce then return end
    State.SellDebounce = true
    pcall(function()
        if State.SellAllBypass then
            if SellEverythingFunc then pcall(function() SellEverythingFunc:InvokeServer() end) end
            return
        end
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local currentHeld = char:FindFirstChildOfClass("Tool")
        local itemsToSell = {}
        local function collectFish(container)
            if not container then return end
            for _, t in ipairs(container:GetChildren()) do
                if t:IsA("Tool") and not isRodTool(t) then
                    local rarity = getFishRarity(t)
                    if rarity and isRarityAllowedToSell(rarity) then
                        table.insert(itemsToSell, t)
                    end
                end
            end
        end
        collectFish(LP.Backpack)
        collectFish(char)
        if #itemsToSell == 0 then return end
        for _, fishTool in ipairs(itemsToSell) do
            if fishTool.Parent then
                pcall(function()
                    hum:EquipTool(fishTool)
                    task.wait(0.12)
                    if SellSingleFunc then SellSingleFunc:InvokeServer() end
                    task.wait(0.08)
                end)
            end
        end
        if currentHeld and currentHeld.Parent and (State.AutoEquipRod or State.FullAutoFish) then
            pcall(function() hum:EquipTool(currentHeld) end)
        else
            local rod = getRod()
            if rod and (State.AutoEquipRod or State.FullAutoFish) and hum then
                pcall(function() hum:EquipTool(rod) end)
            end
        end
    end)
    State.SellDebounce = false
end

pcall(function()
    local rc = require(RS.client.legacyControllers:FindFirstChild("ReelController"))
    if rc and not rc._Hooked2K then
        rc._Hooked2K = true
        local oldIsInBar = rc.IsInBar
        rc.IsInBar = function(self, ...)
            if State.FullAutoFish or State.AutoReel then return true end
            return oldIsInBar(self, ...)
        end
        local oldUpdate = rc.Update
        rc.Update = function(self, dt)
            if State.FullAutoFish or State.AutoReel then self.barPosition = self.fishPosition end
            local res = oldUpdate(self, dt)
            if State.FullAutoFish or State.AutoReel then self.barPosition = self.fishPosition end
            return res
        end
    end
end)

local function handleShake()
    local shakeUI = PlayerGui:FindFirstChild("shakeui")
    if not shakeUI then return end
    local safezone = shakeUI:FindFirstChild("safezone")
    if safezone then
        for _, btn in ipairs(safezone:GetChildren()) do
            if (btn:IsA("ImageButton") or btn:IsA("TextButton")) and btn.Visible then
                pcall(function()
                    if firesignal then
                        firesignal(btn.Activated)
                        firesignal(btn.MouseButton1Click)
                    end
                    if getconnections then
                        for _, c in ipairs(getconnections(btn.Activated)) do pcall(function() c:Fire() end) end
                        for _, c in ipairs(getconnections(btn.MouseButton1Click)) do pcall(function() c:Fire() end) end
                    end
                end)
            end
        end
    end
end

local function handleReel()
    local reelUI = PlayerGui:FindFirstChild("reel")
    if not reelUI then return end
    pcall(function()
        local ReelController = require(RS.client.legacyControllers:FindFirstChild("ReelController"))
        if ReelController and ReelController.ActiveReel then
            local reel = ReelController.ActiveReel
            if reel.fishPosition then reel.barPosition = reel.fishPosition end
        end
    end)
    local bar = reelUI:FindFirstChild("bar")
    if bar then
        local fish = bar:FindFirstChild("fish")
        local playerbar = bar:FindFirstChild("playerbar")
        if fish and playerbar then
            playerbar.Position = UDim2.fromScale(fish.Position.X.Scale, playerbar.Position.Y.Scale)
        end
    end
end

local function handleCast()
    if State.CastDebounce then return end
    if PlayerGui:FindFirstChild("shakeui") or PlayerGui:FindFirstChild("reel") then return end
    local rod = getRod()
    if not rod then return end
    pcall(function()
        local sp = PlayerGui:FindFirstChild("hud") and PlayerGui.hud:FindFirstChild("safezone") and PlayerGui.hud.safezone:FindFirstChild("starterpack")
        if sp and sp.Visible then sp.Visible = false end
    end)
    if rod.Parent == LP.Backpack and (State.AutoEquipRod or State.FullAutoFish) and LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(rod) end
        task.wait(0.5)
    end
    if rod.Parent ~= LP.Character then return end
    if rod:FindFirstChild("bobber") or (rod:FindFirstChild("values") and rod.values:FindFirstChild("casted") and rod.values.casted.Value == true) then
        return
    end
    State.CastDebounce = true
    task.spawn(function()
        local doneCast = false
        pcall(function()
            local gui = PlayerGui:FindFirstChild("FishButtonMobile")
            local btn = gui and gui:FindFirstChild("Frame") and gui.Frame:FindFirstChild("button")
            if btn then
                local c_began = getconnections(btn.InputBegan)
                local c_ended = getconnections(btn.InputEnded)
                local mockInput = { UserInputType = Enum.UserInputType.MouseButton1, KeyCode = Enum.KeyCode.Unknown }
                if c_began[1] and c_began[1].Function then
                    task.spawn(c_began[1].Function, mockInput)
                    local holdTime = math.clamp((State.CastPower / 100) * 0.55, 0.25, 0.6)
                    task.wait(holdTime)
                    if c_ended[1] and c_ended[1].Function then
                        task.spawn(c_ended[1].Function, mockInput)
                    end
                    doneCast = true
                end
            end
        end)
        if not doneCast then
            pcall(function()
                if mouse1press and mouse1release then
                    mouse1press()
                    task.wait(0.4)
                    mouse1release()
                elseif VIM and VIM.SendMouseButtonEvent then
                    VIM:SendMouseButtonEvent(150, 500, 0, true, game, 0)
                    task.wait(0.4)
                    VIM:SendMouseButtonEvent(150, 500, 0, false, game, 0)
                end
            end)
        end
        task.wait(2.2)
        State.CastDebounce = false
    end)
end

task.spawn(function()
    while _G.FischRunning and _G.FischRunId == thisRunId do
        if State.FullAutoFish or State.AutoShake then handleShake() end
        if State.FullAutoFish or State.AutoReel then handleReel() end
        if State.FullAutoFish or State.AutoCast then handleCast() end
        task.wait(0.06)
    end
end)

task.spawn(function()
    while _G.FischRunning and _G.FischRunId == thisRunId do
        if State.AutoSell then executeSell() end
        task.wait(State.SellInterval)
    end
end)

-- ── 5.1 ANTI-AFK ─────────────────────────────────────────────────────────────────
pcall(function()
    if getconnections then
        for _, c in ipairs(getconnections(LP.Idled)) do pcall(function() c:Disable() end) end
    end
end)

local function purgeAfkTags(char)
    if not char then return end
    for _, desc in ipairs(char:GetDescendants()) do
        if desc:IsA("BillboardGui") and (desc.Name:lower():find("afk") or desc.Name:lower():find("idle")) then
            pcall(function() desc.Enabled = false end)
        elseif desc:IsA("TextLabel") and (desc.Text:find("%[AFK%]") or desc.Text:find("AFK")) then
            pcall(function() desc.Visible = false end)
        end
    end
end

if LP.Character then purgeAfkTags(LP.Character) end
table.insert(_conns, LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    purgeAfkTags(char)
    table.insert(_conns, char.DescendantAdded:Connect(function(desc)
        if desc:IsA("BillboardGui") and (desc.Name:lower():find("afk") or desc.Name:lower():find("idle")) then
            pcall(function() desc.Enabled = false end)
        elseif desc:IsA("TextLabel") and (desc.Text:find("%[AFK%]") or desc.Text:find("AFK")) then
            pcall(function() desc.Visible = false end)
        end
    end))
end))

table.insert(_conns, LP.Idled:Connect(function()
    if not State.AntiAFK then return end
    pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.zero) end)
end))

-- ── 6. MOVEMENT & WATER-WALK ENGINE ───────────────────────────────────────────────
local waterPlatform = nil
table.insert(_conns, RunService.Stepped:Connect(function()
    if not _G.FischRunning or _G.FischRunId ~= thisRunId then return end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if State.WalkSpeed and State.WalkSpeed ~= 16 then hum.WalkSpeed = State.WalkSpeed end
        if State.JumpPower and State.JumpPower ~= 50 then hum.JumpPower = State.JumpPower end
    end
    if State.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end
    if State.WalkOnWater then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if not waterPlatform then
                waterPlatform = Instance.new("Part")
                waterPlatform.Name = "2K_WaterWalk"
                waterPlatform.Size = Vector3.new(24, 1.2, 24)
                waterPlatform.Anchored = true
                waterPlatform.CanCollide = true
                waterPlatform.Transparency = 1
                waterPlatform.Parent = Workspace
            end
            local p = hrp.Position
            local surfaceY = 127.2
            if p.Y > 120 then
                waterPlatform.CFrame = CFrame.new(p.X, surfaceY - 0.6, p.Z)
            else
                waterPlatform.CFrame = CFrame.new(p.X, -9999, p.Z)
            end
        end
    else
        if waterPlatform then waterPlatform:Destroy(); waterPlatform = nil end
    end
end))

table.insert(_conns, UserInputService.JumpRequest:Connect(function()
    if State.InfJump and LP.Character then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

table.insert(_conns, RunService.RenderStepped:Connect(function()
    if not _G.FischRunning or _G.FischRunId ~= thisRunId then return end
    if State.Fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
end))

local function applyBoostFPS()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                v.Enabled = false
            end
        end
    end)
end

-- ── 7. MACUI LIBRARY IMPLEMENTATION (NYX EDITION) ───────────────────────────────
local MacLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/chalamkub/Nyx/refs/heads/main/MacUI_Library_v2.lua"))()

local Window = MacLib:Window({
    Title = "2K SCRIPT",
    Subtitle = "Fisch Hub - Powered by Nyx",
    Size = UDim2.fromOffset(868, 650),
    DragStyle = 1,
    DisabledWindowControls = {},
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.RightControl,
    Acrylic = true,
})

-- สร้างแท็บ (Tabs) โดยสร้างจาก Window ตรงๆ
local MainTab = Window:Tab({ Title = "ฟาร์มหลัก", Icon = "rbxassetid://10709769508" })
local TeleportTab = Window:Tab({ Title = "เทเลพอร์ตเกาะ", Icon = "rbxassetid://10709786206" })
local PlayerTab = Window:Tab({ Title = "ผู้เล่น & ความเร็ว", Icon = "rbxassetid://10709789496" })
local SettingsTab = Window:Tab({ Title = "ตั้งค่าสคริปต์", Icon = "rbxassetid://10709779901" })

-- ==========================================
-- แท็บ 1: ฟาร์มหลัก (Main Farm)
-- ==========================================
local MainSection = MainTab:Section({ Title = "ระบบตกปลาอัตโนมัติ", Side = "Left" })
MainSection:Toggle({
    Title = "เปิดระบบ Auto Fish ครบวงจร",
    Description = "หยิบเบ็ด เหวี่ยง เขย่า และดึงอัตโนมัติ",
    Default = false,
    Callback = function(val)
        State.FullAutoFish = val
        State.AutoEquipRod = val
        State.AutoCast     = val
        State.AutoShake    = val
        State.AutoReel     = val
    end
})

MainSection:Slider({
    Title = "พลังการเหวี่ยงเบ็ด (%)",
    Description = "แรงเหวี่ยงเหยื่อลงน้ำ",
    Default = 100,
    Min = 20,
    Max = 100,
    Callback = function(val)
        State.CastPower = val
    end
})

local SellSection = MainTab:Section({ Title = "ระบบขายปลาอัตโนมัติ", Side = "Right" })
SellSection:Toggle({
    Title = "เปิดขายปลาอัตโนมัติ",
    Description = "ขายตามระดับที่เลือก",
    Default = false,
    Callback = function(val) State.AutoSell = val end
})

SellSection:Toggle({
    Title = "ขายทุกระดับ (Sell All)",
    Description = "ขายปลาทั้งหมดไม่คัดกรอง",
    Default = false,
    Callback = function(val) State.SellAllBypass = val end
})

SellSection:Dropdown({
    Title = "เลือกระดับปลาที่จะขาย",
    Description = "เลือกประเภทปลาที่จะนำไปขาย",
    Multi = true,
    Options = {"Trash", "Common", "Uncommon", "Unusual", "Rare", "Legendary", "Mythical", "Exotic", "Secret"},
    Default = {"Trash", "Common", "Uncommon", "Unusual"},
    Callback = function(val)
        State.SelectedRarities = val
    end
})

SellSection:Slider({
    Title = "ระยะเวลาในการขาย (วินาที)",
    Default = 30,
    Min = 10,
    Max = 300,
    Callback = function(val) State.SellInterval = val end
})

SellSection:Button({
    Title = "สั่งขายปลาทันที (Sell Now)",
    Callback = function()
        executeSell()
        Window:Notify({
            Title = "ระบบการขายทำงาน",
            Description = "ส่งคำสั่งขายปลาเรียบร้อยแล้ว",
            Time = 2.5
        })
    end
})

-- ==========================================
-- แท็บ 2: เทเลพอร์ต (Teleport)
-- ==========================================
local TpSection = TeleportTab:Section({ Title = "วาร์ปเกาะ", Side = "Left" })
TpSection:Dropdown({
    Title = "เลือกเกาะปลายทาง",
    Multi = false,
    Options = {
        "Moosewood (ท่าตกปลา Pier)", "Moosewood (หมู่บ้านเริ่มต้น)", "Roslit Bay (อ่าวรอสลิต)",
        "Sunstone Island (เกาะซันสโตน)", "Terrapin Island (เกาะเต่า)", "Snowcap Island (เกาะหิมะ)",
        "Mushgrove Swamp (บึงเห็ด)", "Forsaken Shores (ชายหาดร้าง)", "Ancient Isle (เกาะโบราณ)",
        "Statue of Sovereignty (รูปปั้น)", "The Depths (ใต้บาดาล)", "Vertigo (เกาะเวอร์ติโก)",
        "Desolate Deep (ห้วงลึก)"
    },
    Default = "Moosewood (ท่าตกปลา Pier)",
    Callback = function(val)
        State.SelectedIsland = val
    end
})

TpSection:Button({
    Title = "ไปเกาะที่เลือก",
    Callback = function()
        local pos = IslandData[State.SelectedIsland]
        if pos then
            teleportTo(pos)
            Window:Notify({ Title = "วาร์ปสำเร็จ", Description = "พาคุณมาที่ " .. State.SelectedIsland, Time = 2 })
        end
    end
})

local SpecialTpSection = TeleportTab:Section({ Title = "จุดสำคัญพิเศษ", Side = "Right" })
SpecialTpSection:Button({
    Title = "คนรับซื้อปลา Moosewood (Merchant)",
    Callback = function() teleportTo(IslandData["คนรับซื้อปลา Moosewood (Merchant)"]) end
})
SpecialTpSection:Button({
    Title = "ห้องมนตรา (Enchant Room)",
    Callback = function() teleportTo(IslandData["ห้องมนตรา (Enchant Room)"]) end
})

-- ==========================================
-- แท็บ 3: ผู้เล่น & ความเร็ว (Player & Visuals)
-- ==========================================
local PlayerSection = PlayerTab:Section({ Title = "ตั้งค่าผู้เล่น", Side = "Left" })
PlayerSection:Slider({
    Title = "ความเร็วเดิน (WalkSpeed)",
    Default = 16, Min = 16, Max = 120,
    Callback = function(val) State.WalkSpeed = val end
})

PlayerSection:Slider({
    Title = "พลังกระโดด (JumpPower)",
    Default = 50, Min = 50, Max = 200,
    Callback = function(val) State.JumpPower = val end
})

PlayerSection:Toggle({
    Title = "กระโดดไม่จำกัด (Inf Jump)",
    Default = false,
    Callback = function(val) State.InfJump = val end
})

PlayerSection:Toggle({
    Title = "เดินทะลุกำแพง (Noclip)",
    Default = false,
    Callback = function(val) State.Noclip = val end
})

PlayerSection:Toggle({
    Title = "เดินบนน้ำ (Walk on Water)",
    Default = false,
    Callback = function(val) State.WalkOnWater = val end
})

local VisualSection = PlayerTab:Section({ Title = "อื่นๆ", Side = "Right" })
VisualSection:Toggle({
    Title = "กันหลุด & ลบป้าย AFK",
    Default = true,
    Callback = function(val) State.AntiAFK = val end
})
VisualSection:Toggle({
    Title = "ปรับสว่าง (Fullbright)",
    Default = false,
    Callback = function(val) State.Fullbright = val end
})
VisualSection:Button({
    Title = "ลบเอฟเฟกต์ (Boost FPS)",
    Callback = function()
        applyBoostFPS()
        Window:Notify({ Title = "Boost FPS", Description = "ลดกราฟิกเรียบร้อยแล้ว", Time = 2 })
    end
})

-- ==========================================
-- แท็บ 4: ตั้งค่าสคริปต์ (Settings)
-- ==========================================
local SysSection = SettingsTab:Section({ Title = "ระบบการจัดการ", Side = "Left" })
SysSection:Button({
    Title = "ปิดการทำงานสคริปต์ (Unload)",
    Description = "ลบหน้าต่างและหยุดการทำงานทั้งหมด",
    Callback = function()
        if _G.FischCleanup then _G.FischCleanup() end
    end
})

-- โหลดเสร็จสมบูรณ์
MacLib:SetFolder("Nyx_2K_Script")
Window:Notify({
    Title = "โหลดสำเร็จ",
    Description = "2K Script รันสำเร็จ! กด RightControl เพื่อซ่อนหน้าต่าง",
    Time = 4
})


print("Script is running...")
