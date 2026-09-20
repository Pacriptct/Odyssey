local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local ProfiledRoot = require(script.Parent.ProfiledRoot)
local Theme = require(script.Parent.Theme)
local useTheme = require(script.Parent.useTheme)
local Corner = require(script.Parent.Corner)
local Stroke = require(script.Parent.Stroke)
local Padding = require(script.Parent.Padding)
local ScreenScale = require(script.Parent.ScreenScale)

local e = React.createElement
local useState = React.useState
local useEffect = React.useEffect

local _pushCallback: ((data: { kind: string, text: string, duration: number? }) -> ())? = nil
local _nextId = 0

local Notification = {}

local KIND_LABEL = {
	success = "SUCCESS",
	warning = "WARNING",
	danger = "ERROR",
	error = "ERROR",
	info = "NOTIFICATION",
}

local DISPLAY_TIME = 3

local function NotificationUI()
	local theme = useTheme()
	local current, setCurrent = useState(nil)

	useEffect(function()
		_pushCallback = function(data)
			_nextId += 1
			local id = _nextId
			local stamped = table.clone(data)
			stamped.id = id

			setCurrent(stamped)
			task.delay(stamped.duration or DISPLAY_TIME, function()
				setCurrent(function(c)
					if c and c.id == id then
						return nil
					end
					return c
				end)
			end)
		end
		return function()
			_pushCallback = nil
		end
	end, {})

	if not current then
		return e("Frame", {
			Size = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 1,
		})
	end

	local fgColor = Theme.semantic(current.kind)
	local label = KIND_LABEL[current.kind] or "NOTIFICATION"

	return e("Frame", {
		Size = UDim2.fromOffset(320, 56),
		Position = UDim2.new(1, -336, 1, -68),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = theme.Color.Surface,
		BorderSizePixel = 0,
		ZIndex = 100,
	}, {
		Corner = e(Corner, { radius = theme.Radius.Small }),
		Stroke = e(Stroke, { color = fgColor, transparency = theme.Alpha.BorderStrong }),
		Padding = e(Padding, { left = theme.Space.Medium, right = theme.Space.Medium }),

		Header = e("TextLabel", {
			Text = label,
			Size = UDim2.new(1, 0, 0, 18),
			Position = UDim2.fromOffset(0, 6),
			BackgroundTransparency = 1,
			FontFace = Theme.Font.Bold,
			TextSize = Theme.TextSize.Tiny,
			TextColor3 = fgColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 101,
		}),

		Label = e("TextLabel", {
			Text = current.text,
			Size = UDim2.new(1, 0, 0, 26),
			Position = UDim2.fromOffset(0, 24),
			BackgroundTransparency = 1,
			FontFace = Theme.Font.Regular,
			TextSize = Theme.TextSize.Body,
			TextColor3 = theme.Color.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			ZIndex = 101,
		}),
	})
end

local _root = nil
local _mounted = false

function Notification.mount(playerGui: PlayerGui)
	if _mounted then
		return
	end
	_mounted = true

	local sg = Instance.new("ScreenGui")
	ScreenScale.attach(sg)
	sg.Name = "NotificationGui"
	sg.ResetOnSpawn = false
	sg.DisplayOrder = 100
	sg.IgnoreGuiInset = true
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.Parent = playerGui

	_root = ReactRoblox.createRoot(sg)
	_root:render(ProfiledRoot("Notification", e(NotificationUI, {})))
end

function Notification.push(data: { kind: string, text: string, duration: number? })
	if _pushCallback then
		_pushCallback(data)
	else
		task.defer(function()
			if _pushCallback then
				_pushCallback(data)
			end
		end)
	end
end

local function NotificationElement(props)
	local theme = useTheme()
	local fgColor = Theme.semantic(props.kind)
	local label = KIND_LABEL[props.kind] or "NOTIFICATION"
	local zi = props.zIndex or 100

	return e("Frame", {
		Size = props.size or UDim2.fromOffset(320, 56),
		Position = props.position or UDim2.new(1, -336, 1, -68),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = theme.Color.Surface,
		BorderSizePixel = 0,
		ZIndex = zi,
	}, {
		Corner = e(Corner, { radius = theme.Radius.Small }),
		Stroke = e(Stroke, { color = fgColor, transparency = theme.Alpha.BorderStrong }),
		Padding = e(Padding, { left = theme.Space.Medium, right = theme.Space.Medium }),
		Header = e("TextLabel", {
			Text = label,
			Size = UDim2.new(1, 0, 0, 18),
			Position = UDim2.fromOffset(0, 6),
			BackgroundTransparency = 1,
			FontFace = Theme.Font.Bold,
			TextSize = Theme.TextSize.Tiny,
			TextColor3 = fgColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = zi + 1,
		}),
		Label = e("TextLabel", {
			Text = props.text,
			Size = UDim2.new(1, 0, 0, 26),
			Position = UDim2.fromOffset(0, 24),
			BackgroundTransparency = 1,
			FontFace = Theme.Font.Regular,
			TextSize = Theme.TextSize.Body,
			TextColor3 = theme.Color.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			ZIndex = zi + 1,
		}),
	})
end

setmetatable(Notification, {
	__call = function(_, props)
		return NotificationElement(props)
	end,
})

return Notification
