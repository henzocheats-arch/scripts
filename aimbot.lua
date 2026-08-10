-- ============================================
-- UNIVERSAL AIMBOT + ESP w/ MENU
-- Executor: Synapse/Krnl/Fluxus (Drawing API required)
-- ============================================

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local Workspace   = game:GetService("Workspace")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse  = LP:GetMouse()

-- ============ CONFIG ============
local Config = {
    -- Aimbot
    AimbotEnabled   = true,
    AimKey          = Enum.UserInputType.MouseButton2, -- hold RMB
    AimPart         = "Head",              -- Head / HumanoidRootPart / UpperTorso
    FOV             = 120,                 -- pixel radius
    Smoothness      = 0.25,                -- 0 = snap, 1 = molasses
    TeamCheck       = false,
    WallCheck       = true,
    AliveCheck      = true,
    ShowFOV         = true,

    -- ESP
    ESPEnabled      = true,
    BoxESP          = true,
    NameESP         = true,
    HealthESP       = true,
    DistanceESP     = true,
    TracerESP       = false,
    TracerOrigin    = "Bottom",            -- Bottom / Mouse / Center

    -- Colors
    BoxColor        = Color3.fromRGB(255, 80, 80),
    TextColor       = Color3.fromRGB(255, 255, 255),
    HealthColor     = Color3.fromRGB(80, 255, 100),
    FOVColor        = Color3.fromRGB(255, 255, 255),
}

-- ============ DRAWING: FOV CIRCLE ============
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness   = 1
FOVCircle.NumSides    = 64
FOVCircle.Radius      = Config.FOV
FOVCircle.Filled      = false
FOVCircle.Visible     = Config.ShowFOV
FOVCircle.Color       = Config.FOVColor
FOVCircle.Transparency= 1

-- ============ ESP CACHE ============
local ESPObjects = {}

local function createESP(player)
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled    = false
    box.Color     = Config.BoxColor
    box.Visible   = false

    local name = Drawing.new("Text")
    name.Size    = 14
    name.Center  = true
    name.Outline = true
    name.Color   = Config.TextColor
    name.Visible = false

    local dist = Drawing.new("Text")
    dist.Size    = 13
    dist.Center  = true
    dist.Outline = true
    dist.Color   = Config.TextColor
    dist.Visible = false

    local hpBar = Drawing.new("Square")
    hpBar.Thickness = 1
    hpBar.Filled    = true
    hpBar.Color     = Config.HealthColor
    hpBar.Visible   = false

    local hpBg = Drawing.new("Square")
    hpBg.Thickness = 1
    hpBg.Filled    = true
    hpBg.Color     = Color3.fromRGB(0,0,0)
    hpBg.Visible   = false

    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Color     = Config.BoxColor
    tracer.Visible   = false

    ESPObjects[player] = {
        Box=box, Name=name, Dist=dist,
        HP=hpBar, HPBg=hpBg, Tracer=tracer
    }
end

local function removeESP(player)
    local e = ESPObjects[player]
    if not e then return end
    for _, obj in pairs(e) do obj:Remove() end
    ESPObjects[player] = nil
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LP then createESP(p) end
end
Players.PlayerAdded:Connect(function(p) if p ~= LP then createESP(p) end end)
Players.PlayerRemoving:Connect(removeESP)

-- ============ HELPERS ============
local function getChar(p)
    local c = p.Character
    if not c then return nil end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    local head= c:FindFirstChild("Head")
    if not (hrp and hum and head) then return nil end
    if Config.AliveCheck and hum.Health <= 0 then return nil end
    return c, hrp, hum, head
end

local function isVisible(part)
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

-- ============ AIMBOT ============
local aiming = false
UIS.InputBegan:Connect(function(i,g) if not g and i.UserInputType==Config.AimKey then aiming=true end end)
UIS.InputEnded:Connect(function(i)   if i.UserInputType==Config.AimKey then aiming=false end end)

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

RunService.RenderStepped:Connect(function()
    -- FOV circle follows mouse
    local mp = UIS:GetMouseLocation()
    FOVCircle.Position = mp
    FOVCircle.Radius   = Config.FOV
    FOVCircle.Visible  = Config.ShowFOV and Config.AimbotEnabled

    if Config.AimbotEnabled and aiming then
        local target = getTarget()
        if target then
            local screen = worldToScreen(target.Position)
            local cam = Camera.CFrame
            local goal = CFrame.new(cam.Position, target.Position)
            Camera.CFrame = cam:Lerp(goal, 1 - Config.Smoothness)
        end
    end
end)

-- ============ ESP LOOP ============
RunService.RenderStepped:Connect(function()
    for player, e in pairs(ESPObjects) do
        local vis = false
        if Config.ESPEnabled then
            local char, hrp, hum, head = getChar(player)
            if char then
                local topPos,    onTop    = worldToScreen((head.Position + Vector3.new(0,0.5,0)))
                local botPos,    onBot    = worldToScreen((hrp.Position  - Vector3.new(0,3,0)))
                if onTop and onBot then
                    local height = math.abs(topPos.Y - botPos.Y)
                    local width  = height * 0.55
                    local x = topPos.X - width/2
                    local y = topPos.Y

                    if Config.BoxESP then
                        e.Box.Size     = Vector2.new(width, height)
                        e.Box.Position = Vector2.new(x, y)
                        e.Box.Color    = Config.BoxColor
                        e.Box.Visible  = true
                    end

                    if Config.NameESP then
                        e.Name.Text     = player.Name
                        e.Name.Position = Vector2.new(topPos.X, y - 16)
                        e.Name.Visible  = true
                    end

                    if Config.DistanceESP then
                        local d = (Camera.CFrame.Position - hrp.Position).Magnitude
                        e.Dist.Text     = string.format("[%dm]", math.floor(d))
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
                        e.Tracer.Color   = Config.BoxColor
                        e.Tracer.Visible = true
                    end

                    vis = true
                end
            end
        end
        if not vis then
            for _, obj in pairs(e) do obj.Visible = false end
        end
    end
end)

-- ============ MENU (draggable) ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 340)
Main.Position = UDim2.new(0, 40, 0, 120)
Main.BackgroundColor3 = Color3.fromRGB(20,20,25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
local corner = Instance.new("UICorner", Main); corner.CornerRadius = UDim.new(0,6)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,28)
Title.BackgroundColor3 = Color3.fromRGB(30,30,38)
Title.BorderSizePixel = 0
Title.Text = "⚡ Aim + ESP  [Insert to toggle]"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(240,240,240)
Title.TextSize = 13
local tc = Instance.new("UICorner", Title); tc.CornerRadius = UDim.new(0,6)

local List = Instance.new("Frame", Main)
List.Position = UDim2.new(0,8,0,36)
List.Size = UDim2.new(1,-16,1,-44)
List.BackgroundTransparency = 1
local layout = Instance.new("UIListLayout", List)
layout.Padding = UDim.new(0,4)

local function makeToggle(name, key)
    local btn = Instance.new("TextButton", List)
    btn.Size = UDim2.new(1,0,0,26)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,45)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(230,230,230)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    local pad = Instance.new("UIPadding", btn); pad.PaddingLeft = UDim.new(0,10)
    local bc = Instance.new("UICorner", btn); bc.CornerRadius = UDim.new(0,4)
    local function refresh()
        btn.Text = (Config[key] and "☑  " or "☐  ") .. name
        btn.BackgroundColor3 = Config[key] and Color3.fromRGB(50,80,60) or Color3.fromRGB(35,35,45)
    end
    refresh()
    btn.MouseButton1Click:Connect(function() Config[key] = not Config[key]; refresh() end)
end

local function makeSlider(name, key, min, max)
    local holder = Instance.new("Frame", List)
    holder.Size = UDim2.new(1,0,0,36)
    holder.BackgroundColor3 = Color3.fromRGB(35,35,45)
    holder.BorderSizePixel = 0
    local hc = Instance.new("UICorner", holder); hc.CornerRadius = UDim.new(0,4)
    local lbl = Instance.new("TextLabel", holder)
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0,10,0,2)
    lbl.Size = UDim2.new(1,-20,0,14)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextColor3 = Color3.fromRGB(230,230,230)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = name..": "..tostring(Config[key])

    local bar = Instance.new("Frame", holder)
    bar.Position = UDim2.new(0,10,0,20)
    bar.Size = UDim2.new(1,-20,0,8)
    bar.BackgroundColor3 = Color3.fromRGB(20,20,25)
    local bcc = Instance.new("UICorner", bar); bcc.CornerRadius = UDim.new(0,4)
    local fill = Instance.new("Frame", bar)
    fill.BackgroundColor3 = Color3.fromRGB(120,180,255)
    fill.Size = UDim2.new((Config[key]-min)/(max-min),0,1,0)
    local fc = Instance.new("UICorner", fill); fc.CornerRadius = UDim.new(0,4)

    local dragging = false
    bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
    bar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max-min)*rel + 0.5)
            Config[key] = val
            fill.Size = UDim2.new(rel,0,1,0)
            lbl.Text = name..": "..tostring(val)
        end
    end)
end

makeToggle("Aimbot",       "AimbotEnabled")
makeToggle("Wall Check",   "WallCheck")
makeToggle("Team Check",   "TeamCheck")
makeToggle("Show FOV",     "ShowFOV")
makeSlider("FOV Radius",   "FOV", 30, 400)
makeToggle("ESP Boxes",    "BoxESP")
makeToggle("ESP Names",    "NameESP")
makeToggle("ESP Health",   "HealthESP")
makeToggle("ESP Distance", "DistanceESP")
makeToggle("ESP Tracers",  "TracerESP")

-- Toggle menu with Insert
UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.Insert then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

print("[Aim+ESP] Loaded. RMB to aim, Insert to toggle menu.")
