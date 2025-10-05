-- libNyx by MaryBlackfild
-- JOIN DISCORD: https://discord.gg/rUEEz4mfXw

-- supp library - rndx

if SERVER then
    AddCSLuaFile()
    return
end

local libNyx = libNyx or {}
libNyx.UI = libNyx.UI or {}
_G.libNyx = libNyx

local RNDX = include("libnyx/lib/rndx.lua")


local cvarScale = CreateClientConVar("cl_libnyx_ui_scale", "0", true, false, "UI scale for libNyx (0 = auto).", 0, 2)
local BASE_H = 1080
local _scale = 1.0

local function ComputeScale()
    local manual = tonumber(cvarScale:GetString()) or 0
    if manual > 0 then
        return math.Clamp(manual, 0.50, 2.00)
    end
    return math.Clamp(ScrH() / BASE_H, 0.90, 1.40)
end
local function RecomputeScale()
    _scale = ComputeScale()
    local S = libNyx.UI.Style
    S.radius          = math.floor(12 * _scale)
    S.padding         = math.floor(14 * _scale)
    S.iconSize        = math.floor(24 * _scale)
    S.btnHeight       = math.floor(44 * _scale)
    S.rowHeight       = math.floor(82 * _scale)
    S.shadowSpread    = math.floor(22 * _scale)
    S.shadowIntensity = math.floor(36 * _scale)
    S.strokeWidth     = math.max(1, math.floor(1 * _scale))
    S.headerIndentX   = math.floor(24 * _scale)
    S.headerIndentY   = math.floor(24 * _scale)
    S.comboItemH      = math.floor(34 * _scale)
end
function libNyx.UI.Scale(n) return math.floor((tonumber(n) or 0) * _scale) end

local Style = {
    bgColor        = Color(10,10,14,150),
    panelColor     = Color(16,18,24,120),
    cardColor      = Color(20,22,30,130),
    accentColor    = Color(90,160,255),
    hoverColor     = Color(52,58,70,120),
    textColor      = Color(245,245,250),
    glassFill      = Color(20,24,32,110),
    glassStroke    = Color(255,255,255,22),
    blurIntensity  = 1.0,
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
libNyx.UI.Style = Style
RecomputeScale()

local baseFont = "Manrope"
local function hasSystemFont(name)
    local testName = ("libNyx.FontCheck.%s"):format(name)
    surface.CreateFont(testName, {font = name, size = 12, weight = 400, extended = true})
    surface.SetFont(testName)
    local w, h = surface.GetTextSize("Aa")
    return (w or 0) > 0 and (h or 0) > 0
end
if not hasSystemFont(baseFont) then baseFont = "Tahoma" end

local fontCache = {}
for sz = 10, 200 do
    local key = ("libNyx.%s.%d"):format(baseFont, sz)
    surface.CreateFont(key, {
        font = baseFont,
        size = sz,
        weight = (sz >= 28) and 500 or 400,
        extended = true
    })
    fontCache[sz] = key
end
function libNyx.UI.Font(size)
    size = math.Clamp(math.floor(tonumber(size) or 14), 10, 200)
    return fontCache[size]
end

local MAT_GRADIENT_L = Material("vgui/gradient-l", "noclamp smooth")

local GRAD_PALETTE = {
    Color( 90,160,255),
    Color(255,125,155),
    Color(120,220,160),
    Color(255,200,120),
    Color(170,120,255),
    Color(120,200,255),
}
local function PalettePick(key)
    key = tostring(key or "")
    local sum = 0
    for i = 1, #key do sum = sum + key:byte(i) end
    local idx = (sum % #GRAD_PALETTE) + 1
    return GRAD_PALETTE[idx]
end

libNyx.UI.Sounds = {
    hover = "nyx_uniqueui/nyxclick_2.wav",
    click = "nyx_uniqueui/nyxclick_3.wav"
}

function libNyx.UI.PlayHover()
    surface.PlaySound(libNyx.UI.Sounds.hover)
end

function libNyx.UI.PlayClick()
    surface.PlaySound(libNyx.UI.Sounds.click)
end

if not libNyx.UI._sfxRedirected then
    local _PlaySound = surface.PlaySound
    function surface.PlaySound(snd)
        if snd == "buttons/lightswitch2.wav" then
            snd = (libNyx.UI.Sounds and libNyx.UI.Sounds.hover) or snd
        elseif snd == "ui/buttonclick.wav" or snd == "ui/buttonclickrelease.wav" then
            snd = (libNyx.UI.Sounds and libNyx.UI.Sounds.click) or snd
        end
        return _PlaySound(snd)
    end
    libNyx.UI._sfxRedirected = true
end

libNyx.UI.Draw = {}

function libNyx.UI.Draw.Glass(x, y, w, h, opts)
    opts = opts or {}
    local r      = opts.radius or Style.radius
    local fill   = opts.fill or Style.glassFill
    local stroke = opts.stroke ~= false and (opts.strokeColor or Style.glassStroke)
    local flags  = opts.shape and opts.shape or 0
    local blurI  = tonumber(opts.blurIntensity) or Style.blurIntensity
    local T = RNDX()
    T.Rect(x, y, w, h):Rad(r):Blur(blurI):Draw()
    RNDX.Draw(r, x, y, w, h, fill, flags)
    if stroke then
        RNDX.DrawOutlined(r, x, y, w, h, stroke, Style.strokeWidth, flags)
    end
end

function libNyx.UI.CreateFrame(opts)
    opts = opts or {}
    local Style = libNyx.UI.Style
    local W = math.max(tonumber(opts.w) or 900, libNyx.UI.Scale(240))
    local H = math.max(tonumber(opts.h) or 620, libNyx.UI.Scale(200))
    local title = tostring(opts.title or "")
    local f = vgui.Create("DFrame")
    f:SetTitle("")
    f:ShowCloseButton(false)
    f:SetSizable(false)
    f:MakePopup()
    f._targetW = W
    f._targetH = H
    f._minW = math.max(2, math.floor(W * 0.12))
    f._minH = math.max(2, math.floor(H * 0.12))
    f._overshoot = 1.04
    f._durOpen = 0.22
    f._durClose = 0.18
    f._phase = "opening"
    f._t0 = SysTime()
    f._contentAlpha = 0
    f._title = title
    local cx, cy = ScrW() * 0.5, ScrH() * 0.5
    f:SetSize(f._minW, f._minH)
    f:SetPos(cx - f._minW/2, cy - f._minH/2)
    local function easeOutBack(t)
        local c1 = 1.70158
        local c3 = c1 + 1
        local u = t - 1
        return 1 + c3 * (u * u * u) + c1 * (u * u)
    end
    local function easeInCubic(t) return t * t * t end
    local function expApproach(cur, tgt, spd)
        local k = 1 - math.exp(-(spd or 10) * FrameTime())
        return cur + (tgt - cur) * k
    end
    local function applyContentAlpha(self, a)
        a = math.Clamp(math.floor(a or 0), 0, 255)
        for _, ch in ipairs(self:GetChildren()) do
            if IsValid(ch) then ch:SetAlpha(a) end
        end
    end
    function f:OnChildAdded(pnl)
        pnl:SetAlpha(math.floor(self._contentAlpha or 0))
    end
    local closeBtn
    if libNyx.UI.Components and libNyx.UI.Components.CreateButton then
        closeBtn = libNyx.UI.Components.CreateButton(f, "✕", {variant="ghost", align="center", radius=Style.radius})
        closeBtn:SetSize(libNyx.UI.Scale(40), libNyx.UI.Scale(40))
        closeBtn._onClick = function() f:Close() end
    else
        closeBtn = vgui.Create("DButton", f)
        closeBtn:SetText("✕")
        closeBtn:SetSize(libNyx.UI.Scale(40), libNyx.UI.Scale(40))
        closeBtn.DoClick = function() f:Close() end
    end
    function f:PerformLayout(w, h)
        closeBtn:SetPos(w - Style.headerIndentX - closeBtn:GetWide(), Style.headerIndentY)
    end
    function f:Think()
        local now = SysTime()
        if self._phase == "opening" then
            local t = math.TimeFraction(self._t0, self._t0 + self._durOpen, now)
            if t >= 1 then
                self._phase = "idle"
                self:SetSize(self._targetW, self._targetH)
                self:Center()
                self._contentAlpha = 255
                applyContentAlpha(self, self._contentAlpha)
                self:SetMouseInputEnabled(true)
                self:SetKeyboardInputEnabled(true)
            else
                local e = easeOutBack(t)
                local ow, oh = self._targetW * self._overshoot, self._targetH * self._overshoot
                local w, h = Lerp(e, self._minW, ow), Lerp(e, self._minH, oh)
                if t > 0.85 then
                    local t2 = math.TimeFraction(0.85, 1.0, t)
                    local e2 = 1 - (1 - t2) * (1 - t2)
                    w = Lerp(e2, ow, self._targetW)
                    h = Lerp(e2, oh, self._targetH)
                end
                self:SetSize(math.max(1, w), math.max(1, h))
                self:SetPos(cx - w/2, cy - h/2)
                self._contentAlpha = expApproach(self._contentAlpha or 0, 255 * math.Clamp(t ^ 1.6, 0, 1), 16)
                applyContentAlpha(self, self._contentAlpha)
                self:SetMouseInputEnabled(false)
                self:SetKeyboardInputEnabled(false)
            end
        elseif self._phase == "closing" then
            local t = math.TimeFraction(self._t0, self._t0 + self._durClose, now)
            if t >= 1 then
                self:Remove()
            else
                local e = easeInCubic(t)
                local w = Lerp(e, self._targetW, self._minW)
                local h = Lerp(e, self._targetH, self._minH)
                self:SetSize(math.max(1, w), math.max(1, h))
                self:SetPos(cx - w/2, cy - h/2)
                self._contentAlpha = expApproach(self._contentAlpha or 255, 0, 18)
                applyContentAlpha(self, self._contentAlpha)
            end
        end
    end
    function f:Paint(w, h)
        local r = math.max(Style.radius, libNyx.UI.Scale(14))
        libNyx.UI.Draw.Glass(0, 0, w, h, {radius = r, fill = Style.bgColor, stroke = true, strokeColor = Style.glassStroke, blurIntensity = 1.1})
        if self._title ~= "" then
            draw.SimpleText(self._title, libNyx.UI.Font(libNyx.UI.Scale(30)), Style.headerIndentX, Style.headerIndentY, Style.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
    end
    local realRemove = f.Remove
    function f:Close()
        if self._phase == "closing" then return end
        self._phase = "closing"
        self._t0 = SysTime()
        self:SetMouseInputEnabled(false)
        self:SetKeyboardInputEnabled(false)
    end
    function f:Remove()
        if self._phase ~= "closing" and self._phase ~= "idle" then return end
        realRemove(self)
    end
    return f
end



function libNyx.UI.Draw.Panel(x, y, w, h, opts)
    opts = opts or {}
    local r        = opts.radius or Style.radius
    local col      = opts.color or Style.cardColor
    local doShadow = opts.shadow == true
    local flags    = opts.shape or 0
    if opts.glass == true or opts.blur == true then
        libNyx.UI.Draw.Glass(x, y, w, h, {
            radius = r,
            fill = col,
            stroke = opts.stroke,
            strokeColor = opts.strokeColor,
            shape = flags,
            blurIntensity = opts.blurIntensity or Style.blurIntensity
        })
        return
    end
    if doShadow then
        RNDX.DrawShadows(r, x, y, w, h, Color(0,0,0, 190), Style.shadowSpread, Style.shadowIntensity, flags)
    end
    RNDX.Draw(r, x, y, w, h, col, flags)
    if opts.outline then
        RNDX.DrawOutlined(r, x, y, w, h, opts.outlineColor or Style.glassStroke, opts.outline, flags)
    end
end

libNyx.UI.Components = libNyx.UI.Components or {}
local Components = libNyx.UI.Components

libNyx.UI._fx = libNyx.UI._fx or nil
local function FX()
    if IsValid(libNyx.UI._fx) then return libNyx.UI._fx end
    local pnl = vgui.Create("DPanel")
    pnl:SetZPos(32767)
    pnl:SetMouseInputEnabled(false)
    pnl:SetKeyboardInputEnabled(false)
    pnl:SetSize(ScrW(), ScrH())
    pnl:SetPos(0,0)
    pnl._anims = {}
    pnl.Paint = function(s,w,h)
        local now = SysTime()
        for i = #s._anims, 1, -1 do
            local a = s._anims[i]
            local t = math.TimeFraction(a.t0, a.t0 + a.dur, now)
            if t >= 1 then
                if isfunction(a.cb) then a.cb() end
                table.remove(s._anims, i)
            else
                local e = t < 0.5 and (4*t*t*t) or (1 - (-2*t+2)^3/2)
                local x = Lerp(e, a.sx, a.ex)
                local y = Lerp(e, a.sy, a.ey - a.arc*math.sin(t*math.pi))
                surface.SetDrawColor(255,255,255,255)
                surface.SetMaterial(a.mat)
                surface.DrawTexturedRect(x - a.size/2, y - a.size/2, a.size, a.size)
            end
        end
        if #s._anims == 0 then s:SetVisible(false) end
    end
    hook.Add("OnScreenSizeChanged","libNyx.UI.FX",function()
        if not IsValid(pnl) then return end
        pnl:SetSize(ScrW(), ScrH())
        pnl:SetPos(0,0)
    end)
    libNyx.UI._fx = pnl
    return pnl
end

function libNyx.UI.FlyIcon(mat, sx, sy, ex, ey, size, dur, cb)
    local fx = FX()
    fx:SetVisible(true)
    table.insert(fx._anims, {
        mat = mat, sx = sx, sy = sy, ex = ex, ey = ey,
        size = size or libNyx.UI.Scale(36),
        dur = dur or 0.35, t0 = SysTime(),
        arc = math.min(64, math.Distance(sx,sy,ex,ey)*0.25),
        cb = cb
    })
end

local function FitModel(mp)
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

function Components.CreateCell(parent, opts)
    opts = opts or {}
    local sz    = opts.size or libNyx.UI.Scale(88)
    local r     = opts.radius or libNyx.UI.Scale(14)
    local tint  = opts.tint or Style.accentColor

    local cell  = vgui.Create("DButton", parent)
    cell:SetText("")
    cell:SetSize(sz, sz)

    cell._radius    = r
    cell._tint      = tint
    cell._iconMat   = nil
    cell._iconSize  = math.floor(sz * 0.6)
    cell._mp        = nil
    cell._info      = nil
    cell._infoBox   = nil
    cell._lastScreenPos = {x = 0, y = 0}

    local function expApproach(cur, tgt, spd)
        local k = 1 - math.exp(-(spd or 10) * FrameTime())
        return cur + (tgt - cur) * k
    end

    local function normalizeTags(t)
        local out = {}
        if not istable(t) then return out end
        for _, v in ipairs(t) do
            if isstring(v) then
                out[#out+1] = {text = v, color = PalettePick(v)}
            elseif istable(v) then
                out[#out+1] = {
                    text  = tostring(v.text or v.label or v[1] or ""),
                    color = v.color or v.col or v[2] or PalettePick(v.text or v[1] or "?")
                }
            end
        end
        return out
    end

    local function removeInfoBox()
        if IsValid(cell._infoBox) then
            cell._infoBox:Remove()
            cell._infoBox = nil
        end
    end

    local function ensureInfoBox()
        if IsValid(cell._infoBox) then return cell._infoBox end
        if not cell._info then return nil end

        local ib = vgui.Create("DPanel")
        ib:SetDrawOnTop(true)
        ib:SetMouseInputEnabled(true)
        ib:SetKeyboardInputEnabled(false)

        ib._title = tostring(cell._info.title or "")
        ib._desc  = tostring(cell._info.desc or "")
        ib._tags  = normalizeTags(cell._info.tags)
        ib._tint  = cell._tint
        ib._state     = "opening"  -- opening | open | closing
        ib._t0        = SysTime()
        ib._durOpen   = 0.16
        ib._durClose  = 0.14
        ib._vis       = 0          -- 0..1 ease
        ib._hoverA    = 0

        surface.SetFont(libNyx.UI.Font(libNyx.UI.Scale(20)))
        local tw, th = surface.GetTextSize(ib._title ~= "" and ib._title or " ")
        surface.SetFont(libNyx.UI.Font(libNyx.UI.Scale(16)))
        local dw, dh = surface.GetTextSize(ib._desc ~= "" and ib._desc or " ")

        local pad   = libNyx.UI.Scale(12)
        local gap   = libNyx.UI.Scale(8)
        local tagH  = libNyx.UI.Scale(22)
        local ww    = math.max(libNyx.UI.Scale(240), tw + pad*2, dw + pad*2)
        local hh    = pad + th + (ib._desc ~= "" and (gap + dh) or 0) + ( (#ib._tags>0) and (gap + tagH) or 0 ) + pad

        ib:SetSize(ww, hh)

        local function place()
            local sx, sy = cell:LocalToScreen(0, 0)
            local cw, ch = cell:GetSize()
            local w,  h  = ib:GetSize()
            local x  = sx + cw + libNyx.UI.Scale(10)
            local y  = sy + math.floor((ch - h) * 0.5)
            x = math.min(x, ScrW() - w - libNyx.UI.Scale(8))
            y = math.Clamp(y, libNyx.UI.Scale(8), ScrH() - h - libNyx.UI.Scale(8))
            ib:SetPos(x, y)
        end
        place()

        -- smooth follow (in case layout shifts)
        ib.Think = function(s)
            local sx, sy = cell:LocalToScreen(0, 0)
            if sx ~= (cell._lastScreenPos.x or 0) or sy ~= (cell._lastScreenPos.y or 0) then
                place()
                cell._lastScreenPos.x, cell._lastScreenPos.y = sx, sy
            end

            -- hover amount for visual tuning (transparency + blur)
            local tgtH = s:IsHovered() and 1 or 0
            s._hoverA = expApproach(s._hoverA or 0, tgtH, 10)

            local now = SysTime()
            if s._state == "opening" then
                local t = math.TimeFraction(s._t0, s._t0 + s._durOpen, now)
                if t >= 1 then
                    s._state = "open"
                    s._vis = 1
                else
                    s._vis = 1 - (1 - t) * (1 - t)
                end
            elseif s._state == "closing" then
                local t = math.TimeFraction(s._t0, s._t0 + s._durClose, now)
                if t >= 1 then
                    s:Remove()
                    cell._infoBox = nil
                    return
                else
                    s._vis = 1 - (t * t * t)
                end
            else
                s._vis = expApproach(s._vis or 1, 1, 12)
                if (not cell:IsHovered()) and (not s:IsHovered()) then
                    s._state = "closing"
                    s._t0 = SysTime()
                end
            end
        end

        ib.Paint = function(s, w, h)
            local v = math.Clamp(s._vis or 0, 0, 1)

            local sc   = Lerp(v, 0.92, 1.00)
            local dx   = math.floor((w - w*sc) * 0.5)
            local dy   = math.floor((h - h*sc) * 0.5)
            local baseFillA = Lerp(s._hoverA or 0, 90, 70)
            local strokeA   = 20
            local fillCol   = Color(16,18,24, math.floor(baseFillA * v))
            local strokeCol = Color(255,255,255, math.floor(strokeA * v))
            local blurI     = 1.15 + 0.20 * (s._hoverA or 0)

            libNyx.UI.Draw.Glass(dx, dy, math.floor(w*sc), math.floor(h*sc), {
                radius        = libNyx.UI.Scale(10),
                fill          = fillCol,
                stroke        = true,
                strokeColor   = strokeCol,
                blurIntensity = blurI
            })

            local ca = math.floor(255 * v)
            local slide = math.floor(libNyx.UI.Scale(4) * (1 - v))

            -- Title
            surface.SetFont(libNyx.UI.Font(libNyx.UI.Scale(20)))
            draw.SimpleText(s._title or "", libNyx.UI.Font(libNyx.UI.Scale(20)),
                dx + libNyx.UI.Scale(12), dy + libNyx.UI.Scale(12) + slide,
                Color(Style.textColor.r, Style.textColor.g, Style.textColor.b, ca),
                TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            -- Desc
            if (s._desc or "") ~= "" then
                surface.SetFont(libNyx.UI.Font(libNyx.UI.Scale(16)))
                local _, th = surface.GetTextSize(s._title ~= "" and s._title or " ")
                draw.SimpleText(s._desc or "", libNyx.UI.Font(libNyx.UI.Scale(16)),
                    dx + libNyx.UI.Scale(12), dy + libNyx.UI.Scale(12) + th + libNyx.UI.Scale(6) + slide,
                    Color(255,255,255, math.floor(220 * v)),
                    TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end

            -- Tags row
            if #s._tags > 0 then
                local pad = libNyx.UI.Scale(12)
                local tagH = libNyx.UI.Scale(22)
                local chipR = libNyx.UI.Scale(8)
                local y = dy + h*sc - tagH - pad
                local x = dx + pad
                surface.SetFont(libNyx.UI.Font(libNyx.UI.Scale(14)))
                for _, tg in ipairs(s._tags) do
                    local t  = tg.text or ""
                    local tw = select(1, surface.GetTextSize(t))
                    local cw = tw + libNyx.UI.Scale(14)
                    libNyx.UI.Draw.Panel(x, y, cw, tagH, {
                        radius = chipR,
                        color  = Color((tg.color or Style.accentColor).r, (tg.color or Style.accentColor).g, (tg.color or Style.accentColor).b, math.floor(150 * v)),
                        glass  = true,
                        stroke = true,
                        strokeColor = Color(255,255,255, math.floor(16 * v))
                    })
                    draw.SimpleText(t, libNyx.UI.Font(libNyx.UI.Scale(14)),
                        x + cw/2, y + tagH/2,
                        Color(255,255,255, math.floor(240 * v)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    x = x + cw + libNyx.UI.Scale(6)
                end
            end
        end

        ib.OnCursorExited = function(s)
            if not cell:IsHovered() and s._state ~= "closing" then
                s._state = "closing"
                s._t0 = SysTime()
            end
        end

        cell._infoBox = ib
        return ib
    end

    function cell:SetItemIcon(mat, size, info)
        if isstring(mat) then mat = Material(mat, "noclamp smooth") end
        self._iconMat = mat
        if size then self._iconSize = size end
        self._info = info
        if IsValid(self._mp) then self._mp:Remove() self._mp = nil end
        removeInfoBox()
        self:InvalidateLayout(true)
    end

    function cell:SetItemModel(path)
        self._iconMat = nil
        if not IsValid(self._mp) then
            self._mp = vgui.Create("DModelPanel", self)
            self._mp:Dock(FILL)
            self._mp:DockMargin(libNyx.UI.Scale(6), libNyx.UI.Scale(6), libNyx.UI.Scale(6), libNyx.UI.Scale(6))
            self._mp:SetFOV(28)
            function self._mp:LayoutEntity(ent) end
        end
        self._mp:SetModel(path or "models/props_c17/oildrum001.mdl")
        removeInfoBox()
    end

    function cell:ClearItem()
        self._iconMat = nil
        if IsValid(self._mp) then self._mp:Remove() self._mp = nil end
        self._info = nil
        removeInfoBox()
        self:InvalidateLayout(false)
    end

    function cell:HasItem()
        return self._iconMat ~= nil or IsValid(self._mp)
    end

    function cell:GetCenterScreen()
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
        self._iconSize = math.floor(side * 0.6)
        self._lastScreenPos.x, self._lastScreenPos.y = -1, -1
    end

    function cell:OnCursorEntered()
        if self:HasItem() and self._info then
            local ib = ensureInfoBox()
            if IsValid(ib) and ib._state == "closing" then
                ib._state = "opening"
                ib._t0 = SysTime()
            end
        end
    end

    function cell:OnCursorExited()
        local ib = self._infoBox
        if IsValid(ib) and (not ib:IsHovered()) and ib._state ~= "closing" then
            ib._state = "closing"
            ib._t0 = SysTime()
        end
    end

    function cell:OnRemove()
        removeInfoBox()
    end

    cell.Paint = function(s, w, h)
        libNyx.UI.Draw.Glass(0, 0, w, h, {
            radius        = s._radius,
            fill          = Color(16,18,24,120),
            stroke        = true,
            strokeColor   = Style.glassStroke,
            blurIntensity = 1.05
        })

        if s._iconMat then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(s._iconMat)
            surface.DrawTexturedRect((w - s._iconSize)/2, (h - s._iconSize)/2, s._iconSize, s._iconSize)
        end
    end

    return cell
end



libNyx.UI._drag = libNyx.UI._drag or {active=false}

local function easeInOutCubic(t)
    if t < 0.5 then return 4*t*t*t end
    t = (t - 1); return 1 + 4*t*t*t
end

local function ensureDragHook()
    if libNyx.UI._drag._hooked then return end
    hook.Add("PostRenderVGUI", "zzz.libNyx.UI.DragOverlay", function()
        local d = libNyx.UI._drag
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
                    d.applyTo:SetItemIcon(d.mat, d.origIconSize, d.info)
                elseif IsValid(d.src) and d.mat then
                    d.src:SetItemIcon(d.mat, d.origIconSize, d.info)
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
        libNyx.UI.Draw.Glass(bx, by, boxSize, boxSize, {
            radius        = rad,
            fill          = Color(20,24,32, math.floor(120 * a)),
            stroke        = true,
            strokeColor   = Color(255,255,255, math.floor(22 * a)),
            blurIntensity = 1.25
        })
        if d.mat then
            surface.SetDrawColor(255, 255, 255, math.floor(255 * a))
            surface.SetMaterial(d.mat)
            surface.DrawTexturedRect(mx - iconSize/2, my - iconSize/2, iconSize, iconSize)
        end
        local tgt = vgui.GetHoveredPanel()
        while IsValid(tgt) and not tgt._isInteractiveCell do tgt = tgt:GetParent() end
        local S = libNyx.UI.Style
        if IsValid(tgt) and tgt._isInteractiveCell then
            local tx, ty = tgt:LocalToScreen(0, 0)
            d._tx, d._ty = tx, ty
            d._tw, d._th = tgt:GetWide(), tgt:GetTall()
            d._tr        = tgt._radius or S.radius
            d._talpha    = 1
        else
            d._talpha    = 0
        end
        local dt = FrameTime()
        local k  = 1 - math.pow(0.0001, dt * 60)
        local ka = 1 - math.pow(0.0001, dt * 45)
        d._hx = Lerp(k,  d._hx or d._tx or 0,  d._tx or (d._hx or 0))
        d._hy = Lerp(k,  d._hy or d._ty or 0,  d._ty or (d._hy or 0))
        d._hw = Lerp(k,  d._hw or d._tw or 0,  d._tw or (d._hw or 0))
        d._hh = Lerp(k,  d._hh or d._th or 0,  d._th or (d._hh or 0))
        d._hr = Lerp(k,  d._hr or d._tr or S.radius, d._tr or (d._hr or S.radius))
        d._ha = Lerp(ka, d._ha or 0, d._talpha or 0)
        if (d._ha or 0) > 0.01 and d._hx and d._hy and d._hw and d._hh then
            local acc = S.accentColor
            local x   = math.floor(d._hx + 0.5)
            local y   = math.floor(d._hy + 0.5)
            local w   = math.floor(d._hw + 0.5)
            local h   = math.floor(d._hh + 0.5)
            local r   = math.floor((d._hr or S.radius) + 0.5)
            local aL  = math.floor(210 * d._ha)
            local sw  = math.max(1, math.floor(1 + d._ha))
            RNDX.DrawOutlined(r, x, y, w, h, Color(acc.r, acc.g, acc.b, aL), sw, 0)
        end
    end)
    libNyx.UI._drag._hooked = true
end

function libNyx.UI.StartDragIcon(src, mat, size, offx, offy)
    if isstring(mat) then mat = Material(mat, "noclamp smooth") end
    local S    = libNyx.UI.Style
    local base = tonumber(size) or libNyx.UI.Scale(36)
    ensureDragHook()
    libNyx.UI._drag = {
        active       = true,
        src          = src,
        mat          = mat,
        origIconSize = base,
        offx         = offx or 0,
        offy         = offy or 0,

        info         = (IsValid(src) and src._info) or nil,

        phase    = "pickup",
        t0       = SysTime(),
        dur      = 0.16,
        boxFrom  = math.max(18, base * 0.88),
        boxTo    = base + libNyx.UI.Scale(18),
        radFrom  = math.max(4,  S.radius * 0.5),
        radTo    = math.floor(S.radius * 1.15),
        iconFrom = base * 0.92,
        iconTo   = base,
        _tx=nil,_ty=nil,_tw=nil,_th=nil,_tr=nil,_talpha=0,
        _hx=nil,_hy=nil,_hw=nil,_hh=nil,_hr=nil,_ha=0,
    }
end

function libNyx.UI.StopDragIcon(applyTo)
    local d = libNyx.UI._drag
    if not d or not d.active then return end
    d.applyTo = applyTo
    d.phase = "drop"
    d.t0    = SysTime()
    d.dur   = 0.18
end

local function libnyx_find_cell_under_cursor()
    local p = vgui.GetHoveredPanel()
    while IsValid(p) and not p._isInteractiveCell do p = p:GetParent() end
    return p
end

libNyx.UI._inv = libNyx.UI._inv or {holding=nil, from=nil}

function Components.CreateInteractiveCell(parent, opts)
    local cell = Components.CreateCell(parent, opts)
    cell._isInteractiveCell = true
    function cell:OnMousePressed(mc)
        if mc ~= MOUSE_LEFT then return end
        if libNyx.UI._drag and libNyx.UI._drag.active then return end
        if not self:HasItem() or not self._iconMat then return end
        local lx, ly = self:LocalCursorPos()
        local offx = lx - self:GetWide()/2
        local offy = ly - self:GetTall()/2
        libNyx.UI.StartDragIcon(self, self._iconMat, self._iconSize, offx, offy)
        self:ClearItem()
        self:MouseCapture(true)
        surface.PlaySound("ui/buttonclick.wav")
    end
    function cell:OnMouseReleased(mc)
        if mc ~= MOUSE_LEFT then return end
        self:MouseCapture(false)
        local tgt = libnyx_find_cell_under_cursor()
        if IsValid(tgt) and tgt ~= self and not tgt:HasItem() then
            libNyx.UI.StopDragIcon(tgt)
        else
            libNyx.UI.StopDragIcon(self)
        end
        surface.PlaySound("ui/buttonclickrelease.wav")
    end
    return cell
end

libNyx.UI._rippleStyle = libNyx.UI._rippleStyle or 1
function libNyx.UI.SetRippleStyle(style)
    if isstring(style) then
        local s = string.lower(style)
        if s == "ring" or s == "2" then libNyx.UI._rippleStyle = 2 else libNyx.UI._rippleStyle = 1 end
    else
        libNyx.UI._rippleStyle = (tonumber(style) == 2) and 2 or 1
    end
end
function libNyx.UI.GetRippleStyle() return libNyx.UI._rippleStyle end

local function makeRipple(btn, style)
    btn._ripples = {}
    btn._rippleDur   = 0.45
    btn._rippleSpeed = 340
    btn._rippleStyle = style and ((tonumber(style) == 2 or string.lower(tostring(style)) == "ring") and 2 or 1) or nil
    btn._rippleThick = libNyx.UI.Scale(4)
    function btn:SetRippleStyle(s)
        self._rippleStyle = (tonumber(s) == 2 or string.lower(tostring(s)) == "ring") and 2 or 1
    end
end

local function paintRipples(self, w, h, color)
    local now = SysTime()
    local variant = self._rippleStyle or libNyx.UI.GetRippleStyle()
    local thick = math.max(1, self._rippleThick or libNyx.UI.Scale(3))
    for i = #self._ripples, 1, -1 do
        local r = self._ripples[i]
        local dt = now - r.t0
        if dt >= self._rippleDur then
            table.remove(self._ripples, i)
        else
            local radius = dt * self._rippleSpeed
            local alpha  = math.Clamp(220 * (1 - dt / self._rippleDur), 0, 220)
            if variant == 2 then
                surface.SetDrawColor(color.r, color.g, color.b, alpha)
                for t = 0, thick - 1 do
                    surface.DrawCircle(r.x, r.y, math.max(0, radius - t), color.r, color.g, color.b, alpha)
                end
            else
                surface.SetDrawColor(color.r, color.g, color.b, alpha)
                draw.NoTexture()
                local seg = 28
                local verts = {{x = r.x, y = r.y}}
                for k = 0, seg do
                    local ang = (k / seg) * math.pi * 2
                    verts[#verts+1] = {x = r.x + math.cos(ang) * radius, y = r.y + math.sin(ang) * radius}
                end
                surface.DrawPoly(verts)
            end
        end
    end
end


function Components.CreateCheckbox(parent, opts)
    opts = opts or {}

    local box = vgui.Create("DButton", parent)
    box:SetText("")
    box:SetCursor("hand")
    box._variant  = string.lower(opts.variant or "switch")
    box._checked  = tobool(opts.checked)
    box._tint     = opts.tint or Style.accentColor
    box._label    = opts.label or ""
    box._size     = math.max(libNyx.UI.Scale(20), tonumber(opts.size) or libNyx.UI.Scale(22))
    box._gap      = libNyx.UI.Scale(10)
    box._font     = libNyx.UI.Font(libNyx.UI.Scale(18))
    box._anim     = box._checked and 1 or 0
    box._onChange = opts.onChange
    box._group    = opts.group

    libNyx.UI._checkboxGroups = libNyx.UI._checkboxGroups or {}

    local function ensureGroup(self, name)
        if not name or name == "" then return end
        local t = libNyx.UI._checkboxGroups
        t[name] = t[name] or {}
        if not table.HasValue(t[name], self) then table.insert(t[name], self) end
    end
    local function leaveGroup(self, name)
        if not name or name == "" then return end
        local t = libNyx.UI._checkboxGroups[name]
        if not t then return end
        for i = #t, 1, -1 do
            if t[i] == self then table.remove(t, i) end
        end
    end
    local function notifyGroup(self)
        if self._variant ~= "radio" then return end
        local name = self._group
        if not name or name == "" then return end
        local t = libNyx.UI._checkboxGroups[name] or {}
        for _, other in ipairs(t) do
            if IsValid(other) and other ~= self and other._variant == "radio" then
                other._checked = false
                other._anim = 0
                other:InvalidateLayout(false)
            end
        end
    end

    function box:SetGroup(name)
        if self._group == name then return end
        leaveGroup(self, self._group)
        self._group = name
        ensureGroup(self, name)
    end

    if box._variant == "radio" and (not box._group or box._group == "") then
        box._group = "auto_radio_group_" .. tostring(parent or box:GetParent() or "root")
    end
    ensureGroup(box, box._group)

    function box:ControlSize()
        local h = self._size
        if self._variant == "radio" then
            return h, h
        end
        local mul = (self._variant == "switch") and 1.95 or 1.65
        return math.floor(h * mul), h
    end

    function box:_RefreshSize()
        local cw, ch = self:ControlSize()
        surface.SetFont(self._font)
        local tw = surface.GetTextSize(self._label or "")
        local w = cw + (tw > 0 and (self._gap + tw) or 0) + libNyx.UI.Scale(4)
        local h = math.max(ch, libNyx.UI.Scale(28))
        self:SetSize(w, h)
    end

    function box:SetLabel(t) self._label = tostring(t or "") self:_RefreshSize() end
    function box:SetVariant(v)
        v = string.lower(v or "switch")
        if self._variant == "radio" and v ~= "radio" then
            leaveGroup(self, self._group)
        end
        self._variant = v
        if self._variant == "radio" and (not self._group or self._group == "") then
            self._group = "auto_radio_group_" .. tostring(self:GetParent() or "root")
            ensureGroup(self, self._group)
        end
        self:_RefreshSize()
    end

    function box:SetValue(b)
        b = tobool(b)
        if self._variant == "radio" then
            if self._checked ~= b then
                self._checked = b
                if b then notifyGroup(self) end
                if isfunction(self._onChange) then self._onChange(self._checked, self) end
            end
        else
            if self._checked ~= b then
                self._checked = b
                if isfunction(self._onChange) then self._onChange(self._checked, self) end
            end
        end
        self._anim = self._checked and 1 or 0
        self:InvalidateLayout(false)
    end
    function box:GetValue() return self._checked end
    function box:SetOnChange(fn) self._onChange = fn end
    function box:OnCursorEntered() end

    function box:DoClick()
        if self._variant == "radio" then
            self._checked = not self._checked
            if self._checked then notifyGroup(self) end
            if isfunction(self._onChange) then self._onChange(self._checked, self) end
        else
            self._checked = not self._checked
            if isfunction(self._onChange) then self._onChange(self._checked, self) end
        end
        surface.PlaySound("ui/buttonclickrelease.wav")
    end

    function box:OnRemove()
        leaveGroup(self, self._group)
    end

    box.Think = function(self)
        local target = self._checked and 1 or 0
        self._anim = Lerp(FrameTime() * 12, self._anim or target, target)
    end

    box.Paint = function(self, w, h)
        local tint = self._tint
        local cw, ch = self:ControlSize()
        local cx = 0
        local cy = (h - ch) / 2
        local a = math.Clamp(self._anim or 0, 0, 1)

        if self._variant == "radio" then
            local r = math.floor(ch/2)
            local strokeA = 38 + (120 - 38) * a
            libNyx.UI.Draw.Glass(cx, cy, ch, ch, {radius = r, fill = Color(20,24,32,110), stroke = true, strokeColor = Color(tint.r, tint.g, tint.b, math.floor(strokeA)), blurIntensity = 1.0})
            local dot = math.floor(ch * 0.5 * a)
            if a > 0.01 and dot > 0 then
                local dx = cx + (ch - dot)/2
                local dy = cy + (ch - dot)/2
                libNyx.UI.Draw.Panel(dx, dy, dot, dot, {radius = dot/2, color = Color(tint.r, tint.g, tint.b, math.floor(215*a)), glass = true})
            end
        else
            local r = math.floor(ch/2)
            if self._variant == "switch" then
                local trackCol = Color(Lerp(a, 30, tint.r), Lerp(a, 34, tint.g), Lerp(a, 42, tint.b), math.floor(Lerp(a, 100, 170)))
                libNyx.UI.Draw.Panel(cx, cy, cw, ch, {radius = r, color = trackCol, glass = true, stroke = true})
                local pad = libNyx.UI.Scale(2)
                local knob = ch - pad*2
                local kx = Lerp(a, cx + pad, cx + cw - pad - knob)
                libNyx.UI.Draw.Panel(kx, cy + pad, knob, knob, {radius = knob/2, color = Color(245,245,252,230), glass = true, stroke = true})
            else
                libNyx.UI.Draw.Panel(cx, cy, cw, ch, {radius = r, color = Color(30,34,42,120), glass = true, stroke = true})
                local pad  = libNyx.UI.Scale(3)
                local knob = ch - pad*2
                local kx   = Lerp(a, cx + pad, cx + cw - pad - knob)
                local fillA = math.floor(Lerp(a, 60, 205))
                libNyx.UI.Draw.Panel(kx, cy + pad, knob, knob, {radius = knob/2, color = Color(tint.r, tint.g, tint.b, fillA), glass = true})
                RNDX.DrawOutlined(knob/2, kx, cy + pad, knob, knob, Color(255,255,255, math.floor(Lerp(a, 40, 140))), 1)
            end
        end

        if self._label ~= "" then
            local xText = cx + cw + self._gap
            draw.SimpleText(self._label, self._font, xText, h/2, Style.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end

    box:_RefreshSize()
    return box
end

function Components.CreateButton(parent, text, opts)
    opts = opts or {}
    local btn = vgui.Create("DButton", parent)
    btn:SetText("")
    btn:SetTall(opts.h or Style.btnHeight)
    btn:SetFont(libNyx.UI.Font(libNyx.UI.Scale(20)))
    btn._text        = text or "Button"
    btn._icon        = opts.icon
    btn._align       = opts.align or "center"
    btn._variant     = opts.variant or "primary"
    btn._radius      = opts.radius or Style.radius
    btn._iconSize    = opts.iconSize or Style.iconSize
    btn._onClick     = opts.onClick
    btn._tint        = opts.tint
    btn._centerTint  = opts.centerTint or opts.tint2
    local MAT_GRADIENT_L = Material("vgui/gradient-l", "noclamp smooth")
    local MAT_GRADIENT_R = Material("vgui/gradient-r", "noclamp smooth")
    local function lighten(col, k)
        return Color(
            math.Clamp(col.r + (255 - col.r) * k, 0, 255),
            math.Clamp(col.g + (255 - col.g) * k, 0, 255),
            math.Clamp(col.b + (255 - col.b) * k, 0, 255),
            col.a or 255
        )
    end
    local function DuoDefaults()
        local base   = Color(104,  76, 230, 205)
        local center = Color(184, 160, 255, 140)
        return base, center
    end
    makeRipple(btn,2)
    function btn:DoClick()
        libNyx.UI.PlayClick()
        if isfunction(self._onClick) then self._onClick(self) end
    end
    function btn:OnCursorEntered()
        local mx, my = gui.MousePos()
        mx, my = self:ScreenToLocal(mx, my)
        table.insert(self._ripples, {x = mx, y = my, t0 = SysTime()})
        libNyx.UI.PlayHover()
    end
    btn.Paint = function(self, w, h)
        local pad = Style.padding
        local r   = self._radius
        local v   = self._variant
        local align = ((v == "primary_center") or (v == "center_duo")) and "center" or (self._align or "center")
        if v == "center_duo" then
            local defBase, defCenter = DuoDefaults()
            local baseCol   = self._tint or defBase
            local centerCol = self._centerTint or (self._tint and lighten(self._tint, 0.26)) or defCenter
            local aAdj = self:IsDown() and 20 or (self:IsHovered() and 10 or 0)
            local bg = Color(baseCol.r, baseCol.g, baseCol.b, math.Clamp((baseCol.a or 205) + aAdj, 120, 255))
            libNyx.UI.Draw.Panel(0, 0, w, h, {radius = r, color = bg, glass = true})
            local light = Color(centerCol.r, centerCol.g, centerCol.b, math.Clamp((centerCol.a or 140) + aAdj, 0, 255))
            local coverage = 0.78
            local halfCov  = math.floor(w * coverage * 0.5)
            local cx       = math.floor(w * 0.5)
            local overlap  = 2
            local ro       = 0
            if not (MAT_GRADIENT_L:IsError() or MAT_GRADIENT_R:IsError()) then
                local lx, lw = cx - halfCov - overlap, halfCov + overlap
                RNDX.DrawMaterial(ro, lx, 0, lw, h, light, MAT_GRADIENT_R, 0)
                local rx, rw = cx, halfCov + overlap
                RNDX.DrawMaterial(ro, rx, 0, rw, h, light, MAT_GRADIENT_L, 0)
            end
        elseif v == "primary" or v == "primary_center" then
            local a = self:IsDown() and 235 or (self:IsHovered() and 220 or 205)
            local col = Color(Style.accentColor.r, Style.accentColor.g, Style.accentColor.b, a)
            libNyx.UI.Draw.Panel(0, 0, w, h, {radius = r, color = col, glass = true})
        elseif v == "ghost" then
            local col = self:IsHovered() and Style.hoverColor or Color(0,0,0,0)
            libNyx.UI.Draw.Panel(0, 0, w, h, {radius = r, color = col, glass = true, stroke = true})
        elseif v == "gradient" then
            libNyx.UI.Draw.Panel(0, 0, w, h, {radius = r, color = Color(20,22,30,120), glass = true, stroke = true})
            if not MAT_GRADIENT_L:IsError() then
                local tint = self._tint or PalettePick(self._text)
                local a    = self:IsDown() and (Style.gradientAlphaBtn + 20)
                           or self:IsHovered() and (Style.gradientAlphaBtn + 10)
                           or Style.gradientAlphaBtn
                local gcol = Color(tint.r, tint.g, tint.b, a)
                local gw   = w * 0.6
                RNDX.DrawMaterial(r, 0, 0, gw, h, gcol, MAT_GRADIENT_L, 0)
            end
        else
            local col = self:IsHovered() and Color(Style.panelColor.r,Style.panelColor.g,Style.panelColor.b, 160) or Style.panelColor
            libNyx.UI.Draw.Panel(0, 0, w, h, {radius = r, color = col, glass = true})
        end
        surface.SetFont(libNyx.UI.Font(libNyx.UI.Scale(20)))
        local tw = surface.GetTextSize(self._text or "")
        if align == "left" then
            local x = pad
            if self._icon and not self._icon:IsError() then
                surface.SetDrawColor(Style.textColor)
                surface.SetMaterial(self._icon)
                surface.DrawTexturedRect(x, (h - self._iconSize)/2, self._iconSize, self._iconSize)
                x = x + self._iconSize + pad
            end
            draw.SimpleText(self._text, libNyx.UI.Font(libNyx.UI.Scale(20)), x, h/2, Style.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            local icw = (self._icon and not self._icon:IsError()) and (self._iconSize + pad) or 0
            local content = icw + tw
            local startX = math.floor((w - content) * 0.5)
            if self._icon and not self._icon:IsError() then
                surface.SetDrawColor(Style.textColor)
                surface.SetMaterial(self._icon)
                surface.DrawTexturedRect(startX, (h - self._iconSize)/2, self._iconSize, self._iconSize)
                startX = startX + icw
            end
            draw.SimpleText(self._text, libNyx.UI.Font(libNyx.UI.Scale(20)), startX, h/2, Style.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        paintRipples(self, w, h, Style.textColor)
    end
    return btn
end

function Components.CreateSlider(parent, opts)
    opts = opts or {}
    local sld = vgui.Create("DNumSlider", parent)
    sld:SetText("")
    if IsValid(sld.Label) then sld.Label:Hide() end
    sld:SetMin(tonumber(opts.min) or 0)
    sld:SetMax(tonumber(opts.max) or 100)
    sld:SetDecimals(tonumber(opts.decimals) or 0)
    if opts.value then sld:SetValue(opts.value) end
    sld._tint        = opts.tint or Style.accentColor
    sld._lerpVal     = sld:GetValue()
    sld._drawText    = ""
    sld._taWide      = libNyx.UI.Scale(60)
    sld._pulse       = 0
    sld._knobA       = 0
    sld._dragging    = false
    sld._lastDrawKey = ""
    if IsValid(sld.TextArea) then sld.TextArea:SetVisible(false) end

    local counterBaseSize = libNyx.UI.Scale(18)
    local function fmtnum(v, d)
        if (d or 0) <= 0 then return tostring(math.Round(v)) end
        return string.format("%."..d.."f", v)
    end
    local function expApproach(cur, tgt, spd)
        local k = 1 - math.exp(-(spd or 10) * FrameTime())
        return cur + (tgt - cur) * k
    end
    local counterFont = function(scale)
        local sz = math.Clamp(math.floor(counterBaseSize * scale), 10, 200)
        return libNyx.UI.Font(sz)
    end

    function sld:PerformLayout(w, h)
        if IsValid(self.Label) then
            self.Label:SetWide(0)
            self.Label:Hide()
        end
        local ta = self.TextArea
        local tw = math.max(libNyx.UI.Scale(50), self._taWide or libNyx.UI.Scale(60))
        if IsValid(ta) then
            ta:SetWide(tw)
            ta:SetPos(w - tw, 0)
            ta:SetTall(h)
            ta:SetVisible(false)
        end
        if IsValid(self.Slider) then
            self.Slider:SetPos(0, 0)
            self.Slider:SetSize(w - tw, h)
        end
    end

    function sld:Think()
        self._lerpVal = Lerp(FrameTime()*12, self._lerpVal or self:GetValue(), self:GetValue())
        local d = self:GetDecimals()
        local shown = fmtnum(self._lerpVal, d)
        self._drawText = shown
        surface.SetFont(counterFont(1))
        local tw = surface.GetTextSize(self._drawText)
        local target = math.Clamp(tw + libNyx.UI.Scale(24), libNyx.UI.Scale(50), libNyx.UI.Scale(140))
        if math.abs((self._taWide or 0) - target) > 1 then
            self._taWide = target
            if IsValid(self.TextArea) then self.TextArea:SetWide(self._taWide) end
            self:InvalidateLayout(false)
        end
        local key = self._drawText
        if key ~= self._lastDrawKey then
            self._lastDrawKey = key
            self._pulse = 1
        end
        local hover = IsValid(self.Slider) and self.Slider:IsHovered() or false
        local tgtA = (self._dragging and 1) or (hover and 0.6) or 0
        self._knobA = expApproach(self._knobA, tgtA, 10)
        self._pulse = expApproach(self._pulse, 0, 8)
        if IsValid(self.TextArea) then self.TextArea:SetText(fmtnum(self:GetValue(), d)) end
    end

    function sld.Slider:Paint(w, h)
        local th = libNyx.UI.Scale(6)
        local y  = h*0.5 - th/2
        local maxW = math.max(th, w)
        libNyx.UI.Draw.Panel(0, y, maxW, th, {radius = th/2, color = Color(30,34,42,130 + math.floor(30*sld._knobA)), glass = true})
        local frac = self.GetSlideX and (self:GetSlideX() or 0) or 0
        local fillW = math.max(th, math.min(maxW, maxW * frac))
        if not MAT_GRADIENT_L:IsError() then
            local tint = sld._tint
            local gcol = Color(tint.r, tint.g, tint.b, 170)
            RNDX.DrawMaterial(th/2, 0, y, fillW, th, gcol, MAT_GRADIENT_L, 0)
        else
            draw.RoundedBox(th/2, 0, y, fillW, th, sld._tint)
        end
    end

    local oldMP = sld.Slider.Knob.OnMousePressed
    function sld.Slider.Knob:OnMousePressed(mc)
        sld._dragging = true
        if oldMP then oldMP(self, mc) else pcall(function() self:GetParent():OnMousePressed(mc) end) end
    end
    local oldMR = sld.Slider.Knob.OnMouseReleased
    function sld.Slider.Knob:OnMouseReleased(mc)
        sld._dragging = false
        if oldMR then oldMR(self, mc) else pcall(function() self:GetParent():OnMouseReleased(mc) end) end
    end

    function sld.Slider.Knob:Paint(w,h)
        local base = libNyx.UI.Scale(16)
        local size = math.floor(base * (1 + 0.26 * sld._knobA))
        local x = -size/2 + w/2
        local y = -size/2 + h/2
        libNyx.UI.Draw.Panel(x, y, size, size, {radius = size/2, color = Color(240,240,255, math.floor(180 + 50*sld._knobA)), glass = true, stroke = true})
    end

    function sld:PaintOver(w,h)
        local scale = 1 + 0.40 * self._pulse
        local fnt = counterFont(scale)
        draw.SimpleText(self._drawText or "", fnt, w - libNyx.UI.Scale(8), h/2, Style.textColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    return sld
end


function Components.CreateDropdown(parent, opts)
    opts = opts or {}
    local combo = vgui.Create("DComboBox", parent)
    combo._valueStr    = ""
    combo._placeholder = opts.placeholder or "Выберите…"
    combo._tint        = opts.tint or PalettePick("dropdown")
    combo:SetText("")
    if IsValid(combo.DropButton) then
        combo.DropButton:SetText("")
        combo.DropButton.Paint = function() end
    end
    function combo:SetText(_) end
    function combo:SetValue(str) self._valueStr = tostring(str or "") end
    function combo:GetValue()    return self._valueStr or "" end
    function combo:Paint(w,h)
        libNyx.UI.Draw.Panel(0, 0, w, h, {radius = Style.radius, color = Style.panelColor, glass = true, stroke = true})
        if not MAT_GRADIENT_L:IsError() then
            local gw = w * 0.45
            local col = Color(self._tint.r, self._tint.g, self._tint.b, 90)
            RNDX.DrawMaterial(Style.radius, 0, 0, gw, h, col, MAT_GRADIENT_L, 0)
        end
        local txt = (self._valueStr ~= "" and self._valueStr) or self._placeholder
        draw.SimpleText(txt, libNyx.UI.Font(libNyx.UI.Scale(20)), Style.padding, h/2, Style.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("▼",  libNyx.UI.Font(libNyx.UI.Scale(18)), w - Style.padding, h/2, Style.textColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
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
        local radius   = math.max(Style.radius, libNyx.UI.Scale(12))
        local itemH    = math.max(libNyx.UI.Scale(58), tonumber(opts.itemHeight) or 0)
        local iconSize = libNyx.UI.Scale(22)
        local fontOpt  = libNyx.UI.Font(libNyx.UI.Scale(20))
        m._openT = SysTime()
        m._dur   = 0.18
        m._rev   = 0
        m._tint  = self._tint
        m.Paint = function(s,w,h)
            local t = math.TimeFraction(s._openT, s._openT + s._dur, SysTime())
            s._rev = math.Clamp(1 - (1 - t) ^ 3, 0, 1)
            local clip = s._rev < 0.999
            if clip then
                local sx, sy = s:LocalToScreen(0, 0)
                local rh = math.max(1, h * s._rev)
                render.SetScissorRect(sx, sy, sx + w, sy + rh, true)
            end
            libNyx.UI.Draw.Glass(0, 0, w, h, {radius = radius, fill = Color(16,18,24, 70), stroke = true, strokeColor = Color(255,255,255,22), blurIntensity = 1.35})
            if clip then render.SetScissorRect(0,0,0,0,false) end
        end
        for _, data in ipairs(normalizeChoices()) do
            local label, icon = data.label, data.icon
            local opt = m:AddOption(label, function()
                self:SetValue(label)
                if isfunction(opts.onSelect) then opts.onSelect(label) end
            end)
            opt:SetText("")
            opt:SetTall(itemH)
            opt._label     = label
            opt._icon      = icon
            opt._iconSize  = iconSize
            opt._tint      = self._tint
            makeRipple(opt,2)
            function opt:OnCursorEntered()
                local mx, my = gui.MousePos()
                mx, my = self:ScreenToLocal(mx, my)
                self._ripples = self._ripples or {}
                table.insert(self._ripples, {x = mx, y = my, t0 = SysTime()})
                surface.PlaySound("buttons/lightswitch2.wav")
            end
            opt.Paint = function(s, w, h)
                local hovered = s:IsHovered()
                local r = libNyx.UI.Scale(10)
                libNyx.UI.Draw.Glass(0, 0, w, h, {radius = r, fill = Color(20,24,32, hovered and 95 or 65), stroke = false, blurIntensity = hovered and 1.20 or 0.95})
                if hovered and not MAT_GRADIENT_L:IsError() then
                    local gcol = Color(s._tint.r, s._tint.g, s._tint.b, 120)
                    RNDX.DrawMaterial(r, 0, 0, math.floor(w * 0.55), h, gcol, MAT_GRADIENT_L, 0)
                end
                local x = Style.padding
                if s._icon and not s._icon:IsError() then
                    surface.SetDrawColor(Style.textColor)
                    surface.SetMaterial(s._icon)
                    surface.DrawTexturedRect(x, (h - s._iconSize)/2, s._iconSize, s._iconSize)
                    x = x + s._iconSize + Style.padding
                end
                draw.SimpleText(s._label or "", fontOpt, x, h/2, Style.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                paintRipples(s, w, h, Style.textColor)
            end
        end
        local x, y = self:LocalToScreen(0, self:GetTall() + 4)
        m:Open()
        m:SetMinimumWidth(self:GetWide())
        m:SetAlpha(0)
        m:SetPos(x, y - libNyx.UI.Scale(8))
        m:MoveTo(x, y, m._dur, 0, 0.2)
        m:AlphaTo(255, m._dur, 0)
        self.Menu = m
        return m
    end
    return combo
end


function Components.CreateList(parent, opts)
    opts = opts or {}
    local list = vgui.Create("DScrollPanel", parent)
    list._rowH = math.max(libNyx.UI.Scale(66), opts.rowHeight or Style.rowHeight)
    list._rows = {}
    local vbar = list:GetVBar()
    vbar:SetWide(opts.vbarWidth or libNyx.UI.Scale(12))
    function vbar:Paint(w,h) draw.RoundedBox(4,0,0,w,h, Color(36,36,44,200)) end
    function vbar.btnUp:Paint() end
    function vbar.btnDown:Paint() end
    function vbar.btnGrip:Paint(w,h) draw.RoundedBox(4,0,0,w,h, Style.accentColor) end
    function list:SetRowHeight(h) self._rowH = math.max(libNyx.UI.Scale(66), h or self._rowH) end
    function list:GetSelected() return self._selected end
    function list:SetSelected(row) self._selected = row end
    function list:ClearRows()
        for _, r in ipairs(self._rows) do if IsValid(r) then r:Remove() end end
        self._rows = {}
        self._selected = nil
    end
    local function makeRowPaint(row)
        row.Paint = function(self, w, h)
            local base = (list:GetSelected() == self) and Color(Style.accentColor.r,Style.accentColor.g,Style.accentColor.b, 190)
                       or (self:IsHovered() and Style.hoverColor or Style.cardColor)
            libNyx.UI.Draw.Panel(0, 0, w, h, {radius = Style.radius, color = base, glass = true})
            if not self._plain and not MAT_GRADIENT_L:IsError() then
                local gw = w * 0.5
                local tint = PalettePick(self._title or self._rightText or "row")
                local col  = Color(tint.r, tint.g, tint.b, Style.gradientAlphaRow)
                RNDX.DrawMaterial(Style.radius, 0, 0, gw, h, col, MAT_GRADIENT_L, 0)
            end
            local pad = Style.padding
            local x = pad
            local y = pad
            surface.SetFont(libNyx.UI.Font(libNyx.UI.Scale(22)))
            local rightW = 0
            if self._rightText and self._rightText ~= "" then
                rightW = select(1, surface.GetTextSize(self._rightText)) + pad
            end
            local rightLimitX = w - pad - rightW
            if self._icon and not self._icon:IsError() then
                local ic = math.max(libNyx.UI.Scale(24), Style.iconSize)
                surface.SetDrawColor(255,255,255)
                surface.SetMaterial(self._icon)
                surface.DrawTexturedRect(x, (h - ic)/2, ic, ic)
                x = x + ic + pad
            end
            draw.SimpleText(self._title or "Без названия", libNyx.UI.Font(libNyx.UI.Scale(26)), x, y + libNyx.UI.Scale(2), Style.textColor)
            if istable(self._labels) and #self._labels > 0 then
                local chipH = libNyx.UI.Scale(26)
                local chipY = h - pad - chipH
                local cx = x
                local hidden = 0
                surface.SetFont(libNyx.UI.Font(libNyx.UI.Scale(18)))
                for i, chip in ipairs(self._labels) do
                    local t  = chip.text or tostring(chip) or ""
                    local tw = select(1, surface.GetTextSize(t))
                    local cw, ch = tw + libNyx.UI.Scale(18), chipH
                    if (cx + cw) > rightLimitX then
                        hidden = (#self._labels - i + 1)
                        break
                    end
                    local baseCol = chip.color or PalettePick(t)
                    local fill    = Color( math.max(0, baseCol.r - 10), math.max(0, baseCol.g - 10), math.max(0, baseCol.b - 10), 175 )
                    local chipR   = libNyx.UI.Scale(9)
                    libNyx.UI.Draw.Panel(cx, chipY, cw, ch, {radius = chipR, color = fill, glass = true, stroke = true, strokeColor = Color(255,255,255,18)})
                    if not MAT_GRADIENT_L:IsError() then
                        local gw = cw * 0.65
                        local gcol = Color(baseCol.r, baseCol.g, baseCol.b, Style.gradientAlphaChip)
                        RNDX.DrawMaterial(chipR, cx, chipY, gw, ch, gcol, MAT_GRADIENT_L, 0)
                    end
                    draw.SimpleText(t, libNyx.UI.Font(libNyx.UI.Scale(18)), cx + cw/2, chipY + ch/2, chip.textColor or Style.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    cx = cx + cw + libNyx.UI.Scale(6)
                end
                if hidden > 0 and (cx + libNyx.UI.Scale(34)) <= rightLimitX then
                    local t  = "+" .. hidden
                    local tw = select(1, surface.GetTextSize(t))
                    local cw, ch = tw + libNyx.UI.Scale(18), chipH
                    local chipR = libNyx.UI.Scale(9)
                    libNyx.UI.Draw.Panel(cx, chipY, cw, ch, {radius = chipR, color = Color(36,36,44,175), glass = true, stroke = true, strokeColor = Color(255,255,255,18)})
                    if not MAT_GRADIENT_L:IsError() then
                        local gw = cw * 0.65
                        local gcol = Color(Style.accentColor.r, Style.accentColor.g, Style.accentColor.b, Style.gradientAlphaChip)
                        RNDX.DrawMaterial(chipR, cx, chipY, gw, ch, gcol, MAT_GRADIENT_L, 0)
                    end
                    draw.SimpleText(t, libNyx.UI.Font(libNyx.UI.Scale(18)), cx + cw/2, chipY + ch/2, Style.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
            if self._rightText and self._rightText ~= "" then
                draw.SimpleText(self._rightText, libNyx.UI.Font(libNyx.UI.Scale(28)), w - pad, h/2, Style.textColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
            paintRipples(self, w, h, Style.textColor)
        end
    end
    function list:AddRow(data)
        data = data or {}
        local row = list:Add("DButton")
        row:Dock(TOP)
        row:DockMargin(0, 0, 0, libNyx.UI.Scale(10))
        row:SetTall(self._rowH)
        row:SetText("")
        row._title     = data.title or ""
        row._subtitle  = data.subtitle
        row._icon      = data.icon
        row._labels    = istable(data.labels) and data.labels or {}
        row._rightText = data.rightText
        row._onClick   = data.onClick
        row._plain     = data.gradient == false or data.plain == true
        makeRipple(row)
        makeRowPaint(row)
        function row:DoClick()
            list:SetSelected(self)
            if isfunction(self._onClick) then self._onClick(self) end
        end
        function row:OnCursorEntered()
            local mx, my = gui.MousePos()
            mx, my = self:ScreenToLocal(mx, my)
            table.insert(self._ripples, {x = mx, y = my, t0 = SysTime()})
            surface.PlaySound("buttons/lightswitch2.wav")
        end
        table.insert(self._rows, row)
        return row
    end
    return list
end

function Components.CreateVBox(parent, opts)
    opts = opts or {}
    local w = opts.w or libNyx.UI.Scale(140)
    local h = opts.h or libNyx.UI.Scale(200)
    local pnl = vgui.Create("DButton", parent)
    pnl:SetText("")
    pnl:SetSize(w, h)
    pnl._variant   = (opts.variant or "center_gradient")
    pnl._tint      = opts.tint or Color(140,120,255)
    pnl._title     = opts.title or ""
    pnl._icon      = opts.icon
    pnl._iconSize  = opts.iconSize or libNyx.UI.Scale(40)
    pnl._onClick   = opts.onClick
    pnl._phase     = 0
    pnl._hover     = false
    pnl._hoverA    = 0
    pnl._pulseT    = 0
    pnl._titleFont = libNyx.UI.Font(libNyx.UI.Scale(22))
    pnl._modelA    = 0
    pnl._spinA     = 0
    if isstring(pnl._icon) then pnl._icon = Material(pnl._icon, "noclamp smooth") end

    function pnl:DoClick()
        surface.PlaySound("nyx_uniqueui/nyxclick_3.wav")
        if isfunction(self._onClick) then self._onClick(self) end
    end
    function pnl:OnCursorEntered()
        self._hover = true
        surface.PlaySound("nyx_uniqueui/nyxclick_2.wav")
    end
    function pnl:OnCursorExited()
        self._hover = false
    end

    local wantModel = (pnl._variant == "model") or (pnl._variant == "vertical_gradient" and isstring(opts.model) and opts.model ~= "")
    if wantModel then
        pnl._mp = vgui.Create("DModelPanel", pnl)
        pnl._mp:SetSize(w, h)
        pnl._mp:SetPos(0, 0)
        pnl._mp:SetModel(opts.model or "models/props_c17/oildrum001.mdl")
        pnl._mp:SetFOV(28)
        function pnl._mp:LayoutEntity(ent) end
        pnl._baseCam = nil
        local function FitModelLocal(mp)
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
            mp:SetDirectionalLight(BOX_FRONT,  Color(pnl._tint.r, pnl._tint.g, pnl._tint.b))
            mp:SetDirectionalLight(BOX_RIGHT,  Color(210,220,255))
            mp:SetDirectionalLight(BOX_LEFT,   Color(210,210,210))
            mp:SetDirectionalLight(BOX_BACK,   Color(190,200,220))
            mp:SetDirectionalLight(BOX_BOTTOM, Color(160,170,180))
            pnl._baseCam = {center = center, dist = dist, ang = ang}
        end
        timer.Simple(0, function() if IsValid(pnl._mp) then FitModelLocal(pnl._mp) end end)
    end

    local MAT_GRADIENT_L = Material("vgui/gradient-l", "noclamp smooth")
    local MAT_GRADIENT_R = Material("vgui/gradient-r", "noclamp smooth")
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
        self._hoverA = expApproach(self._hoverA, self._hover and 1 or 0, 8)
        self._pulseT = (self._pulseT + FrameTime() * (0.8 + 1.2 * self._hoverA)) % (math.pi * 2)
        if self._variant == "sunburst" then
            local sp = Lerp(self._hoverA, 0.35, 1.1)
            self._phase = (self._phase + FrameTime() * sp) % (math.pi * 2)
        end
        if IsValid(self._mp) and self._baseCam then
            self._modelA = expApproach(self._modelA, self._hover and 1 or 0, 6)
            self._spinA  = expApproach(self._spinA, self._hover and 1 or 0, 5)
            local distMul = Lerp(self._modelA, 1.0, 0.75)
            local yawJig  = math.sin(CurTime() * (0.6 + 1.0 * self._spinA)) * 6 * self._spinA
            local ang     = Angle(self._baseCam.ang.p, self._baseCam.ang.y + yawJig, self._baseCam.ang.r)
            local camPos  = self._baseCam.center + ang:Forward() * -(self._baseCam.dist * distMul)
            self._mp:SetCamPos(camPos)
            self._mp:SetLookAt(self._baseCam.center)
            self._mp:SetFOV(Lerp(self._modelA, 28, 26))
        end
    end

    pnl.Paint = function(self, w, h)
        libNyx.UI.Draw.Panel(0, 0, w, h, {radius = Style.radius, color = Color(0,0,0,0), glass = true, stroke = true})
        local cx, cy = w * 0.5, h * 0.5
        if self._variant == "center_gradient" then
            local base  = self._tint
            local light = lighten(base, 0.26) light.a = math.floor(Lerp(self._hoverA, 120, 155))
            local coverage = Lerp(self._hoverA, 0.80, 0.92)
            local halfCov  = math.floor(w * coverage * 0.5)
            local cxpix    = math.floor(w * 0.5 + math.sin(self._pulseT) * libNyx.UI.Scale(4) * self._hoverA)
            local overlap  = 2
            RNDX.DrawMaterial(0, cxpix - halfCov - overlap, 0, halfCov + overlap, h, light, MAT_GRADIENT_R, 0)
            RNDX.DrawMaterial(0, cxpix,                      0, halfCov + overlap, h, light, MAT_GRADIENT_L, 0)
        elseif self._variant == "vertical_gradient" then
            local base = self._tint
            local col  = Color(
                math.Clamp(base.r + (255 - base.r) * Lerp(self._hoverA, 0.18, 0.28), 0, 255),
                math.Clamp(base.g + (255 - base.g) * Lerp(self._hoverA, 0.18, 0.28), 0, 255),
                math.Clamp(base.b + (255 - base.b) * Lerp(self._hoverA, 0.18, 0.28), 0, 255),
                Lerp(self._hoverA, 120, 165)
            )
            local gh  = math.floor(h * Lerp(self._hoverA, 0.65, 0.78))
            local y0  = h - gh - math.floor(libNyx.UI.Scale(4) * self._hoverA)
            local MAT_GRADIENT_U = Material("vgui/gradient-u", "noclamp smooth")
            local rect = RNDX().Rect(0, y0, w, gh):Radii(0, 0, Style.radius, Style.radius):Material(MAT_GRADIENT_U):Color(col)
            local mat = rect:GetMaterial()
            surface.SetMaterial(mat)
            surface.SetDrawColor(col)
            surface.DrawTexturedRectUV(0, y0, w, gh, 0, 1, 1, 0)
        elseif self._variant == "sunburst" then
            local rays, step = 18, (math.pi * 2) / 18
            local R = math.max(w, h)
            local a1 = math.floor(Lerp(self._hoverA, 95, 140))
            local a2 = math.floor(Lerp(self._hoverA, 40, 80))
            local col1 = Color(self._tint.r, self._tint.g, self._tint.b, a1)
            local col2 = Color(self._tint.r, self._tint.g, self._tint.b, a2)
            draw.NoTexture()
            for i = 0, rays - 1 do
                local a0 = self._phase + i * step
                local a1r = a0 + step * Lerp(self._hoverA, 0.55, 0.70)
                local v  = {
                    {x = cx, y = cy},
                    {x = cx + math.cos(a0) * R,  y = cy + math.sin(a0) * R},
                    {x = cx + math.cos(a1r) * R, y = cy + math.sin(a1r) * R},
                }
                surface.SetDrawColor((i % 2 == 0) and col1 or col2)
                surface.DrawPoly(v)
            end
        end
        if not wantModel and self._icon and not self._icon:IsError() then
            local s = self._iconSize * (1 + 0.08 * self._hoverA + 0.04 * math.sin(self._pulseT))
            surface.SetDrawColor(Style.textColor)
            surface.SetMaterial(self._icon)
            surface.DrawTexturedRect(cx - s/2, cy - s/2 - libNyx.UI.Scale(10), s, s)
        end
    end

    pnl.PaintOver = function(self, w, h)
        local padX = libNyx.UI.Scale(10)
        local padY = libNyx.UI.Scale(6)
        local txt  = self._title or ""
        surface.SetFont(self._titleFont)
        local tw, th = surface.GetTextSize(txt)
        local bw, bh = tw + padX * 2, th + padY * 2
        local x  = math.floor((w - bw) / 2)
        local y  = h - Style.padding - bh - math.floor(libNyx.UI.Scale(2) * self._hoverA)
        libNyx.UI.Draw.Glass(x, y, bw, bh, {radius = libNyx.UI.Scale(8), fill = Color(16,18,24, math.floor(150 + 30 * self._hoverA)), stroke = true, strokeColor = Color(255,255,255,20), blurIntensity = 1.0})
        draw.SimpleText(txt, self._titleFont, x + bw/2, y + bh/2, Style.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    return pnl
end


function Components.CreateTabs(parent, opts)
    opts = opts or {}

    local pnl = vgui.Create("DPanel", parent)
    pnl._items    = istable(opts.items) and opts.items or {}
    pnl._active   = opts.default
    pnl._onChange = opts.onChange

    pnl:SetPaintBackground(false)
    pnl:SetPaintBorderEnabled(false)
    pnl:SetPaintBackgroundEnabled(false)
    pnl.Paint = nil

    local font   = libNyx.UI.Font(libNyx.UI.Scale(18))
    local tabH   = math.max(libNyx.UI.Scale(42), tonumber(opts.height or 0))
    local padY   = libNyx.UI.Scale(6)
    local MAT_GRADIENT_L = Material("vgui/gradient-l", "noclamp smooth")

    local rail = vgui.Create("DPanel", pnl)
    rail:Dock(FILL)
    rail:DockMargin(Style.padding, padY, Style.padding, padY)
    rail:SetPaintBackground(false)
    rail:SetPaintBorderEnabled(false)
    rail:SetPaintBackgroundEnabled(false)
    rail.Paint = nil

    pnl._btns = {}
    rail._indX = 0
    rail._indW = 0
    rail._indH = tabH
    rail._tgtX = 0
    rail._tgtW = 0
    rail._tgtH = tabH
    rail._haveInd = false

    local function syncIndicatorTo(id, snap)
        local b = pnl._btns[id]
        if not IsValid(b) then rail._haveInd = false return end
        local x, y = b:GetPos()
        local w, h = b:GetSize()
        rail._tgtX = x
        rail._tgtW = w
        rail._tgtH = tabH
        rail._haveInd = true
        if snap then
            rail._indX = rail._tgtX
            rail._indW = rail._tgtW
            rail._indH = rail._tgtH
        end
        rail:InvalidateLayout(false)
    end

    local function expApproach(cur, tgt, speed)
        local k = 1 - math.exp(-(speed or 12) * FrameTime())
        return cur + (tgt - cur) * k
    end

    rail.Think = function(s)
        if not s._haveInd then return end
        local hovering = false
        for _, b in pairs(pnl._btns) do
            if IsValid(b) and b:IsHovered() then hovering = true break end
        end
        local grow = libNyx.UI.Scale(6)
        s._tgtH = hovering and (tabH + grow) or tabH
        s._indX = expApproach(s._indX or s._tgtX, s._tgtX, 10)
        s._indW = expApproach(s._indW or s._tgtW, s._tgtW, 12)
        s._indH = expApproach(s._indH or s._tgtH, s._tgtH, 9)
    end

    rail.Paint = function(s, w, h)
        if not s._haveInd then return end
        local r = libNyx.UI.Scale(10)
        local bx = math.floor(s._indX + 0.5)
        local bw = math.floor(s._indW + 0.5)
        local bh = math.floor(s._indH + 0.5)
        local by = math.floor((tabH - bh) * 0.5)
        libNyx.UI.Draw.Panel(bx, by, bw, bh, {radius = r, color = Color(32,38,48,135), glass = true})
        if not MAT_GRADIENT_L:IsError() then
            local c = Color(Style.accentColor.r, Style.accentColor.g, Style.accentColor.b, 120)
            RNDX.DrawMaterial(r, bx, by, bw, bh, c, MAT_GRADIENT_L, 0)
        end
    end

    local function makeBtn(it, idx)
        local b = vgui.Create("DButton", rail)
        b:SetText("")
        b:SetDrawBackground(false)
        b:SetPaintBackgroundEnabled(false)
        b:SetPaintBorderEnabled(false)
        b:Dock(LEFT)
        b:DockMargin(libNyx.UI.Scale(6), libNyx.UI.Scale(6), libNyx.UI.Scale(6), libNyx.UI.Scale(6))
        b:SetTall(tabH)

        b._id       = tostring(it.id or it.label or idx or "")
        b._label    = tostring(it.label or b._id)
        b._icon     = isstring(it.icon) and Material(it.icon, "noclamp smooth") or it.icon
        b._iconSize = libNyx.UI.Scale(18)

        surface.SetFont(font)
        local tw   = surface.GetTextSize(b._label)
        local padX = libNyx.UI.Scale(16)
        local icw  = (b._icon and not b._icon:IsError()) and (b._iconSize + libNyx.UI.Scale(6)) or 0
        b:SetWide(padX * 2 + icw + tw)

        function b:DoClick()
            pnl:SetActive(self._id)
            if isfunction(pnl._onChange) then pnl._onChange(self._id, self) end
            surface.PlaySound("ui/buttonclickrelease.wav")
        end

        b.Paint = function(s, w, h)
            local selected = (pnl._active == s._id)
            local r = libNyx.UI.Scale(10)
            if not selected and s:IsHovered() then
                libNyx.UI.Draw.Panel(0, 0, w, h, {radius = r, color = Color(30,34,42,90), glass = true})
            end
            local x = padX
            if s._icon and not s._icon:IsError() then
                surface.SetDrawColor(Style.textColor.r, Style.textColor.g, Style.textColor.b, selected and 255 or 200)
                surface.SetMaterial(s._icon)
                surface.DrawTexturedRect(x, (h - s._iconSize) / 2, s._iconSize, s._iconSize)
                x = x + s._iconSize + libNyx.UI.Scale(6)
            end
            draw.SimpleText(
                s._label, font, x, h / 2,
                selected and Style.textColor or Color(Style.textColor.r, Style.textColor.g, Style.textColor.b, 200),
                TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
            )
        end

        pnl._btns[b._id] = b
        return b
    end

    function pnl:SetItems(items)
        for _, c in ipairs(rail:GetChildren()) do if IsValid(c) then c:Remove() end end
        pnl._btns = {}
        pnl._items = items or {}
        for i, it in ipairs(pnl._items) do makeBtn(it, i) end
        rail:InvalidateLayout(true)
        timer.Simple(0, function()
            if not IsValid(pnl) then return end
            local first = pnl._active
            if not first and #pnl._items > 0 then
                first = pnl._items[1].id or pnl._items[1].label
                pnl._active = first
            end
            syncIndicatorTo(pnl._active, true)
        end)
    end

    function pnl:SetActive(id)
        pnl._active = id
        syncIndicatorTo(id, false)
        rail:InvalidateLayout(false)
    end

    function pnl:GetActive()
        return pnl._active
    end

    pnl.SetOnChange = function(self, fn) self._onChange = fn end

    pnl:SetItems(pnl._items)
    if pnl._active == nil and #pnl._items > 0 then
        pnl:SetActive(pnl._items[1].id or pnl._items[1].label)
    else
        pnl:SetActive(pnl._active)
    end

    return pnl
end

function Components.CreateCategoryCard(parent, opts)
    opts = opts or {}
    local card = vgui.Create("DButton", parent)
    card:SetText("")
    card:SetTall(opts.h or libNyx.UI.Scale(120))
    card._title   = opts.title or "Category"
    card._desc    = opts.desc  or "—"
    card._icon    = opts.icon
    if isstring(card._icon) then
        card._icon = Material(card._icon, "noclamp smooth")
    end
    if not (card._icon and not card._icon:IsError()) then
        card._icon = Material("icon16/star.png", "noclamp smooth")
    end
    card._from    = opts.from or Color(125, 82,255)
    card._to      = opts.to   or Color( 40,192,255)
    card._variant = opts.variant or "vibrant"
    card._radius  = opts.radius or libNyx.UI.Scale(18)
    card._onClick = opts.onClick
    card._titleFont = libNyx.UI.Font(libNyx.UI.Scale(30))
    card._descFont  = libNyx.UI.Font(libNyx.UI.Scale(17))
    card._hoverA  = 0
    makeRipple(card)
    function card:DoClick()
        if libNyx.UI and libNyx.UI.PlayClick then libNyx.UI.PlayClick() end
        if isfunction(self._onClick) then self._onClick(self) end
    end
    function card:OnCursorEntered()
        local mx, my = gui.MousePos()
        mx, my = self:ScreenToLocal(mx, my)
        self._ripples = self._ripples or {}
        table.insert(self._ripples, {x = mx, y = my, t0 = SysTime()})
        if libNyx.UI and libNyx.UI.PlayHover then libNyx.UI.PlayHover() end
    end
    local function expApproach(cur, tgt, spd)
        local k = 1 - math.exp(-(spd or 10) * FrameTime())
        return cur + (tgt - cur) * k
    end
    local MAT_GRADIENT_L = Material("vgui/gradient-l", "noclamp smooth")
    local MAT_GRADIENT_R = Material("vgui/gradient-r", "noclamp smooth")
    local function lighten(c, k)
        return Color(
            math.Clamp(c.r + (255 - c.r) * k, 0, 255),
            math.Clamp(c.g + (255 - c.g) * k, 0, 255),
            math.Clamp(c.b + (255 - c.b) * k, 0, 255),
            c.a or 255
        )
    end
    card.Think = function(self)
        self._hoverA = expApproach(self._hoverA or 0, self:IsHovered() and 1 or 0, 10)
    end
    card.Paint = function(self, w, h)
        local r = self._radius
        local a = math.Clamp(self._hoverA or 0, 0, 1)
        if self._variant == "glass" then
            local fillA   = math.floor(Lerp(a, 120, 145))
            local strokeA = math.floor(Lerp(a, 20, 32))
            libNyx.UI.Draw.Glass(0, 0, w, h, {radius = r, fill = Color(20,24,32, fillA), stroke = true, strokeColor = Color(255,255,255, strokeA), blurIntensity = 1.1 + 0.15 * a})
            if not MAT_GRADIENT_L:IsError() then
                local c1 = Color(self._from.r, self._from.g, self._from.b, math.floor(Lerp(a, 95, 140)))
                local c2 = Color(self._to.r,   self._to.g,   self._to.b,   math.floor(Lerp(a, 95, 140)))
                RNDX.DrawMaterial(r, 0,       0, w*0.65, h, c1, MAT_GRADIENT_L, 0)
                RNDX.DrawMaterial(r, w*0.35,  0, w*0.65, h, c2, MAT_GRADIENT_R, 0)
            end
        else
            local baseCol = Color(self._from.r, self._from.g, self._from.b, math.floor(Lerp(a, 220, 235)))
            libNyx.UI.Draw.Panel(0, 0, w, h, {radius = r, color = baseCol, shadow = true})
            if not (MAT_GRADIENT_L:IsError() or MAT_GRADIENT_R:IsError()) then
                local colL = Color(self._to.r,   self._to.g,   self._to.b,   255)
                local colR = Color(self._from.r, self._from.g, self._from.b, 255)
                RNDX.DrawMaterial(r, 0, 0, w, h, colL, MAT_GRADIENT_L, 0)
                RNDX.DrawMaterial(r, 0, 0, w, h, colR, MAT_GRADIENT_R, 0)
            end
            local outlineA = math.floor(18 * a)
            if outlineA > 0 then
                RNDX.DrawOutlined(r, 0, 0, w, h, Color(255,255,255, outlineA), 1)
            end
        end
        if self._icon and not self._icon:IsError() then
            local sz  = math.floor(h * 1.25)
            local s   = 1 + 0.06 * a
            local sz2 = math.floor(sz * s)
            local oy  = -libNyx.UI.Scale(4) * a
            local alpha = (self._variant == "vibrant") and math.floor(Lerp(a, 44, 64)) or math.floor(Lerp(a, 36, 54))
            surface.SetDrawColor(255,255,255, alpha)
            surface.SetMaterial(self._icon)
            surface.DrawTexturedRect(w - sz2 + libNyx.UI.Scale(28), (h - sz2) / 2 + oy, sz2, sz2)
        end
        local padX = libNyx.UI.Scale(18)
        local topY = libNyx.UI.Scale(18)
        surface.SetFont(self._titleFont)
        local _, th = surface.GetTextSize(self._title or "")
        local titleCol = lighten(Style.textColor, a * 0.08)
        draw.SimpleText(self._title, self._titleFont, padX, topY + th/2, titleCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetFont(self._descFont)
        local _, dh = surface.GetTextSize(self._desc or "")
        draw.SimpleText(self._desc or "", self._descFont, padX, topY + th + libNyx.UI.Scale(6) + dh/2, Color(255,255,255, math.floor(Lerp(a, 200, 230))), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        local dashW, dashH = libNyx.UI.Scale(18), libNyx.UI.Scale(4)
        local dashA = math.floor(Lerp(a, 70, 110))
        libNyx.UI.Draw.Panel(padX, h - libNyx.UI.Scale(18), dashW, dashH, {radius = dashH/2, color = Color(255,255,255, dashA)})
        paintRipples(self, w, h, Style.textColor)
    end
    return card
end


function Components.CreateSearchBox(parent, opts)
    opts = opts or {}
    local box = vgui.Create("DPanel", parent)
    box:SetTall(opts.h or libNyx.UI.Scale(38))
    box._radius      = opts.radius or libNyx.UI.Scale(12)
    box._placeholder = opts.placeholder or "Search"
    box._tint        = opts.tint or Style.accentColor
    box._debounce    = tonumber(opts.debounce or 0.12)
    box._focusA      = 0
    box._gradA       = 0
    box._langID      = "EN"
    box._lastText    = ""
    local MAT_GRADIENT_L = Material("vgui/gradient-l", "noclamp smooth")
    local MAT_ICON_SEARCH = Material("icon16/magnifier.png", "noclamp smooth")
    local MAT_ICON_CLEAR  = Material("icon16/cross.png", "noclamp smooth")

    local btnClear = vgui.Create("DButton", box)
    btnClear:SetText("")
    btnClear:Dock(RIGHT)
    btnClear:SetWide(box:GetTall())
    btnClear.Paint = function(s,w,h)
        if not IsValid(box.Entry) or (box.Entry:GetText() == "" or box.Entry:GetText() == nil) then return end
        if s:IsHovered() then
            libNyx.UI.Draw.Panel(libNyx.UI.Scale(6), libNyx.UI.Scale(5), w-libNyx.UI.Scale(12), h-libNyx.UI.Scale(10), {radius = (h-libNyx.UI.Scale(10))/2, color = Color(30,34,42,110), glass = true})
        end
        surface.SetDrawColor(Style.textColor.r, Style.textColor.g, Style.textColor.b, 210)
        local ic = libNyx.UI.Scale(14)
        surface.SetMaterial(MAT_ICON_CLEAR)
        surface.DrawTexturedRect((w-ic)/2, (h-ic)/2, ic, ic)
    end
    btnClear.DoClick = function()
        if not IsValid(box.Entry) then return end
        box.Entry:SetText("")
        if isfunction(opts.onClear) then opts.onClear() end
        if isfunction(opts.onChange) then opts.onChange("") end
    end

    local entry = vgui.Create("DTextEntry", box)
    entry:SetUpdateOnType(true)
    entry:SetText("")
    entry:SetFont(libNyx.UI.Font(libNyx.UI.Scale(18)))
    entry:SetTextColor(Style.textColor)
    entry:SetCursorColor(Style.textColor)
    entry:SetHistoryEnabled(false)
    if entry.SetDrawLanguageID then entry:SetDrawLanguageID(false) end
    box.Entry = entry

    function box:PerformLayout(w,h)
        local leftPad  = libNyx.UI.Scale(12) + libNyx.UI.Scale(16) + libNyx.UI.Scale(8)
        local rightPad = btnClear:GetWide() + libNyx.UI.Scale(6)
        entry:SetPos(leftPad, 0)
        entry:SetSize(w - leftPad - rightPad, h)
    end

    function entry:Paint(w,h)
        self:DrawTextEntryText(Style.textColor, Color(255,255,255,20), Style.textColor)
    end

    function entry:OnChange()
        if not isfunction(opts.onChange) then return end
        local name = "libnyx_search_" .. tostring(box)
        timer.Create(name, box._debounce, 1, function()
            if IsValid(box) and IsValid(box.Entry) then
                opts.onChange(box.Entry:GetText() or "")
            end
        end)
    end

    function entry:OnEnter()
        if isfunction(opts.onSubmit) then opts.onSubmit(self:GetText() or "") end
    end

    function entry:OnGetFocus()
        box._focused = true
    end

    function entry:OnLoseFocus()
        box._focused = false
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
        local f = self._focused and 1 or 0
        self._focusA = expApproach(self._focusA, f, 9)
        self._gradA  = expApproach(self._gradA, f, 7)
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
            if t ~= self._lastText then
                self._lastText = t
                local len = (utf8 and utf8.len and utf8.len(t)) or #t
                if len > 0 and utf8 and utf8.sub then
                    local ch = utf8.sub(t, len, len)
                    if isCyrillicChar(ch) then
                        id = "RU"
                    end
                end
            end
        end
        if id then self._langID = id end
    end

    function box:Paint(w, h)
        libNyx.UI.Draw.Glass(0, 0, w, h, {radius = self._radius, fill = Color(16,18,24,110), stroke = true, strokeColor = Style.glassStroke, blurIntensity = 1.0})
        local baseCov = 0.45
        local focusedCov = 0.34
        local cov = Lerp(self._gradA, baseCov, focusedCov)
        if not MAT_GRADIENT_L:IsError() then
            local gcol = Color(self._tint.r, self._tint.g, self._tint.b, 70)
            local gw = w * cov
            RNDX.DrawMaterial(self._radius, 0, 0, gw, h, gcol, MAT_GRADIENT_L, 0)
        end
        local ic = libNyx.UI.Scale(16)
        local ix = libNyx.UI.Scale(12)
        surface.SetDrawColor(Style.textColor.r, Style.textColor.g, Style.textColor.b, 190)
        surface.SetMaterial(MAT_ICON_SEARCH)
        surface.DrawTexturedRect(ix, (h-ic)/2, ic, ic)
        if (entry:GetText() == "" or entry:GetText() == nil) and not entry:HasFocus() then
            draw.SimpleText(self._placeholder, libNyx.UI.Font(libNyx.UI.Scale(18)), ix + ic + libNyx.UI.Scale(8), h/2, Color(255,255,255,120), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        local focusAlpha = math.floor(180 * self._focusA)
        if focusAlpha > 1 then
            local sw = math.max(1, math.floor(1 + 2 * self._focusA))
            RNDX.DrawOutlined(self._radius, 0, 0, w, h, Color(self._tint.r, self._tint.g, self._tint.b, focusAlpha), sw, 0)
        end
        if entry:HasFocus() then
            local code = self._langID or "EN"
            local showRU = code == "RU"
            local rightPad = btnClear:GetWide() + libNyx.UI.Scale(6)
            local rx = w - rightPad - libNyx.UI.Scale(6)
            if showRU then
                local ph = libNyx.UI.Scale(18)
                local px = rx - libNyx.UI.Scale(4)
                local py = (h - ph) / 2
                local pw = libNyx.UI.Scale(28)
                libNyx.UI.Draw.Panel(px - pw, py, pw, ph, {radius = ph/2, color = Color(30,34,42,160), glass = true})
                draw.SimpleText("RU", libNyx.UI.Font(libNyx.UI.Scale(14)), px - pw/2, h/2, Style.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                draw.SimpleText(code, libNyx.UI.Font(libNyx.UI.Scale(14)), rx, h/2, Color(255,255,255,150), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end
    end

    function box:GetText() return entry:GetText() end
    function box:SetText(t) entry:SetText(t or "") end
    function box:Focus() entry:RequestFocus() end
    return box
end

libNyx.UI.SmoothScroll = libNyx.UI.SmoothScroll or {}

function libNyx.UI.SmoothScroll.ApplyToScrollPanel(sp, opts)
    if not IsValid(sp) or sp._libnyxSmoothInstalled then return end
    local vbar = sp:GetVBar()
    if not IsValid(vbar) then return end
    sp._libnyxSmoothInstalled = true
    local step = tonumber(opts and opts.step) or libNyx.UI.Scale(90)
    local speed = tonumber(opts and opts.speed) or 18
    local fadeHold = tonumber(opts and opts.fadeHold) or 0.9
    local barW = tonumber(opts and opts.width) or libNyx.UI.Scale(12)
    local r = libNyx.UI.Scale(6)
    vbar:SetWide(barW)
    sp._ss = sp._ss or {}
    sp._ss.cur = vbar:GetScroll()
    sp._ss.tgt = sp._ss.cur
    sp._ss.visA = 0
    sp._ss.lastPing = 0
    sp._ss.drag = false

    local function expApproach(cur, tgt, spd)
        local k = 1 - math.exp(-(spd) * FrameTime())
        return cur + (tgt - cur) * k
    end
    local function maxScroll()
        local can = IsValid(sp:GetCanvas()) and sp:GetCanvas():GetTall() or 0
        return math.max(0, can - sp:GetTall())
    end
    local function ping()
        sp._ss.lastPing = CurTime()
    end

    local oldAddScroll = vbar.AddScroll
    vbar.AddScroll = function(self, dlta)
        local m = maxScroll()
        sp._ss.tgt = math.Clamp(sp._ss.tgt + dlta * step, 0, m)
        ping()
    end

    local oldOnMousePressed = vbar.OnMousePressed
    vbar.OnMousePressed = function(self, mc)
        sp._ss.drag = true
        if isfunction(oldOnMousePressed) then oldOnMousePressed(self, mc) end
        ping()
    end
    local oldOnMouseReleased = vbar.OnMouseReleased
    vbar.OnMouseReleased = function(self, mc)
        sp._ss.drag = false
        if isfunction(oldOnMouseReleased) then oldOnMouseReleased(self, mc) end
        ping()
    end
    if IsValid(vbar.btnGrip) then
        local og = vbar.btnGrip.OnMousePressed
        vbar.btnGrip.OnMousePressed = function(s, mc)
            sp._ss.drag = true
            if isfunction(og) then og(s, mc) end
            ping()
        end
        local org = vbar.btnGrip.OnMouseReleased
        vbar.btnGrip.OnMouseReleased = function(s, mc)
            sp._ss.drag = false
            if isfunction(org) then org(s, mc) end
            ping()
        end
    end

    local MAT_GRADIENT_L = Material("vgui/gradient-l", "noclamp smooth")
    vbar.Paint = function(s, w, h)
        local a = math.floor(130 * sp._ss.visA)
        if a <= 0 then return end
        libNyx.UI.Draw.Panel(0, 0, w, h, {radius = r, color = Color(36,36,44, a), glass = true})
    end
    vbar.btnUp.Paint = function() end
    vbar.btnDown.Paint = function() end
    vbar.btnGrip.Paint = function(s, w, h)
        local a = math.floor(200 * sp._ss.visA)
        if a <= 4 then return end
        libNyx.UI.Draw.Panel(0, 0, w, h, {radius = r, color = Color(24,28,36, a + 35), glass = true, stroke = true, strokeColor = Color(255,255,255, 16)})
        if not MAT_GRADIENT_L:IsError() then
            local c = Style.accentColor
            local g = Color(c.r, c.g, c.b, math.Clamp(110 + math.floor(100 * sp._ss.visA), 80, 200))
            RNDX.DrawMaterial(r, 0, 0, w, h, g, MAT_GRADIENT_L, 0)
        end
    end

    local oldThink = sp.Think
    sp.Think = function(self)
        if isfunction(oldThink) then oldThink(self) end
        local m = maxScroll()
        sp._ss.tgt = math.Clamp(sp._ss.tgt, 0, m)
        if sp._ss.drag then
            sp._ss.cur = vbar:GetScroll()
            sp._ss.tgt = sp._ss.cur
        else
            sp._ss.cur = expApproach(sp._ss.cur, sp._ss.tgt, speed)
            if math.abs(sp._ss.cur - vbar:GetScroll()) > 0.5 then
                vbar:SetScroll(sp._ss.cur)
            end
        end
        local want = 0
        if vbar:IsHovered() or (IsValid(vbar.btnGrip) and vbar.btnGrip:IsHovered()) or sp._ss.drag or (CurTime() - sp._ss.lastPing) < fadeHold then
            want = 1
        end
        sp._ss.visA = expApproach(sp._ss.visA, want, 12)
    end
end

function libNyx.UI.SmoothScroll.InstallUnder(root, opts)
    if not IsValid(root) then return end
    local function apply(p)
        if not IsValid(p) then return end
        if isfunction(p.GetVBar) and IsValid(p:GetVBar()) and p:GetVBar().SetUp then
            libNyx.UI.SmoothScroll.ApplyToScrollPanel(p, opts)
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

function libNyx.UI.InstallGlobalScroll(root, opts)
    libNyx.UI.SmoothScroll.InstallUnder(root, opts)
end

-- libNyx by MaryBlackfild
-- JOIN DISCORD: https://discord.gg/rUEEz4mfXw

