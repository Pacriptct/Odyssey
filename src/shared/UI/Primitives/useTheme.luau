local React = require(game.ReplicatedStorage.Packages.React)
local Theme = require(script.Parent.Theme)
local Style = require(script.Parent.Style)

return function()
	local theme, setTheme = React.useState(Theme.getTheme())

	React.useEffect(function()
		local d1 = Theme.subscribe(function()
			setTheme(Theme.getTheme())
		end)
		local d2 = Style.subscribe(function()
			setTheme(Theme.getTheme())
		end)

		return function()
			d1()
			d2()
		end
	end, {})

	return theme
end
