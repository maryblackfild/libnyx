-- libNyx and LiquidGlass shader by MaryBlackfild
-- JOIN DISCORD: https://discord.gg/rUEEz4mfXw

if SERVER then
	AddCSLuaFile()
	return
end

if _G.gSims_RNDX then
	return _G.gSims_RNDX
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

local SHADERS_VERSION = "1764892862"
local SHADERS_GMA = [========[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]========]

do
	if _G.gSims_RNDX_ShaderMounted ~= SHADERS_VERSION then
		local dec = util.Base64Decode(SHADERS_GMA)
		if dec and #dec > 0 then
			local path = "rndx_shaders_" .. SHADERS_VERSION .. ".gma"
			file.Write(path, dec)
			game.MountGMA("data/" .. path)
			_G.gSims_RNDX_ShaderMounted = SHADERS_VERSION
		end
	end
end

local function GET_SHADER(name)
	return SHADERS_VERSION:gsub("%.", "_") .. "_" .. name
end

local BLUR_RT = GetRenderTargetEx(
	"RNDX" .. SHADERS_VERSION .. SysTime(),
	1024,
	1024,
	RT_SIZE_LITERAL,
	MATERIAL_RT_DEPTH_SEPARATE,
	bit.bor(2, 256, 4, 8),
	0,
	IMAGE_FORMAT_BGRA8888
)

local NEW_FLAG do
	local flags_n = -1
	function NEW_FLAG()
		flags_n = flags_n + 1
		return 2 ^ flags_n
	end
end

local NO_TL, NO_TR, NO_BL, NO_BR = NEW_FLAG(), NEW_FLAG(), NEW_FLAG(), NEW_FLAG()
local SHAPE_CIRCLE, SHAPE_FIGMA, SHAPE_IOS = NEW_FLAG(), NEW_FLAG(), NEW_FLAG()
local BLUR = NEW_FLAG()

local RNDX = {}

local _fb_frame = -1
function RNDX.EnsureFB()
	local f = FrameNumber()
	if _fb_frame ~= f then
		render.UpdateScreenEffectTexture()
		_fb_frame = f
	end
end

local shader_mat = [==[
screenspace_general
{
	$pixshader ""
	$vertexshader ""

	$basetexture ""
	$texture1    ""
	$texture2    ""
	$texture3    ""

	$ignorez 1
	$vertexcolor 1
	$vertextransform 1
	"<dx90" { $no_draw 1 }
	$copyalpha 0
	$alpha_blend_color_overlay 0
	$alpha_blend 1
	$linearwrite 1
	$linearread_basetexture 1
	$linearread_texture1 1
	$linearread_texture2 1
	$linearread_texture3 1
}
]==]

local MATRIXES = {}

local MATREG = _G.gSims_RNDX_MATREG or {}
_G.gSims_RNDX_MATREG = MATREG

local function create_shader_mat(name, opts)
	local key = "gsims/rndx/" .. name
	local mat = MATREG[key]
	if not mat then
		local kv = util.KeyValuesToTable(shader_mat, false, true)
		if opts then
			for k, v in pairs(opts) do
				kv[k] = v
			end
		end
		mat = CreateMaterial(key, "screenspace_general", kv)
		MATRIXES[mat] = Matrix()
		MATREG[key] = mat
	end
	return mat
end

local ROUNDED_MAT = create_shader_mat("rounded", {
	["$pixshader"] = GET_SHADER("rndx_rounded_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30")
})

local ROUNDED_TEXTURE_MAT = create_shader_mat("rounded_texture", {
	["$pixshader"] = GET_SHADER("rndx_rounded_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
	["$basetexture"] = "loveyoumom"
})

local BLUR_VERTICAL = "$c0_x"

local ROUNDED_BLUR_MAT = create_shader_mat("blur_horizontal", {
	["$pixshader"] = GET_SHADER("rndx_rounded_blur_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
	["$basetexture"] = BLUR_RT:GetName(),
	["$texture1"] = "_rt_FullFrameFB"
})

local SHADOWS_MAT = create_shader_mat("rounded_shadows", {
	["$pixshader"] = GET_SHADER("rndx_shadows_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30")
})

local SHADOWS_BLUR_MAT = create_shader_mat("shadows_blur_horizontal", {
	["$pixshader"] = GET_SHADER("rndx_shadows_blur_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
	["$basetexture"] = BLUR_RT:GetName(),
	["$texture1"] = "_rt_FullFrameFB"
})

local LIQUID_MAT = create_shader_mat("liquid", {
	["$pixshader"] = GET_SHADER("rndx_liquid_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
	["$texture1"] = "_rt_FullFrameFB"
})

local LIQ_TIME, LIQ_STR, LIQ_ALPHA = "$c0_y", "$c0_z", "$c0_w"
local LIQ_SHIM, LIQ_SAT, LIQ_TINTS, LIQ_GRAIN = "$c1_x", "$c1_y", "$c1_z", "$c1_w"
local LIQ_TR, LIQ_TG, LIQ_TB = "$c2_x", "$c2_y", "$c2_z"
local LIQ_BLUR_ALL, LIQ_BLUR_RAD, LIQ_SMOOTHK = "$c3_x", "$c3_y", "$c3_z"

local SHAPES = {
	[SHAPE_CIRCLE] = 2,
	[SHAPE_FIGMA] = 2.2,
	[SHAPE_IOS] = 4
}

local DEFAULT_SHAPE = SHAPE_FIGMA

local MATERIAL_SetTexture = ROUNDED_MAT.SetTexture
local MATERIAL_SetMatrix = ROUNDED_MAT.SetMatrix
local MATERIAL_SetFloat = ROUNDED_MAT.SetFloat
local MATRIX_SetUnpacked = Matrix().SetUnpacked

local MAT
local X, Y, W, H
local TL, TR, BL, BR
local TEXTURE
local USING_BLUR, BLUR_INTENSITY
local COL_R, COL_G, COL_B, COL_A
local SHAPE, OUTLINE_THICKNESS
local START_ANGLE, END_ANGLE, ROTATION
local CLIP_PANEL
local SHADOW_ENABLED, SHADOW_SPREAD, SHADOW_INTENSITY

local function RESET_PARAMS()
	MAT = nil
	X, Y, W, H = 0, 0, 0, 0
	TL, TR, BL, BR = 0, 0, 0, 0
	TEXTURE = nil
	USING_BLUR, BLUR_INTENSITY = false, 1.0
	COL_R, COL_G, COL_B, COL_A = 255, 255, 255, 255
	SHAPE, OUTLINE_THICKNESS = SHAPES[DEFAULT_SHAPE], -1
	START_ANGLE, END_ANGLE, ROTATION = 0, 360, 0
	CLIP_PANEL = nil
	SHADOW_ENABLED, SHADOW_SPREAD, SHADOW_INTENSITY = false, 0, 0
end

local normalize_corner_radii do
	local HUGE = math.huge
	local function nzr(x)
		if x ~= x or x < 0 then
			return 0
		end
		local lim = math_min(W, H)
		if x == HUGE then
			return lim
		end
		return x
	end
	local function clamp0(x)
		return x < 0 and 0 or x
	end
	function normalize_corner_radii()
		local TL_, TR_, BL_, BR_ = nzr(TL), nzr(TR), nzr(BL), nzr(BR)
		local k = math_max(
			1,
			(TL_ + TR_) / W,
			(BL_ + BR_) / W,
			(TL_ + BL_) / H,
			(TR_ + BR_) / H
		)
		if k > 1 then
			local inv = 1 / k
			TL_, TR_, BL_, BR_ = TL_ * inv, TR_ * inv, BL_ * inv, BR_ * inv
		end
		return clamp0(TL_), clamp0(TR_), clamp0(BL_), clamp0(BR_)
	end
end

local function SetupDraw()
	local TL_, TR_, BL_, BR_ = normalize_corner_radii()
	local matrix = MATRIXES[MAT]
	MATRIX_SetUnpacked(
		matrix,
		BL_, W, OUTLINE_THICKNESS or -1, END_ANGLE,
		BR_, H, SHADOW_INTENSITY, ROTATION,
		TR_, SHAPE, BLUR_INTENSITY or 1.0, 0,
		TL_, TEXTURE and 1 or 0, START_ANGLE, 0
	)
	MATERIAL_SetMatrix(MAT, "$viewprojmat", matrix)
	if COL_R then
		surface_SetDrawColor(COL_R, COL_G, COL_B, COL_A)
	end
	surface_SetMaterial(MAT)
end

local MANUAL_COLOR = NEW_FLAG()
local DEFAULT_DRAW_FLAGS = DEFAULT_SHAPE

local function draw_rounded(x, y, w, h, col, flags, tl, tr, bl, br, texture, thickness)
	if col and col.a == 0 then
		return
	end
	RESET_PARAMS()
	if not flags then
		flags = DEFAULT_DRAW_FLAGS
	end
	local using_blur = bit_band(flags, BLUR) ~= 0
	if using_blur then
		return RNDX.DrawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
	end
	MAT = ROUNDED_MAT
	if texture then
		MAT = ROUNDED_TEXTURE_MAT
		MATERIAL_SetTexture(MAT, "$basetexture", texture)
		TEXTURE = texture
	end
	W, H = w, h
	TL, TR, BL, BR =
		bit_band(flags, NO_TL) == 0 and tl or 0,
		bit_band(flags, NO_TR) == 0 and tr or 0,
		bit_band(flags, NO_BL) == 0 and bl or 0,
		bit_band(flags, NO_BR) == 0 and br or 0
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

function RNDX.Draw(r, x, y, w, h, col, flags)
	return draw_rounded(x, y, w, h, col, flags, r, r, r, r)
end

function RNDX.DrawOutlined(r, x, y, w, h, col, thickness, flags)
	return draw_rounded(x, y, w, h, col, flags, r, r, r, r, nil, thickness or 1)
end

function RNDX.DrawTexture(r, x, y, w, h, col, texture, flags)
	return draw_rounded(x, y, w, h, col, flags, r, r, r, r, texture)
end

function RNDX.DrawMaterial(r, x, y, w, h, col, mat, flags)
	local tex = mat:GetTexture("$basetexture")
	if tex then
		return RNDX.DrawTexture(r, x, y, w, h, col, tex, flags)
	end
end

function RNDX.DrawCircle(x, y, r, col, flags)
	return RNDX.Draw(r / 2, x - r / 2, y - r / 2, r, r, col, (flags or 0) + SHAPE_CIRCLE)
end

function RNDX.DrawCircleOutlined(x, y, r, col, thickness, flags)
	return RNDX.DrawOutlined(r / 2, x - r / 2, y - r / 2, r, r, col, thickness, (flags or 0) + SHAPE_CIRCLE)
end

function RNDX.DrawCircleTexture(x, y, r, col, texture, flags)
	return RNDX.DrawTexture(r / 2, x - r / 2, y - r / 2, r, r, col, texture, (flags or 0) + SHAPE_CIRCLE)
end

function RNDX.DrawCircleMaterial(x, y, r, col, mat, flags)
	local tex = mat:GetTexture("$basetexture")
	if tex then
		return RNDX.DrawTexture(r / 2, x - r / 2, y - r / 2, r, r, col, tex, (flags or 0) + SHAPE_CIRCLE)
	end
end

local USE_SHADOWS_BLUR = false

local function draw_blur()
	RNDX.EnsureFB()
	if USE_SHADOWS_BLUR then
		MAT = SHADOWS_BLUR_MAT
	else
		MAT = ROUNDED_BLUR_MAT
	end
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
	if not flags then
		flags = DEFAULT_DRAW_FLAGS
	end
	X, Y = x, y
	W, H = w, h
	TL, TR, BL, BR =
		bit_band(flags, NO_TL) == 0 and tl or 0,
		bit_band(flags, NO_TR) == 0 and tr or 0,
		bit_band(flags, NO_BL) == 0 and bl or 0,
		bit_band(flags, NO_BR) == 0 and br or 0
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
	BL = BL + SHADOW_SPREAD * 2
	BR = BR + SHADOW_SPREAD * 2
end

local function draw_shadows(r, g, b, a)
	if USING_BLUR then
		USE_SHADOWS_BLUR = true
		draw_blur()
		USE_SHADOWS_BLUR = false
	end
	MAT = SHADOWS_MAT
	if r == false then
		COL_R = nil
	else
		COL_R, COL_G, COL_B, COL_A = r, g, b, a
	end
	SetupDraw()
	surface_DrawTexturedRectUV(X, Y, W, H, -0.015625, -0.015625, 1.015625, 1.015625)
end

function RNDX.DrawShadowsEx(x, y, w, h, col, flags, tl, tr, bl, br, spread, intensity, thickness)
	if col and col.a == 0 then
		return
	end
	local OLD = DisableClipping(true)
	RESET_PARAMS()
	if not flags then
		flags = DEFAULT_DRAW_FLAGS
	end
	X, Y = x, y
	W, H = w, h
	SHADOW_SPREAD = spread or 30
	SHADOW_INTENSITY = intensity or SHADOW_SPREAD * 1.2
	TL, TR, BL, BR =
		bit_band(flags, NO_TL) == 0 and tl or 0,
		bit_band(flags, NO_TR) == 0 and tr or 0,
		bit_band(flags, NO_BL) == 0 and bl or 0,
		bit_band(flags, NO_BR) == 0 and br or 0
	SHAPE = SHAPES[bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)] or SHAPES[DEFAULT_SHAPE]
	OUTLINE_THICKNESS = thickness
	setup_shadows()
	USING_BLUR = bit_band(flags, BLUR) ~= 0
	if bit_band(flags, MANUAL_COLOR) ~= 0 then
		draw_shadows(false, nil, nil, nil)
	elseif col then
		draw_shadows(col.r, col.g, col.b, col.a)
	else
		draw_shadows(0, 0, 0, 255)
	end
	DisableClipping(OLD)
end

function RNDX.DrawShadows(r, x, y, w, h, col, spread, intensity, flags)
	return RNDX.DrawShadowsEx(x, y, w, h, col, flags, r, r, r, r, spread, intensity)
end

function RNDX.DrawShadowsOutlined(r, x, y, w, h, col, thickness, spread, intensity, flags)
	return RNDX.DrawShadowsEx(x, y, w, h, col, flags, r, r, r, r, spread, intensity, thickness or 1)
end

local BASE_FUNCS do
	BASE_FUNCS = {
		Rad = function(self, rad)
			TL, TR, BL, BR = rad, rad, rad, rad
			return self
		end,
		Radii = function(self, tl, tr, bl, br)
			TL, TR, BL, BR = tl or 0, tr or 0, bl or 0, br or 0
			return self
		end,
		Texture = function(self, texture)
			TEXTURE = texture
			return self
		end,
		Material = function(self, mat)
			local tex = mat:GetTexture("$basetexture")
			if tex then
				TEXTURE = tex
			end
			return self
		end,
		Outline = function(self, thickness)
			OUTLINE_THICKNESS = thickness
			return self
		end,
		Shape = function(self, shape)
			SHAPE = SHAPES[shape] or 2.2
			return self
		end,
		Color = function(self, cr, g, b, a)
			if type(cr) == "number" then
				COL_R, COL_G, COL_B, COL_A = cr, g or 255, b or 255, a or 255
			else
				COL_R, COL_G, COL_B, COL_A = cr.r, cr.g, cr.b, cr.a
			end
			return self
		end,
		Blur = function(self, intensity)
			intensity = intensity or 1.0
			intensity = math_max(intensity, 0)
			USING_BLUR, BLUR_INTENSITY = true, intensity
			return self
		end,
		Rotation = function(self, ang)
			ROTATION = math.rad(ang or 0)
			return self
		end,
		StartAngle = function(self, a)
			START_ANGLE = a or 0
			return self
		end,
		EndAngle = function(self, a)
			END_ANGLE = a or 360
			return self
		end,
		Shadow = function(self, spread, intensity)
			SHADOW_ENABLED, SHADOW_SPREAD, SHADOW_INTENSITY =
				true, spread or 30, intensity or (spread or 30) * 1.2
			return self
		end,
		Clip = function(self, pnl)
			CLIP_PANEL = pnl
			return self
		end,
		Flags = function(self, flags)
			flags = flags or 0
			if bit_band(flags, NO_TL) ~= 0 then TL = 0 end
			if bit_band(flags, NO_TR) ~= 0 then TR = 0 end
			if bit_band(flags, NO_BL) ~= 0 then BL = 0 end
			if bit_band(flags, NO_BR) ~= 0 then BR = 0 end
			local shape_flag = bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)
			if shape_flag ~= 0 then
				SHAPE = SHAPES[shape_flag] or SHAPES[DEFAULT_SHAPE]
			end
			if bit_band(flags, BLUR) ~= 0 then
				BASE_FUNCS.Blur(self)
			end
			if bit_band(flags, MANUAL_COLOR) ~= 0 then
				COL_R = nil
			end
			return self
		end
	}
end

local RECT = {
	Rad = BASE_FUNCS.Rad,
	Radii = BASE_FUNCS.Radii,
	Texture = BASE_FUNCS.Texture,
	Material = BASE_FUNCS.Material,
	Outline = BASE_FUNCS.Outline,
	Shape = BASE_FUNCS.Shape,
	Color = BASE_FUNCS.Color,
	Blur = BASE_FUNCS.Blur,
	Rotation = BASE_FUNCS.Rotation,
	StartAngle = BASE_FUNCS.StartAngle,
	EndAngle = BASE_FUNCS.EndAngle,
	Clip = BASE_FUNCS.Clip,
	Shadow = BASE_FUNCS.Shadow,
	Flags = BASE_FUNCS.Flags,
	Draw = function(self)
		if START_ANGLE == END_ANGLE then
			return
		end
		local OLD
		if SHADOW_ENABLED or CLIP_PANEL then
			OLD = DisableClipping(true)
		end
		if CLIP_PANEL then
			local sx, sy = CLIP_PANEL:LocalToScreen(0, 0)
			local sw, sh = CLIP_PANEL:GetSize()
			render.SetScissorRect(sx, sy, sx + sw, sy + sh, true)
		end
		if SHADOW_ENABLED then
			setup_shadows()
			draw_shadows(COL_R, COL_G, COL_B, COL_A)
		elseif USING_BLUR then
			draw_blur()
		else
			if TEXTURE then
				MAT = ROUNDED_TEXTURE_MAT
				MATERIAL_SetTexture(MAT, "$basetexture", TEXTURE)
			else
				MAT = ROUNDED_MAT
			end
			SetupDraw()
			surface_DrawTexturedRectUV(X, Y, W, H, -0.015625, -0.015625, 1.015625, 1.015625)
		end
		if CLIP_PANEL then
			render.SetScissorRect(0, 0, 0, 0, false)
		end
		if SHADOW_ENABLED or CLIP_PANEL then
			DisableClipping(OLD)
		end
	end,
	GetMaterial = function(self)
		if SHADOW_ENABLED or USING_BLUR then
			error("You can't get the material of a shadowed or blurred rectangle!")
		end
		if TEXTURE then
			MAT = ROUNDED_TEXTURE_MAT
			MATERIAL_SetTexture(MAT, "$basetexture", TEXTURE)
		else
			MAT = ROUNDED_MAT
		end
		SetupDraw()
		return MAT
	end
}

local CIRCLE = {
	Texture = BASE_FUNCS.Texture,
	Material = BASE_FUNCS.Material,
	Outline = BASE_FUNCS.Outline,
	Color = BASE_FUNCS.Color,
	Blur = BASE_FUNCS.Blur,
	Rotation = BASE_FUNCS.Rotation,
	StartAngle = BASE_FUNCS.StartAngle,
	EndAngle = BASE_FUNCS.EndAngle,
	Clip = BASE_FUNCS.Clip,
	Shadow = BASE_FUNCS.Shadow,
	Flags = BASE_FUNCS.Flags,
	Draw = RECT.Draw,
	GetMaterial = RECT.GetMaterial
}

local L_STRENGTH, L_SPEED, L_SAT = 0.012, 1.0, 1.06
local L_TINTR, L_TINTG, L_TINTB, L_TINTS = 1.0, 1.0, 1.0, 0.06
local L_SHIM, L_GRAIN, L_ALPHA = 0.9, 0.02, 0.95
local L_BLURALL, L_BLURRAD, L_SMOOTHK = 0.0, 0.0, 2.0

local LRECT = {
	Rad = BASE_FUNCS.Rad,
	Radii = BASE_FUNCS.Radii,
	Outline = BASE_FUNCS.Outline,
	Rotation = BASE_FUNCS.Rotation,
	StartAngle = BASE_FUNCS.StartAngle,
	EndAngle = BASE_FUNCS.EndAngle,
	Clip = BASE_FUNCS.Clip,
	Shadow = BASE_FUNCS.Shadow,
	Flags = BASE_FUNCS.Flags,
	Color = BASE_FUNCS.Color,
	Strength = function(self, v)
		L_STRENGTH = math_max(v or 0, 0)
		return self
	end,
	Speed = function(self, v)
		L_SPEED = v or 1.0
		return self
	end,
	Saturation = function(self, v)
		L_SAT = v or 1.0
		return self
	end,
	Tint = function(self, r, g, b)
		if IsColor and IsColor(r) then
			L_TINTR, L_TINTG, L_TINTB = r.r / 255, r.g / 255, r.b / 255
		else
			L_TINTR, L_TINTG, L_TINTB =
				(r or 255) / 255,
				(g or 255) / 255,
				(b or 255) / 255
		end
		return self
	end,
	TintStrength = function(self, v)
		L_TINTS = math_max(v or 0, 0)
		return self
	end,
	Shimmer = function(self, v)
		L_SHIM = math_max(v or 0, 0)
		return self
	end,
	Grain = function(self, v)
		L_GRAIN = math_max(v or 0, 0)
		return self
	end,
	Alpha = function(self, v)
		L_ALPHA = math_max(v or 0, 0)
		return self
	end,
	GlassBlur = function(self, strength, radius)
		L_BLURALL = math_max(strength or 0, 0)
		L_BLURRAD = math_max(radius or 0, 0)
		return self
	end,
	EdgeSmooth = function(self, pixels)
		L_SMOOTHK = math_max(pixels or 0, 0)
		return self
	end,
	Draw = function(self)
		if START_ANGLE == END_ANGLE then
			return
		end
		RNDX.EnsureFB()
		local OLD
		if SHADOW_ENABLED or CLIP_PANEL then
			OLD = DisableClipping(true)
		end
		if CLIP_PANEL then
			local sx, sy = CLIP_PANEL:LocalToScreen(0, 0)
			local sw, sh = CLIP_PANEL:GetSize()
			render.SetScissorRect(sx, sy, sx + sw, sy + sh, true)
		end
		MAT = LIQUID_MAT
		MATERIAL_SetFloat(MAT, LIQ_TIME, RealTime() * L_SPEED)
		MATERIAL_SetFloat(MAT, LIQ_STR, L_STRENGTH)
		MATERIAL_SetFloat(MAT, LIQ_ALPHA, L_ALPHA)
		MATERIAL_SetFloat(MAT, LIQ_SHIM, L_SHIM)
		MATERIAL_SetFloat(MAT, LIQ_SAT, L_SAT)
		MATERIAL_SetFloat(MAT, LIQ_TINTS, L_TINTS)
		MATERIAL_SetFloat(MAT, LIQ_GRAIN, L_GRAIN)
		MATERIAL_SetFloat(MAT, LIQ_TR, L_TINTR)
		MATERIAL_SetFloat(MAT, LIQ_TG, L_TINTG)
		MATERIAL_SetFloat(MAT, LIQ_TB, L_TINTB)
		MATERIAL_SetFloat(MAT, LIQ_BLUR_ALL, L_BLURALL)
		MATERIAL_SetFloat(MAT, LIQ_BLUR_RAD, L_BLURRAD)
		MATERIAL_SetFloat(MAT, LIQ_SMOOTHK, L_SMOOTHK)
		SetupDraw()
		surface_DrawTexturedRectUV(X, Y, W, H, -0.015625, -0.015625, 1.015625, 1.015625)
		if CLIP_PANEL then
			render.SetScissorRect(0, 0, 0, 0, false)
		end
		if SHADOW_ENABLED or CLIP_PANEL then
			DisableClipping(OLD)
		end
	end
}

local TYPES = {
	Rect = function(x, y, w, h)
		RESET_PARAMS()
		MAT = ROUNDED_MAT
		X, Y, W, H = x, y, w, h
		return RECT
	end,
	Circle = function(x, y, r)
		RESET_PARAMS()
		MAT = ROUNDED_MAT
		SHAPE = SHAPES[SHAPE_CIRCLE]
		X, Y, W, H = x - r / 2, y - r / 2, r, r
		r = r / 2
		TL, TR, BL, BR = r, r, r, r
		return CIRCLE
	end,
	Liquid = function(x, y, w, h)
		RESET_PARAMS()
		MAT = LIQUID_MAT
		X, Y, W, H = x, y, w, h
		return LRECT
	end
}

setmetatable(RNDX, { __call = function() return TYPES end })

RNDX.NO_TL = NO_TL
RNDX.NO_TR = NO_TR
RNDX.NO_BL = NO_BL
RNDX.NO_BR = NO_BR
RNDX.SHAPE_CIRCLE = SHAPE_CIRCLE
RNDX.SHAPE_FIGMA = SHAPE_FIGMA
RNDX.SHAPE_IOS = SHAPE_IOS
RNDX.BLUR = BLUR
RNDX.MANUAL_COLOR = MANUAL_COLOR

function RNDX.SetFlag(flags, flag, bool)
	flag = RNDX[flag] or flag
	if tobool(bool) then
		return bit.bor(flags, flag)
	else
		return bit.band(flags, bit.bnot(flag))
	end
end

function RNDX.SetDefaultShape(shape)
	DEFAULT_SHAPE = shape or SHAPE_FIGMA
	DEFAULT_DRAW_FLAGS = DEFAULT_SHAPE
end

_G.gSims_RNDX = RNDX
return RNDX

-- libNyx and LiquidGlass shader by MaryBlackfild
-- JOIN DISCORD: https://discord.gg/rUEEz4mfXw



