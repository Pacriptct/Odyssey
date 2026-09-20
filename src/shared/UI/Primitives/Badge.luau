local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Corner = require(script.Parent.Corner)
local Stroke = require(script.Parent.Stroke)
local Padding = require(script.Parent.Padding)
local useTheme = require(script.Parent.useTheme)
local e = React.createElement

return function(props)
	local theme = useTheme()
	local color = props.color or theme.Color.Accent
	local bg = props.bg or theme.dim(color, 0.14)
	local label = (props.icon or "") .. props.text

	return e("Frame", {
		Size = UDim2.fromOffset(0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = bg,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
	}, {
		Corner = e(Corner, { radius = props.radius or theme.Radius.Tiny }),
		Stroke = e(Stroke, { color = theme.dim(color, 0.45), transparency = 0 }),
		Padding = e(Padding, { left = 6, right = 6 }),
		Label = e("TextLabel", {
			Text = label,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			FontFace = theme.Font.Bold,
			TextSize = props.fontSize or theme.TextSize.Micro,
			TextColor3 = color,
			TextXAlignment = Enum.TextXAlignment.Center,
		}),
	})
end
