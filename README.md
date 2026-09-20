# Odyssey Game Template

The starter every Odyssey game begins from. It is the engine extracted from
the main game — the service Loader, Networker messaging, ProfileService
persistence, the React UI layer with theming/scaling, the loading screen and
logging — plus one small worked example (a coins system) showing how every
new feature is wired.

**Read [`GUIDE.md`](GUIDE.md)** — it teaches how to run this, how the engine
works, how to write your own systems, and how to scale.

## Quick start

Install [Rokit](https://github.com/rojo-rbx/rokit) once, then from this
folder:

```bash
rokit install          # pins rojo, wally, wally-package-types on your PATH
wally install          # fetches Packages/ and ServerPackages/
rojo build -o "Game.rbxlx"
```

Open `Game.rbxlx` in Roblox Studio, then live-sync source edits:

```bash
rojo serve             # connect via the Rojo plugin in Studio
```

Press **Play** in Studio: the loading screen runs, your profile loads, your
character spawns. Press **M** to open the example coins menu and click
COLLECT.

## Starting a new game from this template

1. Copy this whole folder into a fresh repository.
2. Edit `src/shared/Configs/GameConfig.luau` — name, version, and most
   importantly a fresh `DataStoreKey`.
3. Rename `TITLE` in `src/ReplicatedFirst/OdysseyLoader.client.luau`.
4. Build your systems by copying the Example trio (`CoinService`,
   `CoinServiceClient`, `CoinsMenu`); delete the Example folders when you no
   longer need the reference.

## Layout

| Path | Maps to | Contents |
|------|---------|----------|
| `src/shared` | `ReplicatedStorage.Shared` | Configs, UI, the service framework |
| `src/OdysseyEngine` | `ServerScriptService.OdysseyEngine` | Server services |
| `src/client` | `StarterPlayerScripts.Client` | Client controllers |
| `src/ReplicatedFirst` | `ReplicatedFirst` | Loading screen |
| `Packages` / `ServerPackages` | wally deps | React, Networker, ProfileService, … |
