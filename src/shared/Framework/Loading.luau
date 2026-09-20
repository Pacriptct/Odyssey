-- ReplicatedStorage.Shared.Framework.Loading
--
-- Client-side "is the loading screen finished?" signal, backed by an attribute
-- on the LocalPlayer (set by the ReplicatedFirst loader when it hands off to
-- gameplay). Use it to keep gameplay UI (hotbar, etc.) hidden until the player
-- is actually in the world.
--
--   local Loading = require(ReplicatedStorage.Shared.Framework.Loading)
--   Loading.whenComplete(function() myGui.Enabled = true end)

local Players = game:GetService("Players")

local Loading = {}

Loading.Attribute = "OdysseyLoaded"

local function localPlayer(): Player?
	return Players.LocalPlayer
end

function Loading.isComplete(): boolean
	local p = localPlayer()
	return p ~= nil and p:GetAttribute(Loading.Attribute) == true
end

-- Called by the loader when the screen is dismissed.
function Loading.markComplete()
	local p = localPlayer()
	if p then
		p:SetAttribute(Loading.Attribute, true)
	end
end

-- Run `fn` once loading is complete (immediately if it already is). Returns an
-- unsubscribe function.
function Loading.whenComplete(fn: () -> ()): () -> ()
	local p = localPlayer()
	if not p then
		return function() end
	end
	if p:GetAttribute(Loading.Attribute) == true then
		task.spawn(fn)
		return function() end
	end
	local conn
	conn = p:GetAttributeChangedSignal(Loading.Attribute):Connect(function()
		if p:GetAttribute(Loading.Attribute) == true then
			if conn then
				conn:Disconnect()
				conn = nil
			end
			task.spawn(fn)
		end
	end)
	return function()
		if conn then
			conn:Disconnect()
			conn = nil
		end
	end
end

return Loading
