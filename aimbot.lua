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
----------------------------------------...
-- ================== RENDER LOOPS ==================
RunService.RenderStepped:Connect(function()
    local mp = UIS:GetMouseLocation()
    FOVCircle.Position = mp
    FOVCircle.Radius   = Config.FOV
    FOVCircle.Visible  = Config.ShowFOV and Config.AimbotEnabled

    if Config.AimbotEnabled and aiming then
        local target = getTarget(Config.FOV, Config.AimPart, Config.WallCheck)
        if target then
            local cam = Camera.CFrame
            local goal = CFrame.new(cam.Position, target.Position)
            Camera.CFrame = cam:Lerp(goal, 1 - Config.Smoothness)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    for player, e in pairs(ESPObjects) do
        local vis = false
        if Config.ESPEnabled then
            local char, hrp, hum, head = getChar(player)
            if char then
                local d = (Camera.CFrame.Position - hrp.Position).Magnitude
                if d <= Config.MaxDistance then
                    local topPos, onTop = worldToScreen(head.Position + Vector3.new(0,0.5,0))
                    local botPos, onBot = worldToScreen(hrp.Position - Vector3.new(0,3,0))
                    if onTop and onBot then
                        local height = math.abs(topPos.Y - botPos.Y)
                        local width  = height * 0.55
                        local x = topPos.X - width/2
                        local y = topPos.Y

                        local col = Config.BoxColor
                        if Config.VisibleCheck and isVisible(head) then col = Config.VisibleColor end

                        if Config.BoxESP then
                            e.Box.Size=Vector2.new(width,height); e.Box.Position=Vector2.new(x,y); e.Box.Color=col; e.Box.Visible=true
                        end
                        if Config.NameESP then
                            e.Name.Text=player.Name; e.Name.Position=Vector2.new(topPos.X, y-16); e.Name.Color=col; e.Name.Visible=true
                        end
                        if Config.DistanceESP then
                            e.Dist.Text=string.format("[%dm]", math.floor(d)); e.Dist.Position=Vector2.new(topPos.X, botPos.Y+2); e.Dist.Visible=true
                        end
                        if Config.HealthESP and hum then
                            local pct = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
                            e.HPBg.Size=Vector2.new(3,height); e.HPBg.Position=Vector2.new(x-6, y); e.HPBg.Visible=true
                            e.HP.Size=Vector2.new(3, height*pct); e.HP.Position=Vector2.new(x-6, y+height*(1-pct))
                            e.HP.Color=Color3.fromRGB(255*(1-pct), 255*pct, 60); e.HP.Visible=true
                        end
                        if Config.TracerESP then
                            local origin
                            if Config.TracerOrigin=="Bottom" then origin=Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                            elseif Config.TracerOrigin=="Mouse" then origin=UIS:GetMouseLocation()
                            else origin=Camera.ViewportSize/2 end
                            e.Tracer.From=origin; e.Tracer.To=Vector2.new(topPos.X, botPos.Y); e.Tracer.Color=col; e.Tracer.Visible=true
                        end
                        vis = true
                    end
                end
            end
        end
        if not vis then for _, obj in pairs(e) do obj.Visible = false end end
    end
end)

-- ================== MENU ==================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WeepingCheats"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 280, 0, 460)
Main.Position = UDim2.new(0, 40, 0, 100)
Main.BackgroundColor3 = Color3.fromRGB(18,18,22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,6)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundColor3 = Color3.fromRGB(120,30,40)
Title.BorderSizePixel = 0
Title.Text = "☠ WEEPING CHEATS ☠  [Insert]"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(240,240,240)
Title.TextSize = 13
Instance.new("UICorner", Title).CornerRadius = UDim.new(0,6)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Position = UDim2.new(0,8,0,38)
Scroll.Size = UDim2.new(1,-16,1,-46)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local layout = Instance.new("UIListLayout", Scroll)
layout.Padding = UDim.new(0,4)

local function makeSection(text)
    local lbl = Instance.new("TextLabel", Scroll)
    lbl.Size = UDim2.new(1,0,0,22)
    lbl.BackgroundColor3 = Color3.fromRGB(30,30,38)
    lbl.BorderSizePixel = 0
    lbl.Text = "▸ "..text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextColor3 = Color3.fromRGB(200,120,140)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UIPadding", lbl).PaddingLeft = UDim.new(0,10)
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0,4)
end

local function makeToggle(name, key)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1,0,0,26)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UIPadding", btn).PaddingLeft = UDim.new(0,10)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
    local function refresh()
        btn.Text = (Config[key] and "☑  " or "☐  ") .. name
        btn.BackgroundColor3 = Config[key] and Color3.fromRGB(50,80,60) or Color3.fromRGB(35,35,45)
        btn.TextColor3 = Color3.fromRGB(230,230,230)
    end
    refresh()
    btn.MouseButton1Click:Connect(function() Config[key] = not Config[key]; refresh() end)
end

local function makeSlider(name, key, min, max)
    local holder = Instance.new("Frame", Scroll)
    holder.Size = UDim2.new(1,0,0,38)
    holder.BackgroundColor3 = Color3.fromRGB(35,35,45)
    holder.BorderSizePixel = 0
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0,4)
    local lbl = Instance.new("TextLabel", holder)
    lbl.BackgroundTransparency=1; lbl.Position=UDim2.new(0,10,0,2); lbl.Size=UDim2.new(1,-20,0,14)
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=11; lbl.TextColor3=Color3.fromRGB(230,230,230)
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Text=name..": "..tostring(Config[key])
    local bar = Instance.new("Frame", holder)
    bar.Position=UDim2.new(0,10,0,20); bar.Size=UDim2.new(1,-20,0,10); bar.BackgroundColor3=Color3.fromRGB(20,20,25)
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,4)
    local fill = Instance.new("Frame", bar)
    fill.BackgroundColor3=Color3.fromRGB(200,80,100)
    fill.Size=UDim2.new((Config[key]-min)/(max-min),0,1,0)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,4)
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

makeSection("AIMBOT")
makeToggle("Aimbot Enabled", "AimbotEnabled")
makeToggle("Wall Check",     "WallCheck")
makeToggle("Team Check",     "TeamCheck")
makeToggle("Show FOV",       "ShowFOV")
makeSlider("FOV Radius",     "FOV", 30, 400)

makeSection("SILENT AIM")
makeToggle("Silent Aim",         "SilentAim")
makeToggle("Silent Vis Check",   "SilentAimVisCheck")
makeSlider("Silent FOV",         "SilentAimFOV", 30, 500)

makeSection("ESP")
makeToggle("ESP Master",     "ESPEnabled")
makeToggle("Boxes",          "BoxESP")
makeToggle("Names",          "NameESP")
makeToggle("Health Bars",    "HealthESP")
makeToggle("Distance",       "DistanceESP")
makeToggle("Tracers",        "TracerESP")
makeToggle("Visible Color Swap", "VisibleCheck")
makeSlider("Max Distance",   "MaxDistance", 100, 5000)

-- ================== KEYBIND ==================
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
        Text  = "Loaded ◈ RMB aim ◈ Insert toggle",
        Duration = 4,
    })
