if SERVER then
    AddCSLuaFile()
    return
end

if not libNyx or not libNyx.ui or not libNyx.rndx then return end

local rndx = libNyx.rndx
local ui = libNyx.ui
local style = ui.style
local function scale(n) return (ui and ui.scale and ui.scale(n)) or n end
local function font(sz) return (ui and ui.font and ui.font(scale(sz))) or "DermaDefault" end

local function clampValue(x,a,b) if x<a then return a elseif x>b then return b else return x end end
local function roundStep(x,st) if not st or st<=0 then return x end return math.Round(x/st)*st end
local function stepDecimals(st) local q=tostring(st or "") local p=q:find("%.") return p and (#q-p) or 0 end
local function copyTable(t) local r={} for k,v in pairs(t) do r[k]=v end return r end

local function formatNumber(v)
    if type(v)~="number" then return tostring(v or 0) end
    local out = string.format("%.6f", v):gsub("0+$",""):gsub("%.$","")
    return (out == "" and "0") or out
end

local defaults = {
    size = 300,
    rad = 32,
    strength = 0.012,
    speed = 0,
    sat = 1.06,
    tr = 255, tg = 255, tb = 255,
    tints = 0.06,
    blurAmount = 0.10,
    blurRadius = 0,
    edge = 2.0,
    shimmer = 25.2,
    grain = 0.01,
    alpha = 0.95,
    cursorEnabled = false,
    cursorStrength = 0.018,
    cursorRadius = 120,
    cursorDepth = 0.22,
    cursorSoftness = 1.8,
    cursorSmoothing = 24,
    shape = rndx.SHAPE_IOS,
    shadowEnabled = true,
    shadowSpread = 40,
    shadowIntensity = 56
}

local function createState() return copyTable(defaults) end

local demoCursorKey = "libnyxLiquidPreview"

local function applyDemoCursor(liq, active, screenX, screenY, st)
    if liq.Depth then
        liq:Depth(st.cursorEnabled and (st.cursorDepth or 0) or 0)
    end

    if not st.cursorEnabled then
        if liq.CursorOff then
            liq:CursorOff()
        end
        return liq
    end

    local radius = math.max(st.cursorRadius or 0, 0)
    local strength = math.max(st.cursorStrength or 0, 0)
    local softness = math.max(st.cursorSoftness or 1.8, 0.05)
    local smoothing = math.max(st.cursorSmoothing or 24, 0.1)

    if liq.CursorSmooth then
        return liq:CursorSmooth(
            demoCursorKey,
            active,
            screenX,
            screenY,
            radius,
            strength,
            softness,
            smoothing,
            smoothing * 0.75,
            smoothing
        )
    end

    if active and liq.Cursor then
        return liq:Cursor(screenX, screenY, radius, strength, softness)
    end

    if liq.CursorOff then
        liq:CursorOff()
    end

    return liq
end

local function appendDemoCursorCode(lines, st)
    if not st.cursorEnabled or (st.cursorStrength or 0) <= 0 then
        return
    end

    local smoothing = math.max(st.cursorSmoothing or 24, 0.1)

    table.insert(lines, 1, "local mx, my = gui.MousePos()")
    table.insert(lines, 2, "local inside = mx >= bx and mx <= bx + bw and my >= by and my <= by + bh")
    table.insert(lines, #lines, ":Depth("..formatNumber(st.cursorDepth or 0)..")")
    table.insert(lines, ":CursorSmooth(\"" .. demoCursorKey .. "\", inside, mx, my, "
        .. formatNumber(st.cursorRadius or 0) .. ","
        .. formatNumber(st.cursorStrength or 0) .. ","
        .. formatNumber(st.cursorSoftness or 1.8) .. ","
        .. formatNumber(smoothing) .. ","
        .. formatNumber(smoothing * 0.75) .. ","
        .. formatNumber(smoothing) .. ")")
end

local function open()
    if not ui then return end
    if IsValid(libNyx.LiquidGlassUI) then libNyx.LiquidGlassUI:Remove() return end

    local st = createState()
    local controls = {sliders = {}}

    local rt = vgui.Create("EditablePanel")
    rt:SetSize(ScrW(),ScrH())
    rt:MakePopup()
    gui.EnableScreenClicker(true)
    libNyx.LiquidGlassUI = rt
    ui.disableBackground(rt)
    ui.installGlobalScroll(rt,{step=scale(90),speed=18,fadeHold=0.9,width=scale(12)})

    function rt:OnRemove()
        hook.Remove("OnScreenSizeChanged", "libNyx.LiquidGlass.Relayout")
        gui.EnableScreenClicker(false)
        if rndx.ClearLiquidCursorState then
            rndx.ClearLiquidCursorState(demoCursorKey)
        end
    end
    function rt:OnKeyCodePressed(k) if k==KEY_ESCAPE then self:Remove() end end

    local pad = scale(24)
    local lw  = math.min(scale(380), math.max(scale(300), math.floor(ScrW()*0.26)))

    local nav = vgui.Create("DPanel", rt)
    nav:SetPos(pad, pad)
    nav:SetSize(lw, ScrH() - pad*2)
    ui.disableBackground(nav)
    nav.Paint = function(p,w,h)
        ui.draw.panel(0, 0, w, h, {radius = scale(18), color = style and style.bgColor or Color(10, 10, 14, 150), stroke = true, strokeColor = style and style.glassStroke or Color(255, 255, 255, 22)})
        draw.SimpleText("libNyx · Liquid Glass", font(22), scale(18), scale(16), style and style.textColor or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local bd = vgui.Create("DScrollPanel", nav)
    bd:Dock(FILL)
    bd:DockMargin(scale(12), scale(50), scale(12), scale(12))
    ui.disableBackground(bd)
    ui.smoothScroll.applyToScrollPanel(bd,{step=scale(90),speed=18,fadeHold=0.9,width=scale(12)})
    local vb = bd:GetVBar()
    vb:SetWide(0)
    vb.Paint = function() end
    if vb.btnUp then vb.btnUp:SetVisible(false) end
    if vb.btnDown then vb.btnDown:SetVisible(false) end
    if vb.btnGrip then vb.btnGrip:SetVisible(false) end

    local function title(t)
        local pnl = vgui.Create("DPanel", bd)
        pnl:Dock(TOP)
        pnl:DockMargin(0, scale(10), 0, scale(6))
        pnl:SetTall(scale(30))
        ui.disableBackground(pnl)
        pnl.Paint = function(_,w,h)
            draw.SimpleText(t, font(18), 0, h/2, style and style.textColor or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end

    local function row(h)
        local r = vgui.Create("DPanel", bd)
        r:Dock(TOP)
        r:DockMargin(0, scale(6), 0, 0)
        r:SetTall(h or scale(44))
        ui.disableBackground(r)
        r.Paint = function(_,w,h)
            ui.draw.panel(0,0,w,h,{radius=scale(12),color=style and style.panelColor or Color(20,22,30,130),stroke=true})
        end
        return r
    end

    local clampBox = function() end

    local function slider(lbl,key,min,max,step,tint)
        local r = row(scale(48))
        local L = vgui.Create("DLabel", r)
        L:SetFont(font(18))
        L:SetTextColor(style and style.textColor or color_white)
        L:SetText(lbl)
        L:SizeToContents()
        L:SetPos(scale(12), scale(12))
        local sl = ui.components.createSlider(r,{min=min,max=max,decimals=stepDecimals(step),value=st[key],tint=tint or (style and style.accentColor)})
        sl:Dock(FILL)
        sl:DockMargin(scale(140), 0, scale(12), 0)
        function sl:OnValueChanged(v)
            local val = clampValue(roundStep(v,step),min,max)
            st[key] = val
            if key=="size" then
                clampBox()
            end
        end
        controls.sliders[key] = sl
        return sl
    end

    local function drop(lbl,choices,onPick)
        local r = row(scale(48))
        local L = vgui.Create("DLabel", r)
        L:SetFont(font(18))
        L:SetTextColor(style and style.textColor or color_white)
        L:SetText(lbl)
        L:SizeToContents()
        L:SetPos(scale(12), scale(12))
        local dd = ui.components.createDropdown(r,{choices=choices,placeholder="",onSelect=onPick})
        dd:Dock(RIGHT)
        dd:SetWide(scale(150))
        dd:DockMargin(0, scale(6), scale(8), scale(6))
        return dd
    end

    local function toggle(lbl,init,onChange)
        local r = row(scale(44))
        local sw = ui.components.createCheckbox(r,{variant="switch",checked=init,label=lbl})
        sw:Dock(LEFT)
        sw:DockMargin(scale(10), scale(6), 0, scale(6))
        sw:setOnChange(function(v) if onChange then onChange(v) end end)
        return sw
    end

    title("Layout")
    slider("Size","size",220,520,1)
    controls.sliders.rad = slider("Corner","rad",0,64,1)
    local shapeDD = drop("Shape",{
        {label="iOS"},
        {label="Figma"},
        {label="Circle"},
    },function(lbl)
        if lbl=="iOS" then st.shape=rndx.SHAPE_IOS
        elseif lbl=="Figma" then st.shape=rndx.SHAPE_FIGMA
        else st.shape=rndx.SHAPE_CIRCLE end
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
    slider("Glass Blur","blurAmount",0,0.5,0.01)
    slider("Blur Rad","blurRadius",0,4,0.1)
    slider("Edge Px","edge",0,6,0.1)

    title("FX")
    slider("Shimmer","shimmer",0,50,0.1)
    slider("Grain","grain",0,0.08,0.001)
    slider("Alpha","alpha",0.2,1.0,0.01)

    title("Interaction")
    local swCursor = toggle("Enable Cursor Pull",st.cursorEnabled,function(v) st.cursorEnabled=v end)
    slider("Pull","cursorStrength",0,0.05,0.001)
    slider("Radius","cursorRadius",40,240,1)
    slider("Depth","cursorDepth",0,1,0.01)
    slider("Falloff","cursorSoftness",0.5,4.0,0.05)
    slider("Smoothing","cursorSmoothing",4,48,0.5)

    title("Shadow")
    local swShadow = toggle("Enable Shadow",st.shadowEnabled,function(v) st.shadowEnabled=v end)
    slider("Spread","shadowSpread",0,120,1)
    slider("Intensity","shadowIntensity",0,180,1)

    local bar = vgui.Create("DPanel", nav)
    bar:Dock(BOTTOM)
    bar:SetTall(scale(52))
    ui.disableBackground(bar)
    bar.Paint = function(_,w,h)
        ui.draw.panel(0,0,w,h,{radius=scale(12),color=style and style.cardColor or Color(16,18,24,120),stroke=true})
    end

    local btnW = (lw - scale(8*4)) / 3

    local function shapeLbl()
        if st.shape==rndx.SHAPE_FIGMA then return "Figma"
        elseif st.shape==rndx.SHAPE_CIRCLE then return "Circle"
        else return "iOS" end
    end

    local btnRst = ui.components.createButton(bar,"Reset",{variant="ghost"})
    btnRst:Dock(LEFT)
    btnRst:DockMargin(scale(8), scale(6), scale(6), scale(6))
    btnRst:SetWide(btnW)
    btnRst.onClick = function()
        st = createState()
        for k,ctrl in pairs(controls.sliders) do if IsValid(ctrl) then ctrl:setValue(st[k] or 0) end end
        if IsValid(swCursor) then swCursor:setValue(st.cursorEnabled and true or false) end
        if IsValid(swShadow) then swShadow:setValue(st.shadowEnabled and true or false) end
        if IsValid(shapeDD) then shapeDD:SetValue(shapeLbl()) end
        clampBox()
        if notification and notification.AddLegacy then notification.AddLegacy("libNyx: settings reset.", NOTIFY_HINT, 2) end
        if chat and chat.AddText then chat.AddText(Color(140,180,255), "[libNyx] ", color_white, "Liquid Glass settings reset.") end
    end

    local function shapeConst()
        if st.shape==rndx.SHAPE_FIGMA then return "rndx.SHAPE_FIGMA"
        elseif st.shape==rndx.SHAPE_CIRCLE then return "rndx.SHAPE_CIRCLE"
        else return "rndx.SHAPE_IOS" end
    end

    local function ensurePos()
        local sw,sh = rt:GetWide(), rt:GetTall()
        local bw,bh = st.size, st.size
        local leftBound = pad + lw + scale(12)
        local minX = math.max(leftBound, pad)
        local maxX = sw - pad - bw
        local minY = pad
        local maxY = sh - pad - bh
        if not st.posX then st.posX = sw - bw - pad end
        if not st.posY then st.posY = pad + scale(20) end
        st.posX = clampValue(st.posX, minX, math.max(minX, maxX))
        st.posY = clampValue(st.posY, minY, math.max(minY, maxY))
    end

    local btnCP = ui.components.createButton(bar,"Copy",{variant="ghost"})
    btnCP:Dock(LEFT)
    btnCP:DockMargin(scale(6), scale(6), scale(6), scale(6))
    btnCP:SetWide(btnW)
    btnCP.onClick = function()
        ensurePos()
        local rr = (st.shape==rndx.SHAPE_CIRCLE) and math.floor((st.size or 0)*0.5) or (st.rad or 0)
        local lines = {
            "rndx().Liquid(bx,by,bw,bh)",
            ":Rad("..formatNumber(rr)..")",
            ":Color(255,255,255,255)",
            ":Tint("..math.floor(st.tr or 0)..","..math.floor(st.tg or 0)..","..math.floor(st.tb or 0)..")",
            ":TintStrength("..formatNumber(st.tints or 0)..")",
            ":Saturation("..formatNumber(st.sat or 1)..")",
            ":GlassBlur("..formatNumber(st.blurAmount or 0)..","..formatNumber(st.blurRadius or 0)..")",
            ":EdgeSmooth("..formatNumber(st.edge or 0)..")",
            ":Strength("..formatNumber(st.strength or 0)..")",
            ":Speed("..formatNumber(st.speed or 0)..")",
            ":Shimmer("..formatNumber(st.shimmer or 0)..")",
            ":Grain("..formatNumber(st.grain or 0)..")",
            ":Alpha("..formatNumber(st.alpha or 1)..")",
            ":Flags("..shapeConst()..")"
        }
        appendDemoCursorCode(lines, st)
        if st.shadowEnabled and ((st.shadowSpread or 0)>0 or (st.shadowIntensity or 0)>0) then
            table.insert(lines, #lines, ":Shadow("..formatNumber(st.shadowSpread or 0)..","..formatNumber(st.shadowIntensity or 0)..")")
        end
        local code = table.concat(lines, "\n")
        SetClipboardText(code)
        if notification and notification.AddLegacy then notification.AddLegacy("libNyx: code copied to clipboard.", NOTIFY_GENERIC, 3) end
        if chat and chat.AddText then chat.AddText(Color(140,180,255), "[libNyx] ", color_white, "Liquid Glass builder copied.") end
    end

    local btnX = ui.components.createButton(bar,"Close",{variant="ghost"})
    btnX:Dock(FILL)
    btnX:DockMargin(scale(6), scale(6), scale(8), scale(6))
    btnX.onClick = function() if IsValid(rt) then rt:Remove() end end

    if IsValid(shapeDD) then shapeDD:SetValue(shapeLbl()) end

    local drag = {on=false,dx=0,dy=0}
    rt.hoverAlpha = 0

    local function clampReal()
        local sw,sh = rt:GetWide(), rt:GetTall()
        local bw,bh = st.size, st.size
        local leftBound = pad + lw + scale(12)
        local minX = math.max(leftBound, pad)
        local maxX = sw - pad - bw
        local minY = pad
        local maxY = sh - pad - bh
        if not st.posX then st.posX = sw - bw - pad end
        if not st.posY then st.posY = pad + scale(20) end
        st.posX = clampValue(st.posX, minX, math.max(minX, maxX))
        st.posY = clampValue(st.posY, minY, math.max(minY, maxY))
    end
    clampBox = clampReal
    clampReal()

    hook.Add("OnScreenSizeChanged","libNyx.LiquidGlass.Relayout",function()
        if not IsValid(rt) or not IsValid(nav) or not IsValid(bd) or not IsValid(bar) then return end
        rt:SetSize(ScrW(),ScrH())
        lw = math.min(scale(380), math.max(scale(300), math.floor(ScrW()*0.26)))
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
        if mx == nil or my == nil then
            local tgt = drag.on and 1 or 0
            self.hoverAlpha = Lerp(FrameTime()*10, self.hoverAlpha, tgt)
            self:SetCursor(drag.on and "sizeall" or "arrow")
            return
        end
        local bw,bh = st.size,st.size
        local inside = mx>=st.posX and mx<=st.posX+bw and my>=st.posY and my<=st.posY+bh
        local tgt = (inside or drag.on) and 1 or 0
        self.hoverAlpha = Lerp(FrameTime()*10, self.hoverAlpha, tgt)
        if inside or drag.on then self:SetCursor("sizeall") else self:SetCursor("arrow") end
    end

    local function curRad(w,h)
        if st.shape == rndx.SHAPE_CIRCLE then
            return math.floor(math.min(w,h) * 0.5)
        end
        return st.rad
    end

    function rt:Paint(sw,sh)
        if rndx.EnsureFB then rndx.EnsureFB() end
        clampReal()
        local bx,by = st.posX, st.posY
        local bw,bh = st.size, st.size
        local rr = curRad(bw,bh)
        local mx,my = gui.MousePos()
        local inside = mx>=bx and mx<=bx+bw and my>=by and my<=by+bh

        rndx().Rect(bx,by,bw,bh):Rad(rr):Flags(st.shape):Blur(1):Draw()

        local liq = rndx().Liquid(bx,by,bw,bh)
            :Rad(rr)
            :Color(255,255,255,255)
            :Tint(st.tr,st.tg,st.tb)
            :TintStrength(st.tints)
            :Saturation(st.sat)
            :GlassBlur(st.blurAmount,st.blurRadius)
            :EdgeSmooth(st.edge)
            :Strength(st.strength)
            :Speed(st.speed)
            :Shimmer(st.shimmer)
            :Grain(st.grain)
            :Alpha(st.alpha)
            :Flags(st.shape)

        applyDemoCursor(liq, inside, mx, my, st)
        if st.shadowEnabled and (st.shadowSpread>0 or st.shadowIntensity>0) then liq:Shadow(st.shadowSpread,st.shadowIntensity) end
        liq:Draw()

        local a = self.hoverAlpha
        local c1 = Color(255,255,255, math.floor(235 * (1-a)))
        local c2 = Color(255,255,255, math.floor(235 * a))
        draw.SimpleText("Liquid Glass", "libNyx.Manrope.Liquid", bx + bw/2, by + bh/2, c1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Hold to drag", "libNyx.Manrope.Liquid", bx + bw/2, by + bh/2, c2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

concommand.Add("libnyx_liquid", open)
