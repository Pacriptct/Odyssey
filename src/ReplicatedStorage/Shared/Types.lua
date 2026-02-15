--!strict

export type Keybinds = {
	Interaction: string,
	Sprint: string,
	ShiftLock: string,
	Carry: string,

	UpStrafe: string,
	DownStrafe: string,
	OrbitRight: string,
	OrbitLeft: string,
	HookLeft: string,
	HookRight: string,
	ReloadBlades: string,
	SuperDash: string,
	GearHandles: string,
	GearBoost: string,
	GearBlock: string,
	SwitchODMMode: string,
}

export type Appearance = {
	Hairs: { any },
	Eyes: string,
	EyeColor: { number },
	Nose: string,
	Mouth: string,
	Eyebrows: string,
	Skintone: { number },
	HairColor: { number },
}

export type Stats = {
	Gold: number,
	HumanKills: number,
	TitanKills: number,
	AbnormalTitanKills: number,
	TitanBlinds: number,
	LimbStats: number,
	PDsAttended: number,
}

export type Gear = {
	StrapsEquipped: boolean,
	GearStyle: string,
	GearCloakOn: boolean,
	EquippedShirt: string,
	EquippedPants: string,
}

export type PlayerData = {
	WipeState: boolean,
	SchemaVersion: number,

	FirstName: string,
	LastName: string,
	FullName: string,
	HiddenName: boolean,

	Birthplace: string,
	Age: number,
	Gender: string,

	Branch: string,

	Traits: { string },
	TraitSlotsUnlocked: number,

	Items: { any },

	Appearance: Appearance,
	Stats: Stats,
	Gear: Gear,

	Keybinds: Keybinds,
}
