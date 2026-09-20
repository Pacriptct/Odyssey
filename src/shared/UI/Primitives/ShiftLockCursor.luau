--

local React = require(game:GetService("ReplicatedStorage").Packages.React)

type Props = {
	Enabled: boolean,
}

local DOT_SIZE = 5

local function ShiftLockCursor(props: Props)
	if not props.Enabled then
		return nil
	end

	return React.createElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(235, 235, 235),
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(DOT_SIZE, DOT_SIZE),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 1000,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),

		Stroke = React.createElement("UIStroke", {
			Thickness = 1,
			Transparency = 0.35,
			Color = Color3.fromRGB(20, 20, 20),
		}),
	})
end

return ShiftLockCursor