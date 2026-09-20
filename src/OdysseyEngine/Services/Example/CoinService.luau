-- OdysseyEngine.Services.Example.CoinService
--
-- A complete worked example of a gameplay service. It demonstrates every
-- pattern a new system needs:
--   • Dependencies         (PlayerService inits first, passed to :init)
--   • a Networker channel  (client-callable methods + server→client events)
--   • validated client input (never trust arguments from the client)
--   • persistence through PlayerService (profile.Data.Coins)
--
-- The matching client half is client/Services/Example/CoinServiceClient.luau,
-- and the UI is shared/UI/Example/CoinsMenu.luau. Copy this trio to start any
-- new system, then delete the Example folders once you don't need them.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Networker = require(ReplicatedStorage.Packages.Networker)
local Log = require(ReplicatedStorage.Shared.Framework.Log)

local log = Log.scope("CoinService")

-- Server-authoritative rules. The client never decides amounts.
local COLLECT_AMOUNT = 10
local COLLECT_COOLDOWN = 2 -- seconds

local CoinService = {}
CoinService.Dependencies = { "PlayerService" }

function CoinService:init(playerService)
	self.players = playerService
	self._lastCollect = {} :: { [Player]: number }

	-- 3rd arg = the methods the CLIENT may call. Anything not listed here is
	-- server-only API.
	self.networker = Networker.server.new("CoinService", self, {
		self.requestBalance,
		self.collectCoins,
	})

	game:GetService("Players").PlayerRemoving:Connect(function(player)
		self._lastCollect[player] = nil
	end)
end

------------------------------------------------------------
-- Client-callable (args after `player` come from the client — validate!)
------------------------------------------------------------

-- Client: local coins = net:fetch("requestBalance")
function CoinService:requestBalance(player: Player): number
	return self.players:Get(player, "Coins") or 0
end

-- Client: net:fire("collectCoins")
function CoinService:collectCoins(player: Player)
	local now = os.clock()
	local last = self._lastCollect[player]
	if last and now - last < COLLECT_COOLDOWN then
		return -- too fast; silently ignore
	end
	self._lastCollect[player] = now

	self:AwardCoins(player, COLLECT_AMOUNT)
end

------------------------------------------------------------
-- Server API (other services call these via Loader.get("CoinService"))
------------------------------------------------------------

function CoinService:AwardCoins(player: Player, amount: number)
	self.players:Update(player, "Coins", function(coins)
		return coins + amount
	end)
	-- PlayerService:Set already replicated the new value via "dataUpdated";
	-- this event is for one-shot feedback (sound, popup) on the client.
	self.networker:fire(player, "coinsAwarded", amount)
	log:debug("awarded", amount, "coins to", player.Name)
end

function CoinService:SpendCoins(player: Player, amount: number): boolean
	local coins = self.players:Get(player, "Coins") or 0
	if amount <= 0 or coins < amount then
		return false
	end
	self.players:Set(player, "Coins", coins - amount)
	return true
end

return CoinService
