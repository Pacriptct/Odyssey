--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Signal = require(Packages.Signal)
local Network = require(ReplicatedStorage.Shared.Network)

local DataController = {}
DataController.__index = DataController

function DataController:Init()
	self.Data = nil
	self.Changed = Signal.new()

	local snapshotEvent = Network:GetEvent("DataSnapshot")
	local patchEvent = Network:GetEvent("DataPatch")

	snapshotEvent:Connect(function(data)
		self.Data = data
		self.Changed:Fire(self.Data)
	end)

	patchEvent:Connect(function(patch)
		if not self.Data then return end

		for k, v in pairs(patch) do
			self.Data[k] = v
		end

		self.Changed:Fire(self.Data)
	end)
end

return DataController
