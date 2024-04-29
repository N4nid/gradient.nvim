M = {}

GradientOffset = 0.1
Headlines = 1
Max = 6
Bg = ""

function Round(x)
	return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end
-- Function :		RGBtoHEX(arg1, arg2, arg3)
-- Argument:		Three RGB values
-- 						Red value from 0-255
-- 						Green value from 0-255
-- 						Blue value from 0-255
-- Returns:		String hex value in the form 'cccccc'
function RGBtoHEX(redArg, greenArg, blueArg)
	hex = "#" .. string.format("%.2x%.2x%.2x", redArg, greenArg, blueArg)
	if Headlines <= Max then
		cmd = "highlight Headline" .. Headlines .. " guibg=" .. Bg .. " guifg=" .. hex
		vim.cmd(cmd)
		print(cmd)
		Headlines = Headlines + 1
		HEXtoRGBandMagic(hex)
	end
	return string.format("%.2x%.2x%.2x", redArg, greenArg, blueArg)
end
-- Function :		RGBtoHSB(arg)
-- Argument :	A string RGB color value in the form 'rrr,ggg,bbb'
-- Returns :		Three HSB values
-- 						HSB hue as a percentage from 0.0-1.0
-- 						*	Multiply 360 with this value to obtain the degrees of hue
--							While hue is most often expressed as an integer, the fractional
--							amount can be important for precision in calculations
--						*	Note that 0.0 (0 degrees) and 1.0 (360 degrees) are the same red hue
--							It's a counter-clockwise 360 degree "cylinder" of color
--							red->purple->blue->cyan->green->yellow->orange->red
-- 						HSB saturation as a percentage from 0.0-1.0
-- 						HSB brightness as a percentage from 0.0-1.0
--						*	Note that this is the "brightness" of the color, and not the
--							"lightness" as in the HSL model. A color, particularly in the
--							blue range, can have 100% brightness and still be visibly quite dark.
--							Use the Luminance() function below to obtain "visible lightness"
function RGBtoHSB(colorArg)
	colorArg = string.gsub(colorArg, " ", "")
	inRed, inGreen, inBlue = string.match(colorArg, "(%d+),(%d+),(%d+)")

	percentR = (inRed / 255)
	percentG = (inGreen / 255)
	percentB = (inBlue / 255)

	colorMin = math.min(percentR, percentG, percentB)
	colorMax = math.max(percentR, percentG, percentB)
	deltaMax = colorMax - colorMin

	colorBrightness = colorMax

	if deltaMax == 0 then
		colorHue = 0
		colorSaturation = 0
	else
		colorSaturation = deltaMax / colorMax

		deltaR = (((colorMax - percentR) / 6) + (deltaMax / 2)) / deltaMax
		deltaG = (((colorMax - percentG) / 6) + (deltaMax / 2)) / deltaMax
		deltaB = (((colorMax - percentB) / 6) + (deltaMax / 2)) / deltaMax

		if percentR == colorMax then
			colorHue = deltaB - deltaG
		elseif percentG == colorMax then
			colorHue = (1 / 3) + deltaR - deltaB
		elseif percentB == colorMax then
			colorHue = (2 / 3) + deltaG - deltaR
		end
		--HERE HAPPENS THE MAGIC
		colorHue = colorHue + GradientOffset

		if colorHue < 0 then
			colorHue = colorHue + 1
		end
		if colorHue > 1 then
			colorHue = colorHue - 1
		end
	end
	HSBtoRGB(colorHue, colorSaturation, colorBrightness)

	--return colorHue, colorSaturation, colorBrightness
end

-- Function :		HSBtoRGB(arg1, arg2, arg3)
-- Argument:		Three HSB values
-- 						HSB hue as a percentage from 0.0-1.0
-- 						HSB saturation as a percentage from 0.0-1.0
-- 						HSB brightness as a percentage from 0.0-1.0
-- Returns:		Three RGB values
-- 						Red value from 0-255
-- 						Green value from 0-255
-- 						Blue value from 0-255
function HSBtoRGB(colorHue, colorSaturation, colorBrightness)
	degreesHue = colorHue * 6
	if degreesHue == 6 then
		degreesHue = 0
	end
	degreesHue_int = math.floor(degreesHue)
	percentSaturation1 = colorBrightness * (1 - colorSaturation)
	percentSaturation2 = colorBrightness * (1 - colorSaturation * (degreesHue - degreesHue_int))
	percentSaturation3 = colorBrightness * (1 - colorSaturation * (1 - (degreesHue - degreesHue_int)))
	if degreesHue_int == 0 then
		percentR = colorBrightness
		percentG = percentSaturation3
		percentB = percentSaturation1
	elseif degreesHue_int == 1 then
		percentR = percentSaturation2
		percentG = colorBrightness
		percentB = percentSaturation1
	elseif degreesHue_int == 2 then
		percentR = percentSaturation1
		percentG = colorBrightness
		percentB = percentSaturation3
	elseif degreesHue_int == 3 then
		percentR = percentSaturation1
		percentG = percentSaturation2
		percentB = colorBrightness
	elseif degreesHue_int == 4 then
		percentR = percentSaturation3
		percentG = percentSaturation1
		percentB = colorBrightness
	else
		percentR = colorBrightness
		percentG = percentSaturation1
		percentB = percentSaturation2
	end

	outRed = Round(percentR * 255)
	outGreen = Round(percentG * 255)
	outBlue = Round(percentB * 255)

	RGBtoHEX(outRed, outGreen, outBlue)
	--return outRed, outGreen, outBlue
end
-- Function :		HEXtoRGB(arg)
-- Argument:		Hex string value in the form '#cccccc' or 'cccccc'
-- 						* HEX shorthand is supported
-- Returns:		Three RGB values
-- 						Red value from 0-255
-- 						Green value from 0-255
--
function HEXtoRGBandMagic(hexArg)
	hexArg = hexArg:gsub("#", "")

	if string.len(hexArg) == 3 then
		return tonumber("0x" .. hexArg:sub(1, 1)) * 17,
			tonumber("0x" .. hexArg:sub(2, 2)) * 17,
			tonumber("0x" .. hexArg:sub(3, 3)) * 17
	elseif string.len(hexArg) == 6 then
		r = tonumber("0x" .. hexArg:sub(1, 2))
		g = tonumber("0x" .. hexArg:sub(3, 4))
		b = tonumber("0x" .. hexArg:sub(5, 6))

		print(
			tonumber("0x" .. hexArg:sub(1, 2))
				.. " "
				.. tonumber("0x" .. hexArg:sub(3, 4))
				.. " "
				.. tonumber("0x" .. hexArg:sub(5, 6))
		)
		RGBtoHSB(r .. "," .. g .. "," .. b)
	else
		return 0, 0, 0
	end
end

function brighten(hexArg)
	hexArg = hexArg:gsub("#", "")

	if string.len(hexArg) == 3 then
		return tonumber("0x" .. hexArg:sub(1, 1)) * 17,
			tonumber("0x" .. hexArg:sub(2, 2)) * 17,
			tonumber("0x" .. hexArg:sub(3, 3)) * 17
	elseif string.len(hexArg) == 6 then
		r = tonumber("0x" .. hexArg:sub(1, 2))
		g = tonumber("0x" .. hexArg:sub(3, 4))
		b = tonumber("0x" .. hexArg:sub(5, 6))

		print(
			tonumber("0x" .. hexArg:sub(1, 2))
				.. " "
				.. tonumber("0x" .. hexArg:sub(3, 4))
				.. " "
				.. tonumber("0x" .. hexArg:sub(5, 6))
		)
		r = r + 1
		g = g + 1
		b = b + 1
		if r > 255 then
			r = 255
		end
		if g > 255 then
			g = 255
		end
		if b > 255 then
			b = 255
		end

		return RGBtoHEX(r, g, b)
	else
		return 0, 0, 0
	end
end

--HEXtoRGBandMagic("#7aa2f7")

function M.setup(opts)
	opts = opts or {}

	local bg = vim.api.nvim_exec('echo synIDattr(synIDtrans(hlID("Normal")), "bg#")', true)
	--bg = brighten(bg)
	Bg = bg
	vim.api.nvim_create_user_command("Yoo", function()
		local color = vim.api.nvim_exec('echo synIDattr(synIDtrans(hlID("DashboardHeader")), "fg#")', true)
		Headlines = 1
		HEXtoRGBandMagic(color)
	end, {})
end

return M
