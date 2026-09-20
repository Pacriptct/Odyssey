local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local Corner = require(script.Parent.Corner)
local Stroke = require(script.Parent.Stroke)
local Sounds = require(script.Parent.Sounds)
local useTheme = require(script.Parent.useTheme)

local e = React.createElement
local useEffect = React.useEffect
local useRef = React.useRef

return function(props)
	local theme = useTheme()
	local boxRef = props.inputRef or useRef(nil)

	-- Tracks the last value we know about so we can tell a real keystroke from a
	-- programmatic sync. A value compare (rather than a flag we flip around the
	-- assignment) is required because Roblox fires Changed signals *deferred* —
	-- a flag reset synchronously after setting .Text is already false by the time
	-- the Change handler runs, which would let programmatic syncs play the typing
	-- sound. With several inputs syncing at once that stacks into audible overlap.
	local lastValue = useRef(props.value or "")

	-- Sync external value → TextBox
	useEffect(function()
		local next = props.value or ""
		lastValue.current = next
		if boxRef.current and boxRef.current.Text ~= next then
			boxRef.current.Text = next
		end
	end, { props.value })

	return e("Frame", {
		Size = props.size or UDim2.new(1, 0, 0, 32),
		Position = props.position,
		LayoutOrder = props.layoutOrder,
		BackgroundColor3 = theme.Color.Surface,
		BorderSizePixel = 0,
	}, {
		Corner = e(Corner, { radius = props.radius or theme.Radius.Small }),
		Stroke = e(Stroke, { color = theme.Color.Border, transparency = theme.Alpha.Border }),

		Box = e("TextBox", {
			ref = boxRef,
			Text = props.value or "",
			PlaceholderText = props.placeholder or "",
			PlaceholderColor3 = theme.Color.Muted,
			Size = UDim2.new(1, -14, 1, 0),
			Position = UDim2.fromOffset(7, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = theme.Font.Regular,
			TextSize = props.fontSize or theme.TextSize.Body,
			TextColor3 = props.disabled and theme.Color.Muted or theme.Color.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,

			[React.Change.Text] = function(rbx)
				-- Ignore changes that just echo a programmatic sync (the text
				-- already matches what we last pushed in) — only real keystrokes
				-- differ from lastValue.
				if rbx.Text == lastValue.current then
					return
				end
				lastValue.current = rbx.Text
				if not props.muteTypingSound then
					Sounds.play("type")
				end
				props.onChanged(rbx.Text)
			end,

			[React.Event.FocusLost] = function(_, enterPressed)
				if enterPressed and props.onSubmit then
					Sounds.play("confirm")
					props.onSubmit()
				end
			end,
		}),
	})
end
