local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Corner = require(script.Parent.Corner)
local Stroke = require(script.Parent.Stroke)
local Sounds = require(script.Parent.Sounds)
local useTheme = require(script.Parent.useTheme)
local e = React.createElement

return function(props)
	local theme = useTheme()
	local variant = props.variant or "outline"
	local color = props.color or theme.Color.Accent
	local bgColor, textColor, strokeColor, strokeAlpha

	if variant == "solid" then
		bgColor = color
		textColor = theme.Color.Base
		strokeColor = color
		strokeAlpha = 0.3
	elseif variant == "danger" then
		bgColor = theme.Color.DangerBg
		textColor = theme.Color.Danger
		strokeColor = theme.Color.Danger
		strokeAlpha = theme.Alpha.BorderStrong
	elseif variant == "ghost" then
		bgColor = theme.Color.White
		textColor = theme.Color.Dim
		strokeColor = theme.Color.Border
		strokeAlpha = theme.Alpha.Border
	else -- outline
		bgColor = theme.dim(color, 0.12)
		textColor = color
		strokeColor = theme.dim(color, 0.40)
		strokeAlpha = 0
	end

	return e("TextButton", {
		Text = props.text,
		Size = props.size or UDim2.fromOffset(100, 30),
		Position = props.position,
		AnchorPoint = props.anchorPoint,
		LayoutOrder = props.layoutOrder,
		ZIndex = props.zIndex,
		BackgroundColor3 = bgColor,
		BackgroundTransparency = variant == "ghost" and theme.Alpha.Ghost or 0,
		BorderSizePixel = 0,
		FontFace = theme.Font.Bold,
		TextSize = props.fontSize or theme.TextSize.Small,
		TextColor3 = props.disabled and theme.Color.Muted or textColor,
		AutoButtonColor = false,
		Selectable = false,
		[React.Event.MouseButton1Click] = (not props.disabled) and function()
			Sounds.play(props.soundKind or (variant == "solid" and "confirm" or "select"))
			if props.onClick then
				props.onClick()
			end
		end or nil,
	}, {
		Corner = e(Corner, { radius = props.radius or theme.Radius.Small }),
		Stroke = e(Stroke, { color = strokeColor, transparency = strokeAlpha }),
	})
end
