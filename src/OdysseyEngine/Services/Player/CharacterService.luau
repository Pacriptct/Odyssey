-- OdysseyEngine.Services.Player.CharacterService
--
-- Handles the spawned character: respawn on death (CharacterAutoLoads is off,
-- so respawning is ours to do) and a hook for per-character setup — collision
-- groups, ragdoll rigs, name tags, saved appearance all belong in
-- :onCharacterAdded as your game grows.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.Configs.GameConfig)
local Log = require(ReplicatedStorage.Shared.Framework.Log)

local log = Log.scope("CharacterService")

local CharacterService = {}
CharacterService.Dependencies = { "PlayerService" }

function CharacterService:init(playerService)
	self.players = playerService

	Players.PlayerAdded:Connect(function(player)
		self:_bindPlayer(player)
	end)
	for _, player in Players:GetPlayers() do
		self:_bindPlayer(player)
		if player.Character then
			self:onCharacterAdded(player, player.Character)
		end
	end
end

function CharacterService:_bindPlayer(player: Player)
	player.CharacterAdded:Connect(function(character)
		self:onCharacterAdded(player, character)
	end)
end

function CharacterService:onCharacterAdded(player: Player, character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
	if not humanoid then
		return
	end

	log:debug("character ready for", player.Name)

	-- Per-character setup goes here (collision groups, appearance, tags...).

	humanoid.Died:Connect(function()
		task.delay(GameConfig.RespawnDelay, function()
			if player:IsDescendantOf(Players) then
				player:LoadCharacterAsync()
			end
		end)
	end)
end

return CharacterService
