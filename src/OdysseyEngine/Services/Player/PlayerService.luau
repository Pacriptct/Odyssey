-- OdysseyEngine.Services.Player.PlayerService
--
-- Owns player persistence. One ProfileService profile per player, loaded on
-- join (session-locked, so two servers can never write the same player's data
-- at once), released on leave.
--
-- Everything a player keeps between sessions lives in `profile.Data`, shaped
-- by PROFILE_TEMPLATE below. Adding a field to the template is safe for
-- existing players: `profile:Reconcile()` fills in missing keys on load.
-- Removing/renaming a field needs a migration (see :_migrateProfileData).
--
-- Other services read/write through this service:
--   local players = Loader.get("PlayerService")
--   players:Get(player, "Coins")
--   players:Set(player, "Coins", 100)          -- also replicates to the client
--   players:Update(player, "Coins", function(c) return c + 10 end)
--
-- Mutating a nested table inside profile.Data (e.g. Data.Inventory.Items)
-- persists automatically — ProfileService saves the whole Data table — but
-- call :Push(player, key) afterwards if the client should see the change.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileService = require(ServerScriptService.ServerPackages.ProfileService)
local Networker = require(ReplicatedStorage.Packages.Networker)
local GameConfig = require(ReplicatedStorage.Shared.Configs.GameConfig)
local Loader = require(ReplicatedStorage.Shared.Framework.Loader)
local Log = require(ReplicatedStorage.Shared.Framework.Log)

local log = Log.scope("PlayerService")

-- The saved shape of a player. Every field a new player starts with.
local PROFILE_TEMPLATE = {
	Coins = 0,
	Level = 1,
	XP = 0,

	Settings = {
		MusicVolume = 0.5,
		SfxVolume = 0.8,
	},

	Theme = GameConfig.DefaultTheme,
}

local ProfileStore = ProfileService.GetProfileStore(GameConfig.DataStoreKey, PROFILE_TEMPLATE)

local PlayerService = {}
-- LoadingService must have built its networker before we can notifyReady a
-- player who was already in the server when we init.
PlayerService.Dependencies = { "LoadingService" }
PlayerService.Profiles = {} :: { [Player]: any }
PlayerService.Template = PROFILE_TEMPLATE

function PlayerService:init()
	self.networker = Networker.server.new("PlayerService", self, {
		self.updateSetting,
		self.setPlayerTheme,
	})

	Players.PlayerAdded:Connect(function(player)
		self:onPlayerAdded(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self:onPlayerRemoving(player)
	end)

	-- Players can join before this service inits (the Loader's require phase
	-- yields) — always sweep the ones already present.
	for _, player in Players:GetPlayers() do
		task.spawn(function()
			self:onPlayerAdded(player)
		end)
	end
end

------------------------------------------------------------
-- Join / leave
------------------------------------------------------------

function PlayerService:onPlayerAdded(player: Player)
	if self.Profiles[player] then
		return
	end

	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
	if not profile then
		player:Kick("Could not load your data, please rejoin.")
		return
	end

	profile:AddUserId(player.UserId) -- GDPR: ties the key to the user
	profile:Reconcile() -- fill in fields added to the template since last save

	profile:ListenToRelease(function()
		self.Profiles[player] = nil
		player:Kick("Your data was loaded on another server.")
	end)

	if not player:IsDescendantOf(Players) then
		-- Left while the profile was loading.
		profile:Release()
		return
	end

	self.Profiles[player] = profile
	self:_migrateProfileData(player, profile.Data)

	log:info("profile loaded for", player.Name)

	-- Replicate the full snapshot, then spawn the character and let the
	-- loading screen finish.
	self.networker:fire(player, "dataLoaded", profile.Data)
	player:LoadCharacterAsync()
	Loader.get("LoadingService"):notifyReady(player)
end

function PlayerService:onPlayerRemoving(player: Player)
	local profile = self.Profiles[player]
	if profile then
		profile:Release() -- final save + frees the session lock
	end
end

-- One-off fixups for data saved under an older template shape. Reconcile
-- handles *added* fields; renames/removals go here.
function PlayerService:_migrateProfileData(_player: Player, data: { [string]: any })
	if type(data.Settings) ~= "table" then
		data.Settings = table.clone(PROFILE_TEMPLATE.Settings)
	end
end

------------------------------------------------------------
-- Data access (other services call these)
------------------------------------------------------------

function PlayerService:getProfile(player: Player)
	local profile = self.Profiles[player]
	if not profile then
		log:warn("no profile for", player.Name)
	end
	return profile
end

-- Get(player)        -> whole Data table
-- Get(player, "Key") -> Data.Key
function PlayerService:Get(player: Player, key: string?)
	local profile = self:getProfile(player)
	if not profile then
		return nil
	end
	if key then
		return profile.Data[key]
	end
	return profile.Data
end

-- Write + replicate one top-level key to the owning client.
function PlayerService:Set(player: Player, key: string, value: any)
	local profile = self:getProfile(player)
	if not profile then
		return false
	end
	profile.Data[key] = value
	self.networker:fire(player, "dataUpdated", key, value)
	return true
end

-- Read-modify-write helper: Update(player, "Coins", function(c) return c + 5 end)
function PlayerService:Update(player: Player, key: string, callback: (any) -> any)
	local old = self:Get(player, key)
	if old == nil then
		return
	end
	return self:Set(player, key, callback(old))
end

-- After mutating a nested table in-place, push the new value to the client.
function PlayerService:Push(player: Player, key: string)
	local profile = self:getProfile(player)
	if not profile then
		return
	end
	self.networker:fire(player, "dataUpdated", key, profile.Data[key])
end

------------------------------------------------------------
-- Client-exposed methods (validate EVERYTHING — args come from the client)
------------------------------------------------------------

local ALLOWED_SETTINGS: { [string]: (value: any) -> boolean } = {
	MusicVolume = function(v)
		return type(v) == "number" and v >= 0 and v <= 1
	end,
	SfxVolume = function(v)
		return type(v) == "number" and v >= 0 and v <= 1
	end,
}

function PlayerService:updateSetting(player: Player, key: string, value: any)
	local validator = type(key) == "string" and ALLOWED_SETTINGS[key]
	if not validator or not validator(value) then
		return false
	end
	local settings = self:Get(player, "Settings")
	if type(settings) ~= "table" then
		return false
	end
	settings[key] = value
	self:Push(player, "Settings")
	return true
end

function PlayerService:setPlayerTheme(player: Player, themeName: string)
	if type(themeName) ~= "string" or #themeName > 32 then
		return false
	end
	return self:Set(player, "Theme", themeName)
end

return PlayerService
