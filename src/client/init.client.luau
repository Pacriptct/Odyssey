-- StarterPlayerScripts.Client (client entry point)
--
-- Client controllers are auto-discovered and booted by the Loader — no manual
-- init list. Add a controller by dropping a module in `Services/<Domain>/`
-- that returns a table with an optional `:init()` / `:start()` (and
-- `Dependencies`). Set `AutoLoad = false` on a module that only needs to be
-- required. See src/shared/Framework/Loader.luau and GUIDE.md.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.Configs.GameConfig)
local Log = require(ReplicatedStorage.Shared.Framework.Log)

Log.bindAttributes(ReplicatedStorage)

local Style = require(ReplicatedStorage.Shared.UI.Primitives.Style)
Style.setStyle(GameConfig.DefaultStyle)

local Sounds = require(ReplicatedStorage.Shared.UI.Primitives.Sounds)
Sounds.init()

local Loader = require(ReplicatedStorage.Shared.Framework.Loader)

-- Discover + init + start every client controller in Services.
Loader.boot(script.Services, ("%s — Client"):format(GameConfig.Name))
