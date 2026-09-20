local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement
local Layouts = {}

function Layouts.VList(props)
	return e("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = props.halign or Enum.HorizontalAlignment.Left,
		VerticalAlignment = props.valign or Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, props.gap or 0),
	})
end

function Layouts.HList(props)
	return e("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = props.valign or Enum.VerticalAlignment.Center,
		HorizontalAlignment = props.halign or Enum.HorizontalAlignment.Left,
		Padding = UDim.new(0, props.gap or 0),
	})
end

return Layouts
