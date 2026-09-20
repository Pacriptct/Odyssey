local Themes = {

	Green = {
		-- Backgrounds
		Base = Color3.fromRGB(6, 12, 9),
		Surface = Color3.fromRGB(10, 19, 14),
		Raised = Color3.fromRGB(14, 26, 19),
		Overlay = Color3.fromRGB(18, 34, 24),

		-- Text
		Text = Color3.fromRGB(210, 232, 220),
		Dim = Color3.fromRGB(105, 138, 120),
		Muted = Color3.fromRGB(44, 68, 53),
		Subtle = Color3.fromRGB(25, 48, 34),

		-- Accent
		Accent = Color3.fromRGB(52, 235, 172),
		AccentDim = Color3.fromRGB(24, 96, 70),
		AccentDeep = Color3.fromRGB(10, 64, 42),

		-- Semantic
		Success = Color3.fromRGB(68, 218, 122),
		SuccessBg = Color3.fromRGB(8, 32, 16),
		Warning = Color3.fromRGB(250, 188, 34),
		WarningBg = Color3.fromRGB(32, 24, 4),
		Danger = Color3.fromRGB(246, 108, 108),
		DangerBg = Color3.fromRGB(30, 8, 8),
		Info = Color3.fromRGB(74, 182, 255),
		InfoBg = Color3.fromRGB(6, 20, 36),

		-- Chrome
		Border = Color3.fromRGB(255, 255, 255),
		Divider = Color3.fromRGB(255, 255, 255),
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),
	},
	Blue = {
		Base = Color3.fromRGB(7, 11, 16),
		Surface = Color3.fromRGB(11, 17, 25),
		Raised = Color3.fromRGB(15, 23, 34),
		Overlay = Color3.fromRGB(19, 30, 44),

		Text = Color3.fromRGB(215, 230, 245),
		Dim = Color3.fromRGB(110, 140, 170),
		Muted = Color3.fromRGB(52, 74, 96),
		Subtle = Color3.fromRGB(30, 48, 66),

		Accent = Color3.fromRGB(72, 165, 255),
		AccentDim = Color3.fromRGB(32, 85, 140),
		AccentDeep = Color3.fromRGB(14, 52, 96),

		Success = Color3.fromRGB(82, 208, 138),
		SuccessBg = Color3.fromRGB(8, 28, 22),
		Warning = Color3.fromRGB(255, 190, 50),
		WarningBg = Color3.fromRGB(36, 24, 4),
		Danger = Color3.fromRGB(255, 110, 110),
		DangerBg = Color3.fromRGB(34, 10, 10),
		Info = Color3.fromRGB(95, 175, 255),
		InfoBg = Color3.fromRGB(8, 22, 40),

		Border = Color3.fromRGB(255, 255, 255),
		Divider = Color3.fromRGB(255, 255, 255),
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),
	},
	Purple = {
		Base = Color3.fromRGB(10, 8, 14),
		Surface = Color3.fromRGB(16, 12, 22),
		Raised = Color3.fromRGB(22, 16, 32),
		Overlay = Color3.fromRGB(28, 20, 40),

		Text = Color3.fromRGB(230, 220, 245),
		Dim = Color3.fromRGB(150, 125, 175),
		Muted = Color3.fromRGB(80, 65, 100),
		Subtle = Color3.fromRGB(55, 40, 75),

		Accent = Color3.fromRGB(170, 120, 255),
		AccentDim = Color3.fromRGB(90, 55, 140),
		AccentDeep = Color3.fromRGB(55, 30, 90),

		Success = Color3.fromRGB(88, 215, 150),
		SuccessBg = Color3.fromRGB(10, 26, 20),
		Warning = Color3.fromRGB(255, 185, 70),
		WarningBg = Color3.fromRGB(36, 24, 6),
		Danger = Color3.fromRGB(255, 115, 140),
		DangerBg = Color3.fromRGB(32, 10, 14),
		Info = Color3.fromRGB(130, 165, 255),
		InfoBg = Color3.fromRGB(10, 20, 38),

		Border = Color3.fromRGB(255, 255, 255),
		Divider = Color3.fromRGB(255, 255, 255),
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),
	},
	Crimson = {
		Base = Color3.fromRGB(14, 6, 8),
		Surface = Color3.fromRGB(22, 10, 12),
		Raised = Color3.fromRGB(30, 14, 18),
		Overlay = Color3.fromRGB(38, 18, 24),

		Text = Color3.fromRGB(245, 220, 220),
		Dim = Color3.fromRGB(165, 120, 120),
		Muted = Color3.fromRGB(95, 60, 60),
		Subtle = Color3.fromRGB(60, 35, 35),

		Accent = Color3.fromRGB(255, 90, 90),
		AccentDim = Color3.fromRGB(140, 40, 40),
		AccentDeep = Color3.fromRGB(85, 18, 18),

		Success = Color3.fromRGB(95, 210, 140),
		SuccessBg = Color3.fromRGB(8, 24, 16),
		Warning = Color3.fromRGB(255, 180, 60),
		WarningBg = Color3.fromRGB(32, 20, 4),
		Danger = Color3.fromRGB(255, 70, 70),
		DangerBg = Color3.fromRGB(40, 8, 8),
		Info = Color3.fromRGB(90, 160, 255),
		InfoBg = Color3.fromRGB(8, 20, 36),

		Border = Color3.fromRGB(255, 255, 255),
		Divider = Color3.fromRGB(255, 255, 255),
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),
	},
	Gold = {
		Base = Color3.fromRGB(14, 12, 6),
		Surface = Color3.fromRGB(22, 18, 10),
		Raised = Color3.fromRGB(30, 24, 14),
		Overlay = Color3.fromRGB(38, 30, 18),

		Text = Color3.fromRGB(245, 235, 210),
		Dim = Color3.fromRGB(175, 155, 120),
		Muted = Color3.fromRGB(105, 90, 60),
		Subtle = Color3.fromRGB(65, 55, 35),

		Accent = Color3.fromRGB(255, 210, 95),
		AccentDim = Color3.fromRGB(150, 110, 40),
		AccentDeep = Color3.fromRGB(100, 70, 20),

		Success = Color3.fromRGB(105, 215, 145),
		SuccessBg = Color3.fromRGB(10, 26, 18),
		Warning = Color3.fromRGB(255, 190, 60),
		WarningBg = Color3.fromRGB(34, 22, 4),
		Danger = Color3.fromRGB(255, 110, 110),
		DangerBg = Color3.fromRGB(30, 10, 8),
		Info = Color3.fromRGB(110, 180, 255),
		InfoBg = Color3.fromRGB(8, 22, 36),

		Border = Color3.fromRGB(255, 255, 255),
		Divider = Color3.fromRGB(255, 255, 255),
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),
	},

	Orange = {
		Base = Color3.fromRGB(16, 9, 4),
		Surface = Color3.fromRGB(26, 14, 7),
		Raised = Color3.fromRGB(36, 20, 10),
		Overlay = Color3.fromRGB(48, 28, 14),

		Text = Color3.fromRGB(255, 232, 210),
		Dim = Color3.fromRGB(195, 145, 105),
		Muted = Color3.fromRGB(125, 78, 45),
		Subtle = Color3.fromRGB(82, 46, 24),

		Accent = Color3.fromRGB(255, 135, 45),
		AccentDim = Color3.fromRGB(170, 78, 24),
		AccentDeep = Color3.fromRGB(100, 40, 10),

		Success = Color3.fromRGB(95, 215, 145),
		SuccessBg = Color3.fromRGB(8, 26, 18),
		Warning = Color3.fromRGB(255, 190, 70),
		WarningBg = Color3.fromRGB(38, 24, 4),
		Danger = Color3.fromRGB(255, 90, 75),
		DangerBg = Color3.fromRGB(38, 8, 6),
		Info = Color3.fromRGB(110, 175, 255),
		InfoBg = Color3.fromRGB(8, 22, 38),

		Border = Color3.fromRGB(255, 255, 255),
		Divider = Color3.fromRGB(255, 255, 255),
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),
	},
	Obsidian = {
		Base = Color3.fromRGB(8, 8, 8),
		Surface = Color3.fromRGB(14, 14, 14),
		Raised = Color3.fromRGB(20, 20, 20),
		Overlay = Color3.fromRGB(26, 26, 26),

		Text = Color3.fromRGB(230, 230, 230),
		Dim = Color3.fromRGB(150, 150, 150),
		Muted = Color3.fromRGB(80, 80, 80),
		Subtle = Color3.fromRGB(55, 55, 55),

		Accent = Color3.fromRGB(120, 120, 255),
		AccentDim = Color3.fromRGB(60, 60, 140),
		AccentDeep = Color3.fromRGB(35, 35, 90),

		Success = Color3.fromRGB(90, 210, 140),
		SuccessBg = Color3.fromRGB(10, 24, 16),
		Warning = Color3.fromRGB(255, 185, 60),
		WarningBg = Color3.fromRGB(32, 22, 6),
		Danger = Color3.fromRGB(255, 90, 90),
		DangerBg = Color3.fromRGB(30, 8, 8),
		Info = Color3.fromRGB(95, 165, 255),
		InfoBg = Color3.fromRGB(8, 20, 36),

		Border = Color3.fromRGB(255, 255, 255),
		Divider = Color3.fromRGB(255, 255, 255),
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),
	},
	Dark = {
		Base = Color3.fromRGB(10, 12, 14),
		Surface = Color3.fromRGB(16, 18, 22),
		Raised = Color3.fromRGB(22, 25, 30),
		Overlay = Color3.fromRGB(28, 32, 38),

		Text = Color3.fromRGB(235, 238, 242),
		Dim = Color3.fromRGB(155, 165, 178),
		Muted = Color3.fromRGB(95, 105, 118),
		Subtle = Color3.fromRGB(65, 72, 82),

		Accent = Color3.fromRGB(88, 166, 255),
		AccentDim = Color3.fromRGB(45, 95, 160),
		AccentDeep = Color3.fromRGB(22, 55, 100),

		Success = Color3.fromRGB(72, 210, 140),
		SuccessBg = Color3.fromRGB(12, 32, 22),
		Warning = Color3.fromRGB(255, 190, 60),
		WarningBg = Color3.fromRGB(40, 28, 6),
		Danger = Color3.fromRGB(255, 95, 95),
		DangerBg = Color3.fromRGB(36, 10, 10),
		Info = Color3.fromRGB(100, 175, 255),
		InfoBg = Color3.fromRGB(12, 26, 42),

		Border = Color3.fromRGB(255, 255, 255),
		Divider = Color3.fromRGB(255, 255, 255),
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),
	},
	Light = {
		Base = Color3.fromRGB(245, 247, 250),
		Surface = Color3.fromRGB(235, 238, 242),
		Raised = Color3.fromRGB(225, 230, 236),
		Overlay = Color3.fromRGB(215, 220, 226),

		Text = Color3.fromRGB(28, 32, 38),
		Dim = Color3.fromRGB(80, 90, 105),
		Muted = Color3.fromRGB(125, 135, 150),
		Subtle = Color3.fromRGB(165, 172, 182),

		Accent = Color3.fromRGB(50, 120, 255),
		AccentDim = Color3.fromRGB(100, 145, 230),
		AccentDeep = Color3.fromRGB(25, 75, 160),

		Success = Color3.fromRGB(60, 180, 110),
		SuccessBg = Color3.fromRGB(215, 240, 225),
		Warning = Color3.fromRGB(235, 165, 40),
		WarningBg = Color3.fromRGB(255, 240, 210),
		Danger = Color3.fromRGB(225, 80, 80),
		DangerBg = Color3.fromRGB(250, 220, 220),
		Info = Color3.fromRGB(70, 140, 255),
		InfoBg = Color3.fromRGB(220, 235, 255),

		Border = Color3.fromRGB(0, 0, 0),
		Divider = Color3.fromRGB(0, 0, 0),
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),
	},
	Default = {
		Base = Color3.fromRGB(12, 14, 18),
		Surface = Color3.fromRGB(18, 21, 26),
		Raised = Color3.fromRGB(24, 28, 34),
		Overlay = Color3.fromRGB(30, 35, 42),

		Text = Color3.fromRGB(235, 238, 242),
		Dim = Color3.fromRGB(155, 165, 178),
		Muted = Color3.fromRGB(100, 110, 125),
		Subtle = Color3.fromRGB(70, 78, 90),

		Accent = Color3.fromRGB(90, 160, 255),
		AccentDim = Color3.fromRGB(45, 95, 160),
		AccentDeep = Color3.fromRGB(22, 55, 100),

		Success = Color3.fromRGB(70, 205, 135),
		SuccessBg = Color3.fromRGB(14, 34, 24),
		Warning = Color3.fromRGB(255, 190, 60),
		WarningBg = Color3.fromRGB(40, 28, 6),
		Danger = Color3.fromRGB(255, 95, 95),
		DangerBg = Color3.fromRGB(36, 10, 10),
		Info = Color3.fromRGB(95, 175, 255),
		InfoBg = Color3.fromRGB(12, 26, 42),

		Border = Color3.fromRGB(255, 255, 255),
		Divider = Color3.fromRGB(255, 255, 255),
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),
	},
	Slate = {
		Base = Color3.fromRGB(15, 17, 20),
		Surface = Color3.fromRGB(21, 24, 28),
		Raised = Color3.fromRGB(28, 32, 38),
		Overlay = Color3.fromRGB(34, 39, 46),

		Text = Color3.fromRGB(240, 243, 246),
		Dim = Color3.fromRGB(170, 178, 190),
		Muted = Color3.fromRGB(110, 120, 135),
		Subtle = Color3.fromRGB(80, 88, 100),

		Accent = Color3.fromRGB(120, 170, 255),
		AccentDim = Color3.fromRGB(60, 100, 160),
		AccentDeep = Color3.fromRGB(30, 60, 100),

		Success = Color3.fromRGB(80, 210, 145),
		SuccessBg = Color3.fromRGB(12, 30, 22),
		Warning = Color3.fromRGB(255, 200, 75),
		WarningBg = Color3.fromRGB(40, 30, 8),
		Danger = Color3.fromRGB(255, 105, 105),
		DangerBg = Color3.fromRGB(36, 12, 12),
		Info = Color3.fromRGB(110, 180, 255),
		InfoBg = Color3.fromRGB(14, 28, 45),

		Border = Color3.fromRGB(255, 255, 255),
		Divider = Color3.fromRGB(255, 255, 255),
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),
	},
	Midnight = {
		Base = Color3.fromRGB(6, 10, 18),
		Surface = Color3.fromRGB(10, 16, 26),
		Raised = Color3.fromRGB(16, 22, 36),
		Overlay = Color3.fromRGB(22, 28, 44),

		Text = Color3.fromRGB(220, 230, 250),
		Dim = Color3.fromRGB(140, 160, 200),
		Muted = Color3.fromRGB(80, 100, 140),
		Subtle = Color3.fromRGB(50, 70, 100),

		Accent = Color3.fromRGB(100, 160, 255),
		AccentDim = Color3.fromRGB(45, 85, 150),
		AccentDeep = Color3.fromRGB(20, 45, 95),

		Success = Color3.fromRGB(85, 210, 155),
		SuccessBg = Color3.fromRGB(8, 24, 20),
		Warning = Color3.fromRGB(255, 190, 70),
		WarningBg = Color3.fromRGB(32, 22, 6),
		Danger = Color3.fromRGB(255, 100, 110),
		DangerBg = Color3.fromRGB(28, 10, 14),
		Info = Color3.fromRGB(110, 175, 255),
		InfoBg = Color3.fromRGB(10, 22, 40),

		Border = Color3.fromRGB(255, 255, 255),
		Divider = Color3.fromRGB(255, 255, 255),
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),
	},
	Ember = {
		Base = Color3.fromRGB(20, 10, 8),
		Surface = Color3.fromRGB(28, 14, 12),
		Raised = Color3.fromRGB(36, 18, 16),
		Overlay = Color3.fromRGB(44, 22, 20),

		Text = Color3.fromRGB(255, 230, 220),
		Dim = Color3.fromRGB(190, 140, 130),
		Muted = Color3.fromRGB(120, 70, 60),
		Subtle = Color3.fromRGB(85, 45, 40),

		Accent = Color3.fromRGB(255, 110, 80),
		AccentDim = Color3.fromRGB(150, 60, 40),
		AccentDeep = Color3.fromRGB(90, 30, 20),

		Success = Color3.fromRGB(95, 210, 150),
		SuccessBg = Color3.fromRGB(8, 24, 18),
		Warning = Color3.fromRGB(255, 170, 60),
		WarningBg = Color3.fromRGB(36, 20, 4),
		Danger = Color3.fromRGB(255, 70, 70),
		DangerBg = Color3.fromRGB(40, 8, 8),
		Info = Color3.fromRGB(110, 170, 255),
		InfoBg = Color3.fromRGB(8, 20, 36),

		Border = Color3.fromRGB(255, 255, 255),
		Divider = Color3.fromRGB(255, 255, 255),
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),
	},
	Legion = {
		Base = Color3.fromRGB(18, 22, 20),
		Surface = Color3.fromRGB(24, 30, 26),
		Raised = Color3.fromRGB(32, 38, 32),
		Overlay = Color3.fromRGB(40, 46, 38),

		Text = Color3.fromRGB(230, 235, 225),
		Dim = Color3.fromRGB(160, 170, 150),
		Muted = Color3.fromRGB(100, 110, 95),
		Subtle = Color3.fromRGB(70, 80, 70),

		Accent = Color3.fromRGB(150, 200, 120),
		AccentDim = Color3.fromRGB(80, 110, 60),
		AccentDeep = Color3.fromRGB(50, 70, 40),

		Success = Color3.fromRGB(110, 210, 150),
		SuccessBg = Color3.fromRGB(10, 26, 18),
		Warning = Color3.fromRGB(240, 190, 70),
		WarningBg = Color3.fromRGB(36, 24, 6),
		Danger = Color3.fromRGB(220, 80, 80),
		DangerBg = Color3.fromRGB(30, 10, 10),
		Info = Color3.fromRGB(110, 180, 255),
		InfoBg = Color3.fromRGB(8, 20, 36),

		Border = Color3.fromRGB(255, 255, 255),
		Divider = Color3.fromRGB(255, 255, 255),
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),
	},

	Pink = {
		Base = Color3.fromRGB(18, 8, 14),
		Surface = Color3.fromRGB(28, 12, 22),
		Raised = Color3.fromRGB(38, 18, 30),
		Overlay = Color3.fromRGB(50, 24, 40),

		Text = Color3.fromRGB(255, 225, 240),
		Dim = Color3.fromRGB(205, 140, 175),
		Muted = Color3.fromRGB(130, 75, 105),
		Subtle = Color3.fromRGB(85, 45, 68),

		Accent = Color3.fromRGB(255, 105, 180),
		AccentDim = Color3.fromRGB(170, 55, 115),
		AccentDeep = Color3.fromRGB(105, 24, 68),

		Success = Color3.fromRGB(95, 220, 155),
		SuccessBg = Color3.fromRGB(8, 28, 18),
		Warning = Color3.fromRGB(255, 195, 80),
		WarningBg = Color3.fromRGB(36, 24, 6),
		Danger = Color3.fromRGB(255, 85, 125),
		DangerBg = Color3.fromRGB(38, 8, 18),
		Info = Color3.fromRGB(120, 180, 255),
		InfoBg = Color3.fromRGB(10, 22, 40),

		Border = Color3.fromRGB(255, 255, 255),
		Divider = Color3.fromRGB(255, 255, 255),
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),
	},

	RedBlack = {
		Base = Color3.fromRGB(5, 5, 6),
		Surface = Color3.fromRGB(12, 9, 10),
		Raised = Color3.fromRGB(20, 12, 14),
		Overlay = Color3.fromRGB(32, 14, 18),

		Text = Color3.fromRGB(245, 235, 235),
		Dim = Color3.fromRGB(170, 125, 125),
		Muted = Color3.fromRGB(95, 55, 55),
		Subtle = Color3.fromRGB(55, 30, 30),

		Accent = Color3.fromRGB(255, 40, 40),
		AccentDim = Color3.fromRGB(155, 22, 22),
		AccentDeep = Color3.fromRGB(85, 8, 8),

		Success = Color3.fromRGB(85, 210, 135),
		SuccessBg = Color3.fromRGB(8, 24, 16),
		Warning = Color3.fromRGB(255, 185, 55),
		WarningBg = Color3.fromRGB(34, 22, 4),
		Danger = Color3.fromRGB(255, 60, 60),
		DangerBg = Color3.fromRGB(42, 6, 6),
		Info = Color3.fromRGB(95, 160, 255),
		InfoBg = Color3.fromRGB(8, 18, 34),

		Border = Color3.fromRGB(255, 255, 255),
		Divider = Color3.fromRGB(255, 255, 255),
		White = Color3.new(1, 1, 1),
		Black = Color3.new(0, 0, 0),
	},
}

local listeners: { () -> () } = {}

local activeThemeName = "Dark"
local activeColorTheme = Themes[activeThemeName]

local Theme = {}

---------------------------------------------------------------------
-- Subscription System (React Compatible)
---------------------------------------------------------------------

function Theme.subscribe(callback: () -> ())
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

---------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------

function Theme.getTheme()
	local Style = require(script.Parent.Style)
	local s = Style.getStyle()
	return {
		Color = activeColorTheme,
		Font = s.Font,
		Radius = s.Radius,
		Stroke = s.Stroke,
		Decorations = s.Decorations,
		TextSize = Theme.TextSize,
		Space = Theme.Space,
		Alpha = Theme.Alpha,
		ZIndex = Theme.ZIndex,
		dim = Theme.dim,
		StyleName = Style.getStyleName(),
		ThemeName = activeThemeName,
	}
end

function Theme.setTheme(name: string)
	local t = Themes[name]
	if not t then
		warn("[Theme] Unknown theme:", name)
		return
	end

	activeThemeName = name
	activeColorTheme = t

	notify()
end

function Theme.getThemeName()
	return activeThemeName
end

function Theme.getAllThemes()
	return Themes
end

---------------------------------------------------------------------
-- Static Tokens (Do NOT mutate)
---------------------------------------------------------------------

-- Static Font tokens kept for direct `Theme.Font.X` access. These are Font
-- objects (FontFace-compatible). The active Style overrides these via
-- `Theme.getTheme().Font` for React consumers using `useTheme`.
Theme.Font = setmetatable({}, {
	__index = function(_, k)
		local Style = require(script.Parent.Style)
		return Style.getStyle().Font[k]
	end,
})

Theme.TextSize = {
	Micro = 8,
	Tiny = 10,
	Small = 11,
	Body = 12,
	Label = 13,
	Title = 15,
	Header = 18,
	Hero = 24,
}

Theme.Space = {
	Micro = 2,
	Tiny = 4,
	Small = 6,
	Base = 8,
	Medium = 12,
	Large = 16,
	XLarge = 24,
	XXL = 32,
}

Theme.Radius = {
	Tiny = 3,
	Small = 4,
	Base = 6,
	Medium = 8,
	Large = 12,
	Round = 999,
}

Theme.Alpha = {
	Border = 0.92,
	BorderMid = 0.80,
	BorderStrong = 0.55,
	Divider = 0.94,
	Hover = 0.88,
	Overlay = 0.48,
	Ghost = 0.94,
}

Theme.ZIndex = {
	Base = 1,
	Raised = 5,
	Dropdown = 10,
	Overlay = 20,
	Modal = 50,
	Toast = 80,
	Top = 100,
}

Theme.Raritys = {
	Common = Color3.fromRGB(160, 170, 150),
	Uncommon = Color3.fromRGB(85, 210, 155),
	Rare = Color3.fromRGB(110, 170, 255),
	Legendary = Color3.fromRGB(60, 60, 140),
	Mythic = Color3.fromRGB(255, 190, 70),
}

---------------------------------------------------------------------
-- Utilities
---------------------------------------------------------------------

function Theme.dim(color: Color3, factor: number): Color3
	return Color3.new(
		math.clamp(color.R * factor, 0, 1),
		math.clamp(color.G * factor, 0, 1),
		math.clamp(color.B * factor, 0, 1)
	)
end

function Theme.semantic(kind: string?): (Color3, Color3)
	local colors = activeColorTheme

	if kind == "success" then
		return colors.Success, colors.SuccessBg
	elseif kind == "warning" then
		return colors.Warning, colors.WarningBg
	elseif kind == "danger" then
		return colors.Danger, colors.DangerBg
	elseif kind == "info" then
		return colors.Info, colors.InfoBg
	else
		return colors.Accent, colors.AccentDeep
	end
end

---------------------------------------------------------------------
-- Initialize Default
---------------------------------------------------------------------

Theme.setTheme(activeThemeName)

return Theme
