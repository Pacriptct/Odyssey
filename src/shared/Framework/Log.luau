--!strict
-- ReplicatedStorage.Shared.Framework.Log
--
-- Lightweight, dynamically-controllable logging. Replaces raw print()/warn()
-- so output can be filtered per-tag and per-level at runtime — handy when one
-- system floods the console.
--
-- Usage:
--   local Log = require(ReplicatedStorage.Shared.Framework.Log)
--   local log = Log.scope("TailorService")
--   log:info("opened for", player)        -- printed only if level <= info
--   log:warn("missing Type attribute")    -- always-ish (warn channel)
--   log:debug("state", state)             -- hidden unless you lower the level
--
-- Control it live (Studio command bar, an admin command, or code):
--   Log.setGlobalLevel("warn")            -- mute info/debug everywhere
--   Log.setLevel("ShifterService", "off") -- silence one noisy system
--   Log.setLevel("TailorService", "debug")-- crank one system up
--
-- Or by attribute (no code) on a bound instance — see Log.bindAttributes:
--   LogLevel               = "warn"       -- global
--   LogLevel_TailorService = "debug"      -- per-tag

local Log = {}

export type Level = "trace" | "debug" | "info" | "warn" | "error" | "off"

local LEVELS: { [string]: number } = {
	trace = 10,
	debug = 20,
	info = 30,
	warn = 40,
	error = 50,
	off = 100,
}
Log.Levels = LEVELS

local globalLevel = LEVELS.info
local tagLevels: { [string]: number } = {}

local function levelValue(level: any): number
	if type(level) == "number" then
		return level
	end
	return LEVELS[string.lower(tostring(level))] or LEVELS.info
end

------------------------------------------------------------
-- Dynamic control
------------------------------------------------------------

function Log.setGlobalLevel(level: Level | number)
	globalLevel = levelValue(level)
end

function Log.setLevel(tag: string, level: (Level | number)?)
	tagLevels[tag] = level ~= nil and levelValue(level) or nil
end

function Log.getLevel(tag: string): number
	return tagLevels[tag] or globalLevel
end

local function enabled(tag: string, lvl: number): boolean
	return lvl >= Log.getLevel(tag)
end

------------------------------------------------------------
-- Emit
------------------------------------------------------------

local function emit(tag: string, lvlName: string, ...)
	local lvl = LEVELS[lvlName] or LEVELS.info
	if not enabled(tag, lvl) then
		return
	end
	if lvlName == "warn" then
		warn(("⚠ [%s]"):format(tag), ...)
	elseif lvlName == "error" then
		warn(("✖ [%s] ERROR:"):format(tag), ...)
	else
		print(("[%s]"):format(tag), ...)
	end
end

export type Logger = {
	trace: (self: Logger, ...any) -> (),
	debug: (self: Logger, ...any) -> (),
	info: (self: Logger, ...any) -> (),
	warn: (self: Logger, ...any) -> (),
	error: (self: Logger, ...any) -> (),
	setLevel: (self: Logger, level: (Level | number)?) -> (),
	tag: string,
}

-- A namespaced logger. Reuse one per system (usually `Log.scope("MyService")`).
function Log.scope(tag: string): Logger
	return {
		tag = tag,
		trace = function(_, ...)
			emit(tag, "trace", ...)
		end,
		debug = function(_, ...)
			emit(tag, "debug", ...)
		end,
		info = function(_, ...)
			emit(tag, "info", ...)
		end,
		warn = function(_, ...)
			emit(tag, "warn", ...)
		end,
		error = function(_, ...)
			emit(tag, "error", ...)
		end,
		setLevel = function(_, level)
			Log.setLevel(tag, level)
		end,
	} :: any
end

------------------------------------------------------------
-- Pretty banner (used for boot summaries; matches the old
-- "[OdysseyEngine] Server initialized." but nicer)
------------------------------------------------------------

function Log.banner(title: string, lines: { string }?)
	local width = #title
	if lines then
		for _, l in lines do
			width = math.max(width, #l)
		end
	end
	width = math.max(width, 28) + 2

	local function row(text: string)
		local pad = width - #text
		return "║ " .. text .. string.rep(" ", pad - 1) .. "║"
	end

	local top = "╔" .. string.rep("═", width) .. "╗"
	local bottom = "╚" .. string.rep("═", width) .. "╝"

	print(top)
	print(row(title))
	if lines then
		for _, l in lines do
			print(row(l))
		end
	end
	print(bottom)
end

------------------------------------------------------------
-- Attribute binding: change levels live without touching code.
-- Set `LogLevel` (global) and `LogLevel_<Tag>` attributes on `inst`.
------------------------------------------------------------

function Log.bindAttributes(inst: Instance)
	local function apply()
		local g = inst:GetAttribute("LogLevel")
		if g ~= nil then
			Log.setGlobalLevel(g)
		end
		for name, value in inst:GetAttributes() do
			local tag = string.match(name, "^LogLevel_(.+)$")
			if tag then
				Log.setLevel(tag, value)
			end
		end
	end
	apply()
	inst.AttributeChanged:Connect(apply)
end

------------------------------------------------------------
-- Optional defaults from a config module (Shared.Framework.LogConfig)
------------------------------------------------------------

do
	local cfgModule = script.Parent:FindFirstChild("LogConfig")
	if cfgModule and cfgModule:IsA("ModuleScript") then
		local ok, cfg = pcall(require, cfgModule)
		if ok and type(cfg) == "table" then
			if cfg.Global then
				Log.setGlobalLevel(cfg.Global)
			end
			if type(cfg.Tags) == "table" then
				for tag, level in cfg.Tags do
					Log.setLevel(tag, level)
				end
			end
		end
	end
end

return Log
