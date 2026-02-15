--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Networker = require(Packages.Networker)

local Logger = require(ReplicatedStorage.Shared.Logger)

local CharacterCreatorService = {}
CharacterCreatorService.__index = CharacterCreatorService

-- Lists of valid options
local VALID_GENDERS = {"Male", "Female"}
local VALID_BIRTHPLACES = {"Shiganshina", "Trost", "Stohess", "Karanes", "Wall Maria", "Wall Rose", "Wall Sina"}
local MIN_AGE = 12
local MAX_AGE = 50

function CharacterCreatorService:Init(container)
	self.DataService = container:Get("DataService")
	self._log = Logger.new("CharacterCreatorService")

	-- Initialize networker
	self.networker = Networker.server.new("CharacterCreatorService", self, {
		self.SubmitCharacter,
	})

	self._log:Info("CharacterCreatorService initialized.")
end

-- Validate character data
function CharacterCreatorService:_Validate(characterData: any): (boolean, string?)
	if type(characterData) ~= "table" then
		return false, "Invalid data format"
	end

	-- Validate FirstName
	if type(characterData.FirstName) ~= "string" or #characterData.FirstName < 2 or #characterData.FirstName > 20 then
		return false, "First name must be 2-20 characters"
	end

	-- Validate LastName
	if type(characterData.LastName) ~= "string" or #characterData.LastName < 2 or #characterData.LastName > 20 then
		return false, "Last name must be 2-20 characters"
	end

	-- Validate Gender
	if not table.find(VALID_GENDERS, characterData.Gender) then
		return false, "Invalid gender"
	end

	-- Validate Age
	if type(characterData.Age) ~= "number" or characterData.Age < MIN_AGE or characterData.Age > MAX_AGE then
		return false, string.format("Age must be between %d and %d", MIN_AGE, MAX_AGE)
	end

	-- Validate Birthplace
	if not table.find(VALID_BIRTHPLACES, characterData.Birthplace) then
		return false, "Invalid birthplace"
	end

	return true
end

-- Client calls this to submit character
function CharacterCreatorService:SubmitCharacter(player: Player, characterData: any)
	local valid, errorMsg = self:_Validate(characterData)
	
	if not valid then
		self._log:Warn("Invalid character data from", player.Name, ":", errorMsg)
		self.networker:fire(player, "CharacterRejected", errorMsg or "Invalid data")
		return
	end

	-- Get player data
	local data = self.DataService:Get(player)
	if not data then
		self._log:Error("No data found for", player.Name)
		return
	end

	-- Check if character already created
	if data.FullName ~= "" then
		self._log:Warn(player.Name, "attempted to recreate character")
		self.networker:fire(player, "CharacterRejected", "Character already exists")
		return
	end

	-- Save character data
	local fullName = characterData.FirstName .. " " .. characterData.LastName
	
	self.DataService:Patch(player, {
		FirstName = characterData.FirstName,
		LastName = characterData.LastName,
		FullName = fullName,
		Gender = characterData.Gender,
		Age = characterData.Age,
		Birthplace = characterData.Birthplace,
	})

	self._log:Info("Character created for", player.Name, ":", fullName)
	self.networker:fire(player, "CharacterAccepted")
end

return CharacterCreatorService