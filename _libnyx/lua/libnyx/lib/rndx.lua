

-- NEW shader and effect "LENS" by MARYBLACKFILD

if SERVER then
    AddCSLuaFile()
    return
end

local bit_band = bit.band
local surface_SetDrawColor = surface.SetDrawColor
local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRectUV = surface.DrawTexturedRectUV
local surface_DrawTexturedRect = surface.DrawTexturedRect
local render_CopyRenderTargetToTexture = render.CopyRenderTargetToTexture
local math_min = math.min
local math_max = math.max
local DisableClipping = DisableClipping
local type = type
local ScrW, ScrH = ScrW, ScrH

local SHADERS_VERSION = "1758909609"
local SHADERS_GMA = [========[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]========]

do
    local s = util.Base64Decode(SHADERS_GMA)
    if not s or #s == 0 then return end
    file.Write("rndx_shaders_" .. SHADERS_VERSION .. ".gma", s)
    game.MountGMA("data/rndx_shaders_" .. SHADERS_VERSION .. ".gma")
end

local function GET_SHADER(n)
    return SHADERS_VERSION:gsub("%.", "_") .. "_" .. n
end

local function NewRT(name, w, h, mode)
    return GetRenderTargetEx(name, w, h, mode or RT_SIZE_LITERAL, MATERIAL_RT_DEPTH_SEPARATE, bit.bor(2,256,4,8), 0, IMAGE_FORMAT_BGRA8888)
end

local BLUR_RT = NewRT("RNDX_BLUR_" .. SHADERS_VERSION .. SysTime(), 1024, 1024, RT_SIZE_LITERAL)
local SCENE_RT = NewRT("RNDX_SCENE_" .. SHADERS_VERSION, ScrW(), ScrH(), RT_SIZE_FULL_FRAME_BUFFER)

local function EnsureSceneRT()
    local sw, sh = ScrW(), ScrH()
    if SCENE_RT:Width() ~= sw or SCENE_RT:Height() ~= sh then
        SCENE_RT = NewRT("RNDX_SCENE_" .. SHADERS_VERSION .. "_" .. sw .. "x" .. sh, sw, sh, RT_SIZE_FULL_FRAME_BUFFER)
    end
end

hook.Remove("PreDrawHUD", "RNDX.SceneGrab." .. SHADERS_VERSION)
hook.Add("PreDrawHUD", "RNDX.SceneGrab." .. SHADERS_VERSION, function()
    EnsureSceneRT()
    render.UpdateScreenEffectTexture()
    render_CopyRenderTargetToTexture(SCENE_RT)
end)

local NEW_FLAG do
    local n = -1
    function NEW_FLAG() n = n + 1 return 2 ^ n end
end

local NO_TL, NO_TR, NO_BL, NO_BR = NEW_FLAG(), NEW_FLAG(), NEW_FLAG(), NEW_FLAG()
local SHAPE_CIRCLE, SHAPE_FIGMA, SHAPE_IOS = NEW_FLAG(), NEW_FLAG(), NEW_FLAG()
local BLUR = NEW_FLAG()

local RNDX = {}

local shader_mat = [==[
screenspace_general
{
    $pixshader ""
    $vertexshader ""

    $basetexture ""
    $texture1    ""
    $texture2    ""
    $texture3    ""

    $ignorez            1
    $vertexcolor        1
    $vertextransform    1
    "<dx90" { $no_draw 1 }

    $copyalpha                 0
    $alpha_blend_color_overlay 0
    $alpha_blend               1
    $linearwrite               1
    $linearread_basetexture    1
    $linearread_texture1       1
    $linearread_texture2       1
    $linearread_texture3       1
}
]==]

local MATRIXES = {}
local function create_shader_mat(name, opts)
    local kv = util.KeyValuesToTable(shader_mat, false, true)
    if opts then for k, v in pairs(opts) do kv[k] = v end end
    local m = CreateMaterial("rndx_" .. name .. "_" .. SysTime(), "screenspace_general", kv)
    MATRIXES[m] = Matrix()
    return m
end

local ROUNDED_MAT = create_shader_mat("rounded", {
    ["$pixshader"] = GET_SHADER("rndx_rounded_ps30"),
    ["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
})
local ROUNDED_TEXTURE_MAT = create_shader_mat("rounded_texture", {
    ["$pixshader"] = GET_SHADER("rndx_rounded_ps30"),
    ["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
    ["$basetexture"] = "loveyoumom",
})

local BLUR_VERTICAL = "$c0_x"
local ROUNDED_BLUR_MAT = create_shader_mat("blur_horizontal", {
    ["$pixshader"] = GET_SHADER("rndx_rounded_blur_ps30"),
    ["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
    ["$basetexture"] = BLUR_RT:GetName(),
    ["$texture1"] = "_rt_FullFrameFB",
})

local SHADOWS_MAT = create_shader_mat("rounded_shadows", {
    ["$pixshader"] = GET_SHADER("rndx_shadows_ps30"),
    ["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
})

local SHADOWS_BLUR_MAT = create_shader_mat("shadows_blur_horizontal", {
    ["$pixshader"] = GET_SHADER("rndx_shadows_blur_ps30"),
    ["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
    ["$basetexture"] = BLUR_RT:GetName(),
    ["$texture1"] = "_rt_FullFrameFB",
})

local LENS_MAT = create_shader_mat("lens", {
    ["$pixshader"]    = GET_SHADER("rndx_lens_ps30"),
    ["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
    ["$basetexture"]  = SCENE_RT:GetName(),
    ["$texture1"]     = "_rt_FullFrameFB"
})

local SHAPES = { [SHAPE_CIRCLE]=2, [SHAPE_FIGMA]=2.2, [SHAPE_IOS]=4 }
local DEFAULT_SHAPE = SHAPE_FIGMA

local MATERIAL_SetTexture = ROUNDED_MAT.SetTexture
local MATERIAL_SetMatrix = ROUNDED_MAT.SetMatrix
local MATERIAL_SetFloat = ROUNDED_MAT.SetFloat
local MATRIX_SetUnpacked = Matrix().SetUnpacked

local MAT
local X, Y, W, H
local TL, TR, BLc, BR
local TEXTURE
local USING_BLUR, BLUR_INTENSITY
local COL_R, COL_G, COL_B, COL_A
local SHAPE, OUTLINE_THICKNESS
local START_ANGLE, END_ANGLE, ROTATION
local CLIP_PANEL
local SHADOW_ENABLED, SHADOW_SPREAD, SHADOW_INTENSITY

local LENS_STRENGTH, LENS_CURVE, LENS_ABERRATION
local LENS_BLUR, LENS_MATTE
local TINT_INTENSITY, TINT_R, TINT_G, TINT_B
local EDGE_STRENGTH, EDGE_THICKNESS, EDGE_SOFT
local HIGHLIGHT_INT, HIGHLIGHT_SIZE

local function RESET_PARAMS()
    MAT=nil
    X,Y,W,H=0,0,0,0
    TL,TR,BLc,BR=0,0,0,0
    TEXTURE=nil
    USING_BLUR, BLUR_INTENSITY=false,1.0
    COL_R,COL_G,COL_B,COL_A=255,255,255,255
    SHAPE,OUTLINE_THICKNESS=SHAPES[DEFAULT_SHAPE],-1
    START_ANGLE,END_ANGLE,ROTATION=0,360,0
    CLIP_PANEL=nil
    SHADOW_ENABLED,SHADOW_SPREAD,SHADOW_INTENSITY=false,0,0
    LENS_STRENGTH=0.38
    LENS_CURVE=0.18
    LENS_ABERRATION=0.002
    LENS_BLUR=0.0
    LENS_MATTE=0.0
    TINT_INTENSITY=0.0
    TINT_R,TINT_G,TINT_B=1.0,1.0,1.0
    EDGE_STRENGTH=0.18
    EDGE_THICKNESS=1.25
    EDGE_SOFT=1.0
    HIGHLIGHT_INT=0.35
    HIGHLIGHT_SIZE=0.9
end

local function normalize_corner_radii()
    local HUGE = math.huge
    local function nzr(x) if x~=x or x<0 then return 0 end local lim=math_min(W,H) if x==HUGE then return lim end return x end
    local function c0(x) if x<0 then return 0 else return x end end
    local a,b,c,d=nzr(TL),nzr(TR),nzr(BLc),nzr(BR)
    local k=math_max(1,(a+b)/W,(c+d)/W,(a+c)/H,(b+d)/H)
    if k>1 then local inv=1/k a,b,c,d=a*inv,b*inv,c*inv,d*inv end
    return c0(a),c0(b),c0(c),c0(d)
end

local function SetupDraw()
    TL,TR,BLc,BR = normalize_corner_radii()
    local m = MATRIXES[MAT]
    MATRIX_SetUnpacked(m,
        BLc,W,OUTLINE_THICKNESS or -1,END_ANGLE,
        BR,H,SHADOW_INTENSITY,ROTATION,
        TR,SHAPE,BLUR_INTENSITY or 1.0,0,
        TL,TEXTURE and 1 or 0,START_ANGLE,0
    )
    MATERIAL_SetMatrix(MAT, "$viewprojmat", m)
    if COL_R then surface_SetDrawColor(COL_R, COL_G, COL_B, COL_A) end
    surface_SetMaterial(MAT)
end

local MANUAL_COLOR = NEW_FLAG()
local DEFAULT_DRAW_FLAGS = DEFAULT_SHAPE

local function draw_rounded(x,y,w,h,col,flags,tl,tr,bl,br,texture,thickness)
    if col and col.a == 0 then return end
    RESET_PARAMS()
    if not flags then flags = DEFAULT_DRAW_FLAGS end
    if bit_band(flags, BLUR) ~= 0 then
        return RNDX.DrawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
    end
    MAT = ROUNDED_MAT
    if texture then
        MAT = ROUNDED_TEXTURE_MAT
        MATERIAL_SetTexture(MAT, "$basetexture", texture)
        TEXTURE = texture
    end
    W, H = w, h
    TL, TR, BLc, BR =
        bit_band(flags, NO_TL)==0 and tl or 0,
        bit_band(flags, NO_TR)==0 and tr or 0,
        bit_band(flags, NO_BL)==0 and bl or 0,
        bit_band(flags, NO_BR)==0 and br or 0
    SHAPE = SHAPES[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or SHAPES[DEFAULT_SHAPE]
    OUTLINE_THICKNESS = thickness
    if bit_band(flags, MANUAL_COLOR) ~= 0 then
        COL_R = nil
    elseif col then
        COL_R, COL_G, COL_B, COL_A = col.r, col.g, col.b, col.a
    else
        COL_R, COL_G, COL_B, COL_A = 255, 255, 255, 255
    end
    SetupDraw()
    return surface_DrawTexturedRectUV(x, y, w, h, -0.015625, -0.015625, 1.015625, 1.015625)
end

function RNDX.Draw(r, x, y, w, h, col, flags) return draw_rounded(x, y, w, h, col, flags, r, r, r, r) end
function RNDX.DrawOutlined(r, x, y, w, h, col, t, flags) return draw_rounded(x, y, w, h, col, flags, r, r, r, r, nil, t or 1) end
function RNDX.DrawTexture(r, x, y, w, h, col, tex, flags) return draw_rounded(x, y, w, h, col, flags, r, r, r, r, tex) end
function RNDX.DrawMaterial(r, x, y, w, h, col, mat, flags) local t = mat:GetTexture("$basetexture") if t then return RNDX.DrawTexture(r, x, y, w, h, col, t, flags) end end
function RNDX.DrawCircle(x, y, r, col, flags) return RNDX.Draw(r/2, x-r/2, y-r/2, r, r, col, (flags or 0) + SHAPE_CIRCLE) end
function RNDX.DrawCircleOutlined(x, y, r, col, t, flags) return RNDX.DrawOutlined(r/2, x-r/2, y-r/2, r, r, col, t, (flags or 0) + SHAPE_CIRCLE) end
function RNDX.DrawCircleTexture(x, y, r, col, tex, flags) return RNDX.DrawTexture(r/2, x-r/2, y-r/2, r, r, col, tex, (flags or 0) + SHAPE_CIRCLE) end
function RNDX.DrawCircleMaterial(x, y, r, col, mat, flags) return RNDX.DrawMaterial(r/2, x-r/2, y-r/2, r, r, col, mat, (flags or 0) + SHAPE_CIRCLE) end

local USE_SHADOWS_BLUR = false
local function draw_blur()
    MAT = USE_SHADOWS_BLUR and SHADOWS_BLUR_MAT or ROUNDED_BLUR_MAT
    COL_R, COL_G, COL_B, COL_A = 255, 255, 255, 255
    SetupDraw()
    render_CopyRenderTargetToTexture(BLUR_RT)
    MATERIAL_SetFloat(MAT, BLUR_VERTICAL, 0)
    surface_DrawTexturedRect(X, Y, W, H)
    render_CopyRenderTargetToTexture(BLUR_RT)
    MATERIAL_SetFloat(MAT, BLUR_VERTICAL, 1)
    surface_DrawTexturedRect(X, Y, W, H)
end

function RNDX.DrawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
    RESET_PARAMS()
    if not flags then flags = DEFAULT_DRAW_FLAGS end
    X, Y = x, y
    W, H = w, h
    TL, TR, BLc, BR =
        bit_band(flags, NO_TL)==0 and tl or 0,
        bit_band(flags, NO_TR)==0 and tr or 0,
        bit_band(flags, NO_BL)==0 and bl or 0,
        bit_band(flags, NO_BR)==0 and br or 0
    SHAPE = SHAPES[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or SHAPES[DEFAULT_SHAPE]
    OUTLINE_THICKNESS = thickness
    draw_blur()
end

local function setup_shadows()
    X = X - SHADOW_SPREAD
    Y = Y - SHADOW_SPREAD
    W = W + SHADOW_SPREAD * 2
    H = H + SHADOW_SPREAD * 2
    TL = TL + SHADOW_SPREAD * 2
    TR = TR + SHADOW_SPREAD * 2
    BLc = BLc + SHADOW_SPREAD * 2
    BR = BR + SHADOW_SPREAD * 2
end

local function draw_shadows(r, g, b, a)
    if USING_BLUR then USE_SHADOWS_BLUR = true draw_blur() USE_SHADOWS_BLUR = false end
    MAT = SHADOWS_MAT
    if r == false then COL_R = nil else COL_R, COL_G, COL_B, COL_A = r, g, b, a end
    SetupDraw()
    surface_DrawTexturedRectUV(X, Y, W, H, -0.015625, -0.015625, 1.015625, 1.015625)
end

function RNDX.DrawShadowsEx(x, y, w, h, col, flags, tl, tr, bl, br, spread, intensity, t)
    if col and col.a == 0 then return end
    local old = DisableClipping(true)
    RESET_PARAMS()
    if not flags then flags = DEFAULT_DRAW_FLAGS end
    X, Y = x, y
    W, H = w, h
    SHADOW_SPREAD = spread or 30
    SHADOW_INTENSITY = intensity or SHADOW_SPREAD * 1.2
    TL, TR, BLc, BR =
        bit_band(flags, NO_TL)==0 and tl or 0,
        bit_band(flags, NO_TR)==0 and tr or 0,
        bit_band(flags, NO_BL)==0 and bl or 0,
        bit_band(flags, NO_BR)==0 and br or 0
    SHAPE = SHAPES[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or SHAPES[DEFAULT_SHAPE]
    OUTLINE_THICKNESS = t
    setup_shadows()
    USING_BLUR = bit_band(flags, BLUR) ~= 0
    if bit_band(flags, MANUAL_COLOR) ~= 0 then
        draw_shadows(false, nil, nil, nil)
    elseif col then
        draw_shadows(col.r, col.g, col.b, col.a)
    else
        draw_shadows(0, 0, 0, 255)
    end
    DisableClipping(old)
end

function RNDX.DrawShadows(r, x, y, w, h, col, spread, intensity, flags)
    return RNDX.DrawShadowsEx(x, y, w, h, col, flags, r, r, r, r, spread, intensity)
end

function RNDX.DrawShadowsOutlined(r, x, y, w, h, col, t, spread, intensity, flags)
    return RNDX.DrawShadowsEx(x, y, w, h, col, flags, r, r, r, r, spread, intensity, t or 1)
end

local LENS_STRENGTH_UNI   = "$c0_y"
local LENS_CURVE_UNI      = "$c0_z"
local LENS_ABERRATION_UNI = "$c0_w"
local LENS_BLUR_UNI       = "$c1_x"
local LENS_MATTE_UNI      = "$c1_y"
local LENS_TINT_INTENS    = "$c1_w"
local LENS_TINT_R         = "$c2_x"
local LENS_TINT_G         = "$c2_y"
local LENS_TINT_B         = "$c2_z"
local LENS_EDGE_STRENGTH  = "$c2_w"
local LENS_EDGE_THICK     = "$c3_x"
local LENS_EDGE_SOFT      = "$c3_y"
local LENS_HIGHLIGHT_INT  = "$c3_z"
local LENS_HIGHLIGHT_SIZE = "$c3_w"

local function PushLensUniforms()
    MATERIAL_SetFloat(LENS_MAT, LENS_STRENGTH_UNI,   LENS_STRENGTH or 0.38)
    MATERIAL_SetFloat(LENS_MAT, LENS_CURVE_UNI,      LENS_CURVE or 0.18)
    MATERIAL_SetFloat(LENS_MAT, LENS_ABERRATION_UNI, LENS_ABERRATION or 0.002)
    MATERIAL_SetFloat(LENS_MAT, LENS_BLUR_UNI,       LENS_BLUR or 0.0)
    MATERIAL_SetFloat(LENS_MAT, LENS_MATTE_UNI,      LENS_MATTE or 0.0)
    MATERIAL_SetFloat(LENS_MAT, LENS_TINT_INTENS,    TINT_INTENSITY or 0.0)
    MATERIAL_SetFloat(LENS_MAT, LENS_TINT_R,         TINT_R or 1.0)
    MATERIAL_SetFloat(LENS_MAT, LENS_TINT_G,         TINT_G or 1.0)
    MATERIAL_SetFloat(LENS_MAT, LENS_TINT_B,         TINT_B or 1.0)
    MATERIAL_SetFloat(LENS_MAT, LENS_EDGE_STRENGTH,  EDGE_STRENGTH or 0.18)
    MATERIAL_SetFloat(LENS_MAT, LENS_EDGE_THICK,     EDGE_THICKNESS or 1.25)
    MATERIAL_SetFloat(LENS_MAT, LENS_EDGE_SOFT,      EDGE_SOFT or 1.0)
    MATERIAL_SetFloat(LENS_MAT, LENS_HIGHLIGHT_INT,  HIGHLIGHT_INT or 0.35)
    MATERIAL_SetFloat(LENS_MAT, LENS_HIGHLIGHT_SIZE, HIGHLIGHT_SIZE or 0.9)
end

local function draw_lens()
    EnsureSceneRT()
    MATERIAL_SetTexture(LENS_MAT, "$basetexture", SCENE_RT:GetName())
    MATERIAL_SetTexture(LENS_MAT, "$texture1", "_rt_FullFrameFB")
    render.UpdateScreenEffectTexture()
    MAT = LENS_MAT
    SetupDraw()
    PushLensUniforms()
    surface_DrawTexturedRect(X, Y, W, H)
end

function RNDX.DrawLens(r, x, y, w, h, col, strength, curve, blurAmount, aberration, flags, tintColor, tintIntensity, edgeStrength, edgeThickness, edgeSoft, matte, highlightInt, highlightSize)
    if col and col.a == 0 then return end
    RESET_PARAMS()
    if not flags then flags = DEFAULT_DRAW_FLAGS end
    X, Y = x, y
    W, H = w, h
    TL, TR, BLc, BR =
        bit_band(flags, NO_TL)==0 and r or 0,
        bit_band(flags, NO_TR)==0 and r or 0,
        bit_band(flags, NO_BL)==0 and r or 0,
        bit_band(flags, NO_BR)==0 and r or 0
    SHAPE = SHAPES[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or SHAPES[DEFAULT_SHAPE]
    if col then COL_R, COL_G, COL_B, COL_A = col.r, col.g, col.b, col.a end
    LENS_STRENGTH  = strength     or LENS_STRENGTH
    LENS_CURVE     = curve        or LENS_CURVE
    LENS_BLUR      = blurAmount   or LENS_BLUR
    LENS_ABERRATION= aberration   or LENS_ABERRATION
    if tintColor then TINT_R,TINT_G,TINT_B = tintColor.r/255, tintColor.g/255, tintColor.b/255 end
    TINT_INTENSITY = tintIntensity or TINT_INTENSITY
    EDGE_STRENGTH  = edgeStrength  or EDGE_STRENGTH
    EDGE_THICKNESS = edgeThickness or EDGE_THICKNESS
    EDGE_SOFT      = edgeSoft      or EDGE_SOFT
    LENS_MATTE     = matte         or LENS_MATTE
    HIGHLIGHT_INT  = highlightInt  or HIGHLIGHT_INT
    HIGHLIGHT_SIZE = highlightSize or HIGHLIGHT_SIZE
    draw_lens()
end

local BASE_FUNCS
BASE_FUNCS = {
    Rad=function(self,rad) TL,TR,BLc,BR=rad,rad,rad,rad return self end,
    Radii=function(self,tl,tr,bl,br) TL,TR,BLc,BR=tl or 0,tr or 0,bl or 0,br or 0 return self end,
    Texture=function(self,tex) TEXTURE=tex return self end,
    Material=function(self,mat) local t=mat:GetTexture("$basetexture") if t then TEXTURE=t end return self end,
    Outline=function(self,t) OUTLINE_THICKNESS=t return self end,
    Shape=function(self,s) SHAPE=SHAPES[s] or 2.2 return self end,
    Color=function(self,c,g,b,a) if type(c)=="number" then COL_R,COL_G,COL_B,COL_A=c,g or 255,b or 255,a or 255 else COL_R,COL_G,COL_B,COL_A=c.r,c.g,c.b,c.a end return self end,
    Blur=function(self,int) int=int or 1.0 int=math_max(int,0) USING_BLUR,BLUR_INTENSITY=true,int return self end,
    Rotation=function(self,a) ROTATION=math.rad(a or 0) return self end,
    StartAngle=function(self,a) START_ANGLE=a or 0 return self end,
    EndAngle=function(self,a) END_ANGLE=a or 360 return self end,
    Shadow=function(self,s,i) SHADOW_ENABLED,SHADOW_SPREAD,SHADOW_INTENSITY=true,s or 30,i or (s or 30)*1.2 return self end,
    Clip=function(self,p) CLIP_PANEL=p return self end,
    Flags=function(self,f)
        f=f or 0
        if bit_band(f,NO_TL)~=0 then TL=0 end
        if bit_band(f,NO_TR)~=0 then TR=0 end
        if bit_band(f,NO_BL)~=0 then BLc=0 end
        if bit_band(f,NO_BR)~=0 then BR=0 end
        local sf=bit_band(f,SHAPE_CIRCLE+SHAPE_FIGMA+SHAPE_IOS)
        if sf~=0 then SHAPE=SHAPES[sf] or SHAPES[DEFAULT_SHAPE] end
        if bit_band(f,BLUR)~=0 then BASE_FUNCS.Blur(self) end
        return self
    end,
}

local RECT = {
    Rad=BASE_FUNCS.Rad, Radii=BASE_FUNCS.Radii, Texture=BASE_FUNCS.Texture, Material=BASE_FUNCS.Material, Outline=BASE_FUNCS.Outline,
    Shape=BASE_FUNCS.Shape, Color=BASE_FUNCS.Color, Blur=BASE_FUNCS.Blur, Rotation=BASE_FUNCS.Rotation,
    StartAngle=BASE_FUNCS.StartAngle, EndAngle=BASE_FUNCS.EndAngle, Clip=BASE_FUNCS.Clip, Shadow=BASE_FUNCS.Shadow,
    Draw=function(self)
        if START_ANGLE==END_ANGLE then return end
        local old
        if SHADOW_ENABLED or CLIP_PANEL then old=DisableClipping(true) end
        if CLIP_PANEL then local sx,sy=CLIP_PANEL:LocalToScreen(0,0) local sw,sh=CLIP_PANEL:GetSize() render.SetScissorRect(sx,sy,sx+sw,sy+sh,true) end
        if SHADOW_ENABLED then
            setup_shadows()
            draw_shadows(COL_R,COL_G,COL_B,COL_A)
        elseif USING_BLUR then
            draw_blur()
        else
            if TEXTURE then MAT=ROUNDED_TEXTURE_MAT MATERIAL_SetTexture(MAT,"$basetexture",TEXTURE) else MAT=ROUNDED_MAT end
            SetupDraw()
            surface_DrawTexturedRectUV(X,Y,W,H,-0.015625,-0.015625,1.015625,1.015625)
        end
        if CLIP_PANEL then render.SetScissorRect(0,0,0,0,false) DisableClipping(old) end
    end,
    GetMaterial=function(self)
        if SHADOW_ENABLED or USING_BLUR then error("You can't get the material of a shadowed or blurred rectangle!") end
        if TEXTURE then MAT=ROUNDED_TEXTURE_MAT MATERIAL_SetTexture(MAT,"$basetexture",TEXTURE) else MAT=ROUNDED_MAT end
        SetupDraw()
        return MAT
    end,
}

local CIRCLE = {
    Texture=BASE_FUNCS.Texture, Material=BASE_FUNCS.Material, Outline=BASE_FUNCS.Outline, Color=BASE_FUNCS.Color, Blur=BASE_FUNCS.Blur,
    Rotation=BASE_FUNCS.Rotation, StartAngle=BASE_FUNCS.StartAngle, EndAngle=BASE_FUNCS.EndAngle, Clip=BASE_FUNCS.Clip, Shadow=BASE_FUNCS.Shadow,
    Draw=RECT.Draw, GetMaterial=RECT.GetMaterial,
}

local LENSRECT = {
    Rad=BASE_FUNCS.Rad, Radii=BASE_FUNCS.Radii, Color=BASE_FUNCS.Color, Rotation=BASE_FUNCS.Rotation,
    StartAngle=BASE_FUNCS.StartAngle, EndAngle=BASE_FUNCS.EndAngle, Clip=BASE_FUNCS.Clip, Flags=BASE_FUNCS.Flags,
    Strength=function(self,v) LENS_STRENGTH=v or LENS_STRENGTH return self end,
    Curve=function(self,v) LENS_CURVE=v or LENS_CURVE return self end,
    Aberration=function(self,v) LENS_ABERRATION=v or LENS_ABERRATION return self end,
    BlurAmount=function(self,v) LENS_BLUR=v or LENS_BLUR return self end,
    Matte=function(self,v) LENS_MATTE=v or LENS_MATTE return self end,
    Tint=function(self,c,i) if c then TINT_R,TINT_G,TINT_B=c.r/255,c.g/255,c.b/255 end TINT_INTENSITY=i or TINT_INTENSITY return self end,
    Edge=function(self,s,t,soft) EDGE_STRENGTH=s or EDGE_STRENGTH EDGE_THICKNESS=t or EDGE_THICKNESS EDGE_SOFT=soft or EDGE_SOFT return self end,
    Highlight=function(self,intensity,size) HIGHLIGHT_INT=intensity or HIGHLIGHT_INT HIGHLIGHT_SIZE=size or HIGHLIGHT_SIZE return self end,
    Draw=function(self)
        local old
        if CLIP_PANEL then old=DisableClipping(true) local sx,sy=CLIP_PANEL:LocalToScreen(0,0) local sw,sh=CLIP_PANEL:GetSize() render.SetScissorRect(sx,sy,sx+sw,sy+sh,true) end
        surface.SetDrawColor(255,255,255,255)
        draw_lens()
        if CLIP_PANEL then render.SetScissorRect(0,0,0,0,false) DisableClipping(old) end
    end,
    GetMaterial=function(self)
        MAT = LENS_MAT
        SetupDraw()
        PushLensUniforms()
        return MAT
    end,
}

local TYPES = {
    Rect=function(x,y,w,h) RESET_PARAMS() MAT=ROUNDED_MAT X,Y,W,H=x,y,w,h return RECT end,
    Circle=function(x,y,r) RESET_PARAMS() MAT=ROUNDED_MAT SHAPE=SHAPES[SHAPE_CIRCLE] X,Y,W,H=x-r/2,y-r/2,r,r r=r/2 TL,TR,BLc,BR=r,r,r,r return CIRCLE end,
    LensRect=function(x,y,w,h) RESET_PARAMS() MAT=LENS_MAT X,Y,W,H=x,y,w,h return LENSRECT end,
}

setmetatable(RNDX, { __call=function() return TYPES end })

RNDX.NO_TL=NO_TL RNDX.NO_TR=NO_TR RNDX.NO_BL=NO_BL RNDX.NO_BR=NO_BR
RNDX.SHAPE_CIRCLE=SHAPE_CIRCLE RNDX.SHAPE_FIGMA=SHAPE_FIGMA RNDX.SHAPE_IOS=SHAPE_IOS
RNDX.BLUR=BLUR

function RNDX.SetFlag(flags, flag, bool) flag=RNDX[flag] or flag if tobool(bool) then return bit.bor(flags, flag) else return bit.band(flags, bit.bnot(flag)) end end
function RNDX.SetDefaultShape(shape) DEFAULT_SHAPE = shape or SHAPE_FIGMA DEFAULT_DRAW_FLAGS = DEFAULT_SHAPE end

return RNDX
