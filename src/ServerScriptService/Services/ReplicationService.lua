--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Networker = require(Packages.Networker)

local ReplicationService = {}
ReplicationService.__index = ReplicationService

function ReplicationService:Init(container)
	self.DataService = container:Get("DataService")

	-- Initialize networker with methods clients can call
	self.networker = Networker.server.new("ReplicationService", self, {
		self.RequestSnapshot,
	})

	Players.PlayerAdded:Connect(function(player)
		task.defer(function()
			self:SendSnapshot(player)
		end)
	end)
end

-- Client can call this method
function ReplicationService:RequestSnapshot(player: Player)
	self:SendSnapshot(player)
end

function ReplicationService:SendSnapshot(player: Player)
	local data = self.DataService:Get(player)
	if not data then return end

	-- Send snapshot to client
	self.networker:fire(player, "ReceiveSnapshot", data)
end

function ReplicationService:SendPatch(player: Player, patch: { [string]: any })
	-- Send patch to client
	self.networker:fire(player, "ReceivePatch", patch)
end

return ReplicationService