--!strict

local ControllersFolder = script.Parent:WaitForChild("Controllers")

local ControllerContainer = {}
ControllerContainer.__index = ControllerContainer

ControllerContainer.Controllers = {}

function ControllerContainer:Init()
	for _, module in ipairs(ControllersFolder:GetChildren()) do
		if module:IsA("ModuleScript") then
			local controller = require(module)
			self.Controllers[module.Name] = controller
		end
	end

	for _, controller in pairs(self.Controllers) do
		if controller.Init then
			controller:Init(self)
		end
	end

	_G.ControllerContainer = self
end

function ControllerContainer:Get(name: string)
	return self.Controllers[name]
end

return ControllerContainer
