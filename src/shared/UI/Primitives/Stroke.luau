local ReplicatedStorage = game:GetService("ReplicatedStorage")
local useTheme = require(script.Parent.useTheme)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

return function(props)
	local theme = useTheme()
	local useGradient = props.gradient
	if useGradient == nil then
		useGradient = theme.Stroke and theme.Stroke.Gradient or false
	end
	local thickness = props.thickness or (theme.Stroke and theme.Stroke.Thickness) or 1

	local children = nil
	if useGradient then
		children = {
			Gradient = e("UIGradient", {
				Rotation = props.gradientRotation or (theme.Stroke and theme.Stroke.GradientRotation) or 0,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.85),
					NumberSequenceKeypoint.new(0.5, 0),
					NumberSequenceKeypoint.new(1, 0.85),
				}),
			}),
		}
	end

	return e("UIStroke", {
		Color = props.color or theme.Color.Border,
		Transparency = props.transparency or theme.Alpha.Border,
		Thickness = thickness,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, children)
end
