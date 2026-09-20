-- ReplicatedStorage.Shared.Framework.LogConfig
--
-- Default log levels, applied when Log first loads. Override live at runtime
-- with Log.setGlobalLevel / Log.setLevel, or via LogLevel* attributes (see
-- Log.bindAttributes). Levels: trace < debug < info < warn < error < off.
--
-- Tip: when the console is flooded, set Global = "warn" here (or live), then
-- bump a single system back up with Tags = { ThatSystem = "debug" }.

return {
	-- Everything at or above this prints unless a per-tag override says otherwise.
	Global = "info",

	-- Per-system overrides. Keys are the scope tags passed to Log.scope(...)
	-- (usually the service name). Example: silence a noisy system entirely.
	Tags = {
		-- ShifterService = "warn",
		-- TitanService = "warn",
	},
}
