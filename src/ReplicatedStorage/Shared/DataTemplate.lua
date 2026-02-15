--!strict

local Template = {
	-- Wipe / migration flags
	WipeState = true,
	SchemaVersion = 1,

	-- Core Identity
	FirstName = "",
	LastName = "",
	FullName = "",
	HiddenName = false,

	Birthplace = "",
	Age = 0,
	Gender = "",

	Branch = "Civ",

	-- Traits
	Traits = {} :: { string },
	TraitSlotsUnlocked = 1,

	-- Inventory
	Items = {} :: { any },

	-- Character Customization
	Appearance = {
		Hairs = {} :: { any },
		Eyes = "",
		EyeColor = {} :: { number },
		Nose = "",
		Mouth = "",
		Eyebrows = "",
		Skintone = {} :: { number },
		HairColor = {} :: { number },
	},

	-- Stats / Lore
	Stats = {
		Gold = 0,
		HumanKills = 0,
		TitanKills = 0,
		AbnormalTitanKills = 0,
		TitanBlinds = 0,
		LimbStats = 0,
		PDsAttended = 0,
	},

	-- Gear / Clothing toggles
	Gear = {
		StrapsEquipped = false,
		GearStyle = "",
		GearCloakOn = false,
		EquippedShirt = "",
		EquippedPants = "",
	},

	-- Controls
	Keybinds = {
		Interaction = "C",
		Sprint = "LeftShift",
		ShiftLock = "LeftAlt",
		Carry = "B",

		UpStrafe = "W",
		DownStrafe = "S",
		OrbitRight = "D",
		OrbitLeft = "A",
		HookLeft = "Q",
		HookRight = "E",
		ReloadBlades = "R",
		SuperDash = "V",
		GearHandles = "H",
		GearBoost = "Space",
		GearBlock = "F",
		SwitchODMMode = "LeftControl",
	},
}

return Template
