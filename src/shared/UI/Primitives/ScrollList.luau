local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Layouts = require(script.Parent.Layouts)
local Padding = require(script.Parent.Padding)
local e = React.createElement

return function(props)
	local children = {
		_Layout = e(Layouts.VList, { gap = props.gap or 0 }),
	}
	if props.paddingH or props.paddingV then
		children._Padding = e(Padding, {
			left = props.paddingH or 0,
			right = props.paddingH or 0,
			top = props.paddingV or 0,
			bottom = props.paddingV or 0,
		})
	end

	local incoming = props.children
	if incoming then
		for key, child in pairs(incoming) do
			children[key] = child
		end
	end

	return e("ScrollingFrame", {
		Size = props.size or UDim2.fromScale(1, 1),
		Position = props.position,
		LayoutOrder = props.layoutOrder,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = props.scrollBarWidth or 3,
		ScrollBarImageColor3 = props.barColor or Color3.fromRGB(65, 105, 82),
		CanvasSize = UDim2.fromScale(1, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ClipsDescendants = props.clipChildren ~= false,
	}, children)
end
