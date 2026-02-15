--!strict

local Logger = {}
Logger.__index = Logger

export type Logger = typeof(setmetatable({}, Logger))

local DEBUG_MODE = true

function Logger.new(scope: string): Logger
	return setmetatable({
		_scope = scope,
	}, Logger)
end

function Logger:_format(level: string, ...)
	local prefix = string.format("[%s][%s]", level, self._scope)
	return prefix, ...
end

function Logger:Info(...)
	if not DEBUG_MODE then return end
	print(self:_format("INFO", ...))
end

function Logger:Warn(...)
	warn(self:_format("WARN", ...))
end

function Logger:Error(...)
	warn(self:_format("ERROR", ...))
end

return Logger
