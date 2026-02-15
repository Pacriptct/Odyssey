--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerPackages = ServerScriptService:WaitForChild("Packages")
local ProfileStore = require(ServerPackages.ProfileStore)

local Template = require(ReplicatedStorage.Shared.DataTemplate)
local Logger = require(ReplicatedStorage.Shared.Logger)

type PlayerData = typeof(Template)

-- ProfileStore types
type Profile = {
	Data: PlayerData,
	OnSessionEnd: any, -- ProfileStore's custom signal type
	AddUserId: (self: Profile, userId: number) -> (),
	EndSession: (self: Profile) -> (),
}

type Store = {
	StartSessionAsync: (self: Store, key: string, cancel: (() -> boolean)?) -> Profile?,
}

local DataService = {}
DataService.__index = DataService

local STORE_NAME = "Odyssey_Dev_v0.0001"

function DataService:Init(container: any)
	self.ReplicationService = container:Get("ReplicationService")
	self._log = Logger.new("DataService")
	self._profiles = {} :: { [Player]: Profile }

	self._store = ProfileStore.New(STORE_NAME, Template) :: Store

	Players.PlayerAdded:Connect(function(player)
		self:_Load(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:_Release(player)
	end)

	self._log:Info("DataService initialized.")
end

function DataService:_Load(player: Player)
	local profile = self._store:StartSessionAsync(
		"Player_" .. player.UserId
	) :: Profile?

	if not profile then
		player:Kick("Data failed to load.")
		return
	end

	profile:AddUserId(player.UserId)

	profile.OnSessionEnd:Connect(function()
		self._profiles[player] = nil
		player:Kick("Data session ended.")
	end)

	self._profiles[player] = profile

	self:_Migrate(profile.Data)

	self._log:Info("Profile loaded for", player.Name)
end

function DataService:_Release(player: Player)
	local profile = self._profiles[player]
	if profile then
		profile:EndSession()
	end
end

-- Schema migration
function DataService:_Migrate(data: PlayerData)
	if not data.SchemaVersion then
		data.SchemaVersion = 1
	end

	if data.SchemaVersion < 2 then
		-- future migration example
		data.SchemaVersion = 2
	end
end

-- Public API

function DataService:Get(player: Player): PlayerData?
	local profile = self._profiles[player]
	return if profile then profile.Data else nil
end

function DataService:Set(player: Player, key: string, value: any)
	local data = self:Get(player)
	if not data then return end

	(data :: any)[key] = value

	if self.ReplicationService then
		self.ReplicationService:SendPatch(player, {
			[key] = value
		})
	end
end

function DataService:Patch(player: Player, patch: { [string]: any })
	local data = self:Get(player)
	if not data then return end

	for k, v in pairs(patch) do
		(data :: any)[k] = v
	end

	if self.ReplicationService then
		self.ReplicationService:SendPatch(player, patch)
	end
end

-- Permadeath wipe logic
function DataService:WipeCharacter(player: Player)
	local profile = self._profiles[player]
	if not profile then return end

	-- Create a new copy of the template
	local newData = table.clone(Template) :: PlayerData
	newData.WipeState = true
	newData.SchemaVersion = Template.SchemaVersion
	
	profile.Data = newData

	self._log:Warn("Character wiped for", player.Name)
end

-- Force wipe for testing
function DataService:ForceWipe(player: Player)
	local data = self:Get(player)
	if not data then return end
	
	-- Reset only the character creation fields
	data.FirstName = ""
	data.LastName = ""
	data.FullName = ""
	data.Gender = ""
	data.Age = 0
	data.Birthplace = ""
	
	self._log:Warn("Character data reset for", player.Name)
end

return DataService