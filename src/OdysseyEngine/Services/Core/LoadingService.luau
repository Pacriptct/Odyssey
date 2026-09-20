-- Server half of the loading screen. PlayerService calls :notifyReady(player)
-- once the player's profile is loaded; the ReplicatedFirst loader listens on
-- this channel and plays the step sequence, then dismisses itself.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)

local LoadingService = {}

local BOOT_STEPS = {
	{ pct = 10, text = "Initialising core runtime..." },
	{ pct = 30, text = "Binding service modules..." },
	{ pct = 55, text = "Loading player data profiles..." },
	{ pct = 75, text = "Mounting character services..." },
	{ pct = 92, text = "Syncing server state..." },
	{ pct = 100, text = "Ready." },
}

function LoadingService:init()
	self.networker = Networker.server.new("LoadingService", self, {})
end

function LoadingService:notifyReady(player: Player, customSteps: { { pct: number, text: string } }?)
	self.networker:fire(player, "beginSequence", customSteps or BOOT_STEPS)
end

return LoadingService
