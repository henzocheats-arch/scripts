-- WEEPING CHEATS | Aimbot + ESP + Silent Aim
-- Universal Roblox Script

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-------------------------------------------------
-- SETTINGS
-------------------------------------------------
local Settings = {
    -- Aimbot
    AimbotEnabled = false,
    AimbotKey = Enum.UserInputType.MouseButton2,
    AimPart = "Head",
    FOV = 200,
    Smoothness = 0.15,
    WallCheck = true,
    TeamCheck = false,
    UseMouseMove = false,

    -- Silent Aim
    SilentAimEnabled = false,
    SilentAimHead = true,
    SilentAimFOV = 150,
    SilentAimVisCheck = false,

    -- ESP
    ESPEnabled = false,
    ShowBox = true,
    ShowName = true,
    ShowDistance = true,
    ShowHealth = true,
    ShowTracer = false,
    MaxDistance = 1000,
}

-- Clean old GUI
if CoreGui:FindFirstChild("WeepingCheats") then
    CoreGui.WeepingCheats:Destroy()
end

-------------------------------------------------
-- UI
-------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WeepingCheats"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 480, 0, 620)
Main.Position = UDim2.new(0, 60, 0, 60)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(140, 0, 0)
Stroke.Thickness = 2
Stroke.Parent = Main

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 10, 12)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0, 20)
TitleBarFix.Position = UDim2.new(0, 0, 1, -20)
TitleBarFix.BackgroundColor3 = Color3.fromRGB(28, 10, 12)
TitleBarFix.BorderSizePixel = 0
TitleBarFix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "WEEPING CHEATS"
Title.TextColor3 = Color3.fromRGB(220, 40, 40)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 15, 15)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -60)
Scroll.Position = UDim2.new(0, 10, 0, 55)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(140, 0, 0)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 900)
Scroll.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

local function makeSection(name, order)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(1, -10, 0, 30)
    section.BackgroundColor3 = Color3.fromRGB(35, 12, 14)
    section.BorderSizePixel = 0
    section.Text = "  " .. name
    section.TextColor3 = Color3.fromRGB(220, 60, 60)
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.TextSize = 16
    section.Font = Enum.Font.GothamBold
    section.LayoutOrder = order
    section.Parent = Scroll
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = section
    return section
end

local function makeToggle(text, default, order, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.Parent = Scroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 22)
    btn.Position = UDim2.new(1, -50, 0.5, -11)
    btn.BackgroundColor3 = default and Color3.fromRGB(140, 0, 0) or Color3.fromRGB(60, 60, 65)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = frame

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 11)
    bc.Parent = btn

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(140, 0, 0) or Color3.fromRGB(60, 60, 65)
        callback(state)
    end)
end

local function makeSlider(text, min, max, default, order, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.Parent = Scroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 6)
    bar.Position = UDim2.new(0, 10, 0, 32)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    bar.BorderSizePixel = 0
    bar.Parent = frame

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(1, 0)
    bc.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = fill

    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mx = UserInputService:GetMouseLocation().X
            local rel = math.clamp((mx - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * rel + 0.5)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            label.Text = text .. ": " .. tostring(val)
            callback(val)
        end
    end)
end

-------------------------------------------------
-- BUILD MENU
-------------------------------------------------
makeSection("AIMBOT", 1)
makeToggle("Enable Aimbot", false, 2, function(s) Settings.AimbotEnabled = s end)
makeToggle("Wall Check", true, 3, function(s) Settings.WallCheck = s end)
makeToggle("Team Check", false, 4, function(s) Settings.TeamCheck = s end)
makeToggle("Use MouseMove (locked-cam)", false, 5, function(s) Settings.UseMouseMove = s end)
makeSlider("FOV", 50, 500, 200, 6, function(v) Settings.FOV = v end)
makeSlider("Smoothness (x100)", 1, 100, 15, 7, function(v) Settings.Smoothness = v / 100 end)

makeSection("SILENT AIM", 8)
makeToggle("Enable Silent Aim", false, 9, function(s) Settings.SilentAimEnabled = s end)
makeToggle("Silent Aim: Headshot", true, 10, function(s) Settings.SilentAimHead = s end)
makeToggle("Silent Aim: Vis Check", false, 11, function(s) Settings.SilentAimVisCheck = s end)
makeSlider("Silent Aim FOV", 20, 500, 150, 12, function(v) Settings.SilentAimFOV = v end)

makeSection("ESP", 13)
makeToggle("Enable ESP", false, 14, function(s) Settings.ESPEnabled = s end)
makeToggle("Show Box", true, 15, function(s) Settings.ShowBox = s end)
makeToggle("Show Name", true, 16, function(s) Settings.ShowName = s end)
makeToggle("Show Distance", true, 17, function(s) Settings.ShowDistance = s end)
makeToggle("Show Health", true, 18, function(s) Settings.ShowHealth = s end)
makeToggle("Show Tracer", false, 19, function(s) Settings.ShowTracer = s end)
makeSlider("Max Distance", 100, 5000, 1000, 20, function(v) Settings.MaxDistance = v end)

-------------------------------------------------
-- FOV CIRCLE
-------------------------------------------------
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = Settings.FOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(220, 40, 40)
FOVCircle.Transparency = 1

-------------------------------------------------
-- HELPERS
-------------------------------------------------
local function getChar(plr)
    local char = plr.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    local aim = char:FindFirstChild(Settings.AimPart) or char:FindFirstChild("Head") or hrp
    if not hrp or not hum or hum.Health <= 0 then return nil end
    return char, hrp, hum, aim
end

local function isVisible(targetPart)
    local origin = Camera.CFrame.Position
    local dir = (targetPart.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local filter = {Camera}
    if LocalPlayer.Character then table.insert(filter, LocalPlayer.Character) end
    params.FilterDescendantsInstances = filter
    local result = Workspace:Raycast(origin, dir, params)
    if not result then return true end
    return result.Instance:IsDescendantOf(targetPart.Parent)
end

local function getClosest(fovRadius, useVisCheck, forceHead)
    local closest, closestDist = nil, fovRadius or Settings.FOV
    local mousePos = UserInputService:GetMouseLocation()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
            local char, hrp, hum, aim = getChar(plr)
            local target = forceHead and (char and char:FindFirstChild("Head")) or aim
            if char and target then
                local screenPos, onScreen = Camera:WorldToViewportPoint(target.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < closestDist then
                        if useVisCheck and not isVisible(target) then continue end
                        closest = target
                        closestDist = dist
                    end
                end
            end
        end
    end
    return closest
end

-------------------------------------------------
-- AIMBOT LOOP
-------------------------------------------------
local aiming = false
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Settings.AimbotKey then aiming = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Settings.AimbotKey then aiming = false end
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Visible = Settings.AimbotEnabled

    if Settings.AimbotEnabled and aiming then
        local target = getClosest(Settings.FOV, Settings.WallCheck, false)
        if target then
            if Settings.UseMouseMove and mousemoverel then
                local screenPos = Camera:WorldToViewportPoint(target.Position)
                local mousePos = UserInputService:GetMouseLocation()
                local dx = (screenPos.X - mousePos.X) * Settings.Smoothness
                local dy = (screenPos.Y - mousePos.Y) * Settings.Smoothness
                mousemoverel(dx, dy)
            else
                local targetCF = CFrame.new(Camera.CFrame.Position, target.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, Settings.Smoothness)
            end
        end
    end
end)

-------------------------------------------------
-- SILENT AIM (FireServer hook — safe version)
-------------------------------------------------
local function getSilentTarget()
    if not Settings.SilentAimEnabled then return nil end
    local best, bestDist = nil, Settings.SilentFOV or 200
    local mousePos = UserInputService:GetMouseLocation()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
        local char = plr.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local head = char:FindFirstChild("Head")
        if not hum or hum.Health <= 0 or not head then continue end
        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen then continue end
        local d = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if d < bestDist then
            best = head
            bestDist = d
        end
    end
    return best
end

local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if Settings.SilentAimEnabled and not checkcaller() then
        if method == "FireServer" or method == "InvokeServer" then
            local target = getSilentTarget()
            if target then
                -- replace any CFrame/Vector3 arg with target head position
                for i, v in ipairs(args) do
                    if typeof(v) == "CFrame" then
                        args[i] = CFrame.new(target.Position)
                    elseif typeof(v) == "Vector3" then
                        args[i] = target.Position
                    end
                end
                return oldNamecall(self, unpack(args))
            end
        end
    end

    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-------------------------------------------------
-- ESP SETUP
-------------------------------------------------
local ESPObjects = {}

local function removeESP(plr)
    if ESPObjects[plr] then
        for _, obj in pairs(ESPObjects[plr]) do
            if obj.Remove then obj:Remove() end
        end
        ESPObjects[plr] = nil
    end
end

local function createESP(plr)
    if ESPObjects[plr] then return end
    ESPObjects[plr] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
    }
    local e = ESPObjects[plr]
    e.Box.Thickness = 1
    e.Box.Filled = false
    e.Box.Color = Color3.fromRGB(220, 40, 40)
    e.Box.Visible = false

    e.Name.Size = 14
    e.Name.Center = true
    e.Name.Outline = true
    e.Name.Color = Color3.fromRGB(255, 255, 255)
    e.Name.Visible = false

    e.Distance.Size = 12
    e.Distance.Center = true
    e.Distance.Outline = true
    e.Distance.Color = Color3.fromRGB(200, 200, 200)
    e.Distance.Visible = false

    e.Health.Size = 12
    e.Health.Center = true
    e.Health.Outline = true
    e.Health.Color = Color3.fromRGB(0, 255, 0)
    e.Health.Visible = false

    e.Tracer.Thickness = 1
    e.Tracer.Color = Color3.fromRGB(220, 40, 40)
    e.Tracer.Visible = false
end

local function hookPlayer(plr)
    createESP(plr)
    plr.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart", 10)
        char:WaitForChild("Humanoid", 10)
        createESP(plr)
    end)
end

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then hookPlayer(plr) end
end
Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then hookPlayer(plr) end
end)
Players.PlayerRemoving:Connect(removeESP)

-------------------------------------------------
-- ESP RENDER LOOP
-------------------------------------------------
RunService.RenderStepped:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local e = ESPObjects[plr]
        if not e then continue end

        local function hide()
            e.Box.Visible = false
            e.Name.Visible = false
            e.Distance.Visible = false
            e.Health.Visible = false
            e.Tracer.Visible = false
        end

        if not Settings.ESPEnabled then hide(); continue end
        if Settings.TeamCheck and plr.Team == LocalPlayer.Team then hide(); continue end

        local char, hrp, hum, aim = getChar(plr)
        if not char or not hrp then hide(); continue end

        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        if dist > Settings.MaxDistance then hide(); continue end

        local head = char:FindFirstChild("Head") or aim
        local topPos, topOn = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local botPos, botOn = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

        if not (topOn and botOn) then hide(); continue end

        local height = math.abs(topPos.Y - botPos.Y)
        local width  = height / 1.7
        local x = topPos.X - width / 2
        local y = topPos.Y

        if Settings.ShowBox then
            e.Box.Size = Vector2.new(width, height)
            e.Box.Position = Vector2.new(x, y)
            e.Box.Visible = true
        else e.Box.Visible = false end

        if Settings.ShowName then
            e.Name.Text = plr.DisplayName
            e.Name.Position = Vector2.new(topPos.X, y - 16)
            e.Name.Visible = true
        else e.Name.Visible = false end

        if Settings.ShowDistance then
            e.Distance.Text = string.format("[%dm]", math.floor(dist))
            e.Distance.Position = Vector2.new(topPos.X, y + height + 2)
            e.Distance.Visible = true
        else e.Distance.Visible = false end

        if Settings.ShowHealth and hum then
            local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            e.Health.Text = string.format("HP %d", math.floor(hum.Health))
            e.Health.Position = Vector2.new(topPos.X, y - 30)
            e.Health.Color = Color3.fromRGB(255 * (1 - pct), 255 * pct, 60)
            e.Health.Visible = true
        else e.Health.Visible = false end

        if Settings.ShowTracer then
            e.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            e.Tracer.To = Vector2.new(topPos.X, y + height)
            e.Tracer.Visible = true
        else e.Tracer.Visible = false end
    end
end)

-------------------------------------------------
-- MENU TOGGLE (INSERT KEY)
-------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        Main.Visible = not Main.Visible
    end
end)

-------------------------------------------------
-- STARTUP
-------------------------------------------------
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "WEEPING CHEATS",
        Text  = "Loaded. Press INSERT to toggle menu.",
        Duration = 5,
    })
end)

print("[WEEPING CHEATS] Loaded. RMB = aim, INSERT = menu.")
