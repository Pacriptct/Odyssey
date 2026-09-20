-- Style.luau
-- Visual treatment layer that sits on top of Theme. Theme owns colors;
-- Style owns fonts, corner radii, stroke treatments, and decorator
-- toggles that primitives consult when rendering.

local Styles = {

	Default = {
		Font = {
			Title = Font.fromEnum(Enum.Font.GothamBold),
			Body = Font.fromEnum(Enum.Font.Gotham),
			Bold = Font.fromEnum(Enum.Font.GothamBold),
			Regular = Font.fromEnum(Enum.Font.Gotham),
			Mono = Font.fromEnum(Enum.Font.Code),
		},
		Radius = {
			Tiny = 3,
			Small = 4,
			Base = 6,
			Medium = 8,
			Large = 12,
			Round = 999,
		},
		Stroke = {
			Thickness = 1,
			Gradient = false,
			GradientRotation = 0,
		},
		Decorations = {
			PanelBackgroundGradient = false,
			HeaderUnderline = false,
			HeaderTitleGradient = false,
			TitleUppercase = false,
		},
	},

	-- Fantasy / AoT
	-- Merriweather typography, sharper corners, gradient strokes that fade
	-- at the edges, gradient underlines beneath headers, and a tinted
	-- vertical gradient on panel backgrounds.
	Fantasy = {
		Font = {
			Title = Font.new("rbxasset://fonts/families/Merriweather.json", Enum.FontWeight.Bold),
			Body = Font.new("rbxasset://fonts/families/Merriweather.json", Enum.FontWeight.Regular),
			Bold = Font.new("rbxasset://fonts/families/Merriweather.json", Enum.FontWeight.Bold),
			Regular = Font.new("rbxasset://fonts/families/Merriweather.json", Enum.FontWeight.Regular),
			Mono = Font.fromEnum(Enum.Font.Code),
		},
		Radius = {
			Tiny = 0,
			Small = 0,
			Base = 0,
			Medium = 0,
			Large = 0,
			Round = 999,
		},
		Stroke = {
			Thickness = 1,
			Gradient = true,
			GradientRotation = 0,
		},
		Decorations = {
			PanelBackgroundGradient = true,
			HeaderUnderline = true,
			HeaderTitleGradient = true,
			TitleUppercase = true,
			SquareCorners = true,
		},
	},
}

local listeners: { () -> () } = {}
local activeStyleName = "Default"
local activeStyle = Styles[activeStyleName]

local Style = {}

function Style.subscribe(callback: () -> ())
	table.insert(listeners, callback)
	return function()
		for i, v in listeners do
			if v == callback then
				table.remove(listeners, i)
				break
			end
		end
	end
end

local function notify()
	for _, cb in listeners do
		cb()
	end
end

function Style.getStyle()
	return activeStyle
end

function Style.getStyleName()
	return activeStyleName
end

function Style.setStyle(name: string)
	local s = Styles[name]
	if not s then
		warn("[Style] Unknown style:", name)
		return
	end
	activeStyleName = name
	activeStyle = s
	notify()
end

function Style.getAllStyles()
	return Styles
end

return Style
