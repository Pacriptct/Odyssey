-- ReplicatedStorage.Shared.Framework.Loader
--
-- A tiny service framework. Point it at a folder of module "services" and it:
--   1. requires them all and registers each by name (so they can find each
--      other via Loader.get — this is how we avoid cyclic require() chains),
--   2. runs :init() on each (dependency-ordered), then :start() on each.
--
-- You never hand-edit a boot list again: drop a new service module into the
-- folder and it loads automatically.
--
-- ── Service contract (everything optional) ────────────────────────────────
--   return a table.
--   Service.Name          : string?            -- defaults to the module name
--   Service.AutoLoad      : boolean?           -- set false to register but NOT
--                                                 auto-init (e.g. parent-managed
--                                                 sub-services / helper modules)
--   Service.Dependencies  : { string }?        -- other service names this one
--                                                 needs initialised first; they
--                                                 are ALSO passed to :init() as
--                                                 args, in order.
--   function Service:init(...) end             -- set up state / networker.
--                                                 Args = resolved Dependencies.
--   function Service:start() end               -- runs after ALL inits; safe to
--                                                 call across services here.
--
-- ── Finding other services (no cyclic requires) ───────────────────────────
--   local Loader = require(ReplicatedStorage.Shared.Framework.Loader)
--   local Players = Loader.get("PlayerService")
-- Because every service table is registered before any :init() runs, you can
-- grab references freely; just don't *call* a dependency before it's started
-- (declare it in Dependencies, or call it from :start()/at runtime).

local Log = require(script.Parent.Log)
local log = Log.scope("Loader")

local Loader = {}

local registry: { [string]: any } = {}
local order: { string } = {}
local booted = false

function Loader.get(name: string): any
	return registry[name]
end

function Loader.all(): { [string]: any }
	return registry
end

-- Registers every ModuleScript under `folder`, recursing into subfolders so
-- services can be organized by domain. Folders named in `exclude` are skipped
-- entirely (helper-module folders like InteractionHandlers). Children OF a
-- ModuleScript are considered private and never registered.
local function register(folder: Instance, exclude: { [string]: boolean })
	for _, child in folder:GetChildren() do
		if child:IsA("ModuleScript") then
			local ok, svc = pcall(require, child)
			if not ok then
				log:error("failed to require", child.Name, "—", svc)
			elseif type(svc) == "table" then
				local name = svc.Name or child.Name
				svc.Name = name
				if registry[name] then
					log:warn("duplicate service name:", name)
				end
				registry[name] = svc
			end
		elseif child:IsA("Folder") and not exclude[child.Name] then
			register(child, exclude)
		end
	end
end

-- Dependency-ordered list (topological). Cycles are reported and broken so boot
-- still proceeds.
local function resolveOrder()
	local visited: { [string]: boolean } = {}
	local onStack: { [string]: boolean } = {}

	local function visit(name: string)
		local svc = registry[name]
		if not svc or visited[name] then
			return
		end
		if onStack[name] then
			log:warn("cyclic dependency involving", name, "— breaking it")
			return
		end
		onStack[name] = true
		if type(svc.Dependencies) == "table" then
			for _, dep in svc.Dependencies do
				if not registry[dep] then
					log:warn(name, "depends on unknown service", dep)
				else
					visit(dep)
				end
			end
		end
		onStack[name] = false
		visited[name] = true
		table.insert(order, name)
	end

	for name in registry do
		visit(name)
	end
end

local function resolveArgs(svc): { any }
	local args = {}
	if type(svc.Dependencies) == "table" then
		for i, dep in ipairs(svc.Dependencies) do
			args[i] = registry[dep]
		end
	end
	return args
end

-- Boot everything in `folder` (recursing into subfolders). `title` is shown in
-- the completion banner; `excludeFolders` names subfolders to skip.
function Loader.boot(folder: Instance, title: string?, excludeFolders: { string }?)
	if booted then
		log:warn("Loader.boot called twice; ignoring")
		return
	end
	booted = true

	local exclude: { [string]: boolean } = {}
	for _, name in excludeFolders or {} do
		exclude[name] = true
	end

	register(folder, exclude)
	resolveOrder()

	local initCount = 0
	for _, name in order do
		local svc = registry[name]
		if svc.AutoLoad ~= false and type(svc.init) == "function" then
			local args = resolveArgs(svc)
			local ok, err = pcall(function()
				svc:init(table.unpack(args))
			end)
			if ok then
				initCount += 1
				log:debug("init", name)
			else
				log:error("init failed for", name, "—", err)
			end
		end
	end

	local startCount = 0
	for _, name in order do
		local svc = registry[name]
		if svc.AutoLoad ~= false and type(svc.start) == "function" then
			local ok, err = pcall(function()
				svc:start()
			end)
			if ok then
				startCount += 1
			else
				log:error("start failed for", name, "—", err)
			end
		end
	end

	Log.banner(title or "Framework booted", {
		("services loaded : %d"):format(#order),
		("initialised     : %d"):format(initCount),
		("started         : %d"):format(startCount),
	})
end

return Loader
