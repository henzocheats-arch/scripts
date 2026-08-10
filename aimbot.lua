-- ============================================
--          WEEPING CHEATS
--   Aimbot • ESP • Silent Aim • Menu
--   Executor: Synapse / Krnl / Fluxus / AWP
-- ============================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Workspace  = game:GetService("Workspace")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ================== CONFIG ==================
local Config = {
    -- Aimbot
    AimbotEnabled   = true,
    AimKey          = Enum.UserInputType.MouseButton2,
    AimPart         = "Head",
    FOV             = 120,
    Smoothness      = 0.25,
    TeamCheck       = false,
    WallCheck       = true,
    AliveCheck      = true,
    ShowFOV         = true,

    -- Silent Aim
    SilentAim         = true,
    SilentAimFOV      = 150,
    SilentAimVisCheck = false,
    SilentAimPart     = "Head",

    -- ESP
    ESPEnabled      = true,
    BoxESP          = true,
    NameESP         = true,
    HealthESP       = true,
    DistanceESP     = true,
    TracerESP       = false,
    VisibleCheck    = true,
    MaxDistance     = 2000,
    TracerOrigin    = "Bottom",

    -- Colors
    BoxColor        = Color3.fromRGB(255, 80, 80),
    VisibleColor    = Color3.fromRGB(80, 255, 120),
    TextColor       = Color3.fromRGB(255, 255, 255),
    HealthColor     = Color3.fromRGB(80, 255, 100),
    FOVColor        = Color3.fromRGB(255, 255, 255),
}

-- ================== FOV CIRCLE ==================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness   = 1
FOVCircle.NumSides    = 64
FOVCircle.Radius      = Config.FOV
FOVCircle.Filled      = false
FOVCircle.Visible     = Config.ShowFOV
FOVCircle.Color       = Config.FOVColor
FOVCircle.Transparency= 1

-- ================== ESP CACHE ==================
local ESPObjects = {}

local function createESP(player)
    local box = Drawing.new("Square");   box.Thickness=1; box.Filled=false; box.Color=Config.BoxColor; box.Visible=false
    local name= Drawing.new("Text");     name.Size=14; name.Center=true; name.Outline=true; name.Color=Config.TextColor; name.Visible=false
    local dist= Drawing.new("Text");     dist.Size=13; dist.Center=true; dist.Outline=true; dist.Color=Config.TextColor; dist.Visible=false
    local hp  = Drawing.new("Square");   hp.Thickness=1; hp.Filled=true; hp.Color=Config.HealthColor; hp.Visible=false
    local hpBg= Drawing.new("Square");   hpBg.Thickness=1; hpBg.Filled=true; hpBg.Color=Color3.new(0,0,0); hpBg.Visible=false
    local tr  = Drawing.new("Line");     tr.Thickness=1; tr.Color=Config.BoxColor; tr.Visible=false
    ESPObjects[player] = {Box=box, Name=name, Dist=dist, HP=hp, HPBg=hpBg, Tracer=tr}
end

local function removeESP(player)
    local e = ESPObjects[player]; if not e then return end
    for _, obj in pairs(e) do obj:Remove() end
    ESPObjects[player] = nil
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LP then createESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LP then createESP(p) end end)
Players.PlayerRemoving:Connect(removeESP)

-- ================== HELPERS ==================
local function getChar(p)
    local c = p.Character; if not c then return nil end
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

-- ================== AIMBOT ==================
local aiming = false
UIS.InputBegan:Connect(function(i,g) if not g and i.UserInputType==Config.AimKey then aiming=true end end)
UIS.InputEnded:Connect(function(i)   if i.UserInputType==Config.AimKey then aiming=false end end)

local function getTarget(fov, aimPartName, visCheck)
    local best, bestDist = nil, fov
    local mousePos = UIS:GetMouseLocation()
    for _, p in pairs(Players:GetPlayers()) do
        if p == LP then continue end
        if Config.TeamCheck and p.Team == LP.Team then continue end
        local char, hrp, hum, head = getChar(p)
        if not char then continue end
        local part = char:FindFirstChild(aimPartName) or head
        if visCheck and not isVisible(part) then continue end
        local screen, on = worldToScreen(part.Position)
        if not on then continue end
        local d = (Vector2.new(screen.X, screen.Y) - mousePos).Magnitude
        if d < bestDist then bestDist = d; best = part end
    end
    return best
end

-- ================== SILENT AIM (namecall hook) ==================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args   = {...}

    if Config.SilentAim and (method == "FireServer" or method == "InvokeServer") then
        local target = getTarget(Config.SilentAimFOV, Config.SilentAimPart, Config.SilentAimVisCheck)
        if target then
            local headPos = target.Position
            for i, v in ipairs(args) do
                if typeof(v) == "Vector3" then
                    args[i] = headPos
                elseif typeof(v) == "CFrame" then
                    args[i] = CFrame.new(headPos)
                elseif typeof(v) == "Instance" and v:IsA("BasePart") then
                    args[i] = target
                elseif type(v) == "table" then
                    for k, val in pairs(v) do
                        if typeof(val) == "Vector3" then v[k] = headPos
                        elseif typeof(val) == "CFrame" then v[k] = CFrame.new(headPos)
                        elseif typeof(val) == "Instance" and val:IsA("BasePart") then v[k] = target
                        end
                    end
                end
            end
            return oldNamecall(self, unpack(args))
        end
    end

    return oldNamecall(self, ...)
end)
setreadonly(mt, true)
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

        -- Box
        if Settings.ShowBox then
            e.Box.Size     = Vector2.new(width, height)
            e.Box.Position = Vector2.new(x, y)
            e.Box.Visible  = true
        else e.Box.Visible = false end

        -- Name
        if Settings.ShowName then
            e.Name.Text     = plr.DisplayName
            e.Name.Position = Vector2.new(topPos.X, y - 16)
            e.Name.Visible  = true
        else e.Name.Visible = false end

        -- Distance
        if Settings.ShowDistance then
            e.Distance.Text     = string.format("[%dm]", math.floor(dist))
            e.Distance.Position = Vector2.new(topPos.X, y + height + 2)
            e.Distance.Visible  = true
        else e.Distance.Visible = false end

        -- Health
        if Settings.ShowHealth and hum then
            local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            e.Health.Text     = string.format("HP %d", math.floor(hum.Health))
            e.Health.Position = Vector2.new(topPos.X, y - 30)
            e.Health.Color    
