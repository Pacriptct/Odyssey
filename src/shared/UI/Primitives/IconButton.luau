local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Corner = require(script.Parent.Corner)
local Sounds = require(script.Parent.Sounds)
local useTheme = require(script.Parent.useTheme)
local e = React.createElement

return function(props)
	local sz = props.size or 28
	local theme = useTheme()

	return e("TextButton", {
		Text = props.icon,
		Size = UDim2.fromOffset(sz, sz),
		Position = props.position,
		AnchorPoint = props.anchorPoint,
		LayoutOrder = props.layoutOrder,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = theme.Font.Bold,
		TextSize = props.fontSize or theme.TextSize.Label,
		TextColor3 = props.color or theme.Color.Muted,
		AutoButtonColor = false,
		[React.Event.MouseButton1Click] = props.onClick and function()
			Sounds.play("select")
			props.onClick()
		end or nil,
	}, {
		Corner = e(Corner, { radius = props.radius or theme.Radius.Small }),
	})
end
