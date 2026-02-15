--!strict

local ServerScriptService = game:GetService("ServerScriptService")

local ServicesFolder = ServerScriptService:WaitForChild("Services")

local ServiceContainer = {}
ServiceContainer.__index = ServiceContainer

ServiceContainer.Services = {}

function ServiceContainer:Init()
	for _, module in ipairs(ServicesFolder:GetChildren()) do
		if module:IsA("ModuleScript") then
			local service = require(module)
			if type(service) == "table" then
				self.Services[module.Name] = service
			end
		end
	end

	for _, service in pairs(self.Services) do
		if service.Init then
			service:Init(self)
		end
	end
end

function ServiceContainer:Get(name: string)
	return self.Services[name]
end

return ServiceContainer
