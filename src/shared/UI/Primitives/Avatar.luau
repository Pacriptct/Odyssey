local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Corner = require(script.Parent.Corner)
local Stroke = require(script.Parent.Stroke)
local useTheme = require(script.Parent.useTheme)
local e = React.createElement

return function(props)
	local theme = useTheme()
	local sz = props.size or 32
	local color = props.color or theme.Color.Accent
	local dotSz = math.max(6, math.floor(sz * 0.28))
	local dotOff = math.floor(sz * 0.06)

	return e("Frame", {
		Size = UDim2.fromOffset(sz, sz),
		Position = props.position,
		AnchorPoint = props.anchorPoint,
		LayoutOrder = props.layoutOrder,
		BackgroundColor3 = theme.dim(color, 0.15),
		BorderSizePixel = 0,
	}, {
		Corner = e(Corner, { radius = theme.Radius.Round, circular = true }),
		Stroke = e(Stroke, { color = theme.dim(color, 0.35), transparency = 0 }),
		Initial = e("TextLabel", {
			Text = props.name:sub(1, 1):upper(),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			FontFace = theme.Font.Bold,
			TextSize = math.floor(sz * 0.44),
			TextColor3 = color,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
		}),
		StatusDot = (props.online ~= nil) and e("Frame", {
			Size = UDim2.fromOffset(dotSz, dotSz),
			Position = UDim2.new(1, -(dotOff + dotSz), 1, -(dotOff + dotSz)),
			BackgroundColor3 = props.online and theme.Color.Success or Color3.fromRGB(55, 65, 81),
			BorderSizePixel = 0,
			ZIndex = 2,
		}, {
			Corner = e(Corner, { radius = theme.Radius.Round, circular = true }),
			Ring = e(Stroke, { color = theme.Color.Base, transparency = 0, thickness = 1.5 }),
		}) or nil,
	})
end
