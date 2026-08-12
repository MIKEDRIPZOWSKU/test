-- ============================================================
-- FINAL STABLE RAGEBOT with Loading Screen & Proper Head/Torso Aim
-- ============================================================

if _G.fsocietyLoaded then return end
_G.fsocietyLoaded = true

-- ============================================================
-- LOADING SCREEN (shown during 10-second finalization)
-- ============================================================
local function showLoadingScreen()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LoadingScreen"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = game:GetService("CoreGui")

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    bg.BackgroundTransparency = 0.5
    bg.BorderSizePixel = 0
    bg.Parent = screenGui

    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(0, 150, 0, 150)
    logo.Position = UDim2.new(0.5, -75, 0.5, -100)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://139332626629793"
    logo.Parent = bg

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0, 200, 0, 30)
    text.Position = UDim2.new(0.5, -100, 0.5, 60)
    text.BackgroundTransparency = 1
    text.Text = "FINALIZING..."
    text.TextColor3 = Color3.fromRGB(0, 255, 65)
    text.TextSize = 18
    text.Font = Enum.Font.SourceSansBold  -- clean 8-bit style
    text.TextStrokeTransparency = 0.5
    text.Parent = bg

    -- Add a small loading spinner (optional) – we'll just let it sit
    return screenGui
end

local loadingGui = showLoadingScreen()

-- Load AC bypass (will take time)
loadstring(game:HttpGet("https://pastefy.app/r89qgE8B/raw"))()
task.wait(10)  -- 10-second finalization

-- Remove loading screen
if loadingGui then loadingGui:Destroy() end

-- ============================================================
-- LOAD UI LIBRARY
-- ============================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImInsane-1337/neverlose-ui/refs/heads/main/source/library.lua"))()
if not Library then return end

local CheatName = "RivalsCheat"
Library.Folders = {
    Directory = CheatName,
    Configs = CheatName .. "/Configs",
    Assets = CheatName .. "/Assets",
}
local Accent = Color3.fromRGB(0, 255, 65)
local Gradient = Color3.fromRGB(0, 200, 50)
Library.Theme.Accent = Accent
Library.Theme.AccentGradient = Gradient
Library:ChangeTheme("Accent", Accent)
Library:ChangeTheme("AccentGradient", Gradient)

-- Static watermark
Library:Watermark({
    "fsociety00.dat",
    "Mr. Robot",
    139332626629793
})

-- ============================================================
-- DEVICE SPOOFER
-- ============================================================
local DeviceSpoofer = nil
pcall(function()
    DeviceSpoofer = {}
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    if not (ReplicatedStorage and RunService and Players) then return end
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then return end
    local _active = false
    local _selectedDevice = "MouseKeyboard"
    local _connection = nil
    local DeviceOptions = {"MouseKeyboard", "Touch", "Gamepad", "VR"}
    function DeviceSpoofer:SetDevice(device)
        if not table.find(DeviceOptions, device) then device = "MouseKeyboard" end
        _selectedDevice = device
        if _active then self:Spoof() end
    end
    function DeviceSpoofer:Spoof()
        if not _active then return end
        pcall(function()
            local remote = ReplicatedStorage:FindFirstChild("Remotes")
            if not remote then return end
            local replication = remote:FindFirstChild("Replication")
            if not replication then return end
            local fighter = replication:FindFirstChild("Fighter")
            if not fighter then return end
            local setControls = fighter:FindFirstChild("SetControls")
            if not setControls then return end
            setControls:FireServer(_selectedDevice)
        end)
    end
    function DeviceSpoofer:Start()
        if _active then return end
        _active = true
        self:Spoof()
        if _connection then _connection:Disconnect() end
        _connection = RunService.Heartbeat:Connect(function()
            if _active then self:Spoof() end
        end)
    end
    function DeviceSpoofer:Stop()
        _active = false
        if _connection then _connection:Disconnect() end
    end
    function DeviceSpoofer:IsActive() return _active end
    function DeviceSpoofer:GetCurrentDevice() return _selectedDevice end
    function DeviceSpoofer:GetDeviceOptions() return DeviceOptions end
end)

-- ============================================================
-- UI CONSTRUCTION
-- ============================================================
local Window = Library:Window({
    Name = "fsociety00.dat",
    SubName = "Mr. Robot",
    Logo = "139332626629793",
    MenuKeybind = Enum.KeyCode.RightControl
})
local KeybindList = Library:KeybindList("Keybinds")

Window:Category("Combat")
local CombatPage = Window:Page({Name = "Combat", Icon = "138827881557940"})
Window:Category("Exploits")
local ExploitsPage = Window:Page({Name = "Exploits", Icon = "108839695397679"})
Window:Category("Misc")
local MiscPage = Window:Page({Name = "Misc", Icon = "103180437044643"})
Window:Category("Settings")
local SettingsPage = Library:CreateSettingsPage(Window, KeybindList)

-- Ragebot Section
local RageSection = ExploitsPage:Section({Name = "Ragebot", Side = 1})
local rageToggle = RageSection:Toggle({
    Name = "Enable Ragebot (Desync + Auto-Shoot)",
    Flag = "Ragebot",
    Default = false,
    Callback = function(v)
        if v then startRagebot() else stopRagebot() end
    end
})
local intervalSlider = RageSection:Slider({
    Name = "Shot Delay (seconds, 0 = fastest)",
    Flag = "RageShotDelay",
    Min = 0,
    Max = 0.5,
    Default = 0.03,
    Decimals = 0.01,
    Suffix = "s",
    Callback = function(v)
        shotDelay = v
        if ragebotActive then
            stopAutoShoot()
            startAutoShoot()
        end
    end
})
local aimTarget = "Head"
local aimDropdown = RageSection:Dropdown({
    Name = "Aim Target",
    Flag = "RageAimTarget",
    Default = {"Head"},
    Items = {"Head", "Torso"},
    Multi = false,
    Callback = function(v)
        aimTarget = v[1] or "Head"
    end
})

CombatPage:Section({Name = "Silent Aim", Side = 1}):Label("Coming soon.")
CombatPage:Section({Name = "Ragebot Settings", Side = 2}):Label("Use Exploits tab.")
ExploitsPage:Section({Name = "Melee", Side = 2}):Label("Coming soon.")
ExploitsPage:Section({Name = "Shooting", Side = 1}):Label("Ragebot handles shooting.")

local SpoofSection = MiscPage:Section({Name = "Device Spoofer", Side = 1})
SpoofSection:Toggle({
    Name = "Enable Device Spoofer",
    Flag = "DeviceSpoofer",
    Default = false,
    Callback = function(v)
        if DeviceSpoofer then
            if v then DeviceSpoofer:Start() else DeviceSpoofer:Stop() end
        end
    end
})
SpoofSection:Dropdown({
    Name = "Device Type",
    Flag = "SpoofDevice",
    Default = {"MouseKeyboard"},
    Items = {"MouseKeyboard", "Touch", "Gamepad", "VR"},
    Multi = false,
    Callback = function(v)
        if DeviceSpoofer then
            local device = v[1] or "MouseKeyboard"
            DeviceSpoofer:SetDevice(device)
        end
    end
})

Library:Notification({
    Title = "Script Loaded",
    Description = "fsociety00.dat ready.",
    Duration = 3,
    Icon = "73789337996373"
})
Window:Init()

-- ============================================================
-- RAGEBOT CORE – Desync + Remote Auto-Shoot with Proper Head/Torso Aim
-- ============================================================
local ragebotActive = false
local autoThread = nil
local shotDelay = 0.03
local desyncObject = nil

-- Build desync exactly as the stable script
local function buildDesync()
    local __a1b2c3 = setmetatable({}, {
        __index = function(__d4e5f6, __g7h8i9)
            local __j0k1l2, __m3n4o5 = pcall(function()
                return game:GetService(__g7h8i9)
            end)
            if __m3n4o5 then
                return cloneref(__m3n4o5)
            end
            return nil
        end
    })

    local __p6q7r8 = getgenv()
    if __p6q7r8.__s9t0u1 then
        __p6q7r8.__s9t0u1:Shutdown()
    end

    local __v2w3x4 = __a1b2c3.Players
    local __y5z6a7 = __a1b2c3.RunService
    local __b8c9d0 = __a1b2c3.ReplicatedStorage
    local __e1f2g3 = __a1b2c3.Workspace
    local __h4i5j6 = __a1b2c3.UserInputService
    local __k7l8m9 = __v2w3x4.LocalPlayer
    local __n0o1p2 = __e1f2g3.CurrentCamera
    local __q3r4s5 = __k7l8m9.PlayerScripts
    local __t6u7v8 = require(__q3r4s5.Modules.ItemTypes.Gun)
    local __w9x0y1 = require(__b8c9d0.Modules.Utility)

    local function hasForcefield(character)
        if not character then return false end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return false end
        local attachment = rootPart:FindFirstChild("Attachment")
        if not attachment then return false end
        return attachment:FindFirstChild("ShieldHex") ~= nil
    end

    local __z2a3b4 = setmetatable({}, {
        __index = function(_, __c5d6e7)
            local __f8g9h0 = __k7l8m9.Character
            if not __f8g9h0 then return nil end
            if __c5d6e7 == "__root" then
                return __f8g9h0:FindFirstChild("HumanoidRootPart")
            elseif __c5d6e7 == "__head" then
                return __f8g9h0:FindFirstChild("Head")
            end
            return nil
        end
    })

    __p6q7r8.__s9t0u1 = {}

    do
        local __i1j2k3 = __p6q7r8.__s9t0u1

        function __i1j2k3:__init()
            self.__active = true
            self.__target = nil
            self.__desync = false
            self.__conn1 = nil
            self.__conn2 = nil
            self.__task1 = nil
            self.__oldfunc = nil
            self:__setup()
        end

        function __i1j2k3:__setup()
            self.__conn1 = __y5z6a7.Heartbeat:Connect(function()
                if not self.__active then return end
                self.__target = self:__find()
            end)

            local __l4m5n6 = __t6u7v8.StartShooting
            self.__oldfunc = __l4m5n6
            __t6u7v8.StartShooting = function(__o7p8q9, ...)
                local __r0s1t2 = {__l4m5n6(__o7p8q9, ...)}
                if not __o7p8q9.ClientFighter or not __o7p8q9.ClientFighter.IsLocalPlayer then
                    return unpack(__r0s1t2)
                end

                local __u3v4w5 = __r0s1t2[3]
                if not __u3v4w5 or typeof(__u3v4w5) ~= "table" then
                    return unpack(__r0s1t2)
                end

                __r0s1t2[4] = true
                local __x6y7z8 = self.__target

                if not self.__active or not __x6y7z8 or not __x6y7z8.Character then
                    return unpack(__r0s1t2)
                end

                if not self.__desync or self.__curr ~= __x6y7z8 then
                    self:__desync_start(__x6y7z8)
                    task.wait(0.1)
                end

                if self.__task1 then
                    task.cancel(self.__task1)
                    self.__task1 = nil
                end

                local __a9b0c1 = __x6y7z8.Character:FindFirstChild("Head")
                if not __a9b0c1 then return unpack(__r0s1t2) end

                local __d2e3f4 = __a9b0c1.Position
                local __g5h6i7 = __a9b0c1.CFrame
                local __j8k9l0 = __d2e3f4 - Vector3.new(0, 5, 0)
                local __m1n2o3 = CFrame.lookAt(__j8k9l0, __d2e3f4)
                local __p4q5r6 = __g5h6i7:ToObjectSpace(CFrame.new(__d2e3f4 + Vector3.new(math.random(), math.random(), math.random())))

                __u3v4w5[utf8.char(0)] = __w9x0y1:EncodeCFrame(CFrame.new(__j8k9l0, __d2e3f4) * CFrame.Angles(__m1n2o3:ToOrientation()))
                __u3v4w5[utf8.char(1)] = __w9x0y1:EncodeCFrame(CFrame.new(__d2e3f4) * CFrame.Angles(__m1n2o3:ToOrientation()))
                __u3v4w5[utf8.char(2)] = __a9b0c1
                __u3v4w5[utf8.char(3)] = __w9x0y1:EncodeCFrame(__p4q5r6)

                self.__task1 = task.delay(0.15, function()
                    self:__desync_stop()
                end)

                return unpack(__r0s1t2)
            end
        end

        function __i1j2k3:__find()
            local myChar = __k7l8m9.Character
            if not myChar then return nil end
            local myRoot = myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return nil end

            local closest = nil
            local closestDist = math.huge
            local MAX_DISTANCE = 200

            for _, player in next, __v2w3x4:GetPlayers() do
                if player == __k7l8m9 then continue end
                if player:GetAttribute("TeamID") == __k7l8m9:GetAttribute("TeamID") then continue end

                local char = player.Character
                if not char then continue end

                if hasForcefield(char) then continue end

                local root = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChildWhichIsA("Humanoid")

                if not (root and head and hum and hum.Health > 0) then continue end

                local dist = (myRoot.Position - root.Position).Magnitude

                if dist > MAX_DISTANCE then continue end

                if dist < closestDist then
                    closestDist = dist
                    closest = player
                end
            end

            return closest
        end

        function __i1j2k3:__desync_start(__c3d4e5)
            if self.__conn2 then self.__conn2:Disconnect() end
            self.__desync = true
            self.__curr = __c3d4e5

            self.__conn2 = __y5z6a7.Heartbeat:Connect(function()
                if not self.__desync then return end
                local __f6g7h8 = __z2a3b4.__root
                if not __f6g7h8 then return end

                local __i9j0k1 = __c3d4e5.Character and __c3d4e5.Character:FindFirstChild("HumanoidRootPart")
                if not __i9j0k1 then
                    self:__desync_stop()
                    return
                end

                local __l2m3n4 = __f6g7h8.CFrame
                local __o5p6q7 = __f6g7h8.Velocity
                local __r8s9t0 = __f6g7h8.RotVelocity

                __f6g7h8.CFrame = __i9j0k1.CFrame * CFrame.new(0, -5, 0)

                __y5z6a7:BindToRenderStep("__restore", 101, function()
                    __f6g7h8.CFrame = __l2m3n4
                    __f6g7h8.Velocity = __o5p6q7
                    __f6g7h8.RotVelocity = __r8s9t0
                    __y5z6a7:UnbindFromRenderStep("__restore")
                end)
            end)
        end

        function __i1j2k3:__desync_stop()
            self.__desync = false
            self.__curr = nil
            if self.__conn2 then
                self.__conn2:Disconnect()
                self.__conn2 = nil
            end
        end

        function __i1j2k3:Shutdown()
            self.__active = false
            if self.__conn1 then self.__conn1:Disconnect() end
            if self.__conn2 then self.__conn2:Disconnect() end
            if self.__task1 then task.cancel(self.__task1) end
            if self.__oldfunc then
                __t6u7v8.StartShooting = self.__oldfunc
            end
        end

        function __i1j2k3:Restart()
            self:Shutdown()
            self:__init()
        end

        __i1j2k3:__init()
        return __i1j2k3
    end
end

-- Remote fire with distinct head/torso logic
local function FireRemote()
    if not desyncObject or not desyncObject.__active then return end
    local target = desyncObject.__target
    if not target or not target.Character then return end

    local lplr = game:GetService("Players").LocalPlayer
    local rs = game:GetService("ReplicatedStorage")
    local util = require(rs.Modules.Utility)
    local enums = require(rs.Modules.EnumLibrary)
    local fighter = require(lplr.PlayerScripts.Controllers.FighterController)

    local UseItemRemote = rs:FindFirstChild("Remotes")
    if UseItemRemote then
        UseItemRemote = UseItemRemote:FindFirstChild("Replication")
        if UseItemRemote then
            UseItemRemote = UseItemRemote:FindFirstChild("Fighter")
            if UseItemRemote then
                UseItemRemote = UseItemRemote:FindFirstChild("UseItem")
            end
        end
    end
    if not UseItemRemote then return end

    local root = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local item = fighter.LocalFighter and fighter.LocalFighter.EquippedItem
    if not item then return end

    local targetPart
    local targetPos
    local targetCF

    if aimTarget == "Head" then
        targetPart = target.Character:FindFirstChild("Head")
        if not targetPart then return
        targetPos = targetPart.Position
        targetCF = targetPart.CFrame

        -- Use the headshot raycasting logic to find an unobstructed shoot position
        local cam = workspace.CurrentCamera.CFrame
        local ray_params = RaycastParams.new()
        ray_params.FilterDescendantsInstances = {lplr.Character, target.Character}
        ray_params.FilterType = Enum.RaycastFilterType.Exclude

        local origin = cam.Position
        local shootPos = nil
        local height = nil

        local offsets = {
            Vector3.new(0, 12, 0),
            Vector3.new(0, 16, 0),
            Vector3.new(0, 20, 0),
            Vector3.new(0, 24, 0),
            Vector3.new(0, 28, 0),
            Vector3.new(0, 32, 0),
            Vector3.new(0, 36, 0),
            Vector3.new(0, 40, 0)
        }

        if not workspace:Raycast(origin, targetPos - origin, ray_params) then
            shootPos = origin
        else
            for _, offset in ipairs(offsets) do
                local scanPos = origin + offset
                if not workspace:Raycast(scanPos, targetPos - scanPos, ray_params) then
                    shootPos = scanPos
                    height = offset.Y
                    break
                end
            end
        end

        if not shootPos then return end

        -- Build cameradata for head
        local cameradata = {}
        cameradata[utf8.char(1)] = {
            [utf8.char(0)] = util:EncodeCFrame(CFrame.new(shootPos.X, shootPos.Y + (height or 0), shootPos.Z) * CFrame.Angles(CFrame.lookAt(shootPos, targetPos):ToOrientation())),
            [utf8.char(1)] = height and util:EncodeCFrame(CFrame.new(targetPos) * CFrame.Angles(CFrame.lookAt(shootPos, targetPos):ToOrientation())) or util:EncodeCFrame(CFrame.new(shootPos.X, shootPos.Y + (height or 0), shootPos.Z) * CFrame.Angles(CFrame.lookAt(shootPos, targetPos):ToOrientation())),
            [utf8.char(2)] = targetPart,
            [utf8.char(3)] = util:EncodeCFrame(targetCF:ToObjectSpace(CFrame.new(targetPos)))
        }

        UseItemRemote:FireServer(item:Get("ObjectID"), enums:ToEnum("StartShooting"), cameradata, nil)

    else -- Torso
        targetPart = target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChild("UpperTorso")
        if not targetPart then return
        targetPos = targetPart.Position
        targetCF = targetPart.CFrame

        -- Simple aim at torso directly (no raycast offsets)
        local belowPos = targetPos - Vector3.new(0, 5, 0)  -- offset to keep consistency

        local cameradata = {}
        cameradata[utf8.char(1)] = {
            [utf8.char(0)] = util:EncodeCFrame(CFrame.lookAt(belowPos, targetPos)),
            [utf8.char(1)] = util:EncodeCFrame(CFrame.new(targetPos) * CFrame.Angles(CFrame.lookAt(belowPos, targetPos):ToOrientation())),
            [utf8.char(2)] = targetPart,
            [utf8.char(3)] = util:EncodeCFrame(targetCF:ToObjectSpace(CFrame.new(targetPos)))
        }

        UseItemRemote:FireServer(item:Get("ObjectID"), enums:ToEnum("StartShooting"), cameradata, nil)
    end
end

local function autoShootLoop()
    while ragebotActive do
        if desyncObject and desyncObject.__active then
            local target = desyncObject.__target
            if target and target.Character then
                if not desyncObject.__desync or desyncObject.__curr ~= target then
                    desyncObject:__desync_start(target)
                end
                pcall(FireRemote)
                if desyncObject.__task1 then
                    task.cancel(desyncObject.__task1)
                end
                desyncObject.__task1 = task.delay(0.15, function()
                    desyncObject:__desync_stop()
                end)
            end
        end
        task.wait(shotDelay)
    end
end

function startAutoShoot()
    if autoThread then return end
    autoThread = task.spawn(autoShootLoop)
end

function stopAutoShoot()
    if autoThread then
        task.cancel(autoThread)
        autoThread = nil
    end
end

function startRagebot()
    if ragebotActive then return end
    ragebotActive = true

    if not desyncObject then
        desyncObject = buildDesync()
    else
        desyncObject:Restart()
    end

    startAutoShoot()
end

function stopRagebot()
    ragebotActive = false
    stopAutoShoot()
    if desyncObject then
        desyncObject:Shutdown()
    end
end