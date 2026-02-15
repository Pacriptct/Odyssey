--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Networker = require(Packages.Networker)
local Signal = require(Packages.Signal)

local CharacterCreatorController = {}
CharacterCreatorController.__index = CharacterCreatorController

function CharacterCreatorController:Init(container)
	-- Signals for UI to listen to (renamed to avoid conflict)
	self.OnCharacterAccepted = Signal.new()
	self.OnCharacterRejected = Signal.new()

	-- Initialize networker
	self.networker = Networker.client.new("CharacterCreatorService", self)

	-- Wait for DataController to be initialized
	task.spawn(function()
		local dataController = nil
		repeat
			task.wait(0.1)
			dataController = container:Get("DataController")
		until dataController ~= nil
		
		self.DataController = dataController

		-- Wait for data to load, then check if character exists
		self.DataController.Changed:Connect(function(data)
			if data and data.FullName == "" then
				-- No character, show creator
				self:ShowCreator()
			else
				-- Character exists, hide creator
				self:HideCreator()
			end
		end)
		
		-- Also check if data already exists
		if self.DataController.Data then
			if self.DataController.Data.FullName == "" then
				self:ShowCreator()
			else
				self:HideCreator()
			end
		end
	end)
end

function CharacterCreatorController:ShowCreator()
	local player = Players.LocalPlayer
	local gui = player.PlayerGui:WaitForChild("CharacterCreator")
	gui.Enabled = true
end

function CharacterCreatorController:HideCreator()
	local player = Players.LocalPlayer
	local gui = player.PlayerGui:FindFirstChild("CharacterCreator")
	if gui then
		gui.Enabled = false
	end
end

-- Called by UI when player clicks submit
function CharacterCreatorController:SubmitCharacter(characterData: any)
	self.networker:fire("SubmitCharacter", characterData)
end

-- Server calls these methods via Networker
function CharacterCreatorController:CharacterAccepted()
	print("Character accepted by server!")
	self.OnCharacterAccepted:Fire()
	self:HideCreator()
end

function CharacterCreatorController:CharacterRejected(errorMsg: string)
	print("Character rejected:", errorMsg)
	self.OnCharacterRejected:Fire(errorMsg)
end

return CharacterCreatorController