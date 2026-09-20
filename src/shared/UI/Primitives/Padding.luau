local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

return function(props)
	local base = props.all or 0
	return e("UIPadding", {
		PaddingTop = UDim.new(0, props.top or base),
		PaddingBottom = UDim.new(0, props.bottom or base),
		PaddingLeft = UDim.new(0, props.left or base),
		PaddingRight = UDim.new(0, props.right or base),
	})
end
