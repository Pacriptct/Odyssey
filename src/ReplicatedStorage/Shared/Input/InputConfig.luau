--!strict

local InputConfig = {}

InputConfig.DefaultEnabledContexts = {
	General = true,
	Movement = true,
	Combat = true,
	ODM = false,
	Weapon = false,
	UI = false,
	Menu = false,
	Admin = false,
}

InputConfig.Actions = {
	Interaction = { Context = "General", Priority = 0, Exclusive = true },
	Sprint = { Context = "Movement", Priority = 100, CanHold = true },
	CrouchSlide = { Context = "Movement", Priority = 100, CanHold = true },
	JumpVault = { Context = "Movement", Priority = 100 },
	ShiftLock = { Context = "Movement", Priority = 100 },

	Carry = { Context = "Combat", Priority = 300 },
	Execute = { Context = "Combat", Priority = 300 },
	ToggleFistCombat = { Context = "Combat", Priority = 300 },

	OrbitRight = { Context = "ODM", Priority = 500, CanHold = true },
	OrbitLeft = { Context = "ODM", Priority = 500, CanHold = true },

	HookLeft = { Context = "ODM", Priority = 500, CanHold = true },
	HookRight = { Context = "ODM", Priority = 500, CanHold = true },
	ReloadBlades = { Context = "ODM", Priority = 500 },
	GearHandles = { Context = "ODM", Priority = 500 },
	GearBoost = { Context = "ODM", Priority = 500, CanHold = true },
	GearBlock = { Context = "ODM", Priority = 500, CanHold = true },
	SwitchODMMode = { Context = "ODM", Priority = 500 },
	CheckGas = { Context = "ODM", Priority = 500 },

	HeavyAttack = { Context = "Weapon", Priority = 400 },
}

return InputConfig
