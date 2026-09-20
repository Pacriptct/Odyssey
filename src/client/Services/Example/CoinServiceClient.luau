-- Client.Services.Example.CoinServiceClient
--
-- Client half of the CoinService example. Owns the open/closed state of the
-- coins menu, forwards user intent to the server, and receives one-shot
-- feedback events. The React menu (shared/UI/Example/CoinsMenu.luau)
-- subscribes to this controller — controllers hold state, components render it.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Networker = require(ReplicatedStorage.Packages.Networker)
local Loading = require(ReplicatedStorage.Shared.Framework.Loading)

local TOGGLE_KEY = Enum.KeyCode.M

local CoinServiceClient = {}

local net = Networker.client.new("CoinService", CoinServiceClient)

local open = false
local toggleCallbacks: { (open: boolean) -> () } = {}
local awardCallbacks: { (amount: number) -> () } = {}

local function setOpen(value: boolean)
	if open == value then
		return
	end
	open = value
	for _, cb in toggleCallbacks do
		task.spawn(cb, open)
	end
end

function CoinServiceClient:init()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.KeyCode == TOGGLE_KEY and Loading.isComplete() then
			setOpen(not open)
		end
	end)
end

------------------------------------------------------------
-- Menu state (the React component subscribes to these)
------------------------------------------------------------

function CoinServiceClient:IsOpen(): boolean
	return open
end

function CoinServiceClient:Open()
	setOpen(true)
end

function CoinServiceClient:Close()
	setOpen(false)
end

function CoinServiceClient:onToggle(cb: (open: boolean) -> ()): () -> ()
	table.insert(toggleCallbacks, cb)
	return function()
		local i = table.find(toggleCallbacks, cb)
		if i then
			table.remove(toggleCallbacks, i)
		end
	end
end

function CoinServiceClient:onAwarded(cb: (amount: number) -> ()): () -> ()
	table.insert(awardCallbacks, cb)
	return function()
		local i = table.find(awardCallbacks, cb)
		if i then
			table.remove(awardCallbacks, i)
		end
	end
end

------------------------------------------------------------
-- Server calls
------------------------------------------------------------

function CoinServiceClient:collect()
	net:fire("collectCoins")
end

function CoinServiceClient:fetchBalance(): number
	return net:fetch("requestBalance") or 0
end

------------------------------------------------------------
-- Server → client handlers
------------------------------------------------------------

function CoinServiceClient:coinsAwarded(amount: number)
	for _, cb in awardCallbacks do
		task.spawn(cb, amount)
	end
end

return CoinServiceClient
