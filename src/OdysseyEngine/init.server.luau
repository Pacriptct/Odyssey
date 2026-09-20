-- ServerScriptService.OdysseyEngine (server entry point)
--
-- Services are auto-discovered and booted by the Loader — there is no manual
-- init list. To add a system, drop a module in `Services/<Domain>/` that
-- returns a table with an optional `:init()` / `:start()` and an optional
-- `Dependencies` list. See src/shared/Framework/Loader.luau and GUIDE.md.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Shared.Framework.Loader)
local Log = require(ReplicatedStorage.Shared.Framework.Log)

-- Tune log output live (no code change) via attributes on ReplicatedStorage:
--   LogLevel = "warn"                -> quiet the console globally
--   LogLevel_CoinService = "debug"   -> crank one system up
Log.bindAttributes(ReplicatedStorage)

-- Hold character spawns until player data has loaded (PlayerService spawns
-- the character itself once the profile is in).
Players.CharacterAutoLoads = false

-- Discover + init + start every service under Services (recursing into the
-- domain subfolders), dependency-ordered.
Loader.boot(script.Services, "OdysseyEngine — Server")
