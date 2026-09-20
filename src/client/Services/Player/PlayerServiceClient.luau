-- Client.Services.Player.PlayerServiceClient
--
-- The client-side mirror of the player's saved data. PlayerService fires
-- "dataLoaded" once (the full snapshot) and "dataUpdated" per key after that;
-- this controller caches it and lets UI subscribe to changes.
--
--   local psc = Loader.get("PlayerServiceClient")
--   psc:get("Coins")                     -- read a cached value (nil until loaded)
--   psc:onChange(function() ... end)     -- any key changed
--   psc:onKeyChanged("Coins", fn)        -- one key changed -> fn(newValue)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Networker = require(ReplicatedStorage.Packages.Networker)
local Theme = require(ReplicatedStorage.Shared.UI.Primitives.Theme)

local PlayerServiceClient = {}

-- Constructed at module scope: requiring this module is enough to register
-- the channel, so "dataLoaded" can never race the Loader's init pass.
local net = Networker.client.new("PlayerService", PlayerServiceClient)
PlayerServiceClient._networker = net

-- Trim the default Roblox chrome; re-enable whatever your game wants.
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

PlayerServiceClient.data = nil :: { [string]: any }?

local changeCallbacks: { () -> () } = {}
local keyCallbacks: { [string]: { (value: any) -> () } } = {}

local function fireChange(key: string?, value: any)
	for _, cb in changeCallbacks do
		task.spawn(cb)
	end
	if key and keyCallbacks[key] then
		for _, cb in keyCallbacks[key] do
			task.spawn(cb, value)
		end
	end
end

------------------------------------------------------------
-- Reads & subscriptions
------------------------------------------------------------

function PlayerServiceClient:isLoaded(): boolean
	return self.data ~= nil
end

function PlayerServiceClient:get(key: string): any
	return self.data and self.data[key]
end

function PlayerServiceClient:onChange(cb: () -> ()): () -> ()
	table.insert(changeCallbacks, cb)
	return function()
		local i = table.find(changeCallbacks, cb)
		if i then
			table.remove(changeCallbacks, i)
		end
	end
end

function PlayerServiceClient:onKeyChanged(key: string, cb: (value: any) -> ()): () -> ()
	keyCallbacks[key] = keyCallbacks[key] or {}
	table.insert(keyCallbacks[key], cb)
	return function()
		local list = keyCallbacks[key]
		local i = list and table.find(list, cb)
		if i then
			table.remove(list, i)
		end
	end
end

------------------------------------------------------------
-- Writes (server validates; these are requests, not truth)
------------------------------------------------------------

function PlayerServiceClient:updateSetting(key: string, value: any)
	net:fire("updateSetting", key, value)
end

function PlayerServiceClient:setTheme(themeName: string)
	Theme.setTheme(themeName) -- apply immediately for responsiveness
	net:fire("setPlayerTheme", themeName) -- persist
end

------------------------------------------------------------
-- Server → client handlers
------------------------------------------------------------

function PlayerServiceClient:dataLoaded(data)
	if self.data ~= nil then
		return
	end
	self.data = data
	Theme.setTheme(data.Theme or "Dark")
	fireChange()
end

function PlayerServiceClient:dataUpdated(key, value)
	if not self.data then
		return
	end
	self.data[key] = value
	fireChange(key, value)
end

return PlayerServiceClient
