# The Odyssey Engine Handbook

Everything you need to run this template, write your own systems on it, and
scale it — as a game, as a codebase, and as the base for every game you make.

- [Part 1 — Running it](#part-1--running-it)
- [Part 2 — How the engine works](#part-2--how-the-engine-works)
- [Part 3 — Writing your own code](#part-3--writing-your-own-code)
- [Part 4 — Scaling it](#part-4--scaling-it)
- [Part 5 — Gotchas & checklists](#part-5--gotchas--checklists)

---

# Part 1 — Running it

## The toolchain, and why each tool exists

Roblox games are normally edited inside Studio, which makes version control,
code review, and reuse painful. This template instead keeps **all code as
plain `.luau` files in a git repo** and syncs them into Studio:

| Tool | What it does |
|------|--------------|
| **Rokit** | Toolchain manager. Reads `rokit.toml` and installs the exact pinned versions of the other tools, so everyone on the team (and CI) runs identical versions. |
| **Rojo** | The bridge between the filesystem and Studio. `default.project.json` declares which folder becomes which Instance in the game tree. `rojo build` produces a place file; `rojo serve` live-syncs edits into a running Studio session. |
| **Wally** | Package manager (like npm for Roblox). Reads `wally.toml`, downloads dependencies into `Packages/` (shared) and `ServerPackages/` (server-only). `wally.lock` pins exact versions. |
| **wally-package-types** | Regenerates type information for wally packages so Luau's type checker understands them. Run after `wally install` if you use strict typing. |
| **selene** | Linter. `selene src` catches undefined globals, shadowing, etc. `selene.toml` sets the Roblox standard library. |

## First run

```bash
rokit install                 # once per machine/clone
wally install                 # after every wally.toml change
rojo build -o "Game.rbxlx"    # produce an openable place file
```

Open `Game.rbxlx` in Studio. For day-to-day work:

```bash
rojo serve
```

…then in Studio use the **Rojo plugin** → Connect. From now on, every file
you save in your editor appears in Studio within a second. You edit code in
VS Code (or any editor); you only touch Studio for maps, models, and testing.

**The direction of truth matters:** the filesystem is the source of truth for
*code*; Studio is the source of truth for *world content* (terrain, models,
placed Interactables). Rojo as configured here only syncs the four code
trees, so building the map in Studio and saving the place is fine — just
never edit synced scripts inside Studio, because the next sync overwrites
them.

## Testing

- **Play (F5)** in Studio runs client + server in one window. The Output
  window shows both; use the context dropdown to filter.
- **Test → Clients and Servers → 2 players** runs a real server process with
  multiple clients — the only honest way to test replication, and the first
  thing to reach for when "it works alone but breaks with two players".
- DataStores in Studio: **Game Settings → Security → Enable Studio Access to
  API Services** must be on, or ProfileService can't load/save profiles in
  Studio (players will be kicked with "Could not load your data").

## Publishing

File → Publish to Roblox from Studio the first time (creates the universe +
place). After that you can keep publishing from Studio, or automate later
with a CI upload (`rojo build` + the Open Cloud place-publish API).

---

# Part 2 — How the engine works

## The mental model

Roblox is client/server. The **server** owns the truth: data, money, damage,
spawning. Each **client** owns presentation: input, camera, UI, effects. They
talk only through remotes, wrapped here by **Networker**. Anything the client
sends can be forged by an exploiter, so the server validates everything —
this single idea shapes most of the engine's conventions.

Boot flow, end to end:

```
SERVER                                    CLIENT
──────                                    ──────
init.server.luau                          ReplicatedFirst/OdysseyLoader
  Loader.boot(Services)                     shows loading screen immediately
    require all service modules           init.client.luau
    :init() each (dependency order)         Loader.boot(Services)
    :start() each                             controllers init, UI mounts
                                              (menus render nil — hidden)
player joins
  PlayerService loads profile ──"dataLoaded"──▶ PlayerServiceClient caches it
  spawns character
  LoadingService ─────────────"beginSequence"─▶ loader animates steps,
                                                waits for character,
                                                sets OdysseyLoaded attribute
                                                └─▶ Loading.whenComplete fires,
                                                    HUDs appear
```

## Rojo mapping — where code lives at runtime

| Filesystem | In-game | Runs on |
|------------|---------|---------|
| `src/shared/` | `ReplicatedStorage.Shared` | both (whoever requires it) |
| `src/OdysseyEngine/` | `ServerScriptService.OdysseyEngine` | server |
| `src/client/` | `StarterPlayer.StarterPlayerScripts.Client` | each client |
| `src/ReplicatedFirst/` | `ReplicatedFirst` | client, before anything else |
| `Packages/` | `ReplicatedStorage.Packages` | both |
| `ServerPackages/` | `ServerScriptService.ServerPackages` | server |

So in code:

```lua
require(ReplicatedStorage.Shared.Framework.Loader)   -- src/shared/Framework/Loader.luau
require(ReplicatedStorage.Packages.Networker)        -- wally dependency
```

Never put secrets or server logic in `shared/` — every client can read all
of `ReplicatedStorage`.

## Services & the Loader

Every system is a **service**: a ModuleScript returning a table, under
`src/OdysseyEngine/Services/<Domain>/` (server) or
`src/client/Services/<Domain>/` (client). Domain subfolders (`Core`,
`Player`, `Example`, and whatever you add) are purely organizational — the
Loader recurses into all of them. **There is no boot list to edit.** Drop a
module in the folder and it loads.

The full contract (everything optional):

```lua
local MyService = {}

MyService.Name = "MyService"              -- defaults to the module name
MyService.AutoLoad = true                 -- false = register but don't init
MyService.Dependencies = { "PlayerService" }  -- inited first AND passed to :init

function MyService:init(playerService)    -- args = resolved Dependencies, in order
    self.players = playerService
    self.networker = Networker.server.new("MyService", self, { self.someMethod })
end

function MyService:start()                -- after EVERY service's :init
end

return MyService
```

What `Loader.boot(folder, title)` actually does, in order:

1. **require** every ModuleScript in the folder (recursively) and register
   each table by name;
2. **topologically sort** by `Dependencies` (cycles are warned about and
   broken, boot continues);
3. call **`:init()`** on each, passing the resolved dependency tables;
4. call **`:start()`** on each.

Every call is pcall-wrapped: one broken service logs an error and the rest
of the game still boots. Watch the Output for `✖ [Loader] init failed` —
don't let those linger.

**init vs start:** in `:init()`, set up your own state and networker; other
services exist but may not be initialized yet (unless declared in
`Dependencies`). In `:start()`, everything has initialized — safe to call
across services freely.

**Finding other services — never `require` a service from another service.**
Requiring at module scope creates cyclic-require deadlocks as the graph
grows. Instead:

```lua
local Loader = require(ReplicatedStorage.Shared.Framework.Loader)
local coins = Loader.get("CoinService")   -- lazy, at call time
```

All service tables register before any `:init()` runs, so `Loader.get` always
resolves during init/start — just don't *call methods on* a service before it
initialized (declare it a dependency, or call from `:start()`/at runtime).

**AutoLoad = false** marks modules the Loader should register but not drive —
helpers whose lifecycle a parent service manages, or modules that only need
requiring (their networker builds on require).

## Networker — talking across the boundary

One **channel per name**; both sides reference it by that string. Keep the
channel name equal to the service name.

Server side:

```lua
function MyService:init()
    self.networker = Networker.server.new("MyService", self, {
        self.buyItem,          -- ← ONLY methods listed here are client-callable
        self.requestState,
    })
end

function MyService:buyItem(player, itemId)   -- (self, player, ...client args)
    -- validate itemId! then act, then reply/return
end

self.networker:fire(player, "openShop", payload)  -- event → one client
self.networker:fireAll("worldEvent", ...)         -- event → all clients
```

Client side:

```lua
local MyServiceClient = {}
local net = Networker.client.new("MyService", MyServiceClient)

net:fire("buyItem", itemId)               -- fire-and-forget call to server
local state = net:fetch("requestState")   -- call + wait for return value (yields!)

function MyServiceClient:openShop(payload) end  -- receives server :fire
```

Rules that keep you safe and sane:

- **Validate every argument** of a client-callable method: type-check,
  range-check, whitelist against configs, and check cooldowns server-side.
  The client you wrote is not the client an exploiter runs.
- **Never trust client-supplied amounts, positions, or targets** without
  sanity checks. The client expresses *intent* ("I want to collect"); the
  server decides *outcome* (how much, whether allowed).
- `fetch` yields the calling thread — fine in UI event handlers, dangerous
  in loops. Prefer the push model (server fires updates; client caches).
- The exposure list is your security surface. Server-to-server API methods
  (like `CoinService:AwardCoins`) are simply *not listed*, so clients can't
  invoke them.

## Player data — ProfileService

`PlayerService` owns persistence. Concepts:

- **Profile** — one per player, loaded on join, released on leave. Its
  `.Data` table is everything the player keeps between sessions.
- **PROFILE_TEMPLATE** — the shape of a new player. `profile:Reconcile()`
  copies any template keys missing from an old save, so **adding fields is
  free**. Renaming/removing fields needs a step in `_migrateProfileData`.
- **Session locking** — ProfileService guarantees only one server holds a
  profile at a time. `ListenToRelease` kicks the player if another server
  steals the session (rejoin spam, teleports). This is what prevents the
  classic dupe exploit of writing stale data from two servers.
- **The store key** (`GameConfig.DataStoreKey`) names the dataset. Change it
  → everyone's data "wipes" (the old data still exists under the old key).
  Deliberate lever in dev, catastrophic typo in prod.

API for other services:

```lua
local players = Loader.get("PlayerService")
players:Get(player, "Coins")                          -- read
players:Set(player, "Coins", 100)                     -- write + replicate
players:Update(player, "XP", function(x) return x + 25 end)
players:Get(player).Inventory.Items[id] = item        -- nested mutation persists…
players:Push(player, "Inventory")                     -- …but replicate it yourself
```

Saving is automatic (ProfileService autosaves periodically and on release).
Replication to the owning client is what `Set`/`Push` add on top.

On the client, `PlayerServiceClient` caches the snapshot:

```lua
local psc = Loader.get("PlayerServiceClient")
psc:get("Coins")                          -- nil until dataLoaded arrives
psc:onKeyChanged("Coins", function(v) end)
psc:onChange(function() end)              -- any key
```

## The UI layer

**Three-piece pattern** for every window, mirrored throughout:

1. **Server service** decides *when* (`self.networker:fire(player, "openShop", data)`).
2. **Client controller** holds *state* (open/closed, current data) and
   exposes subscriptions (`onToggle`, `onAwarded`, `IsOpen`).
3. **React component** (`Shared/UI/<Area>/<Name>Menu.luau`) *renders* that
   state. It subscribes in `useEffect`, returns `nil` when hidden, and is
   mounted once by `UIService:init()`.

React here is [jsdotlua React](https://github.com/jsdotlua/react-lua) — real
React 17 semantics in Luau:

```lua
local e = React.createElement
local visible, setVisible = React.useState(false)

React.useEffect(function()
    local unsub = controller:onToggle(setVisible)
    return unsub                       -- cleanup on unmount
end, {})

e("TextButton", {
    Text = "BUY",
    [React.Event.Activated] = function() ... end,
})
```

**Theming:** components never hard-code colors or fonts. `useTheme()` returns
the live theme — `theme.Color.Surface/Accent/Text/...`, `theme.Font.Title`,
`theme.TextSize.Body`, `theme.Space.Medium`, `theme.Radius.Base` — and
re-renders the component when the theme changes. `Theme` owns color palettes
(Dark, Green, Blue, …); `Style` owns fonts/radii/decorations ("Default",
"Fantasy"). Per-game identity = pick or add a palette + style, and every
screen follows.

**Scaling:** all UI is authored in pixels against 1920×1080.
`ScreenScale.attach(screenGui)` (called in every `.mount`) adds a
viewport-driven `UIScale` so it looks identical on every display. Skip it
and your window renders tiny on 4K and huge on phones.

**Primitives** (`Shared/UI/Primitives/`): `Button`, `Card`, `Modal`,
`TextInput`, `ScrollList`, `SectionHeader`, `Badge`, `Divider`, `IconButton`,
`Notification`, plus the styling atoms `Corner`, `Stroke`, `Padding` and the
`Sounds` module for UI sfx. Compose these instead of raw instances so every
screen inherits theme + style automatically.

## The loading flow

`ReplicatedFirst` scripts run during the join handshake, before the world
streams in — that's why the loader lives there and depends on almost
nothing. Sequence: the loader draws immediately → server loads your profile
→ `LoadingService:notifyReady` fires `beginSequence` → the loader animates
its steps, waits for your character (with a timeout so a failed spawn can't
trap you), fades out, and sets the `OdysseyLoaded` attribute.

Gate always-on gameplay UI behind it:

```lua
local Loading = require(ReplicatedStorage.Shared.Framework.Loading)
gui.Enabled = Loading.isComplete()
Loading.whenComplete(function() gui.Enabled = true end)
```

## Logging

Use `Log` instead of `print`/`warn` so noise can be silenced without
touching code:

```lua
local log = Log.scope("MyService")   -- one per system
log:info("ready")  log:warn("odd")  log:debug("state", state)
```

Levels: `trace < debug < info < warn < error < off`. Control live from the
Studio command bar (`Log.setLevel("MyService", "debug")`), from
`LogConfig.luau` defaults, or **with no code at all** via attributes on
`ReplicatedStorage`: `LogLevel = "warn"` (global), `LogLevel_MyService =
"debug"` (per tag).

---

# Part 3 — Writing your own code

## Walk the example first

The template ships one complete feature — coins — chosen because it crosses
every layer. Trace it once and you understand the whole engine:

1. **Input**: `CoinServiceClient:init` binds **M** → toggles menu state.
2. **UI**: `CoinsMenu` subscribed to `onToggle` → renders the window.
   COLLECT button → `CoinServiceClient:collect()` → `net:fire("collectCoins")`.
3. **Server**: `CoinService:collectCoins(player)` — cooldown check (server
   authoritative!), then `AwardCoins` → `PlayerService:Update(player, "Coins", ...)`.
4. **Persistence + replication**: `Update` writes `profile.Data.Coins` and
   fires `dataUpdated` to the owning client.
5. **Back to UI**: `PlayerServiceClient` caches the new value and fires
   `onKeyChanged("Coins")` → the menu re-renders; the separate
   `coinsAwarded` event drives the "+10" flash.

Note the division: the client never says *how many* coins. It says "I
pressed the button"; the server owns amounts, cooldowns, and the write.

## Recipe: a new system, start to finish

Say you're building fishing:

1. **Config first** — `src/shared/Configs/FishingConfig.luau`: fish tables,
   rod stats, sell prices. Data-driven from day one means adding content
   later is a config edit, not code.
2. **Profile fields** — add `Fishing = { Level = 1, Caught = {} }` to
   `PROFILE_TEMPLATE`. Existing players get it via Reconcile automatically.
3. **Server service** — `src/OdysseyEngine/Services/Fishing/FishingService.luau`,
   modeled on `CoinService`: `Dependencies = { "PlayerService" }`, a
   networker exposing only the intents (`castLine`, `reelIn`), validation +
   RNG + rewards on the server.
4. **Client controller** — `src/client/Services/Fishing/FishingServiceClient.luau`,
   modeled on `CoinServiceClient`: input, menu state, server events →
   subscriptions.
5. **UI** — `src/shared/UI/Fishing/FishingMenu.luau`, modeled on `CoinsMenu`;
   add one `FishingMenu.mount(playerGui)` line to `UIService:init()`.
6. **Log scope** — `Log.scope("FishingService")` from the start.

No bootstrap edits anywhere — the Loader discovers both new services.

## Luau, briefly, for writing good modules

- Put `--!strict` at the top of new files where practical; annotate public
  function signatures (`player: Player`, `amount: number`). The type checker
  catches typos at edit time instead of runtime.
- `task.spawn(fn)` runs `fn` on a new thread now; `task.defer` after the
  current step; `task.delay(t, fn)` later. Never `wait()`; use `task.wait()`.
- Connections outlive characters and players — anything you `:Connect` per
  player must be disconnected (or connected on instances that get destroyed,
  which cleans up automatically). The engine's pattern: connect on
  `player.CharacterAdded` / instances, and clear per-player tables in
  `PlayerRemoving` (see `CoinService._lastCollect`).
- Guard yields: any `WaitForChild`, `fetch`, or DataStore call can take
  seconds or fail — decide what happens then (timeout arg, pcall, default).

## Studio + world content

Interact with hand-placed world objects by attribute conventions, not by
hard-coded names. (The main game's `InteractionService` pattern: models
under `Workspace.Interactables` carry `InteractionType = "Shop"` attributes;
a handler module per type routes to the right service. Port it from the main
repo when your game needs world interactions — it's a gameplay system, so it
isn't part of this minimal template.)

---

# Part 4 — Scaling it

## Scaling performance (more players, bigger worlds)

**Server:**
- No per-frame work you can do on events. A `Heartbeat` loop touching every
  player every frame is the classic server-killer; batch to 0.1–0.5s ticks
  where physics-rate precision isn't needed.
- Everything per-player must be O(players); everything per-pair (damage
  checks against every other player) must be spatially culled.
- Use collision groups instead of per-part Touched spaghetti.
- Watch the **MicroProfiler** (Ctrl+F6) and **Server Stats** in Studio; find
  the frame spike before guessing.

**Network:**
- Remotes cost bandwidth per client. `fireAll` on a timer with a big table
  is how games hit the ~50KB/s/player replication budget. Send deltas, not
  snapshots; send on change, not on schedule.
- Replicate to the players who care (`fire(player, ...)`) rather than
  `fireAll` when the data is per-player anyway.
- Client-side prediction: play the swing animation immediately on input,
  and let the server's verdict correct you — never wait a round-trip to feel
  responsive, never trust the client's verdict to be final.

**DataStores:**
- ProfileService already handles budgets, retries, autosaves and session
  locks — resist the urge to call DataStoreService directly for player data.
- Keep `profile.Data` lean: IDs and counts, not redundant blobs. There is a
  4MB/key limit, but you'll feel serialization cost long before that.
- Global/shared data (leaderboards, cross-server events) is different:
  OrderedDataStores and MemoryStoreService, with their own budgets.

**Memory:**
- The leak pattern to hunt: connections and per-player table entries that
  survive the player. Grep for `[player]` tables and confirm each has a
  `PlayerRemoving` cleanup.
- The `* 2.luau` rule (below) also applies to instances: duplicate mounted
  guis, duplicate character rigs.

## Scaling the codebase (more systems, more people)

- **Domain folders are the org chart.** `Services/Combat/`, `Services/Economy/`
  — a contributor should find a system by its name. Mirror server and client
  domain folders.
- **Configs over code.** Every tunable (prices, drop tables, stats) lives in
  `Shared/Configs/`, so designers change balance without touching services
  and diffs stay reviewable.
- **One service, one job.** When a service grows past ~500 lines, split it
  (sub-modules with `AutoLoad = false`, parent drives them).
- **Document per feature.** The main repo's `docs/features/` pattern — one
  markdown file per system stating its files, data keys, and remotes — is
  what makes a year-old system safe to modify. Adopt it as soon as a second
  person (or future-you) will touch the code.
- **Lint in CI.** `selene src` on every PR is cheap and catches the dumb
  stuff. Add `stylua` if formatting arguments waste review time.
- **Naming conventions carry meaning:** `XService` / `XServiceClient` /
  `XMenu` triples; networker channel = service name; `Log.scope` tag =
  service name. Break the convention and the discoverability tooling in your
  head breaks with it.

## Scaling to many games (the template story)

This folder is the seed for every game. The workflow:

1. **New game = copy the template** into a fresh repo (or
   `wally install` + build to verify, then start committing).
2. Change `GameConfig` (name + **fresh DataStoreKey**), the loader title,
   and the default theme/style. That's the entire rebrand surface.
3. Build gameplay in new domain folders. **Don't edit `Framework/` or
   `Primitives/` casually** — those are engine files shared in spirit across
   your games.
4. When you improve an engine file (Loader, Log, a primitive) in one game,
   **port it back to the template**, then forward to your other games. The
   template is the hub; games are spokes. Diff a game's `Framework/` against
   the template's occasionally to catch drift.
5. If juggling copies gets painful (3+ active games), the graduation step is
   moving `Framework/` + `Primitives/` into a private **wally package** (or a
   git submodule) so games declare a version instead of holding a copy. Do
   this only when the pain is real — copies are simpler while there are two
   repos, and the main game already accepts some duplication deliberately.
6. Keep place-specific content (maps, models) in the place file per game;
   the repo carries code and configs.

---

# Part 5 — Gotchas & checklists

## The gotcha list (learned the hard way in the main game)

1. **Players join before your service inits.** The Loader's require phase
   can yield, so `Players.PlayerAdded:Connect` alone misses early joiners.
   Any per-player setup in `:init()` must also sweep `Players:GetPlayers()`
   (and check `player.Character` for character-level setup).
2. **`CharacterAutoLoads` is off.** PlayerService spawns the character after
   data loads; CharacterService respawns after death. If nobody spawns, you
   forgot who owns spawning.
3. **Changing `DataStoreKey` wipes (points away from) all player data.**
4. **Never trust the client.** Every networker-exposed method validates its
   args, applies server-side cooldowns, and whitelists against configs.
5. **No `require` of one service from another at module scope** — use
   `Loader.get` at call time, or `Dependencies`.
6. **Every mounted ScreenGui calls `ScreenScale.attach`** — or it's the one
   window that's the wrong size on someone's monitor.
7. **`ResetOnSpawn = false`** on mounted guis, or your React roots die with
   the first respawn.
8. **No `* 2.luau` files.** Editor/sync artifacts named `Thing 2.luau` get
   auto-discovered by the Loader as duplicate services. Delete on sight.
9. **Resolve state on the server and push it down.** Don't let the client
   default a value and race the server's answer.
10. **`fetch` yields.** Call it from event handlers, not render paths.
11. **Studio API access off** looks exactly like "data is broken". Check
    Game Settings first.
12. **Clean up per-player tables in `PlayerRemoving`** — the standard leak.

## New-game checklist

- [ ] Copy template → new repo; `rokit install && wally install`
- [ ] `GameConfig.luau`: Name, Version, **new DataStoreKey**, theme/style
- [ ] Loader title text in `OdysseyLoader.client.luau`
- [ ] `default.project.json` name field
- [ ] Enable Studio API access in Game Settings after first publish
- [ ] Build one feature by copying the Example trio; delete Example folders
- [ ] Set up `selene src` in CI

## New-system checklist

- [ ] Config module in `Shared/Configs/` for anything tunable
- [ ] Profile fields added to `PROFILE_TEMPLATE` (Reconcile handles old saves)
- [ ] `Services/<Domain>/XService.luau` — deps declared, networker exposes
      only intents, every client arg validated
- [ ] `client/Services/<Domain>/XServiceClient.luau` — state + subscriptions
- [ ] `Shared/UI/<Area>/XMenu.luau` + one mount line in `UIService:init()`
- [ ] `Log.scope("XService")`, no raw prints
- [ ] Per-player state cleaned up in `PlayerRemoving`
- [ ] Tested with **2+ players** in Clients and Servers mode
