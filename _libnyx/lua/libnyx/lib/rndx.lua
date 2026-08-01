
if SERVER then
	AddCSLuaFile()
	return
end

local bitBand = bit.band
local surfaceSetDrawColor = surface.SetDrawColor
local surfaceSetMaterial = surface.SetMaterial
local surfaceDrawTexturedRectUV = surface.DrawTexturedRectUV
local surfaceDrawTexturedRect = surface.DrawTexturedRect
local copyRenderTargetToTexture = render.CopyRenderTargetToTexture
local mathMin = math.min
local mathMax = math.max
local mathFloor = math.floor
local setClippingDisabled = DisableClipping
local stringLower = string.lower
local type = type

local shadersVersion = "1773315959"
local shadersGma = [========[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]========]

do
	local shaderData = util.Base64Decode(shadersGma)
	if shaderData and #shaderData > 0 then
		local shaderPath = "rndx_shaders_" .. shadersVersion .. ".gma"
		if not file.Exists(shaderPath, "DATA") then
			file.Write(shaderPath, shaderData)
		end
		game.MountGMA("data/" .. shaderPath)
	end
end

local function getShader(name)
	return shadersVersion:gsub("%.", "_") .. "_" .. name
end

local blurRenderTarget = GetRenderTargetEx(
	"RNDX" .. shadersVersion .. SysTime(),
	1024,
	1024,
	RT_SIZE_LITERAL,
	MATERIAL_RT_DEPTH_SEPARATE,
	bit.bor(2, 256, 4, 8),
	0,
	IMAGE_FORMAT_BGRA8888
)

local rampRenderTarget = GetRenderTargetEx("RNDX_RAMP" .. shadersVersion,
	256, 1,
	RT_SIZE_LITERAL,
	MATERIAL_RT_DEPTH_SEPARATE,
	bit.bor(4, 8),
	0,
	IMAGE_FORMAT_BGRA8888
)

local newFlag; do
	local flagIndex = -1
	function newFlag()
		flagIndex = flagIndex + 1
		return 2 ^ flagIndex
	end
end

local noTopLeftFlag, noTopRightFlag, noBottomLeftFlag, noBottomRightFlag = newFlag(), newFlag(), newFlag(), newFlag()
local shapeCircleFlag, shapeFigmaFlag, shapeIosFlag = newFlag(), newFlag(), newFlag()
local blurFlag = newFlag()

local RNDX = {}

local framebufferFrame = -1
function RNDX.EnsureFB()
	local f = FrameNumber()
	if framebufferFrame ~= f then
		render.UpdateScreenEffectTexture()
		framebufferFrame = f
	end
end

function RNDX.GetSharedRampTexture()
	return rampRenderTarget
end

function RNDX.UpdateSharedRampTexture(colA, colB)
	if not rampRenderTarget then return end
	if not colA or not colB then return end

	render.PushRenderTarget(rampRenderTarget)
	render.Clear(0, 0, 0, 0, true, true)
	cam.Start2D()
	local w = rampRenderTarget:Width()
	for x = 0, w - 1 do
		local t = x / (w - 1)
		local r = Lerp(t, colA.r or 255, colB.r or 255)
		local g = Lerp(t, colA.g or 255, colB.g or 255)
		local b = Lerp(t, colA.b or 255, colB.b or 255)
		local a = Lerp(t, colA.a or 255, colB.a or 255)
		surfaceSetDrawColor(r, g, b, a)
		surface.DrawRect(x, 0, 1, 1)
	end
	cam.End2D()
	render.PopRenderTarget()
end

local shaderMaterialTemplate = [==[
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

local matrices = {}
local materialRegistry = {}

local function createShaderMaterial(name, opts)
	local key = "gsims/rndx/" .. shadersVersion .. "/" .. name .. (opts and opts["$basetexture"] or "")
	local mat = materialRegistry[key]
	
	if not mat then
		local keyValues = util.KeyValuesToTable(shaderMaterialTemplate, false, true)

		if opts then
			for k, v in pairs(opts) do
				keyValues[k] = v
			end
		end

		mat = CreateMaterial(
			"rndx_shaders_v" .. shadersVersion .. name .. SysTime(),
			"screenspace_general",
			keyValues
		)

		matrices[mat] = Matrix()
		materialRegistry[key] = mat
	else
		matrices[mat] = matrices[mat] or Matrix()
	end

	return mat
end

local roundedMaterial = createShaderMaterial("rounded", {
	["$pixshader"] = getShader("rndx_rounded_ps30"),
	["$vertexshader"] = getShader("rndx_vertex_vs30"),
})
local roundedTextureMaterial = createShaderMaterial("rounded_texture", {
	["$pixshader"] = getShader("rndx_rounded_ps30"),
	["$vertexshader"] = getShader("rndx_vertex_vs30"),
	["$basetexture"] = "loveyoumom",
})

local blurVerticalParameter = "$c0_x"
local c1XParameter, c1YParameter, c1ZParameter, c1WParameter = "$c1_x", "$c1_y", "$c1_z", "$c1_w"
local c2XParameter, c2YParameter, c2ZParameter, c2WParameter = "$c2_x", "$c2_y", "$c2_z", "$c2_w"

local roundedBlurMaterial = createShaderMaterial("blur_horizontal", {
	["$pixshader"] = getShader("rndx_rounded_blur_ps30"),
	["$vertexshader"] = getShader("rndx_vertex_vs30"),
	["$basetexture"] = blurRenderTarget:GetName(),
	["$texture1"] = "_rt_FullFrameFB",
})

local shadowsMaterial = createShaderMaterial("rounded_shadows", {
	["$pixshader"] = getShader("rndx_shadows_ps30"),
	["$vertexshader"] = getShader("rndx_vertex_vs30"),
})

local shadowsBlurMaterial = createShaderMaterial("shadows_blur_horizontal", {
	["$pixshader"] = getShader("rndx_shadows_blur_ps30"),
	["$vertexshader"] = getShader("rndx_vertex_vs30"),
	["$basetexture"] = blurRenderTarget:GetName(),
	["$texture1"] = "_rt_FullFrameFB",
})

local liquidMaterial = createShaderMaterial("liquid", {
	["$pixshader"] = getShader("rndx_liquid_ps30"),
	["$vertexshader"] = getShader("rndx_vertex_vs30"),
	["$texture1"] = "_rt_FullFrameFB"
})

local liquidStateParameter, liquidTimeParameter, liquidStrengthParameter, liquidAlphaParameter = "$c0_x", "$c0_y", "$c0_z", "$c0_w"
local liquidShimmerParameter, liquidSaturationParameter, liquidTintStrengthParameter, liquidGrainParameter = "$c1_x", "$c1_y", "$c1_z", "$c1_w"
local liquidTintRedParameter, liquidTintGreenParameter, liquidTintBlueParameter, liquidLightAngleParameter = "$c2_x", "$c2_y", "$c2_z", "$c2_w"
local liquidBlurAmountParameter, liquidBlurRadiusParameter, liquidSmoothnessParameter, liquidDepthParameter = "$c3_x", "$c3_y", "$c3_z", "$c3_w"

local shapeValues = {
	[shapeCircleFlag] = 2,
	[shapeFigmaFlag] = 2.2,
	[shapeIosFlag] = 4,
}
local defaultShape = shapeFigmaFlag

local materialSetTexture = roundedMaterial.SetTexture
local materialSetMatrix = roundedMaterial.SetMatrix
local materialSetFloat = roundedMaterial.SetFloat
local matrixSetUnpacked = Matrix().SetUnpacked

local activeMaterial
local drawX, drawY, drawWidth, drawHeight
local topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius
local activeTexture
local usingBlur, blurStrength
local colorRed, colorGreen, colorBlue, colorAlpha
local shapeValue, outlineThickness
local startAngle, endAngle, rotation
local clipPanel
local shadowEnabled, shadowSpread, shadowIntensity

local gradientMode, gradientCenterX, gradientCenterY, gradientAngle
local gradientScaleX, gradientScaleY, gradientUsesRampTexture, gradientTilingMode
local gradientRampTexture
local liquidCursorX, liquidCursorY, liquidCursorRadius, liquidCursorStrength, liquidCursorSoftness

local function resetParams()
	activeMaterial = nil
	drawX, drawY, drawWidth, drawHeight = 0, 0, 0, 0
	topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius = 0, 0, 0, 0
	activeTexture = nil
	usingBlur, blurStrength = false, 1.0
	colorRed, colorGreen, colorBlue, colorAlpha = 255, 255, 255, 255
	shapeValue, outlineThickness = shapeValues[defaultShape], -1
	startAngle, endAngle, rotation = 0, 360, 0
	clipPanel = nil
	shadowEnabled, shadowSpread, shadowIntensity = false, 0, 0
	gradientMode, gradientCenterX, gradientCenterY, gradientAngle = 0, 0.5, 0.5, 0
	gradientScaleX, gradientScaleY, gradientUsesRampTexture, gradientTilingMode = 0, 0, false, 0
	gradientRampTexture = nil
end

local normalizeCornerRadii; do
	local hugeValue = math.huge

	local function nzr(x)
		if x ~= x or x < 0 then return 0 end
		local lim = mathMin(drawWidth, drawHeight)
		if x == hugeValue then return lim end
		return x
	end

	local function clamp0(x) return x < 0 and 0 or x end

	function normalizeCornerRadii()
		local topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius = nzr(topLeftRadius), nzr(topRightRadius), nzr(bottomLeftRadius), nzr(bottomRightRadius)

		local k = mathMax(
			1,
			(topLeftRadius + topRightRadius) / drawWidth,
			(bottomLeftRadius + bottomRightRadius) / drawWidth,
			(topLeftRadius + bottomLeftRadius) / drawHeight,
			(topRightRadius + bottomRightRadius) / drawHeight
		)

		if k > 1 then
			local inv = 1 / k
			topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius = topLeftRadius * inv, topRightRadius * inv, bottomLeftRadius * inv, bottomRightRadius * inv
		end

		return clamp0(topLeftRadius), clamp0(topRightRadius), clamp0(bottomLeftRadius), clamp0(bottomRightRadius)
	end
end

local function setupDraw()
	local topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius = normalizeCornerRadii()

	local matrix = matrices[activeMaterial]
	local matrixC12W = activeTexture and 1 or 0
	local matrixC13Y = shadowIntensity
	local matrixC13Z = blurStrength or 1.0
	local matrixC14Z = 0
	local matrixC14W = 0

	if activeMaterial == liquidMaterial then
		matrixC12W = liquidCursorX or -4096
		matrixC13Y = liquidCursorY or -4096
		matrixC13Z = liquidCursorRadius or 0
		matrixC14Z = liquidCursorStrength or 0
		matrixC14W = liquidCursorSoftness or 1.6
	end

	matrixSetUnpacked(
		matrix,

		bottomLeftRadius, drawWidth, outlineThickness or -1, endAngle,
		bottomRightRadius, drawHeight, matrixC13Y, rotation,
		topRightRadius, shapeValue, matrixC13Z, matrixC14Z,
		topLeftRadius, matrixC12W, startAngle, matrixC14W
	)
	materialSetMatrix(activeMaterial, "$viewprojmat", matrix)

	if activeMaterial ~= liquidMaterial then
		local mode = gradientMode or 0
		local cx = gradientCenterX or 0.5
		local cy = gradientCenterY or 0.5
		local gangle = gradientAngle or 0
		local sx = gradientScaleX ~= 0 and gradientScaleX or drawWidth
		local sy = gradientScaleY ~= 0 and gradientScaleY or drawHeight
		local useRamp = gradientUsesRampTexture and 1 or 0
		local tiling = gradientTilingMode or 0

		materialSetFloat(activeMaterial, c1XParameter, cx)
		materialSetFloat(activeMaterial, c1YParameter, cy)
		materialSetFloat(activeMaterial, c1ZParameter, gangle)
		materialSetFloat(activeMaterial, c1WParameter, mode)
		materialSetFloat(activeMaterial, c2XParameter, sx)
		materialSetFloat(activeMaterial, c2YParameter, sy)
		materialSetFloat(activeMaterial, c2ZParameter, useRamp)
		materialSetFloat(activeMaterial, c2WParameter, tiling)

		if gradientRampTexture then
			materialSetTexture(activeMaterial, "$texture2", gradientRampTexture)
		end
	end

	if colorRed then
		surfaceSetDrawColor(colorRed, colorGreen, colorBlue, colorAlpha)
	end

	surfaceSetMaterial(activeMaterial)
end

local manualColorFlag = newFlag()
local defaultDrawFlags = defaultShape

local function drawRounded(x, y, w, h, col, flags, tl, tr, bl, br, texture, thickness)
	if col and col.a == 0 then
		return
	end

	resetParams()

	if not flags then
		flags = defaultDrawFlags
	end

	local usingBlur = bitBand(flags, blurFlag) ~= 0
	if usingBlur then
		return RNDX.DrawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
	end

	activeMaterial = roundedMaterial; if texture then
		activeMaterial = roundedTextureMaterial
		materialSetTexture(activeMaterial, "$basetexture", texture)
		activeTexture = texture
	end

	drawWidth, drawHeight = w, h
	topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius = bitBand(flags, noTopLeftFlag) == 0 and tl or 0,
		bitBand(flags, noTopRightFlag) == 0 and tr or 0,
		bitBand(flags, noBottomLeftFlag) == 0 and bl or 0,
		bitBand(flags, noBottomRightFlag) == 0 and br or 0
	shapeValue = shapeValues[bitBand(flags, shapeCircleFlag + shapeFigmaFlag + shapeIosFlag)] or shapeValues[defaultShape]
	outlineThickness = thickness

	if bitBand(flags, manualColorFlag) ~= 0 then
		colorRed = nil
	elseif col then
		colorRed, colorGreen, colorBlue, colorAlpha = col.r, col.g, col.b, col.a
	else
		colorRed, colorGreen, colorBlue, colorAlpha = 255, 255, 255, 255
	end

	setupDraw()

	return surfaceDrawTexturedRectUV(x, y, w, h, -0.015625, -0.015625, 1.015625, 1.015625)
end

function RNDX.Draw(r, x, y, w, h, col, flags)
	return drawRounded(x, y, w, h, col, flags, r, r, r, r)
end

function RNDX.DrawOutlined(r, x, y, w, h, col, thickness, flags)
	return drawRounded(x, y, w, h, col, flags, r, r, r, r, nil, thickness or 1)
end

function RNDX.DrawTexture(r, x, y, w, h, col, texture, flags)
	return drawRounded(x, y, w, h, col, flags, r, r, r, r, texture)
end

function RNDX.DrawMaterial(r, x, y, w, h, col, mat, flags)
	local tex = mat:GetTexture("$basetexture")
	if tex then
		return RNDX.DrawTexture(r, x, y, w, h, col, tex, flags)
	end
end

function RNDX.DrawCircle(x, y, r, col, flags)
	return RNDX.Draw(r / 2, x - r / 2, y - r / 2, r, r, col, (flags or 0) + shapeCircleFlag)
end

function RNDX.DrawCircleOutlined(x, y, r, col, thickness, flags)
	return RNDX.DrawOutlined(r / 2, x - r / 2, y - r / 2, r, r, col, thickness, (flags or 0) + shapeCircleFlag)
end

function RNDX.DrawCircleTexture(x, y, r, col, texture, flags)
	return RNDX.DrawTexture(r / 2, x - r / 2, y - r / 2, r, r, col, texture, (flags or 0) + shapeCircleFlag)
end

function RNDX.DrawCircleMaterial(x, y, r, col, mat, flags)
	return RNDX.DrawMaterial(r / 2, x - r / 2, y - r / 2, r, r, col, mat, (flags or 0) + shapeCircleFlag)
end

local useShadowBlur = false

local function drawBlur()
	if useShadowBlur then
		activeMaterial = shadowsBlurMaterial
	else
		activeMaterial = roundedBlurMaterial
	end

	colorRed, colorGreen, colorBlue, colorAlpha = 255, 255, 255, 255
	setupDraw()

	copyRenderTargetToTexture(blurRenderTarget)
	materialSetFloat(activeMaterial, blurVerticalParameter, 0)
	surfaceDrawTexturedRect(drawX, drawY, drawWidth, drawHeight)

	copyRenderTargetToTexture(blurRenderTarget)
	materialSetFloat(activeMaterial, blurVerticalParameter, 1)
	surfaceDrawTexturedRect(drawX, drawY, drawWidth, drawHeight)
end

function RNDX.DrawBlur(x, y, w, h, flags, tl, tr, bl, br, thickness)
	resetParams()

	if not flags then
		flags = defaultDrawFlags
	end

	drawX, drawY = x, y
	drawWidth, drawHeight = w, h
	topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius = bitBand(flags, noTopLeftFlag) == 0 and tl or 0,
		bitBand(flags, noTopRightFlag) == 0 and tr or 0,
		bitBand(flags, noBottomLeftFlag) == 0 and bl or 0,
		bitBand(flags, noBottomRightFlag) == 0 and br or 0
	shapeValue = shapeValues[bitBand(flags, shapeCircleFlag + shapeFigmaFlag + shapeIosFlag)] or shapeValues[defaultShape]
	outlineThickness = thickness

	drawBlur()
end

local function setupShadows()
	drawX = drawX - shadowSpread
	drawY = drawY - shadowSpread
	drawWidth = drawWidth + (shadowSpread * 2)
	drawHeight = drawHeight + (shadowSpread * 2)

	topLeftRadius = topLeftRadius + (shadowSpread * 2)
	topRightRadius = topRightRadius + (shadowSpread * 2)
	bottomLeftRadius = bottomLeftRadius + (shadowSpread * 2)
	bottomRightRadius = bottomRightRadius + (shadowSpread * 2)
end

local function drawShadows(r, g, b, a)
	if usingBlur then
		useShadowBlur = true
		drawBlur()
		useShadowBlur = false
	end

	activeMaterial = shadowsMaterial

	if r == false then
		colorRed = nil
	else
		colorRed, colorGreen, colorBlue, colorAlpha = r, g, b, a
	end

	setupDraw()
	surfaceDrawTexturedRectUV(drawX, drawY, drawWidth, drawHeight, -0.015625, -0.015625, 1.015625, 1.015625)
end

function RNDX.DrawShadowsEx(x, y, w, h, col, flags, tl, tr, bl, br, spread, intensity, thickness)
	if col and col.a == 0 then
		return
	end

	local oldClippingState = setClippingDisabled(true)

	resetParams()

	if not flags then
		flags = defaultDrawFlags
	end

	drawX, drawY = x, y
	drawWidth, drawHeight = w, h
	shadowSpread = spread or 30
	shadowIntensity = intensity or shadowSpread * 1.2

	topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius = bitBand(flags, noTopLeftFlag) == 0 and tl or 0,
		bitBand(flags, noTopRightFlag) == 0 and tr or 0,
		bitBand(flags, noBottomLeftFlag) == 0 and bl or 0,
		bitBand(flags, noBottomRightFlag) == 0 and br or 0

	shapeValue = shapeValues[bitBand(flags, shapeCircleFlag + shapeFigmaFlag + shapeIosFlag)] or shapeValues[defaultShape]

	outlineThickness = thickness

	setupShadows()

	usingBlur = bitBand(flags, blurFlag) ~= 0

	if bitBand(flags, manualColorFlag) ~= 0 then
		drawShadows(false, nil, nil, nil)
	elseif col then
		drawShadows(col.r, col.g, col.b, col.a)
	else
		drawShadows(0, 0, 0, 255)
	end

	setClippingDisabled(oldClippingState)
end

function RNDX.DrawShadows(r, x, y, w, h, col, spread, intensity, flags)
	return RNDX.DrawShadowsEx(x, y, w, h, col, flags, r, r, r, r, spread, intensity)
end

function RNDX.DrawShadowsOutlined(r, x, y, w, h, col, thickness, spread, intensity, flags)
	return RNDX.DrawShadowsEx(x, y, w, h, col, flags, r, r, r, r, spread, intensity, thickness or 1)
end

local baseMethods; baseMethods = {
	Rad = function(self, rad)
		topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius = rad, rad, rad, rad
		return self
	end,
	Radii = function(self, tl, tr, bl, br)
		topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius = tl or 0, tr or 0, bl or 0, br or 0
		return self
	end,
	Texture = function(self, texture)
		activeTexture = texture
		return self
	end,
	Material = function(self, mat)
		local tex = mat:GetTexture("$basetexture")
		if tex then
			activeTexture = tex
		end
		return self
	end,
	Outline = function(self, thickness)
		outlineThickness = thickness
		return self
	end,
	Shape = function(self, shape)
		shapeValue = shapeValues[shape] or 2.2
		return self
	end,
	Color = function(self, colorOrRed, g, b, a)
		if type(colorOrRed) == "number" then
			colorRed, colorGreen, colorBlue, colorAlpha = colorOrRed, g or 255, b or 255, a or 255
		else
			colorRed, colorGreen, colorBlue, colorAlpha = colorOrRed.r, colorOrRed.g, colorOrRed.b, colorOrRed.a
		end
		return self
	end,
	Blur = function(self, intensity)
		if not intensity then
			intensity = 1.0
		end
		intensity = mathMax(intensity, 0)
		usingBlur, blurStrength = true, intensity
		return self
	end,
	GradientNone = function(self)
		gradientMode = 0
		gradientRampTexture = nil
		gradientUsesRampTexture = false
		return self
	end,
	GradientTiling = function(self, mode)
		gradientTilingMode = mode or 0
		return self
	end,
	GradientLinear = function(self, cx, cy, angleDegrees, scale)
		gradientMode = 1
		gradientCenterX, gradientCenterY = cx or 0.5, cy or 0.5
		gradientAngle = math.rad(angleDegrees or 0)
		gradientScaleX = scale or 0
		gradientScaleY = 0
		return self
	end,
	GradientRadial = function(self, cx, cy, scaleX, scaleY)
		gradientMode = 2
		gradientCenterX, gradientCenterY = cx or 0.5, cy or 0.5
		gradientScaleX = scaleX or 0
		gradientScaleY = scaleY or gradientScaleX
		return self
	end,
	GradientConic = function(self, cx, cy, angleDegrees)
		gradientMode = 3
		gradientCenterX, gradientCenterY = cx or 0.5, cy or 0.5
		gradientAngle = math.rad(angleDegrees or 0)
		return self
	end,
	GradientTexture = function(self, texture)
		gradientUsesRampTexture = texture ~= nil
		gradientRampTexture = texture or nil
		return self
	end,
	Rotation = function(self, angle)
		rotation = math.rad(angle or 0)
		return self
	end,
	StartAngle = function(self, angle)
		startAngle = angle or 0
		return self
	end,
	EndAngle = function(self, angle)
		endAngle = angle or 360
		return self
	end,
	Shadow = function(self, spread, intensity)
		shadowEnabled, shadowSpread, shadowIntensity = true, spread or 30, intensity or (spread or 30) * 1.2
		return self
	end,
	Clip = function(self, pnl)
		clipPanel = pnl
		return self
	end,
	Flags = function(self, flags)
		flags = flags or 0

		if bitBand(flags, noTopLeftFlag) ~= 0 then
			topLeftRadius = 0
		end
		if bitBand(flags, noTopRightFlag) ~= 0 then
			topRightRadius = 0
		end
		if bitBand(flags, noBottomLeftFlag) ~= 0 then
			bottomLeftRadius = 0
		end
		if bitBand(flags, noBottomRightFlag) ~= 0 then
			bottomRightRadius = 0
		end

		local shapeFlag = bitBand(flags, shapeCircleFlag + shapeFigmaFlag + shapeIosFlag)
		if shapeFlag ~= 0 then
			shapeValue = shapeValues[shapeFlag] or shapeValues[defaultShape]
		end

		if bitBand(flags, blurFlag) ~= 0 then
			baseMethods.Blur(self)
		end

		if bitBand(flags, manualColorFlag) ~= 0 then
			colorRed = nil
		end

		return self
	end,

}

local rectangleBuilder = {
	Rad = baseMethods.Rad,
	Radii = baseMethods.Radii,
	Texture = baseMethods.Texture,
	Material = baseMethods.Material,
	Outline = baseMethods.Outline,
	Shape = baseMethods.Shape,
	Color = baseMethods.Color,
	Blur = baseMethods.Blur,
	GradientNone= baseMethods.GradientNone,
	GradientTiling= baseMethods.GradientTiling,
	GradientLinear= baseMethods.GradientLinear,
	GradientRadial= baseMethods.GradientRadial,
	GradientConic= baseMethods.GradientConic,
	GradientTexture= baseMethods.GradientTexture,
	Rotation = baseMethods.Rotation,
	StartAngle = baseMethods.StartAngle,
	EndAngle = baseMethods.EndAngle,
	Clip = baseMethods.Clip,
	Shadow = baseMethods.Shadow,
	Flags = baseMethods.Flags,

	Draw = function(self)
		if startAngle == endAngle then
			return
		end

		local oldClippingState
		if shadowEnabled or clipPanel then
			oldClippingState = setClippingDisabled(true)
		end

		if clipPanel then
			local sx, sy = clipPanel:LocalToScreen(0, 0)
			local sw, sh = clipPanel:GetSize()
			render.SetScissorRect(sx, sy, sx + sw, sy + sh, true)
		end

		if shadowEnabled then
			setupShadows()
			drawShadows(colorRed, colorGreen, colorBlue, colorAlpha)
		elseif usingBlur then
			drawBlur()
		else
			if activeTexture then
				activeMaterial = roundedTextureMaterial
				materialSetTexture(activeMaterial, "$basetexture", activeTexture)
			end

			setupDraw()
			surfaceDrawTexturedRectUV(drawX, drawY, drawWidth, drawHeight, -0.015625, -0.015625, 1.015625, 1.015625)
		end

		if clipPanel then
			render.SetScissorRect(0, 0, 0, 0, false)
		end

		if shadowEnabled or clipPanel then
			setClippingDisabled(oldClippingState)
		end
	end,

	GetMaterial = function(self)
		if shadowEnabled or usingBlur then
			error("You can't get the material of a shadowed or blurred rectangle!")
		end

		if activeTexture then
			activeMaterial = roundedTextureMaterial
			materialSetTexture(activeMaterial, "$basetexture", activeTexture)
		end
		setupDraw()

		return activeMaterial
	end,
}

local circleBuilder = {
	Texture = baseMethods.Texture,
	Material = baseMethods.Material,
	Outline = baseMethods.Outline,
	Color = baseMethods.Color,
	Blur = baseMethods.Blur,
	GradientNone= baseMethods.GradientNone,
	GradientTiling= baseMethods.GradientTiling,
	GradientLinear= baseMethods.GradientLinear,
	GradientRadial= baseMethods.GradientRadial,
	GradientConic= baseMethods.GradientConic,
	GradientTexture= baseMethods.GradientTexture,
	Rotation = baseMethods.Rotation,
	StartAngle = baseMethods.StartAngle,
	EndAngle = baseMethods.EndAngle,
	Clip = baseMethods.Clip,
	Shadow = baseMethods.Shadow,
	Flags = baseMethods.Flags,

	Draw = rectangleBuilder.Draw,
	GetMaterial = rectangleBuilder.GetMaterial,
}

local liquidStateIdle = 0
local liquidStateHover = 1
local liquidStatePressed = 2
local liquidStateDisabled = 3

local liquidStates = {
	idle = liquidStateIdle,
	hover = liquidStateHover,
	focus = liquidStateHover,
	focused = liquidStateHover,
	pressed = liquidStatePressed,
	down = liquidStatePressed,
	disabled = liquidStateDisabled,
}

local currentLiquidState, liquidStrength, liquidSpeed, liquidSaturation = liquidStateIdle, 0.012, 1.0, 1.06
local liquidTintRed, liquidTintGreen, liquidTintBlue, liquidTintStrength = 1.0, 1.0, 1.0, 0.06
local liquidShimmer, liquidGrain, liquidAlpha = 0.9, 0.02, 0.95
local liquidBlurAmount, liquidBlurRadius, liquidSmoothness = 0.0, 0.0, 2.0
local liquidLightAngle, liquidDepth, liquidDispersion = -2.35619449, 0.0, 0.65
local liquidCursorX, liquidCursorY = -4096, -4096
local liquidCursorRadius, liquidCursorStrength, liquidCursorSoftness = 0.0, 0.0, 1.6
local liquidCursorCache = {}
local liquidPackTurns = math.pi * 2

local function resetLiquidRuntime()
	currentLiquidState = liquidStateIdle
	liquidCursorX, liquidCursorY = -4096, -4096
	liquidCursorRadius, liquidCursorStrength, liquidCursorSoftness = 0.0, 0.0, 1.6
end

local liquidBuilder = {
	Rad = baseMethods.Rad,
	Radii = baseMethods.Radii,
	Outline = baseMethods.Outline,
	Rotation = baseMethods.Rotation,
	StartAngle = baseMethods.StartAngle,
	EndAngle = baseMethods.EndAngle,
	Clip = baseMethods.Clip,
	Shadow = baseMethods.Shadow,
	Flags = baseMethods.Flags,
	Color = baseMethods.Color,
	State = function(self, state)
		if type(state) == "string" then
			state = liquidStates[stringLower(state)] or liquidStateIdle
		else
			state = tonumber(state) or liquidStateIdle
		end

		currentLiquidState = mathMin(mathMax(state, liquidStateIdle), liquidStateDisabled)
		return self
	end,
	Strength = function(self, v)
		liquidStrength = mathMax(v or 0, 0)
		return self
	end,
	Speed = function(self, v)
		liquidSpeed = v or 1.0
		return self
	end,
	Saturation = function(self, v)
		liquidSaturation = v or 1.0
		return self
	end,
	Tint = function(self, r, g, b)
		if IsColor and IsColor(r) then
			liquidTintRed, liquidTintGreen, liquidTintBlue = r.r / 255, r.g / 255, r.b / 255
		else
			liquidTintRed, liquidTintGreen, liquidTintBlue =
				(r or 255) / 255,
				(g or 255) / 255,
				(b or 255) / 255
		end
		return self
	end,
	TintStrength = function(self, v)
		liquidTintStrength = mathMax(v or 0, 0)
		return self
	end,
	Shimmer = function(self, v)
		liquidShimmer = mathMax(v or 0, 0)
		return self
	end,
	Grain = function(self, v)
		liquidGrain = mathMax(v or 0, 0)
		return self
	end,
	Alpha = function(self, v)
		liquidAlpha = mathMax(v or 0, 0)
		return self
	end,
	GlassBlur = function(self, strength, radius)
		liquidBlurAmount = mathMax(strength or 0, 0)
		liquidBlurRadius = mathMax(radius or 0, 0)
		return self
	end,
	LightAngle = function(self, radians)
		liquidLightAngle = radians or liquidLightAngle
		return self
	end,
	Dispersion = function(self, v)
		liquidDispersion = mathMin(mathMax(v or 0, 0), 1)
		return self
	end,
	Depth = function(self, v)
		liquidDepth = mathMin(mathMax(v or 0, 0), 1)
		return self
	end,
	Thickness = function(self, v)
		return self:Depth(v)
	end,
	EdgeSmooth = function(self, pixels)
		liquidSmoothness = mathMax(pixels or 0, 0)
		return self
	end,
	Cursor = function(self, screenX, screenY, radius, strength, softness)
		liquidCursorX = (screenX or -4096) - drawX
		liquidCursorY = (screenY or -4096) - drawY
		liquidCursorRadius = mathMax(radius or 0, 0)
		liquidCursorStrength = mathMax(strength or 0, 0)
		liquidCursorSoftness = mathMax(softness or 1.6, 0.05)
		return self
	end,
	CursorUV = function(self, u, v, radius, strength, softness)
		liquidCursorX = (u or -16) * drawWidth
		liquidCursorY = (v or -16) * drawHeight
		liquidCursorRadius = mathMax(radius or 0, 0)
		liquidCursorStrength = mathMax(strength or 0, 0)
		liquidCursorSoftness = mathMax(softness or 1.6, 0.05)
		return self
	end,
	CursorOff = function(self)
		liquidCursorRadius, liquidCursorStrength = 0.0, 0.0
		return self
	end,
	CursorSmooth = function(self, key, active, screenX, screenY, radius, strength, softness, enterSpeed, exitSpeed, followSpeed)
		local cacheKey = key or (tostring(drawX) .. ":" .. tostring(drawY) .. ":" .. tostring(drawWidth) .. ":" .. tostring(drawHeight))
		local state = liquidCursorCache[cacheKey]
		local defaultX = drawX + drawWidth * 0.5
		local defaultY = drawY + drawHeight * 0.5

		if not state then
			state = {
				blend = 0,
				x = screenX or defaultX,
				y = screenY or defaultY,
			}
			liquidCursorCache[cacheKey] = state
		end

		local isActive = tobool(active) and (radius or 0) > 0 and (strength or 0) > 0
		local blendSpeed = mathMin(FrameTime() * (isActive and (enterSpeed or 20) or (exitSpeed or 14)), 1)
		local followRate = mathMin(FrameTime() * (followSpeed or 24), 1)
		local targetX = screenX or state.x or defaultX
		local targetY = screenY or state.y or defaultY

		state.blend = Lerp(blendSpeed, state.blend or 0, isActive and 1 or 0)
		state.x = Lerp(followRate, state.x or targetX, targetX)
		state.y = Lerp(followRate, state.y or targetY, targetY)

		if state.blend <= 0.001 then
			return self:CursorOff()
		end

		return self:Cursor(state.x, state.y, radius, (strength or 0) * state.blend, softness)
	end,
	Draw = function(self)
		if startAngle == endAngle then
			return
		end
		local clippingState
		if shadowEnabled or clipPanel then
			clippingState = setClippingDisabled(true)
		end
		if clipPanel then
			local sx, sy = clipPanel:LocalToScreen(0, 0)
			local sw, sh = clipPanel:GetSize()
			render.SetScissorRect(sx, sy, sx + sw, sy + sh, true)
		end
		
		activeMaterial = liquidMaterial
		materialSetFloat(activeMaterial, liquidStateParameter, currentLiquidState)
		materialSetFloat(activeMaterial, liquidTimeParameter, RealTime() * liquidSpeed)
		materialSetFloat(activeMaterial, liquidStrengthParameter, liquidStrength)
		materialSetFloat(activeMaterial, liquidAlphaParameter, liquidAlpha)
		materialSetFloat(activeMaterial, liquidShimmerParameter, liquidShimmer)
		materialSetFloat(activeMaterial, liquidSaturationParameter, liquidSaturation)
		materialSetFloat(activeMaterial, liquidTintStrengthParameter, liquidTintStrength)
		materialSetFloat(activeMaterial, liquidGrainParameter, liquidGrain)
		materialSetFloat(activeMaterial, liquidTintRedParameter, liquidTintRed)
		materialSetFloat(activeMaterial, liquidTintGreenParameter, liquidTintGreen)
		materialSetFloat(activeMaterial, liquidTintBlueParameter, liquidTintBlue)
		local dispersionValue = mathFloor(liquidDispersion * 255 + 0.5)
		materialSetFloat(activeMaterial, liquidLightAngleParameter, liquidLightAngle + dispersionValue * liquidPackTurns)
		materialSetFloat(activeMaterial, liquidBlurAmountParameter, liquidBlurAmount)
		materialSetFloat(activeMaterial, liquidBlurRadiusParameter, liquidBlurRadius)
		materialSetFloat(activeMaterial, liquidSmoothnessParameter, liquidSmoothness)
		materialSetFloat(activeMaterial, liquidDepthParameter, liquidDepth)
		
		setupDraw()
		
		surfaceDrawTexturedRectUV(drawX, drawY, drawWidth, drawHeight, -0.015625, -0.015625, 1.015625, 1.015625)
		if clipPanel then
			render.SetScissorRect(0, 0, 0, 0, false)
		end
		if shadowEnabled or clipPanel then
			setClippingDisabled(clippingState)
		end
	end
}

local builders = {
	Rect = function(x, y, w, h)
		resetParams()
		activeMaterial = roundedMaterial
		drawX, drawY, drawWidth, drawHeight = x, y, w, h
		return rectangleBuilder
	end,
	Circle = function(x, y, r)
		resetParams()
		activeMaterial = roundedMaterial
		shapeValue = shapeValues[shapeCircleFlag]
		drawX, drawY, drawWidth, drawHeight = x - r / 2, y - r / 2, r, r
		r = r / 2
		topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius = r, r, r, r
		return circleBuilder
	end,
	Liquid = function(x, y, w, h)
		resetParams()
		resetLiquidRuntime()
		activeMaterial = liquidMaterial
		drawX, drawY, drawWidth, drawHeight = x, y, w, h
		return liquidBuilder
	end
}

setmetatable(RNDX, {
	__call = function()
		return builders
	end
})

RNDX.NO_TL = noTopLeftFlag
RNDX.NO_TR = noTopRightFlag
RNDX.NO_BL = noBottomLeftFlag
RNDX.NO_BR = noBottomRightFlag

RNDX.SHAPE_CIRCLE = shapeCircleFlag
RNDX.SHAPE_FIGMA = shapeFigmaFlag
RNDX.SHAPE_IOS = shapeIosFlag

RNDX.BLUR = blurFlag
RNDX.MANUAL_COLOR = manualColorFlag
RNDX.LIQUID_STATE_IDLE = liquidStateIdle
RNDX.LIQUID_STATE_HOVER = liquidStateHover
RNDX.LIQUID_STATE_PRESSED = liquidStatePressed
RNDX.LIQUID_STATE_DISABLED = liquidStateDisabled

function RNDX.SetFlag(flags, flag, bool)
	flag = RNDX[flag] or flag
	if tobool(bool) then
		return bit.bor(flags, flag)
	else
		return bit.band(flags, bit.bnot(flag))
	end
end

function RNDX.SetDefaultShape(shape)
	defaultShape = shape or shapeFigmaFlag
	defaultDrawFlags = defaultShape
end

function RNDX.ClearLiquidCursorState(key)
	liquidCursorCache[key] = nil
end

return RNDX
