--
local React = require(game.ReplicatedStorage.Packages.React)
local Corner = require(script.Parent.Corner)
local Stroke = require(script.Parent.Stroke)
local e = React.createElement

export type Props = {
	text: string,
	placeholder: string?,
	size: UDim2,
	position: UDim2?,
	bg: Color3,
	fg: Color3,
	placeholderColor: Color3?,
	font: Enum.Font?,
	textSize: number?,
	radius: number?,
	onChanged: (string) -> (),
	onEnter: (() -> ())?,
}

return function(props: Props)
	return e("Frame", {
		Size = props.size,
		Position = props.position,
		BackgroundColor3 = props.bg,
		BorderSizePixel = 0,
	}, {
		Corner = e(Corner, {
			radius = props.radius or 5,
		}),

		Stroke = e(Stroke, {
			color = Color3.fromRGB(255, 255, 255),
			transparency = 0.93,
		}),

		Box = e("TextBox", {
			Text = props.text,
			PlaceholderText = props.placeholder or "",
			PlaceholderColor3 = props.placeholderColor or Color3.fromRGB(80, 110, 95),

			Size = UDim2.new(1, -12, 1, 0),
			Position = UDim2.fromOffset(6, 0),

			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Font = props.font or Enum.Font.Gotham,
			TextSize = props.textSize or 12,
			TextColor3 = props.fg,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,

			[React.Change.Text] = function(rbx: TextBox)
				props.onChanged(rbx.Text)
			end,

			[React.Event.FocusLost] = function(_rbx: TextBox)
				if props.onEnter then
					props.onEnter()
				end
			end,
		}),
	})
end
