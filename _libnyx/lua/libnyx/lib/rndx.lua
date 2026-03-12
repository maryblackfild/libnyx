-- libNyx and LiquidGlass shader by MaryBlackfild
-- JOIN DISCORD: https://discord.gg/rUEEz4mfXw

if SERVER then
	AddCSLuaFile()
	return
end

local RNDX_RUNTIME_VERSION = "liquidglass_runtime_8"

if _G.gSims_RNDX and _G.gSims_RNDX.__runtime_version == RNDX_RUNTIME_VERSION then
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
local math_floor = math.floor
local DisableClipping = DisableClipping
local string_lower = string.lower
local type = type

local SHADERS_VERSION = "1773315959"
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
	bit.bor(2, 256, 4, 8), -- 4, 8 is clamp_s + clamp-t
	0,
	IMAGE_FORMAT_BGRA8888
)

local RAMP_RT = GetRenderTargetEx("RNDX_RAMP" .. SHADERS_VERSION,
	256, 1,
	RT_SIZE_LITERAL,
	MATERIAL_RT_DEPTH_SEPARATE,
	bit.bor(4, 8),
	0,
	IMAGE_FORMAT_BGRA8888
)

local NEW_FLAG; do
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

function RNDX.GetSharedRampTexture()
	return RAMP_RT
end

function RNDX.UpdateSharedRampTexture(colA, colB)
	if not RAMP_RT then return end
	if not colA or not colB then return end

	render.PushRenderTarget(RAMP_RT)
	render.Clear(0, 0, 0, 0, true, true)
	cam.Start2D()
	local w = RAMP_RT:Width()
	for x = 0, w - 1 do
		local t = x / (w - 1)
		local r = Lerp(t, colA.r or 255, colB.r or 255)
		local g = Lerp(t, colA.g or 255, colB.g or 255)
		local b = Lerp(t, colA.b or 255, colB.b or 255)
		local a = Lerp(t, colA.a or 255, colB.a or 255)
		surface_SetDrawColor(r, g, b, a)
		surface.DrawRect(x, 0, 1, 1)
	end
	cam.End2D()
	render.PopRenderTarget()
end

local shader_mat = [==[
screenspace_general
{
	$pixshader ""
	$vertexshader ""

	$basetexture ""
	$texture1	 ""
	$texture2	 ""
	$texture3	 ""

	// Mandatory, don't touch
	$ignorez			1
	$vertexcolor		1
	$vertextransform	1
	"<dx90"
	{
		$no_draw 1
	}

	$copyalpha				 0
	$alpha_blend_color_overlay 0
	$alpha_blend			   1 // for AA
	$linearwrite			   1 // to disable broken gamma correction for colors
	$linearread_basetexture	1 // to disable broken gamma correction for textures
	$linearread_texture1	   1 // to disable broken gamma correction for textures
	$linearread_texture2	   1 // to disable broken gamma correction for textures
	$linearread_texture3	   1 // to disable broken gamma correction for textures
}
]==]

local MATRIXES = {}
if _G.gSims_RNDX_MATREG_VERSION ~= SHADERS_VERSION then
	_G.gSims_RNDX_MATREG = {}
	_G.gSims_RNDX_MATREG_VERSION = SHADERS_VERSION
end
local MATREG = _G.gSims_RNDX_MATREG or {}
_G.gSims_RNDX_MATREG = MATREG

local function create_shader_mat(name, opts)
	local key = "gsims/rndx/" .. SHADERS_VERSION .. "/" .. name .. (opts and opts["$basetexture"] or "")
	local mat = MATREG[key]
	
	if not mat then
		local key_values = util.KeyValuesToTable(shader_mat, false, true)

		if opts then
			for k, v in pairs(opts) do
				key_values[k] = v
			end
		end

		mat = CreateMaterial(
			"rndx_shaders_v" .. SHADERS_VERSION .. name .. SysTime(),
			"screenspace_general",
			key_values
		)

		MATRIXES[mat] = Matrix()
		MATREG[key] = mat
	else
		MATRIXES[mat] = MATRIXES[mat] or Matrix()
	end

	return mat
end

local ROUNDED_MAT = create_shader_mat("rounded", {
	["$pixshader"] = GET_SHADER("rndx_rounded_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
})
local ROUNDED_TEXTURE_MAT = create_shader_mat("rounded_texture", {
	["$pixshader"] = GET_SHADER("rndx_rounded_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
	["$basetexture"] = "loveyoumom", -- if there is no base texture, you can't change it later
})

local BLUR_VERTICAL = "$c0_x"
local C1_X, C1_Y, C1_Z, C1_W = "$c1_x", "$c1_y", "$c1_z", "$c1_w"
local C2_X, C2_Y, C2_Z, C2_W = "$c2_x", "$c2_y", "$c2_z", "$c2_w"

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

-- Liquid Shader Setup
local LIQUID_MAT = create_shader_mat("liquid", {
	["$pixshader"] = GET_SHADER("rndx_liquid_ps30"),
	["$vertexshader"] = GET_SHADER("rndx_vertex_vs30"),
	["$texture1"] = "_rt_FullFrameFB"
})

local LIQ_STATE, LIQ_TIME, LIQ_STR, LIQ_ALPHA = "$c0_x", "$c0_y", "$c0_z", "$c0_w"
local LIQ_SHIM, LIQ_SAT, LIQ_TINTS, LIQ_GRAIN = "$c1_x", "$c1_y", "$c1_z", "$c1_w"
local LIQ_TR, LIQ_TG, LIQ_TB, LIQ_LIGHT_ANGLE = "$c2_x", "$c2_y", "$c2_z", "$c2_w"
local LIQ_BLUR_ALL, LIQ_BLUR_RAD, LIQ_SMOOTHK, LIQ_DEPTH = "$c3_x", "$c3_y", "$c3_z", "$c3_w"

local SHAPES = {
	[SHAPE_CIRCLE] = 2,
	[SHAPE_FIGMA] = 2.2,
	[SHAPE_IOS] = 4,
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

local GRAD_MODE_FLAG, GRAD_CENTER_X, GRAD_CENTER_Y, GRAD_ANGLE
local GRAD_SCALE_X, GRAD_SCALE_Y, GRAD_USE_RAMP_TEX, GRAD_TILING_MODE
local GRAD_RAMP_TEXTURE
local L_CURSOR_X, L_CURSOR_Y, L_CURSOR_RADIUS, L_CURSOR_STRENGTH, L_CURSOR_SOFTNESS

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
	GRAD_MODE_FLAG, GRAD_CENTER_X, GRAD_CENTER_Y, GRAD_ANGLE = 0, 0.5, 0.5, 0
	GRAD_SCALE_X, GRAD_SCALE_Y, GRAD_USE_RAMP_TEX, GRAD_TILING_MODE = 0, 0, false, 0
	GRAD_RAMP_TEXTURE = nil
end

local normalize_corner_radii; do
	local HUGE = math.huge

	local function nzr(x)
		if x ~= x or x < 0 then return 0 end
		local lim = math_min(W, H)
		if x == HUGE then return lim end
		return x
	end

	local function clamp0(x) return x < 0 and 0 or x end

	function normalize_corner_radii()
		local TL, TR, BL, BR = nzr(TL), nzr(TR), nzr(BL), nzr(BR)

		local k = math_max(
			1,
			(TL + TR) / W,
			(BL + BR) / W,
			(TL + BL) / H,
			(TR + BR) / H
		)

		if k > 1 then
			local inv = 1 / k
			TL, TR, BL, BR = TL * inv, TR * inv, BL * inv, BR * inv
		end

		return clamp0(TL), clamp0(TR), clamp0(BL), clamp0(BR)
	end
end

local function SetupDraw()
	local TL, TR, BL, BR = normalize_corner_radii()

	local matrix = MATRIXES[MAT]
	local matrix_c12_w = TEXTURE and 1 or 0
	local matrix_c13_y = SHADOW_INTENSITY
	local matrix_c13_z = BLUR_INTENSITY or 1.0
	local matrix_c14_z = 0
	local matrix_c14_w = 0

	if MAT == LIQUID_MAT then
		matrix_c12_w = L_CURSOR_X or -4096
		matrix_c13_y = L_CURSOR_Y or -4096
		matrix_c13_z = L_CURSOR_RADIUS or 0
		matrix_c14_z = L_CURSOR_STRENGTH or 0
		matrix_c14_w = L_CURSOR_SOFTNESS or 1.6
	end

	MATRIX_SetUnpacked(
		matrix,

		BL, W, OUTLINE_THICKNESS or -1, END_ANGLE,
		BR, H, matrix_c13_y, ROTATION,
		TR, SHAPE, matrix_c13_z, matrix_c14_z,
		TL, matrix_c12_w, START_ANGLE, matrix_c14_w
	)
	MATERIAL_SetMatrix(MAT, "$viewprojmat", matrix)

	if MAT ~= LIQUID_MAT then
		local mode = GRAD_MODE_FLAG or 0
		local cx = GRAD_CENTER_X or 0.5
		local cy = GRAD_CENTER_Y or 0.5
		local gangle = GRAD_ANGLE or 0
		local sx = GRAD_SCALE_X ~= 0 and GRAD_SCALE_X or W
		local sy = GRAD_SCALE_Y ~= 0 and GRAD_SCALE_Y or H
		local use_ramp = GRAD_USE_RAMP_TEX and 1 or 0
		local tiling = GRAD_TILING_MODE or 0

		MATERIAL_SetFloat(MAT, C1_X, cx)
		MATERIAL_SetFloat(MAT, C1_Y, cy)
		MATERIAL_SetFloat(MAT, C1_Z, gangle)
		MATERIAL_SetFloat(MAT, C1_W, mode)
		MATERIAL_SetFloat(MAT, C2_X, sx)
		MATERIAL_SetFloat(MAT, C2_Y, sy)
		MATERIAL_SetFloat(MAT, C2_Z, use_ramp)
		MATERIAL_SetFloat(MAT, C2_W, tiling)

		if GRAD_RAMP_TEXTURE then
			MATERIAL_SetTexture(MAT, "$texture2", GRAD_RAMP_TEXTURE)
		end
	end

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

	MAT = ROUNDED_MAT; if texture then
		MAT = ROUNDED_TEXTURE_MAT
		MATERIAL_SetTexture(MAT, "$basetexture", texture)
		TEXTURE = texture
	end

	W, H = w, h
	TL, TR, BL, BR = bit_band(flags, NO_TL) == 0 and tl or 0,
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

	-- https://github.com/Jaffies/rboxes/blob/main/rboxes.lua
	-- fixes setting $basetexture to ""(none) not working correctly
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
	return RNDX.DrawMaterial(r / 2, x - r / 2, y - r / 2, r, r, col, mat, (flags or 0) + SHAPE_CIRCLE)
end

local USE_SHADOWS_BLUR = false

local function draw_blur()
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
	TL, TR, BL, BR = bit_band(flags, NO_TL) == 0 and tl or 0,
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
	W = W + (SHADOW_SPREAD * 2)
	H = H + (SHADOW_SPREAD * 2)

	TL = TL + (SHADOW_SPREAD * 2)
	TR = TR + (SHADOW_SPREAD * 2)
	BL = BL + (SHADOW_SPREAD * 2)
	BR = BR + (SHADOW_SPREAD * 2)
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
	-- https://github.com/Jaffies/rboxes/blob/main/rboxes.lua
	-- fixes having no $basetexture causing uv to be broken
	surface_DrawTexturedRectUV(X, Y, W, H, -0.015625, -0.015625, 1.015625, 1.015625)
end

function RNDX.DrawShadowsEx(x, y, w, h, col, flags, tl, tr, bl, br, spread, intensity, thickness)
	if col and col.a == 0 then
		return
	end

	local OLD_CLIPPING_STATE = DisableClipping(true)

	RESET_PARAMS()

	if not flags then
		flags = DEFAULT_DRAW_FLAGS
	end

	X, Y = x, y
	W, H = w, h
	SHADOW_SPREAD = spread or 30
	SHADOW_INTENSITY = intensity or SHADOW_SPREAD * 1.2

	TL, TR, BL, BR = bit_band(flags, NO_TL) == 0 and tl or 0,
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

	DisableClipping(OLD_CLIPPING_STATE)
end

function RNDX.DrawShadows(r, x, y, w, h, col, spread, intensity, flags)
	return RNDX.DrawShadowsEx(x, y, w, h, col, flags, r, r, r, r, spread, intensity)
end

function RNDX.DrawShadowsOutlined(r, x, y, w, h, col, thickness, spread, intensity, flags)
	return RNDX.DrawShadowsEx(x, y, w, h, col, flags, r, r, r, r, spread, intensity, thickness or 1)
end

local BASE_FUNCS; BASE_FUNCS = {
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
	Color = function(self, col_or_r, g, b, a)
		if type(col_or_r) == "number" then
			COL_R, COL_G, COL_B, COL_A = col_or_r, g or 255, b or 255, a or 255
		else
			COL_R, COL_G, COL_B, COL_A = col_or_r.r, col_or_r.g, col_or_r.b, col_or_r.a
		end
		return self
	end,
	Blur = function(self, intensity)
		if not intensity then
			intensity = 1.0
		end
		intensity = math_max(intensity, 0)
		USING_BLUR, BLUR_INTENSITY = true, intensity
		return self
	end,
	GradientNone = function(self)
		GRAD_MODE_FLAG = 0
		GRAD_RAMP_TEXTURE = nil
		GRAD_USE_RAMP_TEX = false
		return self
	end,
	GradientTiling = function(self, mode)
		-- 0 clamp, 1 repeat, 2 mirror
		GRAD_TILING_MODE = mode or 0
		return self
	end,
	GradientLinear = function(self, cx, cy, angle_degrees, scale)
		GRAD_MODE_FLAG = 1
		GRAD_CENTER_X, GRAD_CENTER_Y = cx or 0.5, cy or 0.5
		GRAD_ANGLE = math.rad(angle_degrees or 0)
		GRAD_SCALE_X = scale or 0
		GRAD_SCALE_Y = 0
		return self
	end,
	GradientRadial = function(self, cx, cy, scale_x, scale_y)
		GRAD_MODE_FLAG = 2
		GRAD_CENTER_X, GRAD_CENTER_Y = cx or 0.5, cy or 0.5
		GRAD_SCALE_X = scale_x or 0
		GRAD_SCALE_Y = scale_y or GRAD_SCALE_X
		return self
	end,
	GradientConic = function(self, cx, cy, angle_degrees)
		GRAD_MODE_FLAG = 3
		GRAD_CENTER_X, GRAD_CENTER_Y = cx or 0.5, cy or 0.5
		GRAD_ANGLE = math.rad(angle_degrees or 0)
		return self
	end,
	GradientTexture = function(self, texture)
		GRAD_USE_RAMP_TEX = texture ~= nil
		GRAD_RAMP_TEXTURE = texture or nil
		return self
	end,
	Rotation = function(self, angle)
		ROTATION = math.rad(angle or 0)
		return self
	end,
	StartAngle = function(self, angle)
		START_ANGLE = angle or 0
		return self
	end,
	EndAngle = function(self, angle)
		END_ANGLE = angle or 360
		return self
	end,
	Shadow = function(self, spread, intensity)
		SHADOW_ENABLED, SHADOW_SPREAD, SHADOW_INTENSITY = true, spread or 30, intensity or (spread or 30) * 1.2
		return self
	end,
	Clip = function(self, pnl)
		CLIP_PANEL = pnl
		return self
	end,
	Flags = function(self, flags)
		flags = flags or 0

		-- Corner flags
		if bit_band(flags, NO_TL) ~= 0 then
			TL = 0
		end
		if bit_band(flags, NO_TR) ~= 0 then
			TR = 0
		end
		if bit_band(flags, NO_BL) ~= 0 then
			BL = 0
		end
		if bit_band(flags, NO_BR) ~= 0 then
			BR = 0
		end

		-- Shape flags
		local shape_flag = bit_band(flags, SHAPE_CIRCLE + SHAPE_FIGMA + SHAPE_IOS)
		if shape_flag ~= 0 then
			SHAPE = SHAPES[shape_flag] or SHAPES[DEFAULT_SHAPE]
		end

		-- Blur flag
		if bit_band(flags, BLUR) ~= 0 then
			BASE_FUNCS.Blur(self)
		end

		-- Manual color flag
		if bit_band(flags, MANUAL_COLOR) ~= 0 then
			COL_R = nil
		end

		return self
	end,

}

local RECT = {
	Rad = BASE_FUNCS.Rad,
	Radii = BASE_FUNCS.Radii,
	Texture = BASE_FUNCS.Texture,
	Material = BASE_FUNCS.Material,
	Outline = BASE_FUNCS.Outline,
	Shape = BASE_FUNCS.Shape,
	Color = BASE_FUNCS.Color,
	Blur = BASE_FUNCS.Blur,
	GradientNone= BASE_FUNCS.GradientNone,
	GradientTiling= BASE_FUNCS.GradientTiling,
	GradientLinear= BASE_FUNCS.GradientLinear,
	GradientRadial= BASE_FUNCS.GradientRadial,
	GradientConic= BASE_FUNCS.GradientConic,
	GradientTexture= BASE_FUNCS.GradientTexture,
	Rotation = BASE_FUNCS.Rotation,
	StartAngle = BASE_FUNCS.StartAngle,
	EndAngle = BASE_FUNCS.EndAngle,
	Clip = BASE_FUNCS.Clip,
	Shadow = BASE_FUNCS.Shadow,
	Flags = BASE_FUNCS.Flags,

	Draw = function(self)
		if START_ANGLE == END_ANGLE then
			return -- nothing to draw
		end

		local OLD_CLIPPING_STATE
		if SHADOW_ENABLED or CLIP_PANEL then
			OLD_CLIPPING_STATE = DisableClipping(true)
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
			end

			SetupDraw()
			surface_DrawTexturedRectUV(X, Y, W, H, -0.015625, -0.015625, 1.015625, 1.015625)
		end

		if CLIP_PANEL then
			render.SetScissorRect(0, 0, 0, 0, false)
		end

		if SHADOW_ENABLED or CLIP_PANEL then
			DisableClipping(OLD_CLIPPING_STATE)
		end
	end,

	GetMaterial = function(self)
		if SHADOW_ENABLED or USING_BLUR then
			error("You can't get the material of a shadowed or blurred rectangle!")
		end

		if TEXTURE then
			MAT = ROUNDED_TEXTURE_MAT
			MATERIAL_SetTexture(MAT, "$basetexture", TEXTURE)
		end
		SetupDraw()

		return MAT
	end,
}

local CIRCLE = {
	Texture = BASE_FUNCS.Texture,
	Material = BASE_FUNCS.Material,
	Outline = BASE_FUNCS.Outline,
	Color = BASE_FUNCS.Color,
	Blur = BASE_FUNCS.Blur,
	GradientNone= BASE_FUNCS.GradientNone,
	GradientTiling= BASE_FUNCS.GradientTiling,
	GradientLinear= BASE_FUNCS.GradientLinear,
	GradientRadial= BASE_FUNCS.GradientRadial,
	GradientConic= BASE_FUNCS.GradientConic,
	GradientTexture= BASE_FUNCS.GradientTexture,
	Rotation = BASE_FUNCS.Rotation,
	StartAngle = BASE_FUNCS.StartAngle,
	EndAngle = BASE_FUNCS.EndAngle,
	Clip = BASE_FUNCS.Clip,
	Shadow = BASE_FUNCS.Shadow,
	Flags = BASE_FUNCS.Flags,

	Draw = RECT.Draw,
	GetMaterial = RECT.GetMaterial,
}

local LIQUID_STATE_IDLE = 0
local LIQUID_STATE_HOVER = 1
local LIQUID_STATE_PRESSED = 2
local LIQUID_STATE_DISABLED = 3

local LIQUID_STATES = {
	idle = LIQUID_STATE_IDLE,
	hover = LIQUID_STATE_HOVER,
	focus = LIQUID_STATE_HOVER,
	focused = LIQUID_STATE_HOVER,
	pressed = LIQUID_STATE_PRESSED,
	down = LIQUID_STATE_PRESSED,
	disabled = LIQUID_STATE_DISABLED,
}

local L_STATE, L_STRENGTH, L_SPEED, L_SAT = LIQUID_STATE_IDLE, 0.012, 1.0, 1.06
local L_TINTR, L_TINTG, L_TINTB, L_TINTS = 1.0, 1.0, 1.0, 0.06
local L_SHIM, L_GRAIN, L_ALPHA = 0.9, 0.02, 0.95
local L_BLURALL, L_BLURRAD, L_SMOOTHK = 0.0, 0.0, 2.0
local L_LIGHT_ANGLE, L_DEPTH, L_DISPERSION = -2.35619449, 0.0, 0.65
L_CURSOR_X, L_CURSOR_Y = -4096, -4096
L_CURSOR_RADIUS, L_CURSOR_STRENGTH, L_CURSOR_SOFTNESS = 0.0, 0.0, 1.6
local LIQUID_CURSOR_CACHE = _G.gSims_RNDX_LIQUID_CURSOR_CACHE or {}
_G.gSims_RNDX_LIQUID_CURSOR_CACHE = LIQUID_CURSOR_CACHE
local LIQUID_PACK_TURNS = math.pi * 2

local function reset_liquid_runtime()
	L_STATE = LIQUID_STATE_IDLE
	L_CURSOR_X, L_CURSOR_Y = -4096, -4096
	L_CURSOR_RADIUS, L_CURSOR_STRENGTH, L_CURSOR_SOFTNESS = 0.0, 0.0, 1.6
end

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
	State = function(self, state)
		if type(state) == "string" then
			state = LIQUID_STATES[string_lower(state)] or LIQUID_STATE_IDLE
		else
			state = tonumber(state) or LIQUID_STATE_IDLE
		end

		L_STATE = math_min(math_max(state, LIQUID_STATE_IDLE), LIQUID_STATE_DISABLED)
		return self
	end,
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
	LightAngle = function(self, radians)
		L_LIGHT_ANGLE = radians or L_LIGHT_ANGLE
		return self
	end,
	Dispersion = function(self, v)
		L_DISPERSION = math_min(math_max(v or 0, 0), 1)
		return self
	end,
	Depth = function(self, v)
		L_DEPTH = math_min(math_max(v or 0, 0), 1)
		return self
	end,
	Thickness = function(self, v)
		return self:Depth(v)
	end,
	EdgeSmooth = function(self, pixels)
		L_SMOOTHK = math_max(pixels or 0, 0)
		return self
	end,
	Cursor = function(self, screen_x, screen_y, radius, strength, softness)
		L_CURSOR_X = (screen_x or -4096) - X
		L_CURSOR_Y = (screen_y or -4096) - Y
		L_CURSOR_RADIUS = math_max(radius or 0, 0)
		L_CURSOR_STRENGTH = math_max(strength or 0, 0)
		L_CURSOR_SOFTNESS = math_max(softness or 1.6, 0.05)
		return self
	end,
	CursorUV = function(self, u, v, radius, strength, softness)
		L_CURSOR_X = (u or -16) * W
		L_CURSOR_Y = (v or -16) * H
		L_CURSOR_RADIUS = math_max(radius or 0, 0)
		L_CURSOR_STRENGTH = math_max(strength or 0, 0)
		L_CURSOR_SOFTNESS = math_max(softness or 1.6, 0.05)
		return self
	end,
	CursorOff = function(self)
		L_CURSOR_RADIUS, L_CURSOR_STRENGTH = 0.0, 0.0
		return self
	end,
	CursorSmooth = function(self, key, active, screen_x, screen_y, radius, strength, softness, enter_speed, exit_speed, follow_speed)
		local cache_key = key or (tostring(X) .. ":" .. tostring(Y) .. ":" .. tostring(W) .. ":" .. tostring(H))
		local state = LIQUID_CURSOR_CACHE[cache_key]
		local default_x = X + W * 0.5
		local default_y = Y + H * 0.5

		if not state then
			state = {
				blend = 0,
				x = screen_x or default_x,
				y = screen_y or default_y,
			}
			LIQUID_CURSOR_CACHE[cache_key] = state
		end

		local is_active = tobool(active) and (radius or 0) > 0 and (strength or 0) > 0
		local blend_speed = math_min(FrameTime() * (is_active and (enter_speed or 20) or (exit_speed or 14)), 1)
		local follow_rate = math_min(FrameTime() * (follow_speed or 24), 1)
		local target_x = screen_x or state.x or default_x
		local target_y = screen_y or state.y or default_y

		state.blend = Lerp(blend_speed, state.blend or 0, is_active and 1 or 0)
		state.x = Lerp(follow_rate, state.x or target_x, target_x)
		state.y = Lerp(follow_rate, state.y or target_y, target_y)

		if state.blend <= 0.001 then
			return self:CursorOff()
		end

		return self:Cursor(state.x, state.y, radius, (strength or 0) * state.blend, softness)
	end,
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
		
		MAT = LIQUID_MAT
		MATERIAL_SetFloat(MAT, LIQ_STATE, L_STATE)
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
		local dispersion_q = math_floor(L_DISPERSION * 255 + 0.5)
		MATERIAL_SetFloat(MAT, LIQ_LIGHT_ANGLE, L_LIGHT_ANGLE + dispersion_q * LIQUID_PACK_TURNS)
		MATERIAL_SetFloat(MAT, LIQ_BLUR_ALL, L_BLURALL)
		MATERIAL_SetFloat(MAT, LIQ_BLUR_RAD, L_BLURRAD)
		MATERIAL_SetFloat(MAT, LIQ_SMOOTHK, L_SMOOTHK)
		MATERIAL_SetFloat(MAT, LIQ_DEPTH, L_DEPTH)
		
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
		reset_liquid_runtime()
		MAT = LIQUID_MAT
		X, Y, W, H = x, y, w, h
		return LRECT
	end
}

setmetatable(RNDX, {
	__call = function()
		return TYPES
	end
})

-- Flags
RNDX.NO_TL = NO_TL
RNDX.NO_TR = NO_TR
RNDX.NO_BL = NO_BL
RNDX.NO_BR = NO_BR

RNDX.SHAPE_CIRCLE = SHAPE_CIRCLE
RNDX.SHAPE_FIGMA = SHAPE_FIGMA
RNDX.SHAPE_IOS = SHAPE_IOS

RNDX.BLUR = BLUR
RNDX.MANUAL_COLOR = MANUAL_COLOR
RNDX.LIQUID_STATE_IDLE = LIQUID_STATE_IDLE
RNDX.LIQUID_STATE_HOVER = LIQUID_STATE_HOVER
RNDX.LIQUID_STATE_PRESSED = LIQUID_STATE_PRESSED
RNDX.LIQUID_STATE_DISABLED = LIQUID_STATE_DISABLED

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

function RNDX.ClearLiquidCursorState(key)
	LIQUID_CURSOR_CACHE[key] = nil
end

_G.gSims_RNDX = RNDX
RNDX.__runtime_version = RNDX_RUNTIME_VERSION
return RNDX

-- libNyx and LiquidGlass shader by MaryBlackfild
-- JOIN DISCORD: https://discord.gg/rUEEz4mfXw
