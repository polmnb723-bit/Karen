-- LD hub | TD - Kazakh Tower  |  by dev
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local holder = (gethui and gethui()) or game:GetService("CoreGui")
local lp = Players.LocalPlayer

pcall(function()
    local o = holder:FindFirstChild("LDKazakh")
    if o then o:Destroy() end
end)

local GOLD = Color3.fromRGB(255, 214, 102)
local WHITE = Color3.new(1, 1, 1)
local ONC = Color3.fromRGB(30, 120, 60)
local OFFC = Color3.fromRGB(38, 38, 50)

local S = {fly = false, speed = false, jump = false, antisit = false, antifling = false}
local V = {flySpeed = 60, walkSpeed = 40, jumpPower = 80}
local DEF = {walk = 16, jump = 50}
local vert = 0
local char, hum, hrp, bv, bg

local function mk(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end
local function corner(o, r)
    mk("UICorner", {CornerRadius = UDim.new(0, r or 10)}, o)
end

-- ===== أدوات الحركة =====
local ctrl
pcall(function()
    local pm = require(lp:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 5))
    ctrl = pm:GetControls()
end)

local function moveVec()
    local cam = workspace.CurrentCamera
    if ctrl then
        local mv = ctrl:GetMoveVector()
        return cam.CFrame.RightVector * mv.X + cam.CFrame.LookVector * -mv.Z
    end
    return hum and hum.MoveDirection or Vector3.zero
end

local function stopFly()
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    if hum then hum.PlatformStand = false end
end

local function startFly()
    if not (hum and hrp) then return end
    stopFly()
    bv = mk("BodyVelocity", {MaxForce = Vector3.new(1e5, 1e5, 1e5), Velocity = Vector3.zero}, hrp)
    bg = mk("BodyGyro", {MaxTorque = Vector3.new(1e5, 1e5, 1e5), P = 1e4, CFrame = hrp.CFrame}, hrp)
    hum.PlatformStand = true
end

local function bind(c)
    char = c
    hum = c:WaitForChild("Humanoid", 10)
    hrp = c:WaitForChild("HumanoidRootPart", 10)
    if not (hum and hrp) then return end
    DEF.walk = hum.WalkSpeed
    DEF.jump = hum.JumpPower
    bv, bg = nil, nil
    if S.fly then startFly() end
    if S.antisit then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end
end

if lp.Character then task.spawn(bind, lp.Character) end
lp.CharacterAdded:Connect(bind)

-- ===== الواجهة =====
local gui = mk("ScreenGui", {Name = "LDKazakh", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 997}, holder)

local panel = mk("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -14, 0.5, 0),
    Size = UDim2.new(0, 280, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundColor3 = Color3.fromRGB(16, 16, 22),
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    Active = true,
}, gui)
corner(panel, 16)
mk("UIStroke", {Color = GOLD, Transparency = 0.35, Thickness = 2}, panel)
mk("UIPadding", {
    PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 12),
    PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
}, panel)
mk("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
}, panel)

local title = mk("TextLabel", {
    LayoutOrder = 0, Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1,
    Text = "LD hub | TD", Font = Enum.Font.GothamBold, TextSize = 22,
    TextColor3 = Color3.fromRGB(200, 235, 255),
}, panel)
mk("TextLabel", {
    LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
    Text = "Kazakh Tower  |  by dev", Font = Enum.Font.Gotham, TextSize = 14,
    TextColor3 = GOLD,
}, panel)

-- سحب القائمة من العنوان
local dragging, dStart, pStart = false, nil, nil
title.Active = true
title.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        dragging, dStart, pStart = true, inp.Position, panel.Position
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - dStart
        panel.Position = UDim2.new(pStart.X.Scale, pStart.X.Offset + d.X, pStart.Y.Scale, pStart.Y.Offset + d.Y)
    end
end)

-- أزرار صعود ونزول للطيران
local pad = mk("Frame", {
    Position = UDim2.new(0, 20, 1, -170), Size = UDim2.new(0, 70, 0, 140),
    BackgroundTransparency = 1, Visible = false,
}, gui)
local function holdBtn(text, y, val)
    local b = mk("TextButton", {
        Position = UDim2.new(0, 0, 0, y), Size = UDim2.new(1, 0, 0, 64),
        BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35,
        TextColor3 = GOLD, Font = Enum.Font.GothamBold, TextSize = 20, Text = text,
    }, pad)
    corner(b, 12)
    mk("UIStroke", {Color = GOLD, Transparency = 0.4, Thickness = 1.5}, b)
    local function isPress(i)
        return i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1
    end
    b.InputBegan:Connect(function(i) if isPress(i) then vert = val end end)
    b.InputEnded:Connect(function(i) if isPress(i) and vert == val then vert = 0 end end)
end
holdBtn("UP", 0, 1)
holdBtn("DN", 76, -1)

-- ===== التشغيل والإيقاف =====
local function setFly(on)
    S.fly = on
    pad.Visible = on
    vert = 0
    if on then startFly() else stopFly() end
end
local function setSpeed(on)
    S.speed = on
    if not on and hum then hum.WalkSpeed = DEF.walk end
end
local function setJump(on)
    S.jump = on
    if not on and hum then hum.JumpPower = DEF.jump end
end
local function setSit(on)
    S.antisit = on
    if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, not on) end
end
local function setFling(on)
    S.antifling = on
end

-- ===== صفوف الأزرار =====
local order = 2
local function addRow(name, setter, stepper)
    order = order + 1
    local row = mk("Frame", {Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, LayoutOrder = order}, panel)
    local on = false
    local tb = mk("TextButton", {
        Size = stepper and UDim2.new(0.5, 0, 1, 0) or UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = OFFC, TextColor3 = WHITE,
        Font = Enum.Font.GothamBold, TextSize = 15, Text = name .. "  OFF",
    }, row)
    corner(tb, 10)
    tb.MouseButton1Click:Connect(function()
        on = not on
        setter(on)
        tb.Text = name .. (on and "  ON" or "  OFF")
        tb.BackgroundColor3 = on and ONC or OFFC
    end)
    if stepper then
        local val = mk("TextLabel", {
            Position = UDim2.new(0.69, 0, 0, 0), Size = UDim2.new(0.18, 0, 1, 0),
            BackgroundTransparency = 1, TextColor3 = GOLD,
            Font = Enum.Font.GothamBold, TextSize = 15, Text = tostring(V[stepper.key]),
        }, row)
        local function step(d)
            V[stepper.key] = math.clamp(V[stepper.key] + d, stepper.min, stepper.max)
            val.Text = tostring(V[stepper.key])
        end
        for _, b in ipairs({{"-", 0.53, -stepper.step}, {"+", 0.87, stepper.step}}) do
            local sb = mk("TextButton", {
                Position = UDim2.new(b[2], 0, 0, 0), Size = UDim2.new(0.13, 0, 1, 0),
                BackgroundColor3 = OFFC, TextColor3 = WHITE,
                Font = Enum.Font.GothamBold, TextSize = 20, Text = b[1],
            }, row)
            corner(sb, 10)
            sb.MouseButton1Click:Connect(function() step(b[3]) end)
        end
    end
end

addRow("Fly", setFly, {key = "flySpeed", step = 10, min = 20, max = 200})
addRow("Speed", setSpeed, {key = "walkSpeed", step = 8, min = 16, max = 150})
addRow("Jump", setJump, {key = "jumpPower", step = 10, min = 50, max = 250})
addRow("Anti-Sit", setSit)
addRow("Anti-Fling", setFling)

-- إخفاء القائمة وزر فتحها
local tgl = mk("TextButton", {
    AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0),
    Size = UDim2.new(0, 54, 0, 54), BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 0.3, TextColor3 = GOLD, Font = Enum.Font.GothamBold,
    TextSize = 20, Text = "LD", Visible = false, ZIndex = 30,
}, gui)
corner(tgl, 27)
mk("UIStroke", {Color = GOLD, Transparency = 0.2, Thickness = 2}, tgl)

order = order + 1
local hideRow = mk("TextButton", {
    LayoutOrder = order, Size = UDim2.new(1, 0, 0, 38),
    BackgroundColor3 = Color3.fromRGB(120, 25, 25), BackgroundTransparency = 0.2,
    TextColor3 = WHITE, Font = Enum.Font.GothamBold, TextSize = 17, Text = "إخفاء",
}, panel)
corner(hideRow, 10)
hideRow.MouseButton1Click:Connect(function()
    panel.Visible = false
    tgl.Visible = true
end)
tgl.MouseButton1Click:Connect(function()
    panel.Visible = true
    tgl.Visible = false
end)

-- ===== الحلقات =====
local acc = 0
RunService.Heartbeat:Connect(function(dt)
    if not (hum and hum.Parent and hrp and hrp.Parent) then return end

    if S.speed then hum.WalkSpeed = V.walkSpeed end
    if S.jump then
        hum.UseJumpPower = true
        hum.JumpPower = V.jumpPower
    end
    if S.antisit and hum.Sit then
        hum.Sit = false
    end
    if S.antifling and not S.fly then
        local v = hrp.AssemblyLinearVelocity
        if Vector3.new(v.X, 0, v.Z).Magnitude > 120 or hrp.AssemblyAngularVelocity.Magnitude > 60 then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end

    -- منع اصطدام اللاعبين الثانين فينا (محلياً)
    acc = acc + dt
    if S.antifling and acc >= 0.25 then
        acc = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if S.fly and bv and bv.Parent and bg and hrp and hrp.Parent then
        local cam = workspace.CurrentCamera
        bv.Velocity = moveVec() * V.flySpeed + Vector3.new(0, vert * V.flySpeed, 0)
        bg.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
    end
end)
