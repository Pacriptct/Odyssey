--!strict

local ServiceContainer = require(script.Parent.ServiceContainer)

local container = setmetatable({}, ServiceContainer)
container:Init()

print("Odyssey server boot complete.")
