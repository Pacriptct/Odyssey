--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Signal = require(Packages.Signal)
local Networker = require(Packages.Networker)

local DataController = {}
DataController.__index = DataController

function DataController:Init()
	self.Data = nil
	self.Changed = Signal.new()

	-- Initialize networker client
	self.networker = Networker.client.new("ReplicationService", self)

	-- Request initial snapshot from server
	self.networker:fire("RequestSnapshot")
end

-- Server calls this to send snapshot
function DataController:ReceiveSnapshot(data)
	self.Data = data
	self.Changed:Fire(self.Data)
end

-- Server calls this to send patches
function DataController:ReceivePatch(patch)
	if not self.Data then return end

	for k, v in pairs(patch) do
		self.Data[k] = v
	end

	self.Changed:Fire(self.Data)
end

return DataController