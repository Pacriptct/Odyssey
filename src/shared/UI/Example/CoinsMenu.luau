-- Shared.UI.Example.CoinsMenu
--
-- A complete worked example of a React window in the house style:
--   • .mount(playerGui) creates the ScreenGui once (called by UIService)
--   • ScreenScale.attach keeps 1080p-authored pixels consistent on every screen
--   • the component subscribes to its client controller (CoinServiceClient)
--     for open/close and to PlayerServiceClient for live data
--   • it returns nil while hidden — no ScreenGui juggling
--
-- Toggle in game with the M key (see CoinServiceClient).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local Loader = require(ReplicatedStorage.Shared.Framework.Loader)
local Button = require(ReplicatedStorage.Shared.UI.Primitives.Button)
local Corner = require(ReplicatedStorage.Shared.UI.Primitives.Corner)
local Padding = require(ReplicatedStorage.Shared.UI.Primitives.Padding)
local ScreenScale = require(ReplicatedStorage.Shared.UI.Primitives.ScreenScale)
local Stroke = require(ReplicatedStorage.Shared.UI.Primitives.Stroke)
local useTheme = require(ReplicatedStorage.Shared.UI.Primitives.useTheme)

local e = React.createElement
local useState = React.useState
local useEffect = React.useEffect

local WINDOW_W = 320
local WINDOW_H = 220
local Z = 30

local function Component()
	local theme = useTheme()
	local visible, setVisible = useState(false)
	local coins, setCoins = useState(0)
	local flash, setFlash = useState(nil :: string?)

	useEffect(function()
		local coinsClient = Loader.get("CoinServiceClient")
		local playerClient = Loader.get("PlayerServiceClient")

		local unsubs = {
			coinsClient:onToggle(function(open)
				setVisible(open)
				if open then
					setCoins(playerClient:get("Coins") or 0)
				end
			end),
			playerClient:onKeyChanged("Coins", function(value)
				setCoins(value or 0)
			end),
			coinsClient:onAwarded(function(amount)
				setFlash(("+%d"):format(amount))
				task.delay(1.2, function()
					setFlash(nil)
				end)
			end),
		}
		return function()
			for _, unsub in unsubs do
				unsub()
			end
		end
	end, {})

	if not visible then
		return nil
	end

	return e("Frame", {
		Size = UDim2.fromOffset(WINDOW_W, WINDOW_H),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Color.Surface,
		BorderSizePixel = 0,
		ZIndex = Z,
	}, {
		Corner = e(Corner, { radius = theme.Radius.Medium }),
		Stroke = e(Stroke, {}),
		Padding = e(Padding, { all = theme.Space.Large }),

		Title = e("TextLabel", {
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundTransparency = 1,
			Text = "COINS",
			FontFace = theme.Font.Title,
			TextSize = theme.TextSize.Header,
			TextColor3 = theme.Color.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = Z,
		}),

		Close = e("TextButton", {
			Size = UDim2.fromOffset(24, 24),
			Position = UDim2.new(1, 0, 0, 0),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Text = "✕",
			FontFace = theme.Font.Bold,
			TextSize = theme.TextSize.Label,
			TextColor3 = theme.Color.Dim,
			ZIndex = Z + 1,
			[React.Event.Activated] = function()
				Loader.get("CoinServiceClient"):Close()
			end,
		}),

		Balance = e("TextLabel", {
			Size = UDim2.new(1, 0, 0, 48),
			Position = UDim2.fromOffset(0, 44),
			BackgroundTransparency = 1,
			Text = tostring(coins),
			FontFace = theme.Font.Bold,
			TextSize = theme.TextSize.Hero,
			TextColor3 = theme.Color.Accent,
			ZIndex = Z,
		}),

		Flash = flash and e("TextLabel", {
			Size = UDim2.new(1, 0, 0, 18),
			Position = UDim2.fromOffset(0, 96),
			BackgroundTransparency = 1,
			Text = flash,
			FontFace = theme.Font.Regular,
			TextSize = theme.TextSize.Small,
			TextColor3 = theme.Color.Success,
			ZIndex = Z,
		}) or nil,

		Collect = e(Button, {
			text = "COLLECT",
			variant = "solid",
			size = UDim2.new(1, 0, 0, 34),
			position = UDim2.new(0, 0, 1, 0),
			anchorPoint = Vector2.new(0, 1),
			zIndex = Z,
			onClick = function()
				Loader.get("CoinServiceClient"):collect()
			end,
		}),
	})
end

local CoinsMenu = {}

CoinsMenu.Component = Component

function CoinsMenu.mount(playerGui: PlayerGui)
	local existing = playerGui:FindFirstChild("CoinsMenu")
	if existing then
		existing:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	ScreenScale.attach(screenGui)
	screenGui.Name = "CoinsMenu"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = Z
	screenGui.Parent = playerGui

	local root = ReactRoblox.createRoot(screenGui)
	root:render(e(Component))
end

return CoinsMenu
