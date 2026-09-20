local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local useTheme = require(script.Parent.useTheme)
local e = React.createElement

return function(props)
	local theme = useTheme()
	local vertical = props.vertical == true
	local defaultSize = vertical and UDim2.new(0, 1, 1, 0) or UDim2.new(1, 0, 0, 1)
	local useGradient = props.gradient == true

	local color, alpha
	if useGradient then
		color = props.color or theme.Color.Accent
		alpha = props.alpha or 0
	else
		color = props.color or theme.Color.Divider
		alpha = props.alpha or theme.Alpha.Divider
	end

	local children = nil
	if useGradient then
		children = {
			Gradient = e("UIGradient", {
				Rotation = vertical and 90 or 0,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.5, 0.1),
					NumberSequenceKeypoint.new(1, 1),
				}),
			}),
		}
	end

	return e("Frame", {
		Size = props.size or defaultSize,
		Position = props.position,
		BackgroundColor3 = color,
		BackgroundTransparency = alpha,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
	}, children)
end
