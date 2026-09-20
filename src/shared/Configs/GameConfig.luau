-- ReplicatedStorage.Shared.Configs.GameConfig
--
-- One place for the identity of THIS game. When you start a new game from the
-- template, this file is most of what you change.
--
-- ⚠ DataStoreKey: changing it points the game at a brand-new, empty data set.
-- Bump the suffix on purpose (a deliberate wipe in dev), never by accident in
-- a live game.

return {
	Name = "My Odyssey Game",
	Version = "0.1.0",

	-- ProfileService store name. One per game. Suffix is your wipe lever in dev.
	DataStoreKey = "PlayerData_v001",

	-- Seconds a dead character lies before respawning.
	RespawnDelay = 4,

	-- Default UI theme (see Shared/UI/Primitives/Theme.luau for the full list).
	DefaultTheme = "Dark",

	-- Default UI style ("Default" or "Fantasy" — see Primitives/Style.luau).
	DefaultStyle = "Default",
}
