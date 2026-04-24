--!strict

export type InputState = "Began" | "Ended" | "Changed"

export type InputContext =
	"General"
	| "Movement"
	| "ODM"
	| "Combat"
	| "Weapon"
	| "UI"
	| "Menu"
	| "Admin"

export type InputAction = {
	Context: InputContext,
	Priority: number?,
	CanHold: boolean?,
	Exclusive: boolean?,
	AllowGameProcessed: boolean?,
}

export type ProfileKeybinds = {
	[string]: string | { string },
}

export type ActionCallback = (
	actionName: string,
	inputState: InputState,
	inputObject: InputObject
) -> ()

return {}
