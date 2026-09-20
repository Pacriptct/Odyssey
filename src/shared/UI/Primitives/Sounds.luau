-- Sounds.luau
-- Central UI sound effects. Sounds are created once and reused. Call
-- Sounds.init() at client startup; Sounds.play(kind) anywhere afterwards.

local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")

local SOUND_IDS = {
	select = "rbxassetid://113173894169273",
	switch = "rbxassetid://140304802208221",
	confirm = "rbxassetid://132063377749690",
	type = "rbxassetid://113967755234595",
	levelup = "rbxassetid://108161825312558",
	hover = "rbxassetid://138744734909383",
}

local SOUND_VOLUMES = {
	select = 0.5,
	switch = 0.6,
	confirm = 0.7,
	type = 0.35,
	levelup = 0.7,
	hover = 0.35,
}

local sounds: { [string]: Sound } = {}
local initialized = false

local Sounds = {}

function Sounds.init()
	if initialized then
		return
	end
	initialized = true

	local container = Instance.new("Folder")
	container.Name = "OdysseyUISounds"
	container.Parent = SoundService

	local toPreload = {}
	for kind, id in SOUND_IDS do
		local s = Instance.new("Sound")
		s.Name = kind
		s.SoundId = id
		s.Volume = SOUND_VOLUMES[kind] or 0.5
		s.Parent = container
		sounds[kind] = s
		table.insert(toPreload, s)
	end

	task.spawn(function()
		pcall(function()
			ContentProvider:PreloadAsync(toPreload)
		end)
	end)
end

function Sounds.play(kind: string)
	local s = sounds[kind]
	if not s then
		return
	end
	-- Clone so overlapping plays don't cut each other off
	local clone = s:Clone()
	clone.Parent = s.Parent
	clone:Play()
	task.delay(5, function()
		clone:Destroy()
	end)
end

return Sounds
