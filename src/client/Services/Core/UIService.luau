-- Client.Services.Core.UIService
--
-- Mounts every persistent React UI into PlayerGui exactly once, on init.
-- To add a window: write Shared/UI/<Area>/<Name>Menu.luau exposing
-- .mount(playerGui), then add one line here.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CoinsMenu = require(ReplicatedStorage.Shared.UI.Example.CoinsMenu)

local UIService = {}

local mounted = false

function UIService:init()
	if mounted then
		return
	end
	mounted = true

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	CoinsMenu.mount(playerGui)
	-- YourNextMenu.mount(playerGui)
end

return UIService
