-- ================================================
--   WEEPING CHEATS  ::  Universal Aimbot + ESP
--   Executors: Synapse X / Krnl / Fluxus / AWP
--   Toggle Menu: INSERT   |   Aim: Right Mouse Btn
-- ================================================

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local Workspace   = game:GetService("Workspace")
local TweenService= game:GetService("TweenService")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse  = LP:GetMouse()

-- ================== CONFIG ==================
local Config = {
    -- Aimbot
    AimbotEnabled   = true,
    AimKey          = Enum.UserInputType.MouseButton2,
    AimPart         = "Head",
    FOV             = 120,
    Smoothness      = 3,          -- 1 = snap, 10 = slow drag
    TeamCheck       = false,
    WallCheck       = true,
    AliveCheck      = true,
    VisibleCheck    = true,
    ShowFOV         = true,
    UseMouseMove    = false,       -- true = mousemoverel (feels natural), false = camera lerp

    -- ESP
    ESPEnabled      = true,
    BoxESP          = true,
    NameESP         = true,
    HealthESP       = true,
    DistanceESP     = true,
    TracerESP       = false,
    TracerOrigin    = "Bottom",
    MaxDistance     = 2000,

    -- Colors
    BoxColor        = Color3.fromRGB(255, 60, 90),
    VisibleColor    = Color3.fromRGB(80, 255, 120),
    TextColor       = Color3.fromRGB(255, 255, 255),
    FOVColor        = Color3.fromRGB(255, 255, 255),
    AccentColor     = Color3.fromRGB(180, 60, 220),
}

-- ================== FOV CIRCLE ==================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness    = 1
FOVCircle.NumSides     = 72
FOVCircle.Radius       = Config.FOV
FOVCircle.Filled       = false
FOVCircle.Visible      = Config.ShowFOV
FOVCircle.Color        = Config.FOVColor
FOVCircle.Transparency = 1

-- ================== ESP STORAGE ==================
local ESPObjects = {}

local function makeDrawing(class, props)
    local d = Drawing.new(class)
    for k, v in pairs(props) do d[k] = v end
    return d
end

local function createESP(player)
    if ESPObjects[player] then return end
    ESPObjects[player] = {
        Box    = makeDrawing("Square", {Thickness=1, Filled=false, Color=Config.BoxColor, Visible=false}),
        BoxOut = makeDrawing("Square", {Thickness=3, Filled=false, Color=Color3.new(0,0,0), Visible=false, Transparency=0.5}),
        Name   = makeDrawing("Text",   {Size=14, Center=true, Outline=true, Color=Config.TextColor, Visible=false, Font=2}),
        Dist   = makeDrawing("Text",   {Size=13, Center=true, Outline=true, Color=Config.TextColor, Visible=false, Font=2}),
        HP     = makeDrawing("Square", {Thickness=1, Filled=true,  Color=Color3.fromRGB(80,255,100), Visible=false}),
        HPBg   = makeDrawing("Square", {Thickness=1, Filled=true,  Color=Color3.fromRGB(0,0,0),     Visible=false}),
        Tracer = makeDrawing("Line",   {Thickness=1, Color=Config.BoxColor, Visible=false}),
    }
end

local function removeESP(player)
    local e = ESPObjects[player]
    if not e then return end
    for _, obj in pairs(e) do pcall(function() obj:Remove() end) end
    ESPObjects[player] = nil
end

-- Respawn fix: bind fresh on every character
local function hookPlayer(player)
    if player == LP then return end
    createESP(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.2)
        if not ESPObjects[player] then createESP(player) end
    end)
end

for _, p in pairs(Players:GetPlayers()) do hookPlayer(p) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(removeESP)

-- ================== HELPERS ==================
local function getChar(p)
    local c = p.Character
    if not c then return nil end
    local hrp  = c:FindFirstChild("HumanoidRootPart")
    local hum  = c:FindFirstChildOfClass("Humanoid")
    local head = c:FindFirstChild("Head")
    if not (hrp and hum and head) then return nil end
    if Config.AliveCheck and hum.Health <= 0 then return nil end
    return c, hrp, hum, head
end

local function isVisible(part)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local dir    = (part.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LP.Character, Camera}
    local hit = Workspace:Raycast(origin, dir, params)
    if not hit then return true end
    return hit.Instance:IsDescendantOf(part.Parent)
end

local function worldToScreen(pos)
    local v, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(v.X, v.Y), on, v.Z
end

-- ================== AIMBOT ==================
local aiming = false
UIS.InputBegan:Connect(function(i, gp) if not gp and i.UserInputType==Config.AimKey then aiming=true end end)
UIS.InputEnded:Connect(function(i)     if i.UserInputType==Config.AimKey then aiming=false end end)

local function getTarget()
    local best, bestDist = nil, Config.FOV
    local mousePos = UIS:GetMouseLocation()
    for _, p in pairs(Players:GetPlayers()) do
        if p == LP then continue end
        if Config.TeamCheck and p.Team == LP.Team then continue end
        local char, hrp, hum, head = getChar(p)
        if not char then continue end
        local aimPart = char:FindFirstChild(Config.AimPart) or head
        if Config.WallCheck and not isVisible(aimPart) then continue end
        local screen, on = worldToScreen(aimPart.Position)
        if not on then continue end
        local d = (Vector2.new(screen.X, screen.Y) - mousePos).Magnitude
        if d < bestDist then bestDist = d; best = aimPart end
    end
    return best
end

RunService.RenderStepped:Connect(function(dt)
    local mp = UIS:GetMouseLocation()
    FOVCircle.Position = mp
    FOVCircle.Radius   = Config.FOV
    FOVCircle.Visible  = Config.ShowFOV and Config.AimbotEnabled

    if Config.AimbotEnabled and aiming then
        local target = getTarget()
        if target then
            if Config.UseMouseMove and mousemoverel then
                local screen = worldToScreen(target.Position)
                local delta = Vector2.new(screen.X, screen.Y) - mp
                mousemoverel(delta.X / Config.Smoothness, delta.Y / Config.Smoothness)
            else
                local cam  = Camera.CFrame
                local goal = CFrame.new(cam.Position, target.Position)
                Camera.CFrame = cam:Lerp(goal, 1 / math.max(Config.Smoothness, 1))
            end
        end
    end
end)

-- ================== ESP LOOP ==================
RunService.RenderStepped:Connect(function()
    for player, e in pairs(ESPObjects) do
        local shown = false
        if Config.ESPEnabled then
            local char, hrp, hum, head = getChar(player)
            if char then
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                if dist <= Config.MaxDistance then
                    local topPos, onTop = worldToScreen(head.Position + Vector3.new(0, 0.6, 0))
                    local botPos, onBot = worldToScreen(hrp.Position  - Vector3.new(0, 3.2, 0))
                    if onTop and onBot then
                        local height = math.abs(topPos.Y - botPos.Y)
                        local width  = height * 0.55
                        local x = topPos.X - width/2
                        local y = topPos.Y

                        local visible = Config.VisibleCheck and isVisible(head)
                        local col = visible and Config.VisibleColor or Config.BoxColor

                        if Config.BoxESP then
                            e.BoxOut.Size     = Vector2.new(width, height)
                            e.BoxOut.Position = Vector2.new(x, y)
                            e.BoxOut.Visible  = true
                            e.Box.Size        = Vector2.new(width, height)
                            e.Box.Position    = Vector2.new(x, y)
                            e.Box.Color       = col
                            e.Box.Visible     = true
                        end
                        if Config.NameESP then
                            e.Name.Text     = player.Name
                            e.Name.Position = Vector2.new(topPos.X, y - 16)
                            e.Name.Color    = col
                            e.Name.Visible  = true
                        end
                        if Config.DistanceESP then
                            e.Dist.Text     = string.format("[%dm]", math.floor(dist))
                            e.Dist.Position = Vector2.new(topPos.X, botPos.Y + 2)
                            e.Dist.Visible  = true
                        end
                        if Config.HealthESP and hum then
                            local pct = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
                            e.HPBg.Size     = Vector2.new(3, height)
                            e.HPBg.Position = Vector2.new(x - 6, y)
                            e.HPBg.Visible  = true
                            e.HP.Size       = Vector2.new(3, height*pct)
                            e.HP.Position   = Vector2.new(x - 6, y + height*(1-pct))
                            e.HP.Color      = Color3.fromRGB(255*(1-pct), 255*pct, 60)
                            e.HP.Visible    = true
                        end
                        if Config.TracerESP then
                            local origin
                            if Config.TracerOrigin=="Bottom" then
                                origin = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                            elseif Config.TracerOrigin=="Mouse" then
                                origin = UIS:GetMouseLocation()
                            else
                                origin = Camera.ViewportSize/2
                            end
                            e.Tracer.From    = origin
                            e.Tracer.To      = Vector2.new(topPos.X, botPos.Y)
                            e.Tracer.Color   = col
                            e.Tracer.Visible = true
                        end
                        shown = true
                    end
                end
            end
        end
        if not shown then
            for _, obj in pairs(e) do obj.Visible = false end
        end
    end
end)

-- ================== MENU (bigger, dark, sectioned) ==================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WeepingCheats"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 380, 0, 460)
Main.Position = UDim2.new(0, 60, 0, 120)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Config.AccentColor
Stroke.Thickness = 1.5
Stroke.Transparency = 0.3

-- Title bar
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", TitleBar)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "◈  WEEPING CHEATS  ◈"
Title.TextColor3 = Color3.fromRGB(220, 180, 255)
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -36, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 80)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- Scrolling content
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Position = UDim2.new(0, 10, 0, 46)
Scroll.Size = UDim2.new(1, -20, 1, -56)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Config.AccentColor
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 6)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

local function makeSection(label)
    local sec = Instance.new("TextLabel", Scroll)
    sec.Size = UDim2.new(1, 0, 0, 24)
    sec.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    sec.BorderSizePixel = 0
    sec.Font = Enum.Font.GothamBold
    sec.TextSize = 12
    sec.TextColor3 = Config.AccentColor
    sec.Text = "  ▸ " .. label
    sec.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", sec).CornerRadius = UDim.new(0, 4)
end

local function makeToggle(name, key)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    local pad = Instance.new("UIPadding", btn); pad.PaddingLeft = UDim.new(0, 12)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local function refresh()
        btn.Text = (Config[key] and "☑  " or "☐  ") .. name
        btn.BackgroundColor3 = Config[key] and Color3.fromRGB(45, 65, 55) or Color3.fromRGB(32, 32, 40)
    end
    refresh()
    btn.MouseButton1Click:Connect(function() Config[key] = not Config[key]; refresh() end)
end

local function makeSlider(name, key, min, max)
    local holder = Instance.new("Frame", Scroll)
    holder.Size = UDim2.new(1, 0, 0, 42)
    holder.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    holder.BorderSizePixel = 0
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 4)

    local lbl = Instance.new("TextLabel", holder)
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.Size = UDim2.new(1, -20, 0, 16)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = name .. ": " .. tostring(Config[key])

    local bar = Instance.new("Frame", holder)
    bar.Position = UDim2.new(0, 12, 0, 24)
    bar.Size = UDim2.new(1, -24, 0, 10)
    bar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame", bar)
    fill.BackgroundColor3 = Config.AccentColor
    fill.Size = UDim2.new((Config[key]-min)/(max-min), 0, 1, 0)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

    local dragging = false
    bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
    bar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max-min)*rel + 0.5)
            Config[key] = val
            fill.Size = UDim2.new(rel, 0, 1, 0)
            lbl.Text = name .. ": " .. tostring(val)
        end
    end)
end

-- Sections + controls
makeSection("AIMBOT")
makeToggle("Aimbot Enabled",  "AimbotEnabled")
makeToggle("Wall Check",      "WallCheck")
makeToggle("Team Check",      "TeamCheck")
makeToggle("Show FOV Circle", "ShowFOV")
makeToggle("Use MouseMove (natural)", "UseMouseMove")
makeSlider("FOV Radius",      "FOV",        30, 500)
makeSlider("Smoothness",      "Smoothness", 1,  10)

makeSection("ESP")
makeToggle("ESP Enabled",     "ESPEnabled")
makeToggle("Boxes",           "BoxESP")
makeToggle("Names",           "NameESP")
makeToggle("Health Bars",     "HealthESP")
makeToggle("Distance",        "DistanceESP")
makeToggle("Tracers",         "TracerESP")
makeToggle("Visible Check (color swap)", "VisibleCheck")
makeSlider("Max Distance",    "MaxDistance", 100, 5000)

-- ================== TOGGLE MENU ==================
UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.Insert then
        Main.Visible = not Main.Visible
    end
end)

-- ================== NOTIFY ==================
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "WEEPING CHEATS",
        Text  = "Loaded ◈ RMB to aim ◈ Insert to toggle",
        Duration = 4,
    })
end)

print("[WEEPING CHEATS] loaded successfully.")
