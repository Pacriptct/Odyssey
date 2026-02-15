--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = require(ReplicatedStorage.Shared.Network)

local ReplicationService = {}
ReplicationService.__index = ReplicationService

function ReplicationService:Init(container)
	self.DataService = container:Get("DataService")

	self._snapshotEvent = Network:GetEvent("DataSnapshot")
	self._patchEvent = Network:GetEvent("DataPatch")

	Players.PlayerAdded:Connect(function(player)
		task.defer(function()
			self:SendSnapshot(player)
		end)
	end)
end

function ReplicationService:SendSnapshot(player: Player)
	local data = self.DataService:Get(player)
	if not data then return end

	self._snapshotEvent:Fire(player, data)
end

function ReplicationService:SendPatch(player: Player, patch: { [string]: any })
	self._patchEvent:Fire(player, patch)
end

return ReplicationService
