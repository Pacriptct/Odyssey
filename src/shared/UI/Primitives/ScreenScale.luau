--!strict
-- src/shared/UI/Primitives/ScreenScale.luau
--
-- Uniform UI scaling across screen sizes. Every mounted ScreenGui gets a
-- UIScale driven by the camera viewport, so pixel-sized UI (Theme.TextSize,
-- Theme.Space, fromOffset layouts) keeps the same on-screen proportions on
-- every display. Scale is exactly 1 on a 1920x1080 viewport, so the authored
-- look is unchanged there; larger/smaller screens scale up/down uniformly.
--
-- Usage (at every mount site, right after creating the ScreenGui):
--   local ScreenScale = require(ReplicatedStorage.Shared.UI.Primitives.ScreenScale)
--   ScreenScale.attach(screenGui)
--
-- Relative-position math (sliders, point-in-rect hit tests) is unaffected:
-- AbsolutePosition/AbsoluteSize are post-scale values in the same space as
-- input positions.

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local BASE_WIDTH = 1920
local BASE_HEIGHT = 1080
-- Clamp so tiny phone viewports stay readable and huge displays don't blow up.
local MIN_SCALE = 0.65
local MAX_SCALE = 2

local ScreenScale = {}

-- Weak keys: a destroyed UIScale drops out on its own even if Destroying
-- never fired (e.g. gui was never parented).
local attached: { [UIScale]: boolean } = setmetatable({}, { __mode = "k" }) :: any

local currentScale = 1
local viewportConn: RBXScriptConnection? = nil

local function computeScale(): number
	local camera = Workspace.CurrentCamera
	if not camera then
		return 1
	end
	local viewport = camera.ViewportSize
	if viewport.X <= 1 or viewport.Y <= 1 then
		return 1
	end
	return math.clamp(math.min(viewport.X / BASE_WIDTH, viewport.Y / BASE_HEIGHT), MIN_SCALE, MAX_SCALE)
end

local function applyAll()
	currentScale = computeScale()
	for scale in attached do
		scale.Scale = currentScale
	end
end

local function watchCamera()
	if viewportConn then
		viewportConn:Disconnect()
		viewportConn = nil
	end
	local camera = Workspace.CurrentCamera
	if camera then
		viewportConn = camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyAll)
	end
	applyAll()
end

if RunService:IsClient() then
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)
	watchCamera()
end

-- Adds a viewport-driven UIScale under `gui` and keeps it in sync while the
-- gui exists. Returns the UIScale so callers can compose with it if needed.
function ScreenScale.attach(gui: Instance): UIScale
	local scale = Instance.new("UIScale")
	scale.Name = "ScreenScale"
	scale.Scale = currentScale
	scale.Parent = gui
	attached[scale] = true
	gui.Destroying:Connect(function()
		attached[scale] = nil
	end)
	return scale
end

-- Current global UI scale factor (1 at 1080p). For imperative code that
-- needs to convert between design pixels and on-screen pixels.
function ScreenScale.get(): number
	return currentScale
end

return ScreenScale
