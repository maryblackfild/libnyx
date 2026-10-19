if SERVER then
    AddCSLuaFile()
    return
end

libNyx = libNyx or {}
libNyx.ui = libNyx.ui or {}

local rndx = libNyx.rndx
if not rndx then return end

local baseWidth = 1920
local baseHeight = 1080
local scale = 1
local scaleWidth = 1
local scaleHeight = 1

local function computeScale()
    scaleWidth = math.max(0.001, ScrW() / baseWidth)
    scaleHeight = math.max(0.001, ScrH() / baseHeight)
    scale = math.Clamp(math.min(scaleWidth, scaleHeight), 0.75, 1.75)
end

local function recomputeStyle()
    local style = libNyx.ui.style
    if not style then return end

    style.radius = math.floor(12 * scale)
    style.padding = math.floor(14 * scale)
    style.iconSize = math.floor(24 * scale)
    style.btnHeight = math.floor(44 * scale)
    style.rowHeight = math.floor(82 * scale)
    style.shadowSpread = math.floor(22 * scale)
    style.shadowIntensity = math.floor(36 * scale)
    style.strokeWidth = math.max(1, math.floor(scale))
    style.headerIndentX = math.floor(24 * scale)
    style.headerIndentY = math.floor(24 * scale)
    style.comboItemH = math.floor(34 * scale)
end

function libNyx.ui.scale(value, axis)
    value = tonumber(value) or 0
    if axis == "w" then return math.floor(value * scaleWidth) end
    if axis == "h" then return math.floor(value * scaleHeight) end
    if axis == "min" then return math.floor(value * math.min(scaleWidth, scaleHeight)) end
    if axis == "max" then return math.floor(value * math.max(scaleWidth, scaleHeight)) end
    return math.floor(value * scale)
end

function libNyx.ui.scaleW(value)
    return libNyx.ui.scale(value, "w")
end

function libNyx.ui.scaleH(value)
    return libNyx.ui.scale(value, "h")
end

function libNyx.ui.scalePair(width, height)
    return libNyx.ui.scaleW(width), libNyx.ui.scaleH(height)
end

function libNyx.ui.recomputeScale()
    computeScale()
    recomputeStyle()
end

hook.Add("OnScreenSizeChanged", "libNyx.ui.recomputeScale", libNyx.ui.recomputeScale)

local style = {
    bgColor        = Color(10,10,14,150),
    panelColor     = Color(16,18,24,120),
    cardColor      = Color(20,22,30,130),
    accentColor    = Color(90,160,255),
    hoverColor     = Color(52,58,70,120),
    textColor      = Color(245,245,250),
    glassFill      = Color(20,24,32,110),
    glassStroke    = Color(255,255,255,22),
    radius         = 12,
    padding        = 14,
    iconSize       = 24,
    btnHeight      = 44,
    rowHeight      = 82,
    shadowSpread   = 22,
    shadowIntensity= 36,
    strokeWidth    = 1,
    headerIndentX  = 24,
    headerIndentY  = 24,
    gradientAlphaRow  = 120,
    gradientAlphaChip = 110,
    gradientAlphaBtn  = 130,
}
libNyx.ui.style = style
libNyx.ui.recomputeScale()

local baseFont = "Manrope"
local function hasSystemFont(name)
    local test = ("libNyx.fontCheck.%s"):format(name)
    surface.CreateFont(test, {font = name, size = 12, weight = 400, extended = true})
    surface.SetFont(test)
    local w, h = surface.GetTextSize("Aa")
    return (w or 0) > 0 and (h or 0) > 0
end
if not hasSystemFont(baseFont) then baseFont = "Tahoma" end

local fontCache = {}
for sz = 10, 200 do
    local key = ("libNyx.%s.%d"):format(baseFont, sz)
    surface.CreateFont(key, {font = baseFont, size = sz, weight = (sz >= 28) and 500 or 400, extended = true})
    fontCache[sz] = key
end
function libNyx.ui.font(size)
    size = math.Clamp(math.floor(tonumber(size) or 14), 10, 200)
    return fontCache[size]
end

local gradientLeftMaterial = Material("vgui/gradient-l", "noclamp smooth")

local gradientPalette = {
    Color( 90,160,255),
    Color(255,125,155),
    Color(120,220,160),
    Color(255,200,120),
    Color(170,120,255),
    Color(120,200,255),
}
local function palettePick(key)
    key = tostring(key or "")
    local sum = 0
    for i = 1, #key do sum = sum + key:byte(i) end
    local idx = (sum % #gradientPalette) + 1
    return gradientPalette[idx]
end

libNyx.ui.sounds = {
    hover = "nyx_uniqueui/nyxclick_2.mp3",
    click = "nyx_uniqueui/nyxclick_3.mp3",
}

function libNyx.ui.playHover()
    surface.PlaySound(libNyx.ui.sounds.hover)
end

function libNyx.ui.playClick()
    surface.PlaySound(libNyx.ui.sounds.click)
end

local function disablePanelBackground(p)
    if not IsValid(p) then return end
    if p.SetPaintBackground then p:SetPaintBackground(false) end
    if p.SetPaintBackgroundEnabled then p:SetPaintBackgroundEnabled(false) end
    if p.SetPaintBorderEnabled then p:SetPaintBorderEnabled(false) end
    if p.SetDrawBackground then p:SetDrawBackground(false) end
end

function libNyx.ui.disableBackground(root)
    if not IsValid(root) then return end
    disablePanelBackground(root)
    for _, ch in ipairs(root:GetChildren()) do disablePanelBackground(ch) end
    if root.libNyxBackgroundDisabled then return end
    local old = root.OnChildAdded
    root.OnChildAdded = function(self, pnl)
        if isfunction(old) then old(self, pnl) end
        disablePanelBackground(pnl)
    end
    root.libNyxBackgroundDisabled = true
end


local function beginRoundedMask(x, y, width, height, radius, flags)
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilWriteMask(0xFF)
    render.SetStencilTestMask(0xFF)
    render.SetStencilReferenceValue(1)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)

    if render.OverrideColorWriteEnable then
        render.OverrideColorWriteEnable(true, false)
        if render.OverrideAlphaWriteEnable then
            render.OverrideAlphaWriteEnable(true, false)
        end
        rndx.Draw(radius, x, y, width, height, color_white, flags or 0)
        if render.OverrideAlphaWriteEnable then
            render.OverrideAlphaWriteEnable(false, false)
        end
        render.OverrideColorWriteEnable(false, false)
    else
        render.SetBlend(0)
        rndx.Draw(radius, x, y, width, height, color_white, flags or 0)
        render.SetBlend(1)
    end

    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilPassOperation(STENCIL_KEEP)
    render.SetStencilFailOperation(STENCIL_ZERO)
    render.SetStencilZFailOperation(STENCIL_ZERO)
end

local function endRoundedMask()
    render.SetStencilEnable(false)
    render.SetStencilWriteMask(0xFF)
    render.SetStencilTestMask(0xFF)
end

libNyx.ui.draw = {}

function libNyx.ui.draw.beginMask(x, y, width, height, options)
    options = options or {}
    beginRoundedMask(x, y, width, height, options.radius or style.radius, options.shape or 0)
end

function libNyx.ui.draw.endMask()
    endRoundedMask()
end

function libNyx.ui.draw.blur(x, y, width, height, options)
    options = options or {}
    local radius = options.radius or style.radius
    local fill = options.fill or style.glassFill
    local stroke = options.stroke ~= false and (options.strokeColor or style.glassStroke)
    local flags = options.shape or 0
    local blurStrength = math.max(0, tonumber(options.strength) or 1)

    rndx().Rect(x, y, width, height):Rad(radius):Blur(blurStrength):Draw()
    rndx.Draw(radius, x, y, width, height, fill, flags)

    if stroke then
        rndx.DrawOutlined(radius, x, y, width, height, stroke, style.strokeWidth, flags)
    end
end

function libNyx.ui.createFrame(opts)
    opts = opts or {}
    local style = libNyx.ui.style
    local W = math.max(tonumber(opts.w) or 900, libNyx.ui.scale(240))
    local H = math.max(tonumber(opts.h) or 620, libNyx.ui.scale(200))
    local title = tostring(opts.title or "")
    local blur = opts.blur == true
    local f = vgui.Create("DFrame")
    f:SetTitle("")
    f:ShowCloseButton(false)
    f:SetSizable(false)
    f:MakePopup()
    libNyx.ui.disableBackground(f)

    f.targetWidth = W
    f.targetHeight = H
    f.minimumWidth = math.max(2, math.floor(W * 0.12))
    f.minimumHeight = math.max(2, math.floor(H * 0.12))
    f.overshoot = 1.04
    f.openDuration = 0.22
    f.closeDuration = 0.18
    f.phase = "opening"
    f.startedAt = SysTime()
    f.contentAlpha = 0
    f.title = title
    local cx, cy = ScrW() * 0.5, ScrH() * 0.5
    f:SetSize(f.minimumWidth, f.minimumHeight)
    f:SetPos(cx - f.minimumWidth/2, cy - f.minimumHeight/2)

    local function easeOutBack(t) local c1=1.70158 local c3=c1+1 local u=t-1 return 1 + c3*(u*u*u) + c1*(u*u) end
    local function easeInCubic(t) return t*t*t end
    local function expApproach(cur, tgt, spd) local k=1-math.exp(-(spd or 10)*FrameTime()) return cur+(tgt-cur)*k end
    local function applyContentAlpha(self, a)
        a = math.Clamp(math.floor(a or 0), 0, 255)
        for _, ch in ipairs(self:GetChildren()) do if IsValid(ch) then ch:SetAlpha(a) end end
    end
    local oldAdd = f.OnChildAdded
    function f:OnChildAdded(pnl)
        if oldAdd then oldAdd(self, pnl) end
        libNyx.ui.disableBackground(pnl)
        pnl:SetAlpha(math.floor(self.contentAlpha or 0))
    end

    local closeBtn
    if libNyx.ui.components and libNyx.ui.components.createButton then
        closeBtn = libNyx.ui.components.createButton(f, "✕", {variant="ghost", align="center", radius=style.radius})
        closeBtn:SetSize(libNyx.ui.scale(40), libNyx.ui.scale(40))
        if closeBtn.setRippleStyle then closeBtn:setRippleStyle(2) end
        closeBtn.onClick = function() f:Close() end
    else
        closeBtn = vgui.Create("DButton", f)
        closeBtn:SetText("✕")
        closeBtn:SetSize(libNyx.ui.scale(40), libNyx.ui.scale(40))
        libNyx.ui.disableBackground(closeBtn)
        closeBtn.DoClick = function() f:Close() end
    end

    function f:PerformLayout(w, h)
        closeBtn:SetPos(w - style.headerIndentX - closeBtn:GetWide(), style.headerIndentY)
    end

    function f:Think()
        local now = SysTime()
        if self.phase == "opening" then
            local t = math.TimeFraction(self.startedAt, self.startedAt + self.openDuration, now)
            if t >= 1 then
                self.phase = "idle"
                self:SetSize(self.targetWidth, self.targetHeight)
                self:Center()
                self.contentAlpha = 255
                applyContentAlpha(self, self.contentAlpha)
                self:SetMouseInputEnabled(true)
                self:SetKeyboardInputEnabled(true)
            else
                local e = easeOutBack(t)
                local ow, oh = self.targetWidth * self.overshoot, self.targetHeight * self.overshoot
                local w, h = Lerp(e, self.minimumWidth, ow), Lerp(e, self.minimumHeight, oh)
                if t > 0.85 then
                    local t2 = math.TimeFraction(0.85, 1.0, t)
                    local e2 = 1 - (1 - t2) * (1 - t2)
                    w = Lerp(e2, ow, self.targetWidth)
                    h = Lerp(e2, oh, self.targetHeight)
                end
                self:SetSize(math.max(1, w), math.max(1, h))
                self:SetPos(cx - w/2, cy - h/2)
                self.contentAlpha = expApproach(self.contentAlpha or 0, 255 * math.Clamp(t ^ 1.6, 0, 1), 16)
                applyContentAlpha(self, self.contentAlpha)
                self:SetMouseInputEnabled(false)
                self:SetKeyboardInputEnabled(false)
            end
        elseif self.phase == "closing" then
            local t = math.TimeFraction(self.startedAt, self.startedAt + self.closeDuration, now)
            if t >= 1 then
                self:Remove()
            else
                local e = easeInCubic(t)
                local w = Lerp(e, self.targetWidth, self.minimumWidth)
                local h = Lerp(e, self.targetHeight, self.minimumHeight)
                self:SetSize(math.max(1, w), math.max(1, h))
                self:SetPos(cx - w/2, cy - h/2)
                self.contentAlpha = expApproach(self.contentAlpha or 255, 0, 18)
                applyContentAlpha(self, self.contentAlpha)
            end
        end
    end

    function f:Paint(w, h)
        local r = math.max(style.radius, libNyx.ui.scale(14))
        if blur then
            libNyx.ui.draw.blur(0, 0, w, h, {radius = r, fill = style.bgColor, stroke = true, strokeColor = style.glassStroke})
        else
            libNyx.ui.draw.panel(0, 0, w, h, {radius = r, color = style.bgColor, outline = style.strokeWidth, outlineColor = style.glassStroke})
        end
        if self.title ~= "" then
            draw.SimpleText(self.title, libNyx.ui.font(libNyx.ui.scale(30)), style.headerIndentX, style.headerIndentY, style.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
    end

    local realRemove = f.Remove
    function f:Close()
        if self.phase == "closing" then return end
        self.phase = "closing"
        self.startedAt = SysTime()
        self:SetMouseInputEnabled(false)
        self:SetKeyboardInputEnabled(false)
    end
    function f:Remove()
        if self.phase ~= "closing" and self.phase ~= "idle" then return end
        realRemove(self)
    end
    return f
end

function libNyx.ui.draw.panel(x, y, width, height, options)
    options = options or {}
    local radius = options.radius or style.radius
    local color = options.color or options.fill or style.cardColor
    local flags = options.shape or 0

    if options.shadow == true then
        rndx.DrawShadows(radius, x, y, width, height, Color(0, 0, 0, 190), style.shadowSpread, style.shadowIntensity, flags)
    end

    rndx.Draw(radius, x, y, width, height, color, flags)

    if options.outline then
        rndx.DrawOutlined(radius, x, y, width, height, options.outlineColor or style.glassStroke, options.outline, flags)
    elseif options.stroke then
        rndx.DrawOutlined(radius, x, y, width, height, options.strokeColor or style.glassStroke, style.strokeWidth, flags)
    end
end

libNyx.ui.components = libNyx.ui.components or {}
local components = libNyx.ui.components

libNyx.ui.fxLayer = libNyx.ui.fxLayer or nil
local function getFxLayer()
    if IsValid(libNyx.ui.fxLayer) then return libNyx.ui.fxLayer end
    local pnl = vgui.Create("DPanel")
    pnl:SetZPos(32767)
    pnl:SetMouseInputEnabled(false)
    pnl:SetKeyboardInputEnabled(false)
    pnl:SetSize(ScrW(), ScrH())
    pnl:SetPos(0,0)
    libNyx.ui.disableBackground(pnl)
    pnl.animations = {}
    pnl.Paint = function(s,w,h)
        local now = SysTime()
        for i = #s.animations, 1, -1 do
            local a = s.animations[i]
            local t = math.TimeFraction(a.t0, a.t0 + a.dur, now)
            if t >= 1 then
                if isfunction(a.cb) then a.cb() end
                table.remove(s.animations, i)
            else
                local e = t < 0.5 and (4*t*t*t) or (1 - (-2*t+2)^3/2)
                local x = Lerp(e, a.sx, a.ex)
                local y = Lerp(e, a.sy, a.ey - a.arc*math.sin(t*math.pi))
                surface.SetDrawColor(255,255,255,255)
                surface.SetMaterial(a.mat)
                surface.DrawTexturedRect(x - a.size/2, y - a.size/2, a.size, a.size)
            end
        end
        if #s.animations == 0 then s:SetVisible(false) end
    end
    hook.Add("OnScreenSizeChanged","libNyx.ui.getFxLayer",function()
        if not IsValid(pnl) then return end
        pnl:SetSize(ScrW(), ScrH())
        pnl:SetPos(0,0)
    end)
    libNyx.ui.fxLayer = pnl
    return pnl
end

function libNyx.ui.flyIcon(mat, sx, sy, ex, ey, size, dur, cb)
    local fx = getFxLayer()
    fx:SetVisible(true)
    table.insert(fx.animations, {
        mat = mat, sx = sx, sy = sy, ex = ex, ey = ey,
        size = size or libNyx.ui.scale(36),
        dur = dur or 0.35, t0 = SysTime(),
        arc = math.min(64, math.Distance(sx,sy,ex,ey)*0.25),
        cb = cb
    })
end

local function fitModel(mp)
    if not IsValid(mp) or not IsValid(mp.Entity) then return end
    local mn, mx = mp.Entity:GetRenderBounds()
    local size   = mx - mn
    local center = (mn + mx) * 0.5
    local maxdim = math.max(size.x, size.y, size.z)
    local ang    = Angle(12, 25, 0)
    local fov    = mp:GetFOV()
    local dist   = (maxdim * 0.55) / math.rad(fov * 0.5)
    local camPos = center + ang:Forward() * -dist + Vector(0, 0, size.z * 0.08)
    mp:SetCamPos(camPos)
    mp:SetLookAt(center + Vector(0, 0, size.z * 0.05))
    mp:SetAmbientLight(Vector(255, 255, 255))
    mp:SetDirectionalLight(BOX_TOP, Color(255,255,255))
end

function components.createCell(parent, opts)
    opts = opts or {}
    local sz    = opts.size or libNyx.ui.scale(88)
    local r     = opts.radius or libNyx.ui.scale(14)
    local tint  = opts.tint or style.accentColor

    local cell  = vgui.Create("DButton", parent)
    cell:SetText("")
    cell:SetSize(sz, sz)

    cell.radius    = r
    cell.tint      = tint
    cell.iconMaterial   = nil
    cell.iconSize  = math.floor(sz * 0.6)
    cell.modelPanel        = nil
    cell.info      = nil
    cell.infoBox   = nil
    cell.lastScreenPosition = {x = 0, y = 0}

    local function expApproach(cur, tgt, spd)
        local k = 1 - math.exp(-(spd or 10) * FrameTime())
        return cur + (tgt - cur) * k
    end

    local function normalizeTags(t)
        local out = {}
        if not istable(t) then return out end
        for _, v in ipairs(t) do
            if isstring(v) then
                out[#out+1] = {text = v, color = palettePick(v)}
            elseif istable(v) then
                out[#out+1] = {
                    text  = tostring(v.text or v.label or v[1] or ""),
                    color = v.color or v.col or v[2] or palettePick(v.text or v[1] or "?")
                }
            end
        end
        return out
    end

    local function removeInfoBox()
        if IsValid(cell.infoBox) then
            cell.infoBox:Remove()
            cell.infoBox = nil
        end
    end

    local function ensureInfoBox()
        if IsValid(cell.infoBox) then return cell.infoBox end
        if not cell.info then return nil end

        local ib = vgui.Create("DPanel")
        ib:SetDrawOnTop(true)
        ib:SetMouseInputEnabled(true)
        ib:SetKeyboardInputEnabled(false)

        ib.title = tostring(cell.info.title or "")
        ib.description  = tostring(cell.info.desc or "")
        ib.tags  = normalizeTags(cell.info.tags)
        ib.tint  = cell.tint
        ib.state     = "opening"
        ib.startedAt        = SysTime()
        ib.openDuration   = 0.16
        ib.closeDuration  = 0.14
        ib.visibility       = 0
        ib.hoverAlpha    = 0

        surface.SetFont(libNyx.ui.font(libNyx.ui.scale(20)))
        local tw, th = surface.GetTextSize(ib.title ~= "" and ib.title or " ")
        surface.SetFont(libNyx.ui.font(libNyx.ui.scale(16)))
        local dw, dh = surface.GetTextSize(ib.description ~= "" and ib.description or " ")

        local pad   = libNyx.ui.scale(12)
        local gap   = libNyx.ui.scale(8)
        local tagH  = libNyx.ui.scale(22)
        local ww    = math.max(libNyx.ui.scale(240), tw + pad*2, dw + pad*2)
        local hh    = pad + th + (ib.description ~= "" and (gap + dh) or 0) + ( (#ib.tags>0) and (gap + tagH) or 0 ) + pad

        ib:SetSize(ww, hh)

        local function place()
            local sx, sy = cell:LocalToScreen(0, 0)
            local cw, ch = cell:GetSize()
            local w,  h  = ib:GetSize()
            local x  = sx + cw + libNyx.ui.scale(10)
            local y  = sy + math.floor((ch - h) * 0.5)
            x = math.min(x, ScrW() - w - libNyx.ui.scale(8))
            y = math.Clamp(y, libNyx.ui.scale(8), ScrH() - h - libNyx.ui.scale(8))
            ib:SetPos(x, y)
        end
        place()
        ib.Think = function(s)
            local sx, sy = cell:LocalToScreen(0, 0)
            if sx ~= (cell.lastScreenPosition.x or 0) or sy ~= (cell.lastScreenPosition.y or 0) then
                place()
                cell.lastScreenPosition.x, cell.lastScreenPosition.y = sx, sy
            end
            local tgtH = s:IsHovered() and 1 or 0
            s.hoverAlpha = expApproach(s.hoverAlpha or 0, tgtH, 10)

            local now = SysTime()
            if s.state == "opening" then
                local t = math.TimeFraction(s.startedAt, s.startedAt + s.openDuration, now)
                if t >= 1 then
                    s.state = "open"
                    s.visibility = 1
                else
                    s.visibility = 1 - (1 - t) * (1 - t)
                end
            elseif s.state == "closing" then
                local t = math.TimeFraction(s.startedAt, s.startedAt + s.closeDuration, now)
                if t >= 1 then
                    s:Remove()
                    cell.infoBox = nil
                    return
                else
                    s.visibility = 1 - (t * t * t)
                end
            else
                s.visibility = expApproach(s.visibility or 1, 1, 12)
                if (not cell:IsHovered()) and (not s:IsHovered()) then
                    s.state = "closing"
                    s.startedAt = SysTime()
                end
            end
        end

        ib.Paint = function(s, w, h)
            local v = math.Clamp(s.visibility or 0, 0, 1)
            local sc   = Lerp(v, 0.92, 1.00)
            local dx   = math.floor((w - w*sc) * 0.5)
            local dy   = math.floor((h - h*sc) * 0.5)
            local baseFillA = Lerp(s.hoverAlpha or 0, 90, 70)
            local strokeA   = 20
            local fillCol   = Color(16,18,24, math.floor(baseFillA * v))
            local strokeCol = Color(255,255,255, math.floor(strokeA * v))
            local blurI     = 1.15 + 0.20 * (s.hoverAlpha or 0)

            libNyx.ui.draw.panel(dx, dy, math.floor(w*sc), math.floor(h*sc), {
                radius        = libNyx.ui.scale(10),
                fill          = fillCol,
                stroke        = true,
                strokeColor   = strokeCol,
            })

            local ca = math.floor(255 * v)
            local slide = math.floor(libNyx.ui.scale(4) * (1 - v))

            surface.SetFont(libNyx.ui.font(libNyx.ui.scale(20)))
            draw.SimpleText(s.title or "", libNyx.ui.font(libNyx.ui.scale(20)),
                dx + libNyx.ui.scale(12), dy + libNyx.ui.scale(12) + slide,
                Color(style.textColor.r, style.textColor.g, style.textColor.b, ca),
                TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            if (s.description or "") ~= "" then
                surface.SetFont(libNyx.ui.font(libNyx.ui.scale(16)))
                local _, th = surface.GetTextSize(s.title ~= "" and s.title or " ")
                draw.SimpleText(s.description or "", libNyx.ui.font(libNyx.ui.scale(16)),
                    dx + libNyx.ui.scale(12), dy + libNyx.ui.scale(12) + th + libNyx.ui.scale(6) + slide,
                    Color(255,255,255, math.floor(220 * v)),
                    TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end

            if #s.tags > 0 then
                local pad = libNyx.ui.scale(12)
                local tagH = libNyx.ui.scale(22)
                local chipR = libNyx.ui.scale(8)
                local y = dy + h*sc - tagH - pad
                local x = dx + pad
                surface.SetFont(libNyx.ui.font(libNyx.ui.scale(14)))
                for _, tg in ipairs(s.tags) do
                    local t  = tg.text or ""
                    local tw = select(1, surface.GetTextSize(t))
                    local cw = tw + libNyx.ui.scale(14)
                    libNyx.ui.draw.panel(x, y, cw, tagH, {
                        radius = chipR,
                        color  = Color((tg.color or style.accentColor).r, (tg.color or style.accentColor).g, (tg.color or style.accentColor).b, math.floor(150 * v)),
                        stroke = true,
                        strokeColor = Color(255,255,255, math.floor(16 * v))
                    })
                    draw.SimpleText(t, libNyx.ui.font(libNyx.ui.scale(14)),
                        x + cw/2, y + tagH/2,
                        Color(255,255,255, math.floor(240 * v)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    x = x + cw + libNyx.ui.scale(6)
                end
            end
        end

        ib.OnCursorExited = function(s)
            if not cell:IsHovered() and s.state ~= "closing" then
                s.state = "closing"
                s.startedAt = SysTime()
            end
        end

        cell.infoBox = ib
        return ib
    end

    function cell:setItemIcon(mat, size, info)
        if isstring(mat) then mat = Material(mat, "noclamp smooth") end
        self.iconMaterial = mat
        if size then self.iconSize = size end
        self.info = info
        if IsValid(self.modelPanel) then self.modelPanel:Remove() self.modelPanel = nil end
        removeInfoBox()
        self:InvalidateLayout(true)
    end

    function cell:setItemModel(path)
        self.iconMaterial = nil
        if not IsValid(self.modelPanel) then
            self.modelPanel = vgui.Create("DModelPanel", self)
            self.modelPanel:Dock(FILL)
            self.modelPanel:DockMargin(libNyx.ui.scale(6), libNyx.ui.scale(6), libNyx.ui.scale(6), libNyx.ui.scale(6))
            self.modelPanel:SetFOV(28)
            function self.modelPanel:LayoutEntity(ent) end
        end
        self.modelPanel:SetModel(path or "models/props_c17/oildrum001.mdl")
        removeInfoBox()
    end

    function cell:clearItem()
        self.iconMaterial = nil
        if IsValid(self.modelPanel) then self.modelPanel:Remove() self.modelPanel = nil end
        self.info = nil
        removeInfoBox()
        self:InvalidateLayout(false)
    end

    function cell:hasItem()
        return self.iconMaterial ~= nil or IsValid(self.modelPanel)
    end

    function cell:getCenterScreen()
        local x, y = self:LocalToScreen(self:GetWide()/2, self:GetTall()/2)
        return x, y
    end

    function cell:PerformLayout(w, h)
        local dock = self:GetDock()
        if dock == LEFT or dock == RIGHT then
            self:SetWide(h)
        elseif dock == TOP or dock == BOTTOM then
            self:SetTall(w)
        elseif dock ~= FILL then
            local side = math.min(w, h)
            self:SetSize(side, side)
        end
    end

    function cell:OnSizeChanged(w, h)
        local side = math.min(w, h)
        self.iconSize = math.floor(side * 0.6)
        self.lastScreenPosition.x, self.lastScreenPosition.y = -1, -1
    end

    function cell:OnCursorEntered()
        if self:hasItem() and self.info then
            local ib = ensureInfoBox()
            if IsValid(ib) and ib.state == "closing" then
                ib.state = "opening"
                ib.startedAt = SysTime()
            end
        end
    end

    function cell:OnCursorExited()
        local ib = self.infoBox
        if IsValid(ib) and (not ib:IsHovered()) and ib.state ~= "closing" then
            ib.state = "closing"
            ib.startedAt = SysTime()
        end
    end

    function cell:OnRemove()
        removeInfoBox()
    end

    cell.Paint = function(s, w, h)
        libNyx.ui.draw.panel(0, 0, w, h, {
            radius        = s.radius,
            fill          = Color(16,18,24,120),
            stroke        = true,
            strokeColor   = style.glassStroke,
        })

        if s.iconMaterial then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(s.iconMaterial)
            surface.DrawTexturedRect((w - s.iconSize)/2, (h - s.iconSize)/2, s.iconSize, s.iconSize)
        end
    end

    return cell
end

libNyx.ui.dragState = libNyx.ui.dragState or {active=false}

local function easeInOutCubic(t)
    if t < 0.5 then return 4*t*t*t end
    t = (t - 1); return 1 + 4*t*t*t
end

local function ensureDragHook()
    if libNyx.ui.dragState.hooked then return end
    hook.Add("PostRenderVGUI", "libNyx.ui.dragOverlay", function()
        local d = libNyx.ui.dragState
        if not d or not d.active then return end
        local mx, my = gui.MousePos()
        mx = mx + (d.offx or 0)
        my = my + (d.offy or 0)
        local now = SysTime()
        local a   = 1
        local boxSize, rad, iconSize
        if d.phase == "pickup" then
            local t = math.TimeFraction(d.t0, d.t0 + d.dur, now)
            if t >= 1 then
                d.phase = "drag"
                t = 1
            end
            local e = easeInOutCubic(math.Clamp(t, 0, 1))
            boxSize  = Lerp(e, d.boxFrom,  d.boxTo)
            rad      = Lerp(e, d.radFrom,  d.radTo)
            iconSize = Lerp(e, d.iconFrom, d.iconTo)
        elseif d.phase == "drop" then
            local t = math.TimeFraction(d.t0, d.t0 + d.dur, now)
            if t >= 1 then
                d.active = false
                if IsValid(d.applyTo) and d.mat then
                    d.applyTo:setItemIcon(d.mat, d.origIconSize, d.info)
                elseif IsValid(d.src) and d.mat then
                    d.src:setItemIcon(d.mat, d.origIconSize, d.info)
                end
                if d.onDone then pcall(d.onDone) end
                return
            end

            local e = easeInOutCubic(math.Clamp(t, 0, 1))
            boxSize  = Lerp(e, d.boxTo,    d.boxTo * 0.92)
            rad      = Lerp(e, d.radTo,    d.radTo * 0.85)
            iconSize = Lerp(e, d.iconTo,   d.iconTo * 0.90)
            a        = 1 - e
        else
            boxSize  = d.boxTo
            rad      = d.radTo
            iconSize = d.iconTo
        end
        local bx = mx - boxSize/2
        local by = my - boxSize/2
        libNyx.ui.draw.panel(bx, by, boxSize, boxSize, {
            radius        = rad,
            fill          = Color(20,24,32, math.floor(120 * a)),
            stroke        = true,
            strokeColor   = Color(255,255,255, math.floor(22 * a)),
        })
        if d.mat then
            surface.SetDrawColor(255, 255, 255, math.floor(255 * a))
            surface.SetMaterial(d.mat)
            surface.DrawTexturedRect(mx - iconSize/2, my - iconSize/2, iconSize, iconSize)
        end
        local tgt = vgui.GetHoveredPanel()
        while IsValid(tgt) and not tgt.isInteractiveCell do tgt = tgt:GetParent() end
        local S = libNyx.ui.style
        if IsValid(tgt) and tgt.isInteractiveCell then
            local tx, ty = tgt:LocalToScreen(0, 0)
            d.textX, d.textY = tx, ty
            d.textWidth, d.textHeight = tgt:GetWide(), tgt:GetTall()
            d.textRight        = tgt.radius or menuStyle.radius
            d.targetAlpha    = 1
        else
            d.targetAlpha    = 0
        end
        local dt = FrameTime()
        local k  = 1 - math.pow(0.0001, dt * 60)
        local ka = 1 - math.pow(0.0001, dt * 45)
        d.hoverX = Lerp(k,  d.hoverX or d.textX or 0,  d.textX or (d.hoverX or 0))
        d.hoverY = Lerp(k,  d.hoverY or d.textY or 0,  d.textY or (d.hoverY or 0))
        d.hoverWidth = Lerp(k,  d.hoverWidth or d.textWidth or 0,  d.textWidth or (d.hoverWidth or 0))
        d.hoverHeight = Lerp(k,  d.hoverHeight or d.textHeight or 0,  d.textHeight or (d.hoverHeight or 0))
        d.hoverRadius = Lerp(k,  d.hoverRadius or d.textRight or menuStyle.radius, d.textRight or (d.hoverRadius or menuStyle.radius))
        d.hoverAlpha = Lerp(ka, d.hoverAlpha or 0, d.targetAlpha or 0)
        if (d.hoverAlpha or 0) > 0.01 and d.hoverX and d.hoverY and d.hoverWidth and d.hoverHeight then
            local acc = S.accentColor
            local x   = math.floor(d.hoverX + 0.5)
            local y   = math.floor(d.hoverY + 0.5)
            local w   = math.floor(d.hoverWidth + 0.5)
            local h   = math.floor(d.hoverHeight + 0.5)
            local r   = math.floor((d.hoverRadius or menuStyle.radius) + 0.5)
            local aL  = math.floor(210 * d.hoverAlpha)
            local sw  = math.max(1, math.floor(1 + d.hoverAlpha))
            rndx.DrawOutlined(r, x, y, w, h, Color(acc.r, acc.g, acc.b, aL), sw, 0)
        end
    end)
    libNyx.ui.dragState.hooked = true
end

function libNyx.ui.startDragIcon(src, mat, size, offx, offy)
    if isstring(mat) then mat = Material(mat, "noclamp smooth") end
    local S    = libNyx.ui.style
    local base = tonumber(size) or libNyx.ui.scale(36)
    ensureDragHook()
    libNyx.ui.dragState = {
        active       = true,
        src          = src,
        mat          = mat,
        origIconSize = base,
        offx         = offx or 0,
        offy         = offy or 0,

        info         = (IsValid(src) and src.info) or nil,

        phase    = "pickup",
        t0       = SysTime(),
        dur      = 0.16,
        boxFrom  = math.max(18, base * 0.88),
        boxTo    = base + libNyx.ui.scale(18),
        radFrom  = math.max(4,  S.radius * 0.5),
        radTo    = math.floor(S.radius * 1.15),
        iconFrom = base * 0.92,
        iconTo   = base,
    }
end

function libNyx.ui.stopDragIcon(applyTo)
    local d = libNyx.ui.dragState
    if not d or not d.active then return end
    d.applyTo = applyTo
    d.phase = "drop"
    d.t0    = SysTime()
    d.dur   = 0.18
end

local function findCellUnderCursor()
    local p = vgui.GetHoveredPanel()
    while IsValid(p) and not p.isInteractiveCell do p = p:GetParent() end
    return p
end

libNyx.ui.inventoryState = libNyx.ui.inventoryState or {holding=nil, from=nil}

function components.createInteractiveCell(parent, opts)
    local cell = components.createCell(parent, opts)
    cell.isInteractiveCell = true
    function cell:OnMousePressed(mc)
        if mc ~= MOUSE_LEFT then return end
        if libNyx.ui.dragState and libNyx.ui.dragState.active then return end
        if not self:hasItem() or not self.iconMaterial then return end
        local lx, ly = self:LocalCursorPos()
        local offx = lx - self:GetWide()/2
        local offy = ly - self:GetTall()/2
        libNyx.ui.startDragIcon(self, self.iconMaterial, self.iconSize, offx, offy)
        self:clearItem()
        self:MouseCapture(true)
        surface.PlaySound("ui/buttonclick.wav")
    end
    function cell:OnMouseReleased(mc)
        if mc ~= MOUSE_LEFT then return end
        self:MouseCapture(false)
        local tgt = findCellUnderCursor()
        if IsValid(tgt) and tgt ~= self and not tgt:hasItem() then
            libNyx.ui.stopDragIcon(tgt)
        else
            libNyx.ui.stopDragIcon(self)
        end
        surface.PlaySound("ui/buttonclickrelease.wav")
    end
    return cell
end

libNyx.ui.rippleStyle = libNyx.ui.rippleStyle or 1
function libNyx.ui.setRippleStyle(style)
    if isstring(style) then
        local s = string.lower(style)
        if s == "ring" or s == "2" then libNyx.ui.rippleStyle = 2 else libNyx.ui.rippleStyle = 1 end
    else
        libNyx.ui.rippleStyle = (tonumber(style) == 2) and 2 or 1
    end
end
function libNyx.ui.getRippleStyle() return libNyx.ui.rippleStyle end

local function makeRipple(btn, style)
    btn.ripples = {}
    btn.rippleDuration = 0.45
    btn.rippleSpeed = 340
    btn.rippleStyle = style and ((tonumber(style) == 2 or string.lower(tostring(style)) == "ring") and 2 or 1) or nil
    btn.rippleThickness = libNyx.ui.scale(4)
    btn.rippleRadius = nil
    btn.rippleShape = 0
    function btn:setRippleStyle(s)
        self.rippleStyle = (tonumber(s) == 2 or string.lower(tostring(s)) == "ring") and 2 or 1
    end
    function btn:setRippleMask(radius, shape)
        self.rippleRadius = radius
        self.rippleShape = shape or 0
    end
end

local function paintRipples(self, w, h, color)
    if not self.ripples or #self.ripples == 0 then return end

    local now = SysTime()
    local variant = self.rippleStyle or libNyx.ui.getRippleStyle()
    local thick = math.max(1, self.rippleThickness or libNyx.ui.scale(3))
    local usedMask = false
    if self.rippleRadius then
        libNyx.ui.draw.beginMask(0, 0, w, h, {radius = self.rippleRadius, shape = self.rippleShape or 0})
        usedMask = true
    end
    for i = #self.ripples, 1, -1 do
        local ripple = self.ripples[i]
        local dt = now - ripple.t0
        if dt >= self.rippleDuration then
            table.remove(self.ripples, i)
        else
            local radius = dt * self.rippleSpeed
            local alpha = math.Clamp(220 * (1 - dt / self.rippleDuration), 0, 220)
            if variant == 2 then
                rndx.DrawCircleOutlined(ripple.x, ripple.y, radius * 2, Color(color.r, color.g, color.b, alpha), thick)
            else
                surface.SetDrawColor(color.r, color.g, color.b, alpha)
                draw.NoTexture()
                local seg = 28
                local verts = {{x = ripple.x, y = ripple.y}}
                for k = 0, seg do
                    local ang = (k / seg) * math.pi * 2
                    verts[#verts + 1] = {x = ripple.x + math.cos(ang) * radius, y = ripple.y + math.sin(ang) * radius}
                end
                surface.DrawPoly(verts)
            end
        end
    end
    if usedMask then
        libNyx.ui.draw.endMask()
    end
end

function components.createCheckbox(parent, opts)
    opts = opts or {}

    local switch = vgui.Create("DButton", parent)
    switch:SetText("")
    switch:SetCursor("hand")
    switch.checked = tobool(opts.checked)
    switch.tint = opts.tint or style.accentColor
    switch.label = tostring(opts.label or "")
    switch.controlHeight = math.max(libNyx.ui.scale(17), tonumber(opts.size) or libNyx.ui.scale(17))
    switch.controlWidth = math.floor(switch.controlHeight * 36 / 17)
    switch.gap = libNyx.ui.scale(10)
    switch.fontName = libNyx.ui.font(libNyx.ui.scale(18))
    switch.animation = switch.checked and 1 or 0
    switch.onChange = opts.onChange

    function switch:refreshSize()
        surface.SetFont(self.fontName)
        local textWidth = surface.GetTextSize(self.label)
        local width = self.controlWidth + (textWidth > 0 and self.gap + textWidth or 0) + libNyx.ui.scale(2)
        self:SetSize(width, self.controlHeight)
    end

    function switch:setLabel(text)
        self.label = tostring(text or "")
        self:refreshSize()
    end

    function switch:setValue(value)
        value = tobool(value)
        if self.checked == value then return end

        self.checked = value
        if isfunction(self.onChange) then
            self.onChange(self.checked, self)
        end
    end

    function switch:getValue()
        return self.checked
    end

    function switch:setOnChange(callback)
        self.onChange = callback
    end

    function switch:DoClick()
        self:setValue(not self.checked)
        surface.PlaySound("ui/buttonclickrelease.wav")
    end

    function switch:Think()
        local target = self.checked and 1 or 0
        self.animation = Lerp(math.min(FrameTime() * 12, 1), self.animation or target, target)
    end

    function switch:Paint(w, h)
        local animation = math.Clamp(self.animation or 0, 0, 1)
        local controlHeight = self.controlHeight
        local controlWidth = self.controlWidth
        local controlY = math.floor((h - controlHeight) * 0.5)
        local radius = controlHeight * 0.5
        local outlineWidth = math.max(1, libNyx.ui.scale(2))

        if animation > 0.01 then
            rndx.Draw(
                radius,
                0,
                controlY,
                controlWidth,
                controlHeight,
                Color(self.tint.r, self.tint.g, self.tint.b, math.floor(255 * animation)),
                0
            )
        end

        if animation < 0.99 then
            rndx.DrawOutlined(
                radius,
                0,
                controlY,
                controlWidth,
                controlHeight,
                Color(33, 33, 33, math.floor(255 * (1 - animation))),
                outlineWidth,
                0
            )
        end

        local knobSize = controlHeight - libNyx.ui.scale(2)
        local knobX = Lerp(animation, libNyx.ui.scale(1), controlWidth - knobSize - libNyx.ui.scale(1))
        local knobY = controlY + libNyx.ui.scale(1)
        local knobRadius = knobSize * 0.5

        if animation < 0.99 then
            rndx.DrawOutlined(
                knobRadius,
                knobX,
                knobY,
                knobSize,
                knobSize,
                Color(173, 173, 173, math.floor(255 * (1 - animation))),
                outlineWidth,
                rndx.SHAPE_CIRCLE
            )
        end

        if animation > 0.01 then
            rndx.Draw(
                knobRadius,
                knobX,
                knobY,
                knobSize,
                knobSize,
                Color(10, 10, 10, math.floor(255 * animation)),
                rndx.SHAPE_CIRCLE
            )
        end

        if self.label ~= "" then
            draw.SimpleText(
                self.label,
                self.fontName,
                controlWidth + self.gap,
                h * 0.5,
                style.textColor,
                TEXT_ALIGN_LEFT,
                TEXT_ALIGN_CENTER
            )
        end
    end

    switch:refreshSize()
    return switch
end

function components.createButton(parent, text, opts)
    opts = opts or {}
    local btn = vgui.Create("DButton", parent)
    btn:SetText("")
    btn:SetTall(opts.h or style.btnHeight)
    btn:SetFont(libNyx.ui.font(libNyx.ui.scale(20)))
    btn.text        = text or "Button"
    btn.icon        = opts.icon
    btn.align       = opts.align or "center"
    btn.variant     = opts.variant or "primary"
    btn.radius      = opts.radius or style.radius
    btn.iconSize    = opts.iconSize or style.iconSize
    btn.onClick     = opts.onClick
    btn.tint        = opts.tint
    btn.centerTint  = opts.centerTint or opts.tint2

    function btn:SetText(value)
        self.text = tostring(value or "")
    end
    
    function btn:GetText()
        return self.text
    end
    
    local gradientLeftMaterial = Material("vgui/gradient-l", "noclamp smooth")
    local gradientRightMaterial = Material("vgui/gradient-r", "noclamp smooth")
    local function lighten(col, k)
        return Color(
            math.Clamp(col.r + (255 - col.r) * k, 0, 255),
            math.Clamp(col.g + (255 - col.g) * k, 0, 255),
            math.Clamp(col.b + (255 - col.b) * k, 0, 255),
            col.a or 255
        )
    end
    local function duoDefaults()
        local base   = Color(104,  76, 230, 205)
        local center = Color(184, 160, 255, 140)
        return base, center
    end
    makeRipple(btn, 2)
    btn:setRippleMask(btn.radius)
    function btn:DoClick()
        libNyx.ui.playClick()
        if isfunction(self.onClick) then self.onClick(self) end
    end
    function btn:OnCursorEntered()
        local mx, my = gui.MousePos()
        mx, my = self:ScreenToLocal(mx, my)
        table.insert(self.ripples, {x = mx, y = my, t0 = SysTime()})
        libNyx.ui.playHover()
    end
    btn.Paint = function(self, w, h)
        local pad = style.padding
        local r   = self.radius
        local v   = self.variant
        local align = ((v == "primaryCenter") or (v == "centerDuo")) and "center" or (self.align or "center")
        if v == "centerDuo" then
            local defBase, defCenter = duoDefaults()
            local baseCol   = self.tint or defBase
            local centerCol = self.centerTint or (self.tint and lighten(self.tint, 0.26)) or defCenter
            local aAdj = self:IsDown() and 20 or (self:IsHovered() and 10 or 0)
            local bg = Color(baseCol.r, baseCol.g, baseCol.b, math.Clamp((baseCol.a or 205) + aAdj, 120, 255))
            libNyx.ui.draw.panel(0, 0, w, h, {radius = r, color = bg})
            local light = Color(centerCol.r, centerCol.g, centerCol.b, math.Clamp((centerCol.a or 140) + aAdj, 0, 255))
            local coverage = 0.78
            local halfCov  = math.floor(w * coverage * 0.5)
            local cx       = math.floor(w * 0.5)
            local overlap  = 2
            local ro       = 0
            if not (gradientLeftMaterial:IsError() or gradientRightMaterial:IsError()) then
                local lx, lw = cx - halfCov - overlap, halfCov + overlap
                rndx.DrawMaterial(ro, lx, 0, lw, h, light, gradientRightMaterial, 0)
                local rx, rw = cx, halfCov + overlap
                rndx.DrawMaterial(ro, rx, 0, rw, h, light, gradientLeftMaterial, 0)
            end
        elseif v == "primary" or v == "primaryCenter" then
            local a = self:IsDown() and 235 or (self:IsHovered() and 220 or 205)
            local col = Color(style.accentColor.r, style.accentColor.g, style.accentColor.b, a)
            libNyx.ui.draw.panel(0, 0, w, h, {radius = r, color = col})
        elseif v == "ghost" then
            local col = self:IsHovered() and style.hoverColor or Color(0,0,0,0)
            libNyx.ui.draw.panel(0, 0, w, h, {radius = r, color = col, stroke = true})
        elseif v == "gradient" then
            libNyx.ui.draw.panel(0, 0, w, h, {radius = r, color = Color(20,22,30,120), stroke = true})
            if not gradientLeftMaterial:IsError() then
                local tint = self.tint or palettePick(self.text)
                local a    = self:IsDown() and (style.gradientAlphaBtn + 20)
                           or self:IsHovered() and (style.gradientAlphaBtn + 10)
                           or style.gradientAlphaBtn
                local gcol = Color(tint.r, tint.g, tint.b, a)
                local gw   = w * 0.6
                rndx.DrawMaterial(r, 0, 0, gw, h, gcol, gradientLeftMaterial, 0)
            end
        else
            local col = self:IsHovered() and Color(style.panelColor.r,style.panelColor.g,style.panelColor.b, 160) or style.panelColor
            libNyx.ui.draw.panel(0, 0, w, h, {radius = r, color = col})
        end
        surface.SetFont(libNyx.ui.font(libNyx.ui.scale(20)))
        local tw = surface.GetTextSize(self.text or "")
        if align == "left" then
            local x = pad
            if self.icon and not self.icon:IsError() then
                surface.SetDrawColor(style.textColor)
                surface.SetMaterial(self.icon)
                surface.DrawTexturedRect(x, (h - self.iconSize)/2, self.iconSize, self.iconSize)
                x = x + self.iconSize + pad
            end
            draw.SimpleText(self.text, libNyx.ui.font(libNyx.ui.scale(20)), x, h/2, style.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            local icw = (self.icon and not self.icon:IsError()) and (self.iconSize + pad) or 0
            local content = icw + tw
            local startX = math.floor((w - content) * 0.5)
            if self.icon and not self.icon:IsError() then
                surface.SetDrawColor(style.textColor)
                surface.SetMaterial(self.icon)
                surface.DrawTexturedRect(startX, (h - self.iconSize)/2, self.iconSize, self.iconSize)
                startX = startX + icw
            end
            draw.SimpleText(self.text, libNyx.ui.font(libNyx.ui.scale(20)), startX, h/2, style.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        paintRipples(self, w, h, style.textColor)
    end
    return btn
end

function libNyx.ui.components.createSlider(parent, opts)
    opts = opts or {}
    local uiApi   = libNyx.ui
    local style = uiApi.style
    local sld   = vgui.Create("DPanel", parent)
    sld:SetTall(style.btnHeight)
    uiApi.disableBackground(sld)

    sld.minimum      = tonumber(opts.min) or 0
    sld.maximum      = tonumber(opts.max) or 100
    sld.decimals      = math.max(0, tonumber(opts.decimals) or 0)
    sld.value    = math.Clamp(tonumber(opts.value) or sld.minimum, sld.minimum, sld.maximum)
    sld.lerpedValue  = sld.value
    sld.tint     = opts.tint or style.accentColor
    sld.gap      = uiApi.scale(10)
    sld.dragging = false
    sld.hoverAlpha   = 0
    sld.knobAlpha    = 0
    sld.pulse    = 0
    sld.lastText = ""
    sld.fontName     = uiApi.font(uiApi.scale(18))
    sld.numberFont  = uiApi.font(uiApi.scale(18))

    local gradientLeftMaterial = Material("vgui/gradient-l","noclamp smooth")
    local function formatSliderValue(v,d) return (d or 0) <= 0 and tostring(math.Round(v)) or string.format("%."..d.."f", v) end
    local function fracFromValue(v) local r=sld.maximum - sld.minimum if r<=0 then return 0 end return (v - sld.minimum)/r end
    local function valueFromFrac(f) return sld.minimum + f*(sld.maximum - sld.minimum) end
    local function clamp01(x) return x<0 and 0 or (x>1 and 1 or x) end
    local function expApproach(cur,tgt,spd) local k=1-math.exp(-(spd or 12)*FrameTime()) return cur+(tgt-cur)*k end

    local function counterWidth(txt)
        surface.SetFont(sld.numberFont)
        local w = select(1, surface.GetTextSize(txt))
        return math.Clamp(w + uiApi.scale(24), uiApi.scale(50), uiApi.scale(140))
    end

    local function trackBounds(w,h)
        local num = formatSliderValue(sld.lerpedValue, sld.decimals)
        local ta  = counterWidth(num)
        local th  = uiApi.scale(6)
        local tx  = 0
        local tw  = math.max(1, w - ta - sld.gap)
        local ty  = math.floor(h*0.5 - th*0.5)
        return tx, ty, tw, th, ta
    end

    function sld:setMin(v) self.minimum = tonumber(v) or self.minimum self:setValue(self.value) end
    function sld:setMax(v) self.maximum = tonumber(v) or self.maximum self:setValue(self.value) end
    function sld:setDecimals(d) self.decimals = math.max(0, tonumber(d) or self.decimals) end

    function sld:setValue(v)
        local nv = math.Clamp(tonumber(v) or self.value, self.minimum, self.maximum)
        if nv == self.value then return end
        self.value = nv
        if isfunction(self.OnValueChanged) then self:OnValueChanged(nv) end
    end
    function sld:getValue() return self.value end

    function sld:OnMousePressed(mc)
        if mc ~= MOUSE_LEFT then return end
        local lx, ly = self:LocalCursorPos()
        local tx, ty, tw, th = trackBounds(self:GetWide(), self:GetTall())
        if lx >= tx and lx <= (tx+tw) and ly >= ty - uiApi.scale(8) and ly <= ty + th + uiApi.scale(8) then
            self.dragging = true
            self:MouseCapture(true)
            local f = clamp01((lx - tx) / tw)
            self:setValue(valueFromFrac(f))
        end
    end

    function sld:OnMouseReleased(mc)
        if mc ~= MOUSE_LEFT then return end
        self.dragging = false
        self:MouseCapture(false)
    end

    function sld:OnCursorMoved(x,y)
        if not self.dragging then return end
        local tx, _, tw = trackBounds(self:GetWide(), self:GetTall())
        local f = clamp01((x - tx) / tw)
        self:setValue(valueFromFrac(f))
    end

    function sld:OnMouseWheeled(dl)
        local base = (self.maximum - self.minimum) * 0.01
        local gran = self.decimals > 0 and (1 / (10 ^ self.decimals)) or 1
        local step = math.max(base, gran)
        self:setValue(self.value + step * (dl > 0 and 1 or -1))
    end

    function sld:Think()
        self.lerpedValue = Lerp(FrameTime()*12, self.lerpedValue or self.value, self.value)
        local txt = formatSliderValue(self.lerpedValue, self.decimals)
        if txt ~= self.lastText then
            self.lastText = txt
            self.pulse = 1
        end
        local hov = self:IsHovered() or self.dragging
        self.hoverAlpha = expApproach(self.hoverAlpha, hov and 1 or 0, 10)
        self.knobAlpha  = expApproach(self.knobAlpha, self.dragging and 1 or (hov and 0.6 or 0), 12)
        self.pulse  = expApproach(self.pulse, 0, 8)
        if self.dragging then self:SetCursor("sizewe") else self:SetCursor("hand") end
    end

    function sld:Paint(w,h)
        local tx, ty, tw, th = trackBounds(w,h)
        local f  = (self.maximum - self.minimum) == 0 and 0 or (self.lerpedValue - self.minimum) / (self.maximum - self.minimum)
        local kn = uiApi.scale(16) + uiApi.scale(6) * self.knobAlpha

        uiApi.draw.panel(tx, ty, tw, th, {radius = th/2, color = Color(30,34,42,130 + math.floor(30*self.knobAlpha))})

        local minCenter = kn * 0.5
        local maxCenter = math.max(minCenter, tw - kn * 0.5)
        local centerOff = math.Clamp(tw * f, minCenter, maxCenter)
        local kx = math.floor(tx + centerOff)
        local ky = math.floor(h*0.5 - kn*0.5)

        local fillW = math.max(th, math.min(tw, kx - tx))
        if not gradientLeftMaterial:IsError() then
            local gcol = Color(self.tint.r, self.tint.g, self.tint.b, 170)
            if rndx and rndx.DrawMaterial then rndx.DrawMaterial(th/2, tx, ty, fillW, th, gcol, gradientLeftMaterial, 0)
            else draw.RoundedBox(th/2, tx, ty, fillW, th, self.tint) end
        else
            draw.RoundedBox(th/2, tx, ty, fillW, th, self.tint)
        end

        uiApi.draw.panel(kx - kn/2, ky, kn, kn, {radius = kn/2, color = Color(240,240,255, math.floor(180 + 50*self.knobAlpha)), stroke = true})

        local num = formatSliderValue(self.lerpedValue, self.decimals)
        local scale = 1 + 0.40 * self.pulse
        local fs = uiApi.font(math.Clamp(math.floor(18 * scale), 10, 200))
        draw.SimpleText(num, fs, w - uiApi.scale(8), h/2, style.textColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    sld.lastText = formatSliderValue(sld.value, sld.decimals)
    return sld
end

function components.createDropdown(parent, opts)
    opts = opts or {}
    local combo = vgui.Create("DComboBox", parent)
    combo.valueText    = ""
    combo.placeholder = opts.placeholder or "Выберите…"
    combo.tint        = opts.tint or palettePick("dropdown")
    combo:SetText("")
    if IsValid(combo.DropButton) then
        combo.DropButton:SetText("")
        combo.DropButton.Paint = function() end
    end
    function combo:SetText(_) end
    function combo:SetValue(str) self.valueText = tostring(str or "") end
    function combo:GetValue()    return self.valueText or "" end
    function combo:Paint(w,h)
        libNyx.ui.draw.panel(0, 0, w, h, {radius = style.radius, color = style.panelColor, stroke = true})
        local txt = (self.valueText ~= "" and self.valueText) or self.placeholder
        draw.SimpleText(txt, libNyx.ui.font(libNyx.ui.scale(20)), style.padding, h/2, style.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("▼",  libNyx.ui.font(libNyx.ui.scale(18)), w - style.padding, h/2, style.textColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    local function normalizeChoices()
        local out, ch = {}, istable(opts.choices) and opts.choices or {}
        for _, v in ipairs(ch) do
            if istable(v) then
                local lbl = v.label or v.text or v[1] or ""
                local ic  = v.icon or v[2]
                if isstring(ic) then ic = Material(ic, "noclamp smooth") end
                out[#out+1] = { label = tostring(lbl), icon = ic }
            else
                out[#out+1] = { label = tostring(v) }
            end
        end
        return out
    end
    function combo:OpenMenu()
        if IsValid(self.Menu) then self.Menu:Remove() self.Menu = nil end
        local m = DermaMenu(self)
        m:SetDrawOnTop(true)
        m:SetPaintBackground(false)
        m:SetPaintBorderEnabled(false)
        local radius   = math.max(style.radius, libNyx.ui.scale(12))
        local itemH    = math.max(libNyx.ui.scale(58), tonumber(opts.itemHeight) or 0)
        local iconSize = libNyx.ui.scale(22)
        local fontOpt  = libNyx.ui.font(libNyx.ui.scale(20))
        m.openTime = SysTime()
        m.duration   = 0.18
        m.reverse   = 0
        m.tint = self.tint
        m.Paint = function(s, w, h)
            libNyx.ui.draw.blur(0, 0, w, h, {
                radius = radius,
                strength = tonumber(opts.blurStrength) or 2,
                fill = Color(style.panelColor.r, style.panelColor.g, style.panelColor.b, 190),
                stroke = true,
                strokeColor = style.glassStroke
            })
        end
        for _, data in ipairs(normalizeChoices()) do
            local label, icon = data.label, data.icon
            local opt = m:AddOption(label, function()
                self:SetValue(label)
                if isfunction(opts.onSelect) then opts.onSelect(label) end
            end)
            opt:SetText("")
            opt:SetTall(itemH)
            opt.label     = label
            opt.icon      = icon
            opt.iconSize  = iconSize
            opt.tint      = self.tint
            makeRipple(opt,2)
            function opt:OnCursorEntered()
                local mx, my = gui.MousePos()
                mx, my = self:ScreenToLocal(mx, my)
                self.ripples = self.ripples or {}
                table.insert(self.ripples, {x = mx, y = my, t0 = SysTime()})
                surface.PlaySound("buttons/lightswitch2.wav")
            end
            opt.Paint = function(s, w, h)
                local hovered = s:IsHovered()
                local r = libNyx.ui.scale(10)
                if hovered then
                    libNyx.ui.draw.panel(0, 0, w, h, {radius = r, color = Color(255, 255, 255, 10)})
                end
                if hovered and not gradientLeftMaterial:IsError() then
                    local gcol = Color(s.tint.r, s.tint.g, s.tint.b, 120)
                    rndx.DrawMaterial(r, 0, 0, math.floor(w * 0.55), h, gcol, gradientLeftMaterial, 0)
                end
                local x = style.padding
                if s.icon and not s.icon:IsError() then
                    surface.SetDrawColor(style.textColor)
                    surface.SetMaterial(s.icon)
                    surface.DrawTexturedRect(x, (h - s.iconSize)/2, s.iconSize, s.iconSize)
                    x = x + s.iconSize + style.padding
                end
                draw.SimpleText(s.label or "", fontOpt, x, h/2, style.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                paintRipples(s, w, h, style.textColor)
            end
        end
        local x, y = self:LocalToScreen(0, self:GetTall() + 4)
        m:Open()
        m:SetMinimumWidth(self:GetWide())
        m:SetAlpha(0)
        m:SetPos(x, y - libNyx.ui.scale(8))
        m:MoveTo(x, y, m.duration, 0, 0.2)
        m:AlphaTo(255, m.duration, 0)
        self.Menu = m
        return m
    end
    return combo
end

function components.createList(parent, opts)
    opts = opts or {}
    local list = vgui.Create("DScrollPanel", parent)
    list.rowHeight = math.max(libNyx.ui.scale(66), opts.rowHeight or style.rowHeight)
    list.rows = {}
    local vbar = list:GetVBar()
    vbar:SetWide(opts.vbarWidth or libNyx.ui.scale(12))
    vbar.btnUp:SetTall(0)
    vbar.btnDown:SetTall(0)
    vbar.btnUp:SetVisible(false)
    vbar.btnDown:SetVisible(false)
    function vbar:Paint(w,h) draw.RoundedBox(4,0,0,w,h, Color(36,36,44,200)) end
    function vbar.btnUp:Paint() end
    function vbar.btnDown:Paint() end
    function vbar.btnGrip:Paint(w,h) draw.RoundedBox(4,0,0,w,h, style.accentColor) end
    function list:setRowHeight(h) self.rowHeight = math.max(libNyx.ui.scale(66), h or self.rowHeight) end
    function list:getSelected() return self.selected end
    function list:setSelected(row) self.selected = row end
    function list:clearRows()
        for _, r in ipairs(self.rows) do if IsValid(r) then r:Remove() end end
        self.rows = {}
        self.selected = nil
    end
    local function makeRowPaint(row)
        row.Paint = function(self, w, h)
            local base = (list:getSelected() == self) and Color(style.accentColor.r,style.accentColor.g,style.accentColor.b, 190)
                       or (self:IsHovered() and style.hoverColor or style.cardColor)
            libNyx.ui.draw.panel(0, 0, w, h, {radius = style.radius, color = base})
            if not self.plain and not gradientLeftMaterial:IsError() then
                local gw = w * 0.5
                local tint = palettePick(self.title or self.rightText or "row")
                local col  = Color(tint.r, tint.g, tint.b, style.gradientAlphaRow)
                rndx.DrawMaterial(style.radius, 0, 0, gw, h, col, gradientLeftMaterial, 0)
            end
            local pad = style.padding
            local x = pad
            local y = pad
            surface.SetFont(libNyx.ui.font(libNyx.ui.scale(22)))
            local rightW = 0
            if self.rightText and self.rightText ~= "" then
                rightW = select(1, surface.GetTextSize(self.rightText)) + pad
            end
            local rightLimitX = w - pad - rightW
            if self.icon and not self.icon:IsError() then
                local ic = math.max(libNyx.ui.scale(24), style.iconSize)
                surface.SetDrawColor(255,255,255)
                surface.SetMaterial(self.icon)
                surface.DrawTexturedRect(x, (h - ic)/2, ic, ic)
                x = x + ic + pad
            end
            draw.SimpleText(self.title or "Без названия", libNyx.ui.font(libNyx.ui.scale(26)), x, y + libNyx.ui.scale(2), style.textColor)
            if istable(self.labels) and #self.labels > 0 then
                local chipH = libNyx.ui.scale(22)
                local chipY = h - pad - chipH
                local cx = x
                local hidden = 0
                local chipFont = libNyx.ui.font(libNyx.ui.scale(15))
                surface.SetFont(chipFont)
                for i, chip in ipairs(self.labels) do
                    local t  = chip.text or tostring(chip) or ""
                    local tw = select(1, surface.GetTextSize(t))
                    local cw, ch = tw + libNyx.ui.scale(14), chipH
                    if (cx + cw) > rightLimitX then
                        hidden = (#self.labels - i + 1)
                        break
                    end
                    local baseCol = chip.color or palettePick(t)
                    local fill    = Color( math.max(0, baseCol.r - 10), math.max(0, baseCol.g - 10), math.max(0, baseCol.b - 10), 175 )
                    local chipR = libNyx.ui.scale(7)
                    libNyx.ui.draw.panel(cx, chipY, cw, ch, {radius = chipR, color = fill, stroke = true, strokeColor = Color(255,255,255,18)})
                    if not gradientLeftMaterial:IsError() then
                        local gw = cw * 0.65
                        local gcol = Color(baseCol.r, baseCol.g, baseCol.b, style.gradientAlphaChip)
                        rndx.DrawMaterial(chipR, cx, chipY, gw, ch, gcol, gradientLeftMaterial, 0)
                    end
                    draw.SimpleText(t, chipFont, cx + cw/2, chipY + ch/2, chip.textColor or style.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    cx = cx + cw + libNyx.ui.scale(5)
                end
                if hidden > 0 and (cx + libNyx.ui.scale(34)) <= rightLimitX then
                    local t  = "+" .. hidden
                    local tw = select(1, surface.GetTextSize(t))
                    local cw, ch = tw + libNyx.ui.scale(14), chipH
                    local chipR = libNyx.ui.scale(7)
                    libNyx.ui.draw.panel(cx, chipY, cw, ch, {radius = chipR, color = Color(36,36,44,175), stroke = true, strokeColor = Color(255,255,255,18)})
                    if not gradientLeftMaterial:IsError() then
                        local gw = cw * 0.65
                        local gcol = Color(style.accentColor.r, style.accentColor.g, style.accentColor.b, style.gradientAlphaChip)
                        rndx.DrawMaterial(chipR, cx, chipY, gw, ch, gcol, gradientLeftMaterial, 0)
                    end
                    draw.SimpleText(t, chipFont, cx + cw/2, chipY + ch/2, style.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
            if self.rightText and self.rightText ~= "" then
                draw.SimpleText(self.rightText, libNyx.ui.font(libNyx.ui.scale(28)), w - pad, h/2, style.textColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
            paintRipples(self, w, h, style.textColor)
        end
    end
    function list:addRow(data)
        data = data or {}
        local row = list:Add("DButton")
        row:Dock(TOP)
        row:DockMargin(0, 0, 0, libNyx.ui.scale(10))
        row:SetTall(self.rowHeight)
        row:SetText("")
        row.title     = data.title or ""
        row.subtitle  = data.subtitle
        row.icon      = data.icon
        row.labels    = istable(data.labels) and data.labels or {}
        row.rightText = data.rightText
        row.onClick   = data.onClick
        row.plain     = data.gradient == false or data.plain == true
        makeRipple(row)
        row:setRippleMask(style.radius)
        makeRowPaint(row)
        function row:DoClick()
            list:setSelected(self)
            if isfunction(self.onClick) then self.onClick(self) end
        end
        function row:OnCursorEntered()
            local mx, my = gui.MousePos()
            mx, my = self:ScreenToLocal(mx, my)
            table.insert(self.ripples, {x = mx, y = my, t0 = SysTime()})
            surface.PlaySound("buttons/lightswitch2.wav")
        end
        table.insert(self.rows, row)
        return row
    end
    return list
end

function components.createVBox(parent, opts)
    opts = opts or {}
    local w = opts.w or libNyx.ui.scale(140)
    local h = opts.h or libNyx.ui.scale(200)
    local pnl = vgui.Create("DButton", parent)
    pnl:SetText("")
    pnl:SetSize(w, h)
    pnl.variant   = (opts.variant or "centerGradient")
    pnl.tint      = opts.tint or Color(140,120,255)
    pnl.title     = opts.title or ""
    pnl.icon      = opts.icon
    pnl.iconSize  = opts.iconSize or libNyx.ui.scale(40)
    pnl.onClick   = opts.onClick
    pnl.phase     = 0
    pnl.hover     = false
    pnl.hoverAlpha    = 0
    pnl.pulseTime    = 0
    pnl.titleFont = libNyx.ui.font(libNyx.ui.scale(22))
    pnl.modelAlpha    = 0
    pnl.spinAlpha     = 0
    if isstring(pnl.icon) then pnl.icon = Material(pnl.icon, "noclamp smooth") end

    function pnl:DoClick()
        surface.PlaySound(libNyx.ui.sounds.click)
        if isfunction(self.onClick) then self.onClick(self) end
    end
    function pnl:OnCursorEntered()
        self.hover = true
        surface.PlaySound(libNyx.ui.sounds.hover)
    end
    function pnl:OnCursorExited()
        self.hover = false
    end

    local wantModel = (pnl.variant == "model") or (pnl.variant == "verticalGradient" and isstring(opts.model) and opts.model ~= "")
    if wantModel then
        pnl.modelPanel = vgui.Create("DModelPanel", pnl)
        pnl.modelPanel:SetSize(w, h)
        pnl.modelPanel:SetPos(0, 0)
        pnl.modelPanel:SetModel(opts.model or "models/props_c17/oildrum001.mdl")
        pnl.modelPanel:SetFOV(28)
        function pnl.modelPanel:LayoutEntity(ent) end
        pnl.baseCamera = nil
        local function fitModelLocal(mp)
            if not IsValid(mp) or not IsValid(mp.Entity) then return end
            local mn, mx = mp.Entity:GetRenderBounds()
            local size   = mx - mn
            local center = (mn + mx) * 0.5
            local maxdim = math.max(size.x, size.y, size.z)
            local ang    = Angle(12, 25, 0)
            local fov    = mp:GetFOV()
            local dist   = (maxdim * 0.52) / math.tan(math.rad(fov * 0.5))
            local camPos = center + ang:Forward() * -dist + Vector(0, 0, size.z * 0.04)
            mp:SetCamPos(camPos)
            mp:SetLookAt(center)
            mp:SetAmbientLight(Vector(255, 255, 255))
            mp:SetDirectionalLight(BOX_TOP,    Color(255,255,255))
            mp:SetDirectionalLight(BOX_FRONT,  Color(pnl.tint.r, pnl.tint.g, pnl.tint.b))
            mp:SetDirectionalLight(BOX_RIGHT,  Color(210,220,255))
            mp:SetDirectionalLight(BOX_LEFT,   Color(210,210,210))
            mp:SetDirectionalLight(BOX_BACK,   Color(190,200,220))
            mp:SetDirectionalLight(BOX_BOTTOM, Color(160,170,180))
            pnl.baseCamera = {center = center, dist = dist, ang = ang}
        end
        timer.Simple(0, function() if IsValid(pnl.modelPanel) then fitModelLocal(pnl.modelPanel) end end)
    end

    local gradientLeftMaterial = Material("vgui/gradient-l", "noclamp smooth")
    local gradientRightMaterial = Material("vgui/gradient-r", "noclamp smooth")
    local gradientUpMaterial = Material("vgui/gradient-u", "noclamp smooth")
    local function lighten(c, k)
        return Color(
            math.Clamp(c.r + (255 - c.r) * k, 0, 255),
            math.Clamp(c.g + (255 - c.g) * k, 0, 255),
            math.Clamp(c.b + (255 - c.b) * k, 0, 255),
            c.a or 255
        )
    end
    local function expApproach(cur, tgt, spd)
        local k = 1 - math.exp(-(spd or 10) * FrameTime())
        return cur + (tgt - cur) * k
    end

    pnl.Think = function(self)
        self.hoverAlpha = expApproach(self.hoverAlpha, self.hover and 1 or 0, 8)
        self.pulseTime = (self.pulseTime + FrameTime() * (0.8 + 1.2 * self.hoverAlpha)) % (math.pi * 2)
        if self.variant == "sunburst" then
            local sp = Lerp(self.hoverAlpha, 0.35, 1.1)
            self.phase = (self.phase + FrameTime() * sp) % (math.pi * 2)
        end
        if IsValid(self.modelPanel) and self.baseCamera then
            self.modelAlpha = expApproach(self.modelAlpha, self.hover and 1 or 0, 6)
            self.spinAlpha  = expApproach(self.spinAlpha, self.hover and 1 or 0, 5)
            local distMul = Lerp(self.modelAlpha, 1.0, 0.75)
            local yawJig  = math.sin(CurTime() * (0.6 + 1.0 * self.spinAlpha)) * 6 * self.spinAlpha
            local ang     = Angle(self.baseCamera.ang.p, self.baseCamera.ang.y + yawJig, self.baseCamera.ang.r)
            local camPos  = self.baseCamera.center + ang:Forward() * -(self.baseCamera.dist * distMul)
            self.modelPanel:SetCamPos(camPos)
            self.modelPanel:SetLookAt(self.baseCamera.center)
            self.modelPanel:SetFOV(Lerp(self.modelAlpha, 28, 26))
        end
    end

    pnl.Paint = function(self, w, h)
        local radius = style.radius
        libNyx.ui.draw.panel(0, 0, w, h, {radius = radius, color = Color(0, 0, 0, 0), stroke = true})
        libNyx.ui.draw.beginMask(0, 0, w, h, {radius = radius})
        local cx, cy = w * 0.5, h * 0.5
        if self.variant == "centerGradient" then
            local base = self.tint
            local light = lighten(base, 0.26)
            light.a = math.floor(Lerp(self.hoverAlpha, 120, 155))
            local coverage = Lerp(self.hoverAlpha, 0.80, 0.92)
            local halfCov = math.floor(w * coverage * 0.5)
            local cxpix = math.floor(w * 0.5 + math.sin(self.pulseTime) * libNyx.ui.scale(4) * self.hoverAlpha)
            local overlap = 2
            rndx.DrawMaterial(0, cxpix - halfCov - overlap, 0, halfCov + overlap, h, light, gradientRightMaterial, 0)
            rndx.DrawMaterial(0, cxpix, 0, halfCov + overlap, h, light, gradientLeftMaterial, 0)
        elseif self.variant == "verticalGradient" then
            local base = self.tint
            local col = Color(
                math.Clamp(base.r + (255 - base.r) * Lerp(self.hoverAlpha, 0.18, 0.28), 0, 255),
                math.Clamp(base.g + (255 - base.g) * Lerp(self.hoverAlpha, 0.18, 0.28), 0, 255),
                math.Clamp(base.b + (255 - base.b) * Lerp(self.hoverAlpha, 0.18, 0.28), 0, 255),
                Lerp(self.hoverAlpha, 120, 165)
            )
            local gh = math.floor(h * 0.65)
            local y0 = h - gh
            local rect = rndx().Rect(0, y0, w, gh):Radii(0, 0, radius, radius):Material(gradientUpMaterial):Color(col)
            local mat = rect:GetMaterial()
            surface.SetMaterial(mat)
            surface.SetDrawColor(col)
            surface.DrawTexturedRectUV(0, y0, w, gh, 0, 1, 1, 0)
        elseif self.variant == "sunburst" then
            local rays, step = 18, (math.pi * 2) / 18
            local rayRadius = math.max(w, h)
            local alphaOne = math.floor(Lerp(self.hoverAlpha, 95, 140))
            local alphaTwo = math.floor(Lerp(self.hoverAlpha, 40, 80))
            local colOne = Color(self.tint.r, self.tint.g, self.tint.b, alphaOne)
            local colTwo = Color(self.tint.r, self.tint.g, self.tint.b, alphaTwo)
            draw.NoTexture()
            for i = 0, rays - 1 do
                local a0 = self.phase + i * step
                local a1r = a0 + step * Lerp(self.hoverAlpha, 0.55, 0.70)
                local verts = {
                    {x = cx, y = cy},
                    {x = cx + math.cos(a0) * rayRadius, y = cy + math.sin(a0) * rayRadius},
                    {x = cx + math.cos(a1r) * rayRadius, y = cy + math.sin(a1r) * rayRadius},
                }
                surface.SetDrawColor((i % 2 == 0) and colOne or colTwo)
                surface.DrawPoly(verts)
            end
        end
        if not wantModel and self.icon and not self.icon:IsError() then
            local s = self.iconSize * (1 + 0.08 * self.hoverAlpha + 0.04 * math.sin(self.pulseTime))
            surface.SetDrawColor(style.textColor)
            surface.SetMaterial(self.icon)
            surface.DrawTexturedRect(cx - s / 2, cy - s / 2 - libNyx.ui.scale(10), s, s)
        end
    end

    pnl.PaintOver = function(self, w, h)
        local padX = libNyx.ui.scale(10)
        local padY = libNyx.ui.scale(6)
        local txt  = self.title or ""
        surface.SetFont(self.titleFont)
        local tw, th = surface.GetTextSize(txt)
        local bw, bh = tw + padX * 2, th + padY * 2
        local x  = math.floor((w - bw) / 2)
        local y  = h - style.padding - bh - math.floor(libNyx.ui.scale(2) * self.hoverAlpha)
        draw.SimpleText(txt, self.titleFont, x + bw / 2, y + bh / 2, style.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        libNyx.ui.draw.endMask()
    end

    return pnl
end

function components.createTabs(parent, opts)
    opts = opts or {}

    local pnl = vgui.Create("DPanel", parent)
    pnl.items = istable(opts.items) and opts.items or {}
    pnl.active = opts.default
    pnl.onChange = opts.onChange
    pnl:SetPaintBackground(false)
    pnl:SetPaintBorderEnabled(false)
    pnl:SetPaintBackgroundEnabled(false)
    pnl.Paint = nil

    local font = libNyx.ui.font(libNyx.ui.scale(18))
    local gap = math.max(0, tonumber(opts.gap) or libNyx.ui.scale(4))
    local radius = opts.radius or libNyx.ui.scale(10)

    local rail = vgui.Create("DPanel", pnl)
    rail:Dock(FILL)
    rail:SetPaintBackground(false)
    rail:SetPaintBorderEnabled(false)
    rail:SetPaintBackgroundEnabled(false)
    rail.Paint = nil

    pnl.buttons = {}

    local function makeButton(item, index)
        local button = vgui.Create("DButton", rail)
        button:SetText("")
        button:SetDrawBackground(false)
        button:SetPaintBackgroundEnabled(false)
        button:SetPaintBorderEnabled(false)
        button:SetCursor("hand")
        button:Dock(LEFT)
        button:DockMargin(gap, 0, gap, 0)

        button.id = tostring(item.id or item.label or index or "")
        button.label = tostring(item.label or button.id)
        button.icon = isstring(item.icon) and Material(item.icon, "noclamp smooth") or item.icon
        button.iconSize = libNyx.ui.scale(18)

        surface.SetFont(font)
        local textWidth = surface.GetTextSize(button.label)
        local paddingX = libNyx.ui.scale(16)
        local iconWidth = button.icon and not button.icon:IsError() and button.iconSize + libNyx.ui.scale(6) or 0
        button:SetWide(paddingX * 2 + iconWidth + textWidth)

        makeRipple(button, 2)
        button:setRippleMask(radius)

        function button:OnCursorEntered()
            if libNyx.ui and libNyx.ui.playHover then
                libNyx.ui.playHover()
            end
        end

        function button:DoClick()
            local mouseX, mouseY = gui.MousePos()
            mouseX, mouseY = self:ScreenToLocal(mouseX, mouseY)
            self.ripples = self.ripples or {}
            self.ripples[#self.ripples + 1] = {x = mouseX, y = mouseY, t0 = SysTime()}

            pnl:setActive(self.id)
            if isfunction(pnl.onChange) then
                pnl.onChange(self.id, self)
            end
            surface.PlaySound("ui/buttonclickrelease.wav")
        end

        function button:Paint(w, h)
            local selected = pnl.active == self.id
            local inset = math.max(1, libNyx.ui.scale(1))
            local drawWidth = math.max(0, w - inset * 2)
            local drawHeight = math.max(0, h - inset * 2)
            local drawRadius = math.min(radius, drawHeight * 0.5)

            if not selected and self:IsHovered() then
                libNyx.ui.draw.panel(inset, inset, drawWidth, drawHeight, {
                    radius = drawRadius,
                    color = Color(255, 255, 255, 10)
                })
            end

            if selected then
                rndx.DrawOutlined(
                    drawRadius,
                    inset,
                    inset,
                    drawWidth,
                    drawHeight,
                    Color(style.accentColor.r, style.accentColor.g, style.accentColor.b, 210),
                    math.max(1, libNyx.ui.scale(1)),
                    0
                )
            end

            local textX = paddingX
            if self.icon and not self.icon:IsError() then
                surface.SetDrawColor(
                    style.textColor.r,
                    style.textColor.g,
                    style.textColor.b,
                    selected and 255 or 200
                )
                surface.SetMaterial(self.icon)
                surface.DrawTexturedRect(textX, (h - self.iconSize) * 0.5, self.iconSize, self.iconSize)
                textX = textX + self.iconSize + libNyx.ui.scale(6)
            end

            draw.SimpleText(
                self.label,
                font,
                textX,
                h * 0.5,
                selected and style.textColor or Color(style.textColor.r, style.textColor.g, style.textColor.b, 200),
                TEXT_ALIGN_LEFT,
                TEXT_ALIGN_CENTER
            )

            paintRipples(self, w, h, style.textColor)
        end

        pnl.buttons[button.id] = button
        return button
    end

    function pnl:setItems(items)
        for _, child in ipairs(rail:GetChildren()) do
            if IsValid(child) then
                child:Remove()
            end
        end

        self.buttons = {}
        self.items = items or {}

        for index, item in ipairs(self.items) do
            makeButton(item, index)
        end

        rail:InvalidateLayout(true)

        if self.active == nil and #self.items > 0 then
            self.active = self.items[1].id or self.items[1].label
        end
    end

    function pnl:setActive(id)
        if not self.buttons[tostring(id or "")] then return end
        self.active = tostring(id)
    end

    function pnl:getActive()
        return self.active
    end

    function pnl:setOnChange(callback)
        self.onChange = callback
    end

    pnl:setItems(pnl.items)
    if pnl.active ~= nil then
        pnl:setActive(pnl.active)
    end

    return pnl
end

function components.createCategoryCard(parent, opts)
    opts = opts or {}
    local card = vgui.Create("DButton", parent)
    card:SetText("")
    card:SetTall(opts.h or libNyx.ui.scale(120))
    card.title   = opts.title or "Category"
    card.description    = opts.desc  or "—"
    card.icon    = opts.icon
    if isstring(card.icon) then
        card.icon = Material(card.icon, "noclamp smooth")
    end
    if not (card.icon and not card.icon:IsError()) then
        card.icon = Material("icon16/star.png", "noclamp smooth")
    end
    card.fromColor    = opts.from or Color(125, 82,255)
    card.toColor      = opts.to   or Color( 40,192,255)
    card.variant = opts.variant or "vibrant"
    card.radius  = opts.radius or libNyx.ui.scale(18)
    card.onClick = opts.onClick
    card.titleFont = libNyx.ui.font(libNyx.ui.scale(30))
    card.descriptionFont  = libNyx.ui.font(libNyx.ui.scale(17))
    card.hoverAlpha  = 0
    makeRipple(card)
    card:setRippleMask(card.radius)
    function card:DoClick()
        if libNyx.ui and libNyx.ui.playClick then libNyx.ui.playClick() end
        if isfunction(self.onClick) then self.onClick(self) end
    end
    function card:OnCursorEntered()
        local mx, my = gui.MousePos()
        mx, my = self:ScreenToLocal(mx, my)
        self.ripples = self.ripples or {}
        table.insert(self.ripples, {x = mx, y = my, t0 = SysTime()})
        if libNyx.ui and libNyx.ui.playHover then libNyx.ui.playHover() end
    end
    local function expApproach(cur, tgt, spd)
        local k = 1 - math.exp(-(spd or 10) * FrameTime())
        return cur + (tgt - cur) * k
    end
    local gradientLeftMaterial = Material("vgui/gradient-l", "noclamp smooth")
    local gradientRightMaterial = Material("vgui/gradient-r", "noclamp smooth")
    local function lighten(c, k)
        return Color(
            math.Clamp(c.r + (255 - c.r) * k, 0, 255),
            math.Clamp(c.g + (255 - c.g) * k, 0, 255),
            math.Clamp(c.b + (255 - c.b) * k, 0, 255),
            c.a or 255
        )
    end
    card.Think = function(self)
        self.hoverAlpha = expApproach(self.hoverAlpha or 0, self:IsHovered() and 1 or 0, 10)
    end
    card.Paint = function(self, w, h)
        local r = self.radius
        local a = math.Clamp(self.hoverAlpha or 0, 0, 1)
        if self.variant == "glass" then
            libNyx.ui.draw.panel(0, 0, w, h, {radius = r, color = Color(18, 22, 30, math.floor(Lerp(a, 125, 140))), stroke = true})
        else
            local baseCol = Color(self.fromColor.r, self.fromColor.g, self.fromColor.b, math.floor(Lerp(a, 220, 235)))
            libNyx.ui.draw.panel(0, 0, w, h, {radius = r, color = baseCol, shadow = true})
        end
        libNyx.ui.draw.beginMask(0, 0, w, h, {radius = r})
        if self.variant == "glass" then
            if not gradientLeftMaterial:IsError() then
                local c1 = Color(self.fromColor.r, self.fromColor.g, self.fromColor.b, math.floor(Lerp(a, 95, 140)))
                local c2 = Color(self.toColor.r, self.toColor.g, self.toColor.b, math.floor(Lerp(a, 95, 140)))
                rndx.DrawMaterial(r, 0, 0, w * 0.65, h, c1, gradientLeftMaterial, 0)
                rndx.DrawMaterial(r, w * 0.35, 0, w * 0.65, h, c2, gradientRightMaterial, 0)
            end
        else
            if not (gradientLeftMaterial:IsError() or gradientRightMaterial:IsError()) then
                local colL = Color(self.toColor.r, self.toColor.g, self.toColor.b, 255)
                local colR = Color(self.fromColor.r, self.fromColor.g, self.fromColor.b, 255)
                rndx.DrawMaterial(r, 0, 0, w, h, colL, gradientLeftMaterial, 0)
                rndx.DrawMaterial(r, 0, 0, w, h, colR, gradientRightMaterial, 0)
            end
        end
        if self.icon and not self.icon:IsError() then
            local sz = math.floor(h * 1.25)
            local s = 1 + 0.06 * a
            local sz2 = math.floor(sz * s)
            local oy = -libNyx.ui.scale(4) * a
            local alpha = (self.variant == "vibrant") and math.floor(Lerp(a, 44, 64)) or math.floor(Lerp(a, 36, 54))
            surface.SetDrawColor(255, 255, 255, alpha)
            surface.SetMaterial(self.icon)
            surface.DrawTexturedRect(w - sz2 + libNyx.ui.scale(28), (h - sz2) / 2 + oy, sz2, sz2)
        end
        libNyx.ui.draw.endMask()
        if self.variant ~= "glass" then
            local outlineA = math.floor(18 * a)
            if outlineA > 0 then
                rndx.DrawOutlined(r, 0, 0, w, h, Color(255, 255, 255, outlineA), 1)
            end
        end
        local padX = libNyx.ui.scale(18)
        local topY = libNyx.ui.scale(18)
        surface.SetFont(self.titleFont)
        local _, th = surface.GetTextSize(self.title or "")
        local titleCol = lighten(style.textColor, a * 0.08)
        draw.SimpleText(self.title, self.titleFont, padX, topY + th/2, titleCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetFont(self.descriptionFont)
        local _, dh = surface.GetTextSize(self.description or "")
        draw.SimpleText(self.description or "", self.descriptionFont, padX, topY + th + libNyx.ui.scale(6) + dh/2, Color(255,255,255, math.floor(Lerp(a, 200, 230))), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        local dashW, dashH = libNyx.ui.scale(18), libNyx.ui.scale(4)
        local dashA = math.floor(Lerp(a, 70, 110))
        libNyx.ui.draw.panel(padX, h - libNyx.ui.scale(18), dashW, dashH, {radius = dashH/2, color = Color(255,255,255, dashA)})
        paintRipples(self, w, h, style.textColor)
    end
    return card
end

function components.createSearchBox(parent, opts)
    opts = opts or {}
    local box = vgui.Create("DPanel", parent)
    box:SetTall(opts.h or libNyx.ui.scale(38))
    box.radius      = opts.radius or libNyx.ui.scale(12)
    box.placeholder = opts.placeholder or "Search"
    box.tint        = opts.tint or style.accentColor
    box.debounce = tonumber(opts.debounce or 0.12)
    box.searchTimerName = "libNyx.search." .. tostring(box)
    box.focusAlpha      = 0
    box.gradientAlpha       = 0
    box.languageId      = "EN"
    box.lastText    = ""
    local gradientLeftMaterial = Material("vgui/gradient-l", "noclamp smooth")
    local searchIconMaterial = Material("icon16/magnifier.png", "noclamp smooth")
    local clearIconMaterial  = Material("icon16/cross.png", "noclamp smooth")

    local btnClear = vgui.Create("DButton", box)
    btnClear:SetText("")
    btnClear:Dock(RIGHT)
    btnClear:SetWide(box:GetTall())
    btnClear.Paint = function(s,w,h)
        if not IsValid(box.entry) or (box.entry:GetText() == "" or box.entry:GetText() == nil) then return end
        if s:IsHovered() then
            libNyx.ui.draw.panel(libNyx.ui.scale(6), libNyx.ui.scale(5), w - libNyx.ui.scale(12), h - libNyx.ui.scale(10), {radius = (h - libNyx.ui.scale(10)) / 2, color = Color(255, 255, 255, 12)})
        end
        surface.SetDrawColor(style.textColor.r, style.textColor.g, style.textColor.b, 210)
        local ic = libNyx.ui.scale(14)
        surface.SetMaterial(clearIconMaterial)
        surface.DrawTexturedRect((w-ic)/2, (h-ic)/2, ic, ic)
    end
    btnClear.DoClick = function()
        if not IsValid(box.entry) then return end
        box.entry:SetText("")
        if isfunction(opts.onClear) then opts.onClear() end
        if isfunction(opts.onChange) then opts.onChange("") end
    end

    local entry = vgui.Create("DTextEntry", box)
    entry:SetUpdateOnType(true)
    entry:SetText("")
    entry:SetFont(libNyx.ui.font(libNyx.ui.scale(18)))
    entry:SetTextColor(style.textColor)
    entry:SetCursorColor(style.textColor)
    entry:SetHistoryEnabled(false)
    if entry.SetDrawLanguageID then entry:SetDrawLanguageID(false) end
    box.entry = entry

    function box:PerformLayout(w,h)
        local leftPad  = libNyx.ui.scale(12) + libNyx.ui.scale(16) + libNyx.ui.scale(8)
        local rightPad = btnClear:GetWide() + libNyx.ui.scale(6)
        entry:SetPos(leftPad, 0)
        entry:SetSize(w - leftPad - rightPad, h)
    end

    function entry:Paint(w,h)
        self:DrawTextEntryText(style.textColor, Color(255,255,255,20), style.textColor)
    end

    function entry:OnChange()
        if not isfunction(opts.onChange) then return end
        timer.Create(box.searchTimerName, box.debounce, 1, function()
            if IsValid(box) and IsValid(box.entry) then
                opts.onChange(box.entry:GetText() or "")
            end
        end)
    end

    function entry:OnEnter()
        if isfunction(opts.onSubmit) then opts.onSubmit(self:GetText() or "") end
    end

    function entry:OnGetFocus()
        box.focused = true
    end

    function entry:OnLoseFocus()
        box.focused = false
    end

    local function expApproach(cur, tgt, spd)
        local k = 1 - math.exp(-(spd or 10) * FrameTime())
        return cur + (tgt - cur) * k
    end

    local function isCyrillicChar(ch)
        if not ch or ch == "" then return false end
        if utf8 and utf8.codepoint then
            local cp = utf8.codepoint(ch)
            if cp then
                if (cp >= 0x0400 and cp <= 0x04FF) or (cp >= 0x0500 and cp <= 0x052F) then return true end
            end
        end
        return false
    end

    box.Think = function(self)
        local f = self.focused and 1 or 0
        self.focusAlpha = expApproach(self.focusAlpha, f, 9)
        local id
        if entry.GetLanguageID then
            id = entry:GetLanguageID()
            if isstring(id) and #id >= 2 then
                id = string.upper(string.sub(id,1,2))
            else
                id = nil
            end
        end
        if not id then
            local t = entry:GetText() or ""
            if t ~= self.lastText then
                self.lastText = t
                local len = (utf8 and utf8.len and utf8.len(t)) or #t
                if len > 0 and utf8 and utf8.sub then
                    local ch = utf8.sub(t, len, len)
                    if isCyrillicChar(ch) then
                        id = "RU"
                    end
                end
            end
        end
        if id then self.languageId = id end
    end

    function box:Paint(w, h)
        libNyx.ui.draw.panel(0, 0, w, h, {radius = self.radius, color = Color(18, 22, 30, 120)})
        local borderColor = Color(255, 255, 255, 18)
        if self.focusAlpha > 0.001 then
            borderColor = Color(
                Lerp(self.focusAlpha, borderColor.r, self.tint.r),
                Lerp(self.focusAlpha, borderColor.g, self.tint.g),
                Lerp(self.focusAlpha, borderColor.b, self.tint.b),
                Lerp(self.focusAlpha, 18, 180)
            )
        end
        rndx.DrawOutlined(self.radius, 0, 0, w, h, borderColor, math.max(1, math.floor(1 + self.focusAlpha)), 0)
        local ic = libNyx.ui.scale(16)
        local ix = libNyx.ui.scale(12)
        surface.SetDrawColor(style.textColor.r, style.textColor.g, style.textColor.b, 190)
        surface.SetMaterial(searchIconMaterial)
        surface.DrawTexturedRect(ix, (h - ic) / 2, ic, ic)
        if (entry:GetText() == "" or entry:GetText() == nil) and not entry:HasFocus() then
            draw.SimpleText(self.placeholder, libNyx.ui.font(libNyx.ui.scale(18)), ix + ic + libNyx.ui.scale(8), h / 2, Color(255, 255, 255, 120), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        if entry:HasFocus() then
            local code = self.languageId or "EN"
            local showRU = code == "RU"
            local rightPad = btnClear:GetWide() + libNyx.ui.scale(6)
            local rx = w - rightPad - libNyx.ui.scale(6)
            if showRU then
                local ph = libNyx.ui.scale(18)
                local px = rx - libNyx.ui.scale(4)
                local py = (h - ph) / 2
                local pw = libNyx.ui.scale(28)
                libNyx.ui.draw.panel(px - pw, py, pw, ph, {radius = ph/2, color = Color(30,34,42,160)})
                draw.SimpleText("RU", libNyx.ui.font(libNyx.ui.scale(14)), px - pw/2, h/2, style.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                draw.SimpleText(code, libNyx.ui.font(libNyx.ui.scale(14)), rx, h/2, Color(255,255,255,150), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end
    end

    function box:getText() return entry:GetText() end
    function box:setText(t) entry:SetText(t or "") end
    function box:focus() entry:RequestFocus() end
    function box:OnRemove()
        timer.Remove(self.searchTimerName)
    end
    return box
end

libNyx.ui.smoothScroll = libNyx.ui.smoothScroll or {}

function libNyx.ui.smoothScroll.applyToScrollPanel(sp, opts)
    if not IsValid(sp) or sp.libNyxSmoothInstalled then return end
    local vbar = sp:GetVBar()
    if not IsValid(vbar) then return end
    sp.libNyxSmoothInstalled = true
    local step = tonumber(opts and opts.step) or libNyx.ui.scale(90)
    local speed = tonumber(opts and opts.speed) or 18
    local fadeHold = tonumber(opts and opts.fadeHold) or 0.9
    local barW = tonumber(opts and opts.width) or libNyx.ui.scale(12)
    local r = libNyx.ui.scale(6)
    vbar:SetWide(barW)
    vbar.btnUp:SetTall(0)
    vbar.btnDown:SetTall(0)
    vbar.btnUp:SetVisible(false)
    vbar.btnDown:SetVisible(false)
    sp.scrollState = sp.scrollState or {}
    sp.scrollState.cur = vbar:GetScroll()
    sp.scrollState.tgt = sp.scrollState.cur
    sp.scrollState.visA = 0
    sp.scrollState.lastPing = 0
    sp.scrollState.drag = false

    local function expApproach(cur, tgt, spd)
        local k = 1 - math.exp(-(spd) * FrameTime())
        return cur + (tgt - cur) * k
    end
    local function maxScroll()
        local can = IsValid(sp:GetCanvas()) and sp:GetCanvas():GetTall() or 0
        return math.max(0, can - sp:GetTall())
    end
    local function ping()
        sp.scrollState.lastPing = CurTime()
    end

    local oldAddScroll = vbar.AddScroll
    vbar.AddScroll = function(self, dlta)
        local m = maxScroll()
        sp.scrollState.tgt = math.Clamp(sp.scrollState.tgt + dlta * step, 0, m)
        ping()
    end

    local oldOnMousePressed = vbar.OnMousePressed
    vbar.OnMousePressed = function(self, mc)
        sp.scrollState.drag = true
        if isfunction(oldOnMousePressed) then oldOnMousePressed(self, mc) end
        ping()
    end
    local oldOnMouseReleased = vbar.OnMouseReleased
    vbar.OnMouseReleased = function(self, mc)
        sp.scrollState.drag = false
        if isfunction(oldOnMouseReleased) then oldOnMouseReleased(self, mc) end
        ping()
    end
    if IsValid(vbar.btnGrip) then
        local og = vbar.btnGrip.OnMousePressed
        vbar.btnGrip.OnMousePressed = function(s, mc)
            sp.scrollState.drag = true
            if isfunction(og) then og(s, mc) end
            ping()
        end
        local org = vbar.btnGrip.OnMouseReleased
        vbar.btnGrip.OnMouseReleased = function(s, mc)
            sp.scrollState.drag = false
            if isfunction(org) then org(s, mc) end
            ping()
        end
    end

    local gradientLeftMaterial = Material("vgui/gradient-l", "noclamp smooth")
    vbar.Paint = function(s, w, h)
        local a = math.floor(130 * sp.scrollState.visA)
        if a <= 0 then return end
        libNyx.ui.draw.panel(0, 0, w, h, {radius = r, color = Color(36,36,44, a)})
    end
    vbar.btnUp.Paint = function() end
    vbar.btnDown.Paint = function() end
    vbar.btnGrip.Paint = function(s, w, h)
        local a = math.floor(200 * sp.scrollState.visA)
        if a <= 4 then return end
        libNyx.ui.draw.panel(0, 0, w, h, {radius = r, color = Color(24,28,36, a + 35), stroke = true, strokeColor = Color(255,255,255, 16)})
        if not gradientLeftMaterial:IsError() then
            local c = style.accentColor
            local g = Color(c.r, c.g, c.b, math.Clamp(110 + math.floor(100 * sp.scrollState.visA), 80, 200))
            rndx.DrawMaterial(r, 0, 0, w, h, g, gradientLeftMaterial, 0)
        end
    end

    local oldThink = sp.Think
    sp.Think = function(self)
        if isfunction(oldThink) then oldThink(self) end
        local m = maxScroll()
        sp.scrollState.tgt = math.Clamp(sp.scrollState.tgt, 0, m)
        if sp.scrollState.drag then
            sp.scrollState.cur = vbar:GetScroll()
            sp.scrollState.tgt = sp.scrollState.cur
        else
            sp.scrollState.cur = expApproach(sp.scrollState.cur, sp.scrollState.tgt, speed)
            if math.abs(sp.scrollState.cur - sp.scrollState.tgt) <= 0.25 then
                sp.scrollState.cur = sp.scrollState.tgt
            end
            if math.abs(sp.scrollState.cur - vbar:GetScroll()) > 0.01 then
                vbar:SetScroll(sp.scrollState.cur)
            end
        end
        local want = 0
        if vbar:IsHovered() or (IsValid(vbar.btnGrip) and vbar.btnGrip:IsHovered()) or sp.scrollState.drag or (CurTime() - sp.scrollState.lastPing) < fadeHold then
            want = 1
        end
        sp.scrollState.visA = expApproach(sp.scrollState.visA, want, 12)
    end
end

function libNyx.ui.smoothScroll.installUnder(root, opts)
    if not IsValid(root) then return end
    local function apply(p)
        if not IsValid(p) then return end
        if isfunction(p.GetVBar) and IsValid(p:GetVBar()) and p:GetVBar().SetUp then
            libNyx.ui.smoothScroll.applyToScrollPanel(p, opts)
        end
        for _, ch in ipairs(p:GetChildren()) do apply(ch) end
        local old = p.OnChildAdded
        p.OnChildAdded = function(s, child)
            if isfunction(old) then old(s, child) end
            apply(child)
        end
    end
    apply(root)
end

function libNyx.ui.installGlobalScroll(root, opts)
    libNyx.ui.smoothScroll.installUnder(root, opts)
end

local function menuScale(value) return libNyx.ui.scale and libNyx.ui.scale(value) or value end
local function menuFont(size) return libNyx.ui.font and libNyx.ui.font(size) or "DermaDefault" end
local function lerpExp(cur, tgt, speed)
    local k = 1 - math.exp(-(speed or 14) * FrameTime())
    return cur + (tgt - cur) * k
end

libNyx.menuSkinInstalled = libNyx.menuSkinInstalled or false
function libNyx.ui.installGlobalMenuSkin(opt)
    if libNyx.menuSkinInstalled then return end
    opt = opt or {}

    local menuStyle = libNyx.ui.style or {}
    local radius        = opt.radius        or menuStyle.radius or 10
    local fill          = opt.fill          or Color(16,18,24, 210)
    local stroke        = opt.stroke        or menuStyle.glassStroke or Color(255,255,255, 22)
    local textColor     = opt.textColor     or Color(235,235,240)
    local rowHover      = opt.rowHover      or Color(255,255,255, 10)
    local rowActive     = opt.rowActive     or Color(255,255,255, 16)
    local fontObj       = opt.font and (type(opt.font)=="function" and opt.font() or opt.font) or menuFont(menuScale(16))
    local padding       = opt.padding       or menuScale(4)

    local function styleMenuTable()
        local T = vgui.GetControlTable("DMenu")
        if T then
            T.Paint = function(self, w, h)
                if libNyx.ui.draw and libNyx.ui.draw.panel then
                    libNyx.ui.draw.panel(0, 0, w, h, {
                        radius = menuScale(radius),
                        fill   = fill,
                        stroke = true,
                        strokeColor = stroke,
                    })
                else
                    draw.RoundedBox(menuScale(radius), 0, 0, w, h, fill)
                    surface.SetDrawColor(stroke)
                    surface.DrawOutlinedRect(0, 0, w, h)
                end
            end
            local oldPerform = T.PerformLayout
            T.PerformLayout = function(self, ...)
                self:SetPadding(padding)
                if oldPerform then oldPerform(self, ...) end
                self:SizeToContents()
            end
        end

        local O = vgui.GetControlTable("DMenuOption")
        if O then
            local oldSetText = O.SetText
            O.SetText = function(self, txt)
                oldSetText(self, txt)
                self:SetFont(fontObj)
                self:SetTextColor(textColor)
            end
            O.Paint = function(self, w, h)
                self.nyxHover = lerpExp(self.nyxHover or 0, self:IsHovered() and 1 or 0, 18)
                local a = self.nyxHover or 0
                local r = menuScale(6)
                local c = Color(rowHover.r, rowHover.g, rowHover.b, math.floor(rowHover.a * a))
                if libNyx.ui.draw and libNyx.ui.draw.panel then
                    libNyx.ui.draw.panel(2, 1, w-4, h-2, {
                        radius = r,
                        color  = c,
                        stroke = false
                    })
                else
                    draw.RoundedBox(r, 2, 1, w-4, h-2, c)
                end
                if self.m_bSelected or self:GetToggle() then
                    local act = Color(rowActive.r, rowActive.g, rowActive.b, rowActive.a)
                    if libNyx.ui.draw and libNyx.ui.draw.panel then
                        libNyx.ui.draw.panel(2, 1, w-4, h-2, {radius = r, color = act})
                    else
                        draw.RoundedBox(r, 2, 1, w-4, h-2, act)
                    end
                end
                return false
            end
        end
        local D = vgui.GetControlTable("DMenuDivider")
        if D then
            D.Paint = function(self, w, h)
                surface.SetDrawColor(255,255,255, 18)
                surface.DrawRect(menuScale(8), math.floor(h*0.5), w - menuScale(16), 1)
            end
            D.GetSpacing = function() return menuScale(6) end
        end
    end
    if vgui.GetControlTable("DMenu") then
        styleMenuTable()
    else
        timer.Simple(0, styleMenuTable)
    end

    libNyx.menuSkinInstalled = true
end

do
    local style     = libNyx.ui.style
    local scaleValue     = libNyx.ui.scale
    local fontValue      = libNyx.ui.font
    local drawPanel = libNyx.ui.draw and libNyx.ui.draw.panel
    local darkColor      = (style and (style.panelColor or Color(20,22,30,130))) or Color(20,22,30,130)

    local notifyGeneric = 0
    local notifyError = 1
    local notifyUndo = 2
    local notifyHint = 3
    local notifyCleanup = 4

    local notificationIcons = {
        info   = Material("icon16/information.png","noclamp smooth"),
        ok     = Material("icon16/accept.png","noclamp smooth"),
        undo   = Material("icon16/arrow_undo.png","noclamp smooth"),
        error  = Material("icon16/exclamation.png","noclamp smooth"),
        broom  = Material("icon16/bin.png","noclamp smooth"),
        mail   = Material("icon16/email.png","noclamp smooth"),
        box    = Material("icon16/box.png","noclamp smooth"),
        star   = Material("icon16/star.png","noclamp smooth"),
    }

    local notificationTypes = {
        [notifyGeneric] = { icon = notificationIcons.info  },
        [notifyError]   = { icon = notificationIcons.error },
        [notifyUndo]    = { icon = notificationIcons.undo  },
        [notifyHint]    = { icon = notificationIcons.star  },
        [notifyCleanup] = { icon = notificationIcons.broom },
    }

    local function pickIcon(msg, fallback)
        local m = string.lower(tostring(msg or ""))
        if m:find("mail",1,true) or m:find("letter",1,true) or m:find("письм",1,true) then return notificationIcons.mail end
        if m:find("parcel",1,true) or m:find("package",1,true) or m:find("посылк",1,true) then return notificationIcons.box end
        return fallback or notificationIcons.info
    end

    libNyx.ui.notifyState = libNyx.ui.notifyState or {}

    local function getNotificationLayer()
        if IsValid(libNyx.ui.notifyState.layer) then return libNyx.ui.notifyState.layer end
        if not vgui or not vgui.Create or not vgui.GetControlTable or not vgui.GetControlTable("DPanel") then return nil end
        if not vgui.GetWorldPanel or not IsValid(vgui.GetWorldPanel()) then return nil end

        local L = vgui.Create("DPanel")
        if not IsValid(L) then return nil end

        L:SetZPos(32767)
        L:SetDrawOnTop(true)
        L:SetMouseInputEnabled(false)
        L:SetKeyboardInputEnabled(false)
        L:SetSize(ScrW(), ScrH())
        L:SetPos(0,0)
        libNyx.ui.disableBackground(L)
        L.list = {}
        function L:relayout()
            local padR = scaleValue(24)
            local gap  = scaleValue(8)
            local total = 0
            for i = 1, #self.list do
                local p = self.list[i]
                if IsValid(p) then
                    total = total + p:GetTall()
                    if i < #self.list then total = total + gap end
                end
            end
            local y = math.max(scaleValue(14), math.floor(ScrH()*0.5 - total*0.5))
            for i = 1, #self.list do
                local p = self.list[i]
                if IsValid(p) then
                    local x = ScrW() - padR - p:GetWide()
                    if p.spawned then
                        p:SetPos(x, y)
                        p.spawned = nil
                    else
                        p:MoveTo(x, y, 0.15, 0, 0.2)
                    end
                    y = y + p:GetTall() + gap
                end
            end
        end
        hook.Add("OnScreenSizeChanged","libNyx.notify.relayout",function()
            if not IsValid(L) then return end
            L:SetSize(ScrW(),ScrH())
            L:SetPos(0,0)
            L:relayout()
        end)
        libNyx.ui.notifyState.layer = L
        return L
    end

    local function createToast(text, icon, life)
        local L = getNotificationLayer()
        if not IsValid(L) then return nil end

        local p = vgui.Create("DButton", L)
        if not IsValid(p) then return nil end
        p:SetText("")
        p:SetDrawOnTop(true)
        p:SetZPos(32766)
        p:SetMouseInputEnabled(true)
        p:SetKeyboardInputEnabled(false)
        p.icon   = icon or pickIcon(text, notificationIcons.info)
        p.lifetime   = math.max(0.5, tonumber(life) or 4)
        p.killAt = SysTime() + p.lifetime
        p.fade   = 0
        p.slide  = 1
        p.spawned  = true

        local padX  = scaleValue(14)
        local h     = scaleValue(40)
        local iconW = scaleValue(22)
        local font  = fontValue(scaleValue(18))

        surface.SetFont(font)
        local tw = select(1, surface.GetTextSize(tostring(text or "")))
        local w  = math.Clamp(tw + padX*2 + iconW + scaleValue(14), scaleValue(220), math.floor(ScrW()*0.5))
        p:SetSize(w, h)

        function p:DoClick()
            self.killAt = SysTime() - 0.01
            surface.PlaySound("ui/buttonclickrelease.wav")
        end
        function p:OnCursorEntered()
            self.killAt = SysTime() + 1.2 + self.lifetime*0.25
            surface.PlaySound("buttons/lightswitch2.wav")
        end

        p.Think = function(s)
            local now = SysTime()
            local want = (s.killAt or now) > now and 1 or 0
            s.fade  = s.fade + (want - s.fade) * math.min(FrameTime()*16,1)
            s.slide = s.slide + ((want==1) and -s.slide or (1 - s.slide)) * math.min(FrameTime()*10,1)
            if s.fade <= 0.02 and want == 0 then
                s:Remove()
                for i=#L.list,1,-1 do if L.list[i]==s then table.remove(L.list,i) break end end
                L:relayout()
            end
        end

        p.Paint = function(s, w, h)
            local a = math.Clamp(s.fade or 0, 0, 1)
            if a <= 0.001 then return end
            local r = math.max(style.radius, scaleValue(10))
            local slide = math.floor(scaleValue(6) * (s.slide or 0))
            if rndx and rndx.EnsureFB then rndx.EnsureFB() end
            if drawPanel then
                drawPanel(0,0,w,h,{radius=r,color=Color(darkColor.r,darkColor.g,darkColor.b, math.floor(95*a))})
            end
            if rndx and rndx().Liquid then
                rndx().Liquid(0,0,w,h)
                    :Rad(r)
                    :Strength(0.014)
                    :Speed(0.35)
                    :Saturation(1.06)
                    :Tint(20,24,32)
                    :TintStrength(0.10)
                    :Shimmer(22.0)
                    :Grain(0.005)
                    :Alpha(0.95*a)
                    :GlassBlur(0.02,0.38)
                    :EdgeSmooth(2.0)
                    :Draw()
            end
            if drawPanel then
                local sheenH = math.max(1, math.floor(h*0.26))
                local sw = math.max(1, w - scaleValue(16))
                drawPanel(scaleValue(8), scaleValue(6), sw, sheenH, {radius=math.floor(r*0.8), color=Color(255,255,255, math.floor(10*a))})
            end
            draw.SimpleText(
                tostring(text or ""),
                font,
                padX, h/2 + slide*0.25,
                Color(style.textColor.r,style.textColor.g,style.textColor.b, math.floor(255*a)),
                TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
            )
            if s.icon and not s.icon:IsError() then
                local ic = iconW
                surface.SetDrawColor(255,255,255, math.floor(255*a))
                surface.SetMaterial(s.icon)
                surface.DrawTexturedRect(w - padX - ic, (h - ic)/2, ic, ic)
            end
        end

        table.insert(L.list, 1, p)
        L:relayout()
        return p
    end

    function libNyx.ui.pushNotify(msg, typeOrColor, len, icon)
        local t = notificationTypes[tonumber(typeOrColor) or notifyGeneric] or notificationTypes[notifyGeneric]
        local ico = icon or pickIcon(msg, t.icon)
        return createToast(msg, ico, len)
    end

    if not libNyx.ui.notificationSkinInstalled then
        libNyx.ui.notificationSkinInstalled = true
        libNyx.ui.originalNotification = libNyx.ui.originalNotification or {}
        libNyx.ui.originalNotification.AddLegacy   = notification.AddLegacy
        libNyx.ui.originalNotification.AddProgress = notification.AddProgress
        libNyx.ui.originalNotification.Kill        = notification.Kill

        notification.AddLegacy = function(txt, kind, length)
            libNyx.ui.pushNotify(txt, kind, length)
        end

        local progress = {}
        notification.AddProgress = function(id, txt, frac)
            if not IsValid(progress[id]) then
                local row = createToast(txt, notificationIcons.info, 9999)
                if not IsValid(row) then return id end
                row.progress = 0
                row.PaintOver = function(s, w, h)
                    if not s.progress then return end
                    local pad = scaleValue(8)
                    local ph  = scaleValue(4)
                    local pw  = math.floor((w - pad*2) * math.Clamp(s.progress, 0, 1))
                    if drawPanel then
                        drawPanel(pad, h - ph - pad, w - pad*2, ph, {radius = ph/2, color = Color(40,44,52,150)})
                        if pw > 1 then
                            drawPanel(pad, h - ph - pad, pw, ph, {radius = ph/2, color = Color(style.accentColor.r,style.accentColor.g,style.accentColor.b,190)})
                        end
                    end
                end
                progress[id] = row
            end
            progress[id].progress = tonumber(frac) or 0
            return id
        end

        notification.Kill = function(id)
            local p = progress[id]
            if IsValid(p) then p.killAt = SysTime() - 0.01 end
            progress[id] = nil
        end

        local function patchGamemode()
            local gm = gmod and gmod.GetGamemode and gmod.GetGamemode()
            if not gm or gm.nyxAddNotifyPatched then return end
            gm.nyxAddNotifyPatched = true
            gm.nyxOriginalAddNotify = gm.AddNotify
            function gm:AddNotify(txt, kind, length)
                libNyx.ui.pushNotify(txt, kind, length)
            end
        end

        timer.Simple(0, patchGamemode)
        hook.Add("OnGamemodeLoaded","libNyx.notify.patchGamemode",patchGamemode)
        hook.Add("DarkRPFinishedLoading","libNyx.notify.patchGamemode",patchGamemode)
    end

    function libNyx.ui.installGlobalNotificationSkin()
        return IsValid(getNotificationLayer())
    end

end
