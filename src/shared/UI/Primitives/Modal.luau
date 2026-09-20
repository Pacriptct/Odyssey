local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local React = require(ReplicatedStorage.Packages.React)
local Corner = require(script.Parent.Corner)
local Stroke = require(script.Parent.Stroke)
local Padding = require(script.Parent.Padding)
local Layouts = require(script.Parent.Layouts)
local Divider = require(script.Parent.Divider)
local IconButton = require(script.Parent.IconButton)
local useTheme = require(script.Parent.useTheme)
local e = React.createElement
local useRef = React.useRef
local useEffect = React.useEffect

return function(props)
	local theme = useTheme()
	local accent = props.accentColor or theme.Color.Accent
	local zi = props.zIndex or theme.ZIndex.Modal
	local w = props.width or 320
	local autoH = (props.height or 0) == 0

	local scrimRef = useRef(nil)
	local dialogRef = useRef(nil)

	useEffect(function()
		if scrimRef.current then
			scrimRef.current.BackgroundTransparency = 1
			TweenService:Create(
				scrimRef.current,
				TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ BackgroundTransparency = theme.Alpha.Overlay }
			):Play()
		end
		if dialogRef.current then
			dialogRef.current.Position = UDim2.new(0.5, 0, 0.5, 12)
			TweenService:Create(
				dialogRef.current,
				TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = UDim2.fromScale(0.5, 0.5) }
			):Play()
		end
	end, {})

	local dialogChildren = {
		_Corner = e(Corner, { radius = theme.Radius.Medium }),
		_Stroke = e(Stroke, { color = accent, transparency = theme.Alpha.BorderStrong }),
		_Padding = e(Padding, { all = theme.Space.Large }),
		_Layout = e(Layouts.VList, { gap = theme.Space.Medium }),
	}
	if props.title then
		dialogChildren._TitleRow = e("Frame", {
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			LayoutOrder = 0,
		}, {
			Title = e("TextLabel", {
				Text = props.title:upper(),
				Size = UDim2.new(1, props.onClose and -28 or 0, 1, 0),
				BackgroundTransparency = 1,
				FontFace = theme.Font.Bold,
				TextSize = theme.TextSize.Label,
				TextColor3 = theme.Color.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
			CloseBtn = props.onClose and e(IconButton, {
				icon = "✕",
				onClick = props.onClose,
				size = 20,
				color = theme.Color.Dim,
				position = UDim2.new(1, -20, 0, 0),
				anchorPoint = Vector2.new(1, 0),
			}) or nil,
		})
		dialogChildren._TitleDivider = e(Divider, { layoutOrder = 1, gradient = true })
	end
	if props[React.Children] then
		for k, v in pairs(props[React.Children]) do
			dialogChildren[k] = v
		end
	end
	return e("Frame", {
		ref = scrimRef,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme.Color.Black,
		BackgroundTransparency = theme.Alpha.Overlay,
		BorderSizePixel = 0,
		ZIndex = zi,
	}, {
		Dialog = e("Frame", {
			ref = dialogRef,
			Size = UDim2.fromOffset(w, autoH and 0 or props.height),
			AutomaticSize = autoH and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = theme.Color.Surface,
			BorderSizePixel = 0,
			ZIndex = zi + 1,
		}, dialogChildren),
	})
end
