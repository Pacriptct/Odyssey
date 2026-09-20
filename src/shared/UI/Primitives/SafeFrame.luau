--

-- src/shared/UI/Primitives/SafeFrame.luau

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

local DEFAULT_PAD = 2

return function(props)
	local pad = props.pad or DEFAULT_PAD
	local z = props.zIndex or props.ZIndex or 1
	local isButton = props.asButton == true

	local outerProps = {
		Size = props.size or props.Size or UDim2.fromScale(1, 0),
		Position = props.position or props.Position,
		AnchorPoint = props.anchorPoint or props.AnchorPoint,
		AutomaticSize = props.automaticSize or props.AutomaticSize,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
		ZIndex = z,
		ClipsDescendants = false,
	}

	local innerProps: any = {
		Size = UDim2.new(1, -pad * 2, 1, -pad * 2),
		Position = UDim2.fromOffset(pad, pad),
		BackgroundColor3 = props.backgroundColor3 or props.BackgroundColor3 or Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = props.backgroundTransparency or props.BackgroundTransparency or 0,
		BorderSizePixel = 0,
		ZIndex = z,
		ClipsDescendants = props.clipsDescendants or props.ClipsDescendants or false,
	}

	if isButton then
		innerProps.Text = props.text or ""
		innerProps.AutoButtonColor = props.autoButtonColor or false

		if props.onClick then
			innerProps[React.Event.MouseButton1Click] = props.onClick
		end

		if props.onMouseEnter then
			innerProps[React.Event.MouseEnter] = props.onMouseEnter
		end

		if props.onMouseLeave then
			innerProps[React.Event.MouseLeave] = props.onMouseLeave
		end
	end

	return e("Frame", outerProps, {
		Inner = e(isButton and "TextButton" or "Frame", innerProps, props.children or {}),
	})
end