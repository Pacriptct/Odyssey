--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Networker = require(Packages.Networker)

local Network = Networker.new("Odyssey")

return Network
