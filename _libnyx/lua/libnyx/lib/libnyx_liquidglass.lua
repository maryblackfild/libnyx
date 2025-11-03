-- libNyx and LiquidGlass shader by MaryBlackfild
-- JOIN DISCORD: https://discord.gg/rUEEz4mfXw

if SERVER then AddCSLuaFile() return end

local RNDX = include("libnyx/lib/rndx.lua")

surface.CreateFont("libNyx.Manrope.Liquid",{font="Manrope",size=30,weight=800,antialias=true,extended=true})
--surface.CreateFont("libNyx.UI.18",{font="Manrope",size=18,weight=700,antialias=true,extended=true})
--surface.CreateFont("libNyx.UI.16",{font="Manrope",size=16,weight=600,antialias=true,extended=true})
--surface.CreateFont("libNyx.UI.14",{font="Manrope",size=14,weight=600,antialias=true,extended=true})

CreateClientConVar("libnyx_liquid_size","300",true,false)

local Nyx   = libNyx and libNyx.UI
local Style = Nyx and Nyx.Style
local function s(n) return (Nyx and Nyx.Scale and Nyx.Scale(n)) or n end
local function f(sz) return (Nyx and Nyx.Font and Nyx.Font(s(sz))) or "DermaDefault" end

local function clp(x,a,b) if x<a then return a elseif x>b then return b else return x end end
local function rstep(x,st) if not st or st<=0 then return x end return math.Round(x/st)*st end
local function sdec(st) local q=tostring(st or "") local p=q:find("%.") return p and (#q-p) or 0 end
local function dup(t) local r={} for k,v in pairs(t) do r[k]=v end return r end

local function fmt(v)
    if type(v)~="number" then return tostring(v or 0) end
    local out = string.format("%.6f", v):gsub("0+$",""):gsub("%.$","")
    return (out == "" and "0") or out
end

local DEF = {
    size = tonumber(GetConVar("libnyx_liquid_size"):GetString()) or 300,
    rad = 32,
    strength = 0.012,
    speed = 0,
    sat = 1.06,
    tr = 255, tg = 255, tb = 255,
    tints = 0.06,
    blur_all = 0.10,
    blur_rad = 0,
    edge = 2.0,
    shimmer = 25.2,
    grain = 0.01,
    alpha = 0.95,
    shape = RNDX.SHAPE_IOS,
    shadow_enabled = true,
    shadow_spread = 40,
    shadow_intensity = 56
}

local function mk() return dup(DEF) end

local function open()
    if not Nyx then return end
    if IsValid(libNyx.LiquidGlassUI) then libNyx.LiquidGlassUI:Remove() return end

    local st = mk()
    local ui = { sliders = {} }

    local rt = vgui.Create("EditablePanel")
    rt:SetSize(ScrW(),ScrH())
    rt:MakePopup()
    gui.EnableScreenClicker(true)
    libNyx.LiquidGlassUI = rt
    Nyx.AutoNoBG(rt)
    Nyx.InstallGlobalScroll(rt,{step=s(90),speed=18,fadeHold=0.9,width=s(12)})

    function rt:OnRemove() gui.EnableScreenClicker(false) end
    function rt:OnKeyCodePressed(k) if k==KEY_ESCAPE then self:Remove() end end

    local pad = s(24)
    local lw  = math.min(s(380), math.max(s(300), math.floor(ScrW()*0.26)))

    local nav = vgui.Create("DPanel", rt)
    nav:SetPos(pad, pad)
    nav:SetSize(lw, ScrH() - pad*2)
    Nyx.AutoNoBG(nav)
    nav.Paint = function(p,w,h)
        Nyx.Draw.Glass(0,0,w,h,{
            radius=s(18),
            fill=Style and Style.bgColor or Color(10,10,14,150),
            stroke=true,
            strokeColor=Style and Style.glassStroke or Color(255,255,255,22),
            blurIntensity=1.1
        })
        draw.SimpleText("libNyx · Liquid Glass", f(22), s(18), s(16), Style and Style.textColor or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local bd = vgui.Create("DScrollPanel", nav)
    bd:Dock(FILL)
    bd:DockMargin(s(12), s(50), s(12), s(12))
    Nyx.AutoNoBG(bd)
    Nyx.SmoothScroll.ApplyToScrollPanel(bd,{step=s(90),speed=18,fadeHold=0.9,width=s(12)})
    local vb = bd:GetVBar()
    vb:SetWide(0)
    vb.Paint = function() end
    if vb.btnUp then vb.btnUp:SetVisible(false) end
    if vb.btnDown then vb.btnDown:SetVisible(false) end
    if vb.btnGrip then vb.btnGrip:SetVisible(false) end

    local function title(t)
        local pnl = vgui.Create("DPanel", bd)
        pnl:Dock(TOP)
        pnl:DockMargin(0, s(10), 0, s(6))
        pnl:SetTall(s(30))
        Nyx.AutoNoBG(pnl)
        pnl.Paint = function(_,w,h)
            draw.SimpleText(t, f(18), 0, h/2, Style and Style.textColor or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end

    local function row(h)
        local r = vgui.Create("DPanel", bd)
        r:Dock(TOP)
        r:DockMargin(0, s(6), 0, 0)
        r:SetTall(h or s(44))
        Nyx.AutoNoBG(r)
        r.Paint = function(_,w,h)
            Nyx.Draw.Panel(0,0,w,h,{radius=s(12),color=Style and Style.panelColor or Color(20,22,30,130),glass=true,stroke=true})
        end
        return r
    end

    local clampBox = function() end

    local function slider(lbl,key,min,max,step,tint)
        local r = row(s(48))
        local L = vgui.Create("DLabel", r)
        L:SetFont(f(18))
        L:SetTextColor(Style and Style.textColor or color_white)
        L:SetText(lbl)
        L:SizeToContents()
        L:SetPos(s(12), s(12))
        local sl = Nyx.Components.CreateSlider(r,{min=min,max=max,decimals=sdec(step),value=st[key],tint=tint or (Style and Style.accentColor)})
        sl:Dock(FILL)
        sl:DockMargin(s(140), 0, s(12), 0)
        function sl:OnValueChanged(v)
            local val = clp(rstep(v,step),min,max)
            st[key] = val
            if key=="size" then
                RunConsoleCommand("libnyx_liquid_size", tostring(math.floor(val)))
                clampBox()
            end
        end
        ui.sliders[key] = sl
        return sl
    end

    local function drop(lbl,choices,onPick)
        local r = row(s(48))
        local L = vgui.Create("DLabel", r)
        L:SetFont(f(18))
        L:SetTextColor(Style and Style.textColor or color_white)
        L:SetText(lbl)
        L:SizeToContents()
        L:SetPos(s(12), s(12))
        local dd = Nyx.Components.CreateDropdown(r,{choices=choices,placeholder="",onSelect=onPick})
        dd:Dock(RIGHT)
        dd:SetWide(s(150))
        dd:DockMargin(0, s(6), s(8), s(6))
        return dd
    end

    local function toggle(lbl,init,onChange)
        local r = row(s(44))
        local sw = Nyx.Components.CreateCheckbox(r,{variant="switch",checked=init,label=lbl})
        sw:Dock(LEFT)
        sw:DockMargin(s(10), s(6), 0, s(6))
        sw:SetOnChange(function(v) if onChange then onChange(v) end end)
        return sw
    end

    title("Layout")
    slider("Size","size",220,520,1)
    ui.sliders.rad = slider("Corner","rad",0,64,1)
    local shapeDD = drop("Shape",{
        {label="iOS"},
        {label="Figma"},
        {label="Circle"},
    },function(lbl)
        if lbl=="iOS" then st.shape=RNDX.SHAPE_IOS
        elseif lbl=="Figma" then st.shape=RNDX.SHAPE_FIGMA
        else st.shape=RNDX.SHAPE_CIRCLE end
        clampBox()
    end)

    title("Visuals")
    slider("Strength","strength",0,0.06,0.001)
    slider("Speed","speed",0,4,0.1)
    slider("Saturation","sat",0.5,1.6,0.01)
    slider("Tint R","tr",0,255,1,Color(255,110,110))
    slider("Tint G","tg",0,255,1,Color(110,255,110))
    slider("Tint B","tb",0,255,1,Color(110,110,255))
    slider("Tint Amt","tints",0,0.35,0.005)

    title("Blur & Edge")
    slider("Glass Blur","blur_all",0,0.5,0.01)
    slider("Blur Rad","blur_rad",0,4,0.1)
    slider("Edge Px","edge",0,6,0.1)

    title("FX")
    slider("Shimmer","shimmer",0,50,0.1)
    slider("Grain","grain",0,0.08,0.001)
    slider("Alpha","alpha",0.2,1.0,0.01)

    title("Shadow")
    local swShadow = toggle("Enable Shadow",st.shadow_enabled,function(v) st.shadow_enabled=v end)
    slider("Spread","shadow_spread",0,120,1)
    slider("Intensity","shadow_intensity",0,180,1)

    local bar = vgui.Create("DPanel", nav)
    bar:Dock(BOTTOM)
    bar:SetTall(s(52))
    Nyx.AutoNoBG(bar)
    bar.Paint = function(_,w,h)
        Nyx.Draw.Panel(0,0,w,h,{radius=s(12),color=Style and Style.cardColor or Color(16,18,24,120),glass=true,stroke=true})
    end

    local btnW = (lw - s(8*4)) / 3

    local function shapeLbl()
        if st.shape==RNDX.SHAPE_FIGMA then return "Figma"
        elseif st.shape==RNDX.SHAPE_CIRCLE then return "Circle"
        else return "iOS" end
    end

    local btnRst = Nyx.Components.CreateButton(bar,"Reset",{variant="ghost"})
    btnRst:Dock(LEFT)
    btnRst:DockMargin(s(8), s(6), s(6), s(6))
    btnRst:SetWide(btnW)
    btnRst._onClick = function()
        st = mk()
        RunConsoleCommand("libnyx_liquid_size", tostring(st.size))
        for k,ctrl in pairs(ui.sliders) do if IsValid(ctrl) then ctrl:SetValue(st[k] or 0) end end
        if IsValid(swShadow) then swShadow:SetChecked(st.shadow_enabled and true or false) end
        if IsValid(shapeDD) and shapeDD.SetSelectedLabel then shapeDD:SetSelectedLabel(shapeLbl()) end
        clampBox()
        if notification and notification.AddLegacy then notification.AddLegacy("libNyx: settings reset.", NOTIFY_HINT, 2) end
        if chat and chat.AddText then chat.AddText(Color(140,180,255), "[libNyx] ", color_white, "Liquid Glass settings reset.") end
    end

    local function shapeConst()
        if st.shape==RNDX.SHAPE_FIGMA then return "RNDX.SHAPE_FIGMA"
        elseif st.shape==RNDX.SHAPE_CIRCLE then return "RNDX.SHAPE_CIRCLE"
        else return "RNDX.SHAPE_IOS" end
    end

    local function ensurePos()
        local sw,sh = rt:GetWide(), rt:GetTall()
        local bw,bh = st.size, st.size
        local leftBound = pad + lw + s(12)
        local minX = math.max(leftBound, pad)
        local maxX = sw - pad - bw
        local minY = pad
        local maxY = sh - pad - bh
        if not st.posX then st.posX = sw - bw - pad end
        if not st.posY then st.posY = pad + s(20) end
        st.posX = clp(st.posX, minX, math.max(minX, maxX))
        st.posY = clp(st.posY, minY, math.max(minY, maxY))
    end

    local btnCP = Nyx.Components.CreateButton(bar,"Copy",{variant="ghost"})
    btnCP:Dock(LEFT)
    btnCP:DockMargin(s(6), s(6), s(6), s(6))
    btnCP:SetWide(btnW)
    btnCP._onClick = function()
        ensurePos()
        local rr = (st.shape==RNDX.SHAPE_CIRCLE) and math.floor((st.size or 0)*0.5) or (st.rad or 0)
        local lines = {
            "RNDX().Liquid(bx,by,bw,bh)",
            "            :Rad("..fmt(rr)..")",
            "            :Color(255,255,255,255)",
            "            :Tint("..math.floor(st.tr or 0)..","..math.floor(st.tg or 0)..","..math.floor(st.tb or 0)..")",
            "            :TintStrength("..fmt(st.tints or 0)..")",
            "            :Saturation("..fmt(st.sat or 1)..")",
            "            :GlassBlur("..fmt(st.blur_all or 0)..","..fmt(st.blur_rad or 0)..")",
            "            :EdgeSmooth("..fmt(st.edge or 0)..")",
            "            :Strength("..fmt(st.strength or 0)..")",
            "            :Speed("..fmt(st.speed or 0)..")",
            "            :Shimmer("..fmt(st.shimmer or 0)..")",
            "            :Grain("..fmt(st.grain or 0)..")",
            "            :Alpha("..fmt(st.alpha or 1)..")",
            "            :Flags("..shapeConst()..")"
        }
        if st.shadow_enabled and ((st.shadow_spread or 0)>0 or (st.shadow_intensity or 0)>0) then
            table.insert(lines, #lines, "            :Shadow("..fmt(st.shadow_spread or 0)..","..fmt(st.shadow_intensity or 0)..")")
        end
        local code = table.concat(lines, "\n")
        SetClipboardText(code)
        if notification and notification.AddLegacy then notification.AddLegacy("libNyx: code copied to clipboard.", NOTIFY_GENERIC, 3) end
        if chat and chat.AddText then chat.AddText(Color(140,180,255), "[libNyx] ", color_white, "Liquid Glass builder copied.") end
    end

    local btnX = Nyx.Components.CreateButton(bar,"Close",{variant="ghost"})
    btnX:Dock(FILL)
    btnX:DockMargin(s(6), s(6), s(8), s(6))
    btnX._onClick = function() if IsValid(rt) then rt:Remove() end end

    if IsValid(shapeDD) and shapeDD.SetSelectedLabel then shapeDD:SetSelectedLabel(shapeLbl()) end

    local drag = {on=false,dx=0,dy=0}
    rt._hoverA = 0

    local function clampReal()
        local sw,sh = rt:GetWide(), rt:GetTall()
        local bw,bh = st.size, st.size
        local leftBound = pad + lw + s(12)
        local minX = math.max(leftBound, pad)
        local maxX = sw - pad - bw
        local minY = pad
        local maxY = sh - pad - bh
        if not st.posX then st.posX = sw - bw - pad end
        if not st.posY then st.posY = pad + s(20) end
        st.posX = clp(st.posX, minX, math.max(minX, maxX))
        st.posY = clp(st.posY, minY, math.max(minY, maxY))
    end
    clampBox = clampReal
    clampReal()

    hook.Add("OnScreenSizeChanged","libNyx.LiquidGlass.Relayout",function()
        if not IsValid(rt) or not IsValid(nav) or not IsValid(bd) or not IsValid(bar) then return end
        rt:SetSize(ScrW(),ScrH())
        lw = math.min(s(380), math.max(s(300), math.floor(ScrW()*0.26)))
        nav:SetPos(pad, pad)
        nav:SetSize(lw, ScrH() - pad*2)
        clampReal()
    end)

    function rt:OnMousePressed(mc)
        if mc ~= MOUSE_LEFT then return end
        local mx,my = self:LocalCursorPos()
        local bw,bh = st.size,st.size
        if mx>=st.posX and mx<=st.posX+bw and my>=st.posY and my<=st.posY+bh then
            drag.on = true
            drag.dx = mx - st.posX
            drag.dy = my - st.posY
            self:MouseCapture(true)
        end
    end

    function rt:OnMouseReleased(mc)
        if mc ~= MOUSE_LEFT then return end
        if drag.on then
            drag.on = false
            self:MouseCapture(false)
        end
    end

    function rt:OnCursorMoved(x,y)
        if not drag.on then return end
        st.posX = x - drag.dx
        st.posY = y - drag.dy
        clampReal()
    end

    function rt:Think()
        local mx,my = self:LocalCursorPos()
        local bw,bh = st.size,st.size
        local inside = mx>=st.posX and mx<=st.posX+bw and my>=st.posY and my<=st.posY+bh
        local tgt = (inside or drag.on) and 1 or 0
        self._hoverA = Lerp(FrameTime()*10, self._hoverA, tgt)
        if inside or drag.on then self:SetCursor("sizeall") else self:SetCursor("arrow") end
    end

    local function curRad(w,h)
        if st.shape == RNDX.SHAPE_CIRCLE then
            return math.floor(math.min(w,h) * 0.5)
        end
        return st.rad
    end

    function rt:Paint(sw,sh)
        clampReal()
        local bx,by = st.posX, st.posY
        local bw,bh = st.size, st.size
        local rr = curRad(bw,bh)

        RNDX().Rect(bx,by,bw,bh):Rad(rr):Flags(st.shape):Blur(1):Draw()

        local liq = RNDX().Liquid(bx,by,bw,bh)
            :Rad(rr)
            :Color(255,255,255,255)
            :Tint(st.tr,st.tg,st.tb)
            :TintStrength(st.tints)
            :Saturation(st.sat)
            :GlassBlur(st.blur_all,st.blur_rad)
            :EdgeSmooth(st.edge)
            :Strength(st.strength)
            :Speed(st.speed)
            :Shimmer(st.shimmer)
            :Grain(st.grain)
            :Alpha(st.alpha)
            :Flags(st.shape)

        if st.shadow_enabled and (st.shadow_spread>0 or st.shadow_intensity>0) then liq:Shadow(st.shadow_spread,st.shadow_intensity) end
        liq:Draw()

        local a = self._hoverA
        local c1 = Color(255,255,255, math.floor(235 * (1-a)))
        local c2 = Color(255,255,255, math.floor(235 * a))
        draw.SimpleText("Liquid Glass", "libNyx.Manrope.Liquid", bx + bw/2, by + bh/2, c1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Hold to drag", "libNyx.Manrope.Liquid", bx + bw/2, by + bh/2, c2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

concommand.Add("libnyx_liquid", open)


-- libNyx and LiquidGlass shader by MaryBlackfild
-- JOIN DISCORD: https://discord.gg/rUEEz4mfXw
