local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local Corner = require(script.Parent.Corner)
local Stroke = require(script.Parent.Stroke)
local Padding = require(script.Parent.Padding)
local useTheme = require(script.Parent.useTheme)

local e = React.createElement

return function(props)
	local theme = useTheme()
	local children = {
		_Corner = e(Corner, { radius = props.radius or theme.Radius.Base }),
		_Stroke = e(Stroke, {
			color = props.accentColor or theme.Color.Border,
			transparency = props.accentAlpha or theme.Alpha.Border,
		}),
	}

	if theme.Decorations and theme.Decorations.PanelBackgroundGradient and props.gradient ~= false then
		children._BgGradient = e("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, theme.Color.Raised),
				ColorSequenceKeypoint.new(1, theme.Color.Surface),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 0.18),
			}),
		})
	end

	if props.padding then
		children._Padding = e(Padding, { all = props.padding })
	end

	local propChildren = props[React.Children] or props.children
	if propChildren then
		for k, v in pairs(propChildren) do
			children[k] = v
		end
	end

	return e("Frame", {
		Size = props.size or UDim2.fromScale(1, 0),
		AutomaticSize = props.autoSize or Enum.AutomaticSize.None,
		Position = props.position,
		LayoutOrder = props.layoutOrder,
		BackgroundColor3 = props.color or theme.Color.Raised,
		BorderSizePixel = 0,
		ClipsDescendants = props.clipChildren or false,
	}, children)
end
