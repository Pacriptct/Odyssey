--!strict

local ControllerContainer = require(script.Parent.ControllerContainer)

local container = setmetatable({}, ControllerContainer)
container:Init()

print("Odyssey client boot complete.")
