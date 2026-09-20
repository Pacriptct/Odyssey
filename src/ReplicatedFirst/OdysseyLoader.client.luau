-- ReplicatedFirst/OdysseyLoader.client.luau
--
-- Custom loading screen. Runs before anything else on the client
-- (ReplicatedFirst scripts execute during the join handshake), replaces the
-- default Roblox loader, plays a boot sequence driven by the server's
-- LoadingService, then hands off to gameplay by setting the "OdysseyLoaded"
-- attribute (see Shared/Framework/Loading.luau).
--
-- Deliberately asset-free: styled frames and text only, so it works in a
-- fresh game with zero uploads. Swap in your logo / sounds per game.

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

ReplicatedFirst:RemoveDefaultLoadingScreen()

local TITLE = "O D Y S S E Y"
local TAGLINE = "LOADING"
local VERSION = "v0.1.0"

local DISMISS_DELAY = 0.6
local SERVER_TIMEOUT = 30 -- fall back to default steps if the server never answers
local BOOT_DURATION = 6 -- seconds the fake step sequence spreads across
local CHARACTER_TIMEOUT = 20 -- never trap the player behind the loader

local C_BG = Color3.fromRGB(15, 16, 18)
local C_TEXT = Color3.fromRGB(235, 235, 235)
local C_MUTED = Color3.fromRGB(130, 132, 136)
local C_FAINT = Color3.fromRGB(60, 62, 66)
local C_ACCENT = Color3.fromRGB(235, 235, 235)

local DEFAULT_STEPS = {
	{ pct = 10, text = "Starting up" },
	{ pct = 30, text = "Loading services" },
	{ pct = 55, text = "Loading player data" },
	{ pct = 75, text = "Preparing character" },
	{ pct = 92, text = "Finishing up" },
	{ pct = 100, text = "Ready" },
}

local function make(class, props, parent)
	local obj = Instance.new(class)
	for k, v in props do
		obj[k] = v
	end
	if parent then
		obj.Parent = parent
	end
	return obj
end

local function tween(obj, t, props)
	TweenService:Create(obj, t, props):Play()
end

local ease = TweenInfo.new

------------------------------------------------------------
-- Build UI
------------------------------------------------------------

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = make("ScreenGui", {
	Name = "OdysseyLoader",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 1000,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local bg = make("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = C_BG,
	BorderSizePixel = 0,
}, gui)

local content = make("CanvasGroup", {
	Size = UDim2.fromOffset(520, 220),
	Position = UDim2.new(0.5, 0, 0.5, 10),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	GroupTransparency = 1,
	ZIndex = 10,
}, gui)
make("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	SortOrder = Enum.SortOrder.LayoutOrder,
}, content)

local title = make("TextLabel", {
	Size = UDim2.fromOffset(520, 48),
	BackgroundTransparency = 1,
	Text = TITLE,
	Font = Enum.Font.GothamMedium,
	TextSize = 40,
	TextColor3 = C_TEXT,
	LayoutOrder = 1,
	ZIndex = 10,
}, content)

local titleUnderline = make("Frame", {
	Size = UDim2.fromOffset(200, 1),
	BackgroundColor3 = C_ACCENT,
	BackgroundTransparency = 0.25,
	BorderSizePixel = 0,
	LayoutOrder = 2,
	ZIndex = 10,
}, content)
make("UIGradient", {
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(1, 1),
	}),
}, titleUnderline)

make("Frame", { Size = UDim2.fromOffset(1, 10), BackgroundTransparency = 1, LayoutOrder = 3 }, content)

local tagline = make("TextLabel", {
	Size = UDim2.fromOffset(520, 16),
	BackgroundTransparency = 1,
	Text = TAGLINE,
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextColor3 = C_MUTED,
	LayoutOrder = 4,
	ZIndex = 10,
}, content)

make("Frame", { Size = UDim2.fromOffset(1, 24), BackgroundTransparency = 1, LayoutOrder = 5 }, content)

local statusLabel = make("TextLabel", {
	Size = UDim2.fromOffset(360, 18),
	BackgroundTransparency = 1,
	Text = "Connecting",
	Font = Enum.Font.Gotham,
	TextSize = 13,
	TextColor3 = C_MUTED,
	LayoutOrder = 6,
	ZIndex = 10,
}, content)

make("Frame", { Size = UDim2.fromOffset(1, 14), BackgroundTransparency = 1, LayoutOrder = 7 }, content)

local progressWrap = make("Frame", {
	Size = UDim2.fromOffset(240, 2),
	BackgroundColor3 = C_FAINT,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	LayoutOrder = 8,
	ZIndex = 10,
}, content)

local progressFill = make("Frame", {
	Size = UDim2.fromScale(0, 1),
	BackgroundColor3 = C_ACCENT,
	BorderSizePixel = 0,
	ZIndex = 11,
}, progressWrap)

make("TextLabel", {
	Size = UDim2.fromOffset(400, 16),
	Position = UDim2.new(0.5, -200, 1, -24),
	BackgroundTransparency = 1,
	Text = VERSION,
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextColor3 = C_FAINT,
	ZIndex = 15,
}, gui)

-- Fade the content column in.
task.delay(0.05, function()
	tween(content, ease(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		GroupTransparency = 0,
		Position = UDim2.fromScale(0.5, 0.5),
	})
end)

------------------------------------------------------------
-- Wait for the game, then wire Networker
------------------------------------------------------------

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages", 30)
local Networker = require(Packages:WaitForChild("Networker", 30))

------------------------------------------------------------
-- Step animation + dismiss
------------------------------------------------------------

local function animateSteps(steps, onDone)
	local sliceTime = BOOT_DURATION / #steps
	local idx = 1

	local function runNext()
		if idx > #steps then
			onDone()
			return
		end
		local step = steps[idx]
		idx += 1

		statusLabel.Text = step.text
		tween(
			progressFill,
			ease(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Size = UDim2.fromScale(step.pct / 100, 1) }
		)

		if step.pct < 100 then
			task.delay(sliceTime, runNext)
		else
			task.delay(DISMISS_DELAY, onDone)
		end
	end
	runNext()
end

-- Hold the screen until the player's character has actually streamed in (with
-- a safety timeout so a failed spawn can never trap the player forever).
local function waitForCharacter()
	local deadline = os.clock() + CHARACTER_TIMEOUT
	while os.clock() < deadline do
		local char = Players.LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			return
		end
		task.wait(0.1)
	end
end

local dismissed = false
local function dismiss()
	if dismissed then
		return
	end
	dismissed = true

	waitForCharacter()

	tween(content, ease(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { GroupTransparency = 1 })
	tween(bg, ease(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { BackgroundTransparency = 1 })
	task.wait(1.1)

	if gui and gui.Parent then
		gui:Destroy()
	end

	-- Hand off to gameplay: anything gated on Loading.whenComplete (HUDs,
	-- always-on UI) appears now that the player is in the world.
	Players.LocalPlayer:SetAttribute("OdysseyLoaded", true)
end

------------------------------------------------------------
-- Listen for the server's go signal
------------------------------------------------------------

local received = false

local loaderHandler = {}
function loaderHandler:beginSequence(steps)
	if received then
		return
	end
	received = true
	animateSteps(steps or DEFAULT_STEPS, dismiss)
end

local _net = Networker.client.new("LoadingService", loaderHandler)

task.delay(SERVER_TIMEOUT, function()
	if not received then
		warn("[OdysseyLoader] Server timed out — running defaults")
		received = true
		animateSteps(DEFAULT_STEPS, dismiss)
	end
end)
