local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local useTheme = require(script.Parent.useTheme)
local e = React.createElement

return function(props)
	local theme = useTheme()
	local pH = props.paddingH or 0
	local hasPip = props.accentColor ~= nil
	local pipOffset = hasPip and 10 or 0
	local decorations = theme.Decorations or {}
	local titleText = props.title
	if decorations.TitleUppercase and titleText then
		titleText = string.upper(titleText)
	end

	local titleChildren = nil
	if decorations.HeaderTitleGradient then
		titleChildren = {
			Gradient = e("UIGradient", {
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, theme.Color.Text),
					ColorSequenceKeypoint.new(1, theme.Color.Accent),
				}),
			}),
		}
	end

	return e("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
	}, {
		Pip = hasPip and e("Frame", {
			Size = UDim2.fromOffset(3, 18),
			Position = UDim2.new(0, pH, 0.5, -9),
			BackgroundColor3 = props.accentColor,
			BorderSizePixel = 0,
		}) or nil,

		Title = e("TextLabel", {
			Text = titleText,
			Size = UDim2.new(1, -(pH * 2 + pipOffset), 1, 0),
			Position = UDim2.fromOffset(pH + pipOffset, 0),
			BackgroundTransparency = 1,
			FontFace = theme.Font.Title or theme.Font.Bold,
			TextSize = theme.TextSize.Small,
			TextColor3 = theme.Color.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
		}, titleChildren),

		Subtitle = props.subtitle and e("TextLabel", {
			Text = props.subtitle,
			Size = UDim2.fromScale(0.5, 1),
			Position = UDim2.fromScale(0.5, 0),
			BackgroundTransparency = 1,
			FontFace = theme.Font.Regular,
			TextSize = theme.TextSize.Tiny,
			TextColor3 = theme.Color.Muted,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Center,
		}) or nil,

		Underline = decorations.HeaderUnderline and e("Frame", {
			Size = UDim2.new(1, -pH * 2, 0, 1),
			Position = UDim2.new(0, pH, 1, -2),
			BackgroundColor3 = theme.Color.Accent,
			BorderSizePixel = 0,
		}, {
			Gradient = e("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.5, 0.1),
					NumberSequenceKeypoint.new(1, 1),
				}),
			}),
		}) or nil,
	})
end
