local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Theme)
local Style = require(script.Parent.Style)
local e = React.createElement

return function(props)
	local s = Style.getStyle()
	local circular = props.circular == true

	if not circular and s.Decorations and s.Decorations.SquareCorners then
		return nil
	end

	return e("UICorner", {
		CornerRadius = UDim.new(0, props.radius or Theme.Radius.Base),
	})
end
