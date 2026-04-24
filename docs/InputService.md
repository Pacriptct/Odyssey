# Odyssey Input Service

The `InputServiceClient` is the central client-side input router for Odyssey. It converts raw Roblox inputs like `LeftShift`, `Space`, `MouseButton1`, or `Q` into named game actions like `Sprint`, `JumpVault`, `PrimaryAttack`, or `HookLeft`.

It should not contain gameplay logic. Movement, ODM, combat, interaction, and UI services bind to input actions and decide what those actions actually do.

---

## Core Flow

```txt
Player presses key
↓
InputServiceClient converts input → action name
↓
Feature service receives action callback
↓
Feature service performs local behavior and/or sends intent to server
```

Example:

```txt
LeftShift
↓
Sprint
↓
MovementServiceClient:SetSprinting(true)
```

Example with server validation:

```txt
Q
↓
HookLeft
↓
ODMServiceClient:StartHook("Left")
↓
ODMService server validates gear, cooldown, alive state, etc.
```

---

## File Structure

```txt
ReplicatedStorage
└── Shared
    └── Input
        └── InputConfig.luau

StarterPlayerScripts
└── Client
    └── Services
        ├── InputServiceClient.luau
        ├── PlayerServiceClient.luau
        ├── MovementServiceClient.luau
        └── ...
```

---

## Responsibilities

### Profile Template / PlayerService

The profile template stores the player’s actual saved keybinds.

```lua
Keybinds = {
    Interaction = "C",
    Sprint = "LeftShift",
    CrouchSlide = "LeftControl",
    JumpVault = "Space",
    ShiftLock = "LeftAlt",

    HookLeft = "Q",
    HookRight = "E",
    GearBoost = "Space",
    SwitchODMMode = "LeftControl",
}
```

This is the source of truth for what key each action is assigned to.

### InputConfig

`InputConfig` does **not** store actual keys. It only describes valid actions, their context, and priority.

```lua
Sprint = {
    Context = "Movement",
    Priority = 100,
    CanHold = true,
    Exclusive = true,
}
```

### InputServiceClient

`InputServiceClient`:

```txt
- Loads actions from InputConfig
- Receives keybinds from Client.luau
- Converts keys into action names
- Tracks held actions
- Resolves context priority
- Fires callbacks registered by feature services
```

### Feature Services

Feature services bind to actions and handle gameplay behavior.

```lua
InputServiceClient:BindAction("Sprint", function(_, state)
    if state == "Began" then
        self:SetSprinting(true)
    elseif state == "Ended" then
        self:SetSprinting(false)
    end
end)
```

---

## Client Bootstrap

`Client.luau` bridges `PlayerServiceClient` keybinds into `InputServiceClient`.

```lua
local PlayerServiceClient = require(script.Services.PlayerServiceClient)
local InputServiceClient = require(script.Services.InputServiceClient)
local MovementServiceClient = require(script.Services.MovementServiceClient)

InputServiceClient:init()
MovementServiceClient:init()
PlayerServiceClient:init()

local lastKeybinds = nil

local function syncInputKeybinds()
    local keybinds = PlayerServiceClient:getKeybinds()

    if not keybinds then
        return
    end

    if keybinds == lastKeybinds then
        return
    end

    lastKeybinds = keybinds
    InputServiceClient:RefreshKeybindsFromProfile(keybinds)
end

PlayerServiceClient:onChange(function()
    syncInputKeybinds()
end)

syncInputKeybinds()
```

Important rule:

```txt
PlayerServiceClient should not require InputServiceClient.
InputServiceClient should not require PlayerServiceClient.
Client.luau connects them.
```

This avoids circular requires and duplicate module instances.

---

## Adding a New Input Action

Example: adding `Dodge`.

### 1. Add the keybind to the profile template

```lua
Keybinds = {
    Sprint = "LeftShift",
    CrouchSlide = "LeftControl",
    Dodge = "Q",
}
```

If players already have saved data, `profile:Reconcile()` should add missing defaults from the template.

### 2. Add the action to InputConfig

```lua
Dodge = {
    Context = "Movement",
    Priority = 100,
    CanHold = false,
    Exclusive = true,
},
```

### 3. Bind the action in the owning service

```lua
InputServiceClient:BindAction("Dodge", function(_, state)
    if state ~= "Began" then
        return
    end

    self:Dodge()
end)
```

```lua
function MovementServiceClient:Dodge()
    local humanoid = self:_getHumanoid()
    local root = self:_getRootPart()

    if not humanoid or not root then
        return
    end

    local direction = humanoid.MoveDirection

    if direction.Magnitude <= 0.05 then
        direction = root.CFrame.LookVector
    end

    root.AssemblyLinearVelocity += direction.Unit * 45
end
```

---

## Contexts

Contexts control which group of actions are currently active.

```lua
DefaultEnabledContexts = {
    General = true,
    Movement = true,
    Combat = true,

    ODM = false,
    Weapon = false,
    UI = false,
    Menu = false,
    Admin = false,
}
```

Enable or disable a context:

```lua
InputServiceClient:SetContextEnabled("ODM", true)
InputServiceClient:SetContextEnabled("Movement", false)
```

---

## Priority and Overlapping Keys

Overlapping keys are allowed.

Example profile:

```lua
JumpVault = "Space"
GearBoost = "Space"

CrouchSlide = "LeftControl"
SwitchODMMode = "LeftControl"
```

Example config:

```lua
JumpVault = {
    Context = "Movement",
    Priority = 100,
}

GearBoost = {
    Context = "ODM",
    Priority = 500,
}
```

When ODM is disabled:

```txt
Space → JumpVault
LeftControl → CrouchSlide
```

When ODM is enabled:

```txt
Space → GearBoost
LeftControl → SwitchODMMode
```

Higher priority wins.

---

## Binding Actions

Use `BindAction` inside client services.

```lua
InputServiceClient:BindAction("Interaction", function(actionName, state, inputObject)
    if state ~= "Began" then
        return
    end

    self:TryInteract()
end)
```

Callback arguments:

```txt
actionName: string
state: "Began" | "Ended" | "Changed"
inputObject: InputObject
```

---

## Held Actions

Check if an action is currently held:

```lua
if InputServiceClient:IsActionHeld("Sprint") then
    print("Sprint is held")
end
```

Useful for actions like:

```txt
Sprint
CrouchSlide
GearBoost
GearBlock
HookLeft
HookRight
OrbitLeft
OrbitRight
```

---

## Blocking Input

Block all gameplay input:

```lua
InputServiceClient:SetInputBlocked(true)
```

Restore input:

```lua
InputServiceClient:SetInputBlocked(false)
```

Useful for:

```txt
Cutscenes
Loading screens
Character creation
Menus
Death state
```

---

## Menus and UI

When a menu opens, disable gameplay contexts.

```lua
InputServiceClient:SetContextEnabled("Menu", true)
InputServiceClient:SetContextEnabled("UI", true)

InputServiceClient:SetContextEnabled("Movement", false)
InputServiceClient:SetContextEnabled("Combat", false)
InputServiceClient:SetContextEnabled("ODM", false)
```

When the menu closes:

```lua
InputServiceClient:SetContextEnabled("Menu", false)
InputServiceClient:SetContextEnabled("UI", false)

InputServiceClient:SetContextEnabled("Movement", true)
InputServiceClient:SetContextEnabled("Combat", true)
```

If ODM was equipped before opening the menu, re-enable it based on gear state.

---

## Server Communication

Do not send raw keys to the server.

Bad:

```lua
Remote:FireServer("LeftShift")
Remote:FireServer("Space")
```

Good:

```lua
self.Networker:fire("setSprinting", true)
self.Networker:fire("requestVault")
self.Networker:fire("hookStarted", "Left")
self.Networker:fire("requestInteract", interactableId)
```

The client sends intent. The server validates.

Server should check things like:

```txt
- Is the player alive?
- Is the player stunned?
- Does the player have gear equipped?
- Is the target in range?
- Is the cooldown ready?
- Is the action allowed by the state machine?
```

---

## Directional Movement

Do **not** add keybinds for normal directional walking like `W`, `A`, `S`, and `D` unless Odyssey is replacing Roblox’s movement controller completely.

Directional walking should use:

```lua
humanoid.MoveDirection
```

Example:

```lua
local moveDirection = humanoid.MoveDirection
local localDirection = root.CFrame:VectorToObjectSpace(moveDirection)

local forwardAmount = -localDirection.Z
local rightAmount = localDirection.X
```

Use this for:

```txt
Directional walk animations
Strafe animations
Backward walking animations
Blend trees
IK movement adjustments
```

Only add input binds for actions like:

```txt
Sprint
Dodge
Slide
WallRun
Vault
Roll
Attack
Interact
HookLeft
HookRight
```

---

## Example MovementServiceClient

```lua
local Players = game:GetService("Players")

local InputServiceClient = require(script.Parent.InputServiceClient)

local MovementServiceClient = {} :: any

MovementServiceClient._initialized = false
MovementServiceClient._sprinting = false

function MovementServiceClient:init()
    if self._initialized then
        return
    end

    self._initialized = true

    InputServiceClient:BindAction("Sprint", function(_, state)
        if state == "Began" then
            self:SetSprinting(true)
        elseif state == "Ended" then
            self:SetSprinting(false)
        end
    end)

    InputServiceClient:BindAction("CrouchSlide", function(_, state)
        if state == "Began" then
            self:BeginCrouchSlide()
        elseif state == "Ended" then
            self:EndCrouchSlide()
        end
    end)
end

function MovementServiceClient:_getHumanoid()
    local character = Players.LocalPlayer.Character
    if not character then
        return nil
    end

    return character:FindFirstChildOfClass("Humanoid")
end

function MovementServiceClient:SetSprinting(enabled)
    self._sprinting = enabled

    local humanoid = self:_getHumanoid()
    if not humanoid then
        return
    end

    humanoid.WalkSpeed = if enabled then 22 else 16
end

function MovementServiceClient:BeginCrouchSlide()
    if self._sprinting then
        self:StartSlide()
    else
        self:SetCrouching(true)
    end
end

function MovementServiceClient:EndCrouchSlide()
    self:StopSlide()
    self:SetCrouching(false)
end

return MovementServiceClient
```

---

## Example ODMServiceClient

```lua
local InputServiceClient = require(script.Parent.InputServiceClient)

local ODMServiceClient = {} :: any

ODMServiceClient._equipped = false

function ODMServiceClient:init()
    InputServiceClient:SetContextEnabled("ODM", false)

    InputServiceClient:BindAction("HookLeft", function(_, state)
        if state == "Began" then
            self:StartHook("Left")
        elseif state == "Ended" then
            self:EndHook("Left")
        end
    end)

    InputServiceClient:BindAction("GearBoost", function(_, state)
        if state == "Began" then
            self:SetBoosting(true)
        elseif state == "Ended" then
            self:SetBoosting(false)
        end
    end)
end

function ODMServiceClient:SetEquipped(equipped)
    self._equipped = equipped
    InputServiceClient:SetContextEnabled("ODM", equipped)
end

function ODMServiceClient:StartHook(side)
    if not self._equipped then
        return
    end

    self.Networker:fire("hookStarted", side)
end

function ODMServiceClient:EndHook(side)
    self.Networker:fire("hookEnded", side)
end

function ODMServiceClient:SetBoosting(enabled)
    if not self._equipped then
        return
    end

    self.Networker:fire("setBoosting", enabled)
end

return ODMServiceClient
```

---

## Debugging

Print current keybind map:

```lua
InputServiceClient:DebugPrintBindings()
```

Example output:

```txt
LeftShift: Sprint
LeftControl: CrouchSlide, SwitchODMMode
Space: JumpVault, GearBoost
Q: HookLeft
E: HookRight
```

Check what actions are bound to a specific input:

```lua
local actions = InputServiceClient:GetBoundActionsForInput("Space")
print(actions)
```

Check active contexts:

```lua
local contexts = InputServiceClient:GetActiveContexts()
print(contexts.Movement, contexts.ODM)
```

---

## Common Issues

### Action does not fire

Check:

```txt
- Is the service binding the action initialized?
- Did keybinds apply?
- Is the action in InputConfig?
- Is the action in the profile Keybinds table?
- Is the context enabled?
- Is gameProcessed blocking it because the player is typing?
```

### Keybind exists but warning says unknown action

The profile has a keybind that does not exist in `InputConfig.Actions`.

Fix by adding the action to `InputConfig`.

### Overlapping key fires the wrong action

Check context priority.

Example:

```txt
Space has JumpVault and GearBoost.
If ODM is enabled, GearBoost wins.
If ODM is disabled, JumpVault wins.
```

### Directional walking does not work

Do not use keybinds for directional walking.

Use:

```lua
Humanoid.MoveDirection
```

### PlayerServiceClient data loads twice

Make sure no UI/shared module requires client services from `StarterPlayer.StarterPlayerScripts`.

Bad:

```lua
local StarterPlayer = game:GetService("StarterPlayer")
local PlayerServiceClient = require(StarterPlayer.StarterPlayerScripts.Client.Services.PlayerServiceClient)
```

Good from a shared UI module:

```lua
local Players = game:GetService("Players")

local playerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts")
local services = playerScripts:WaitForChild("Client"):WaitForChild("Services")
local PlayerServiceClient = require(services:WaitForChild("PlayerServiceClient"))
```

Good from another client service:

```lua
local PlayerServiceClient = require(script.Parent.PlayerServiceClient)
```

---

## Best Practices

Good:

```txt
InputServiceClient detects "Sprint"
MovementServiceClient handles sprint
```

Bad:

```txt
InputServiceClient changes WalkSpeed directly
```

Good:

```txt
ODMServiceClient sends hookStarted("Left") to server
```

Bad:

```txt
InputServiceClient sends "Q" to server
```

Good:

```txt
PlayerServiceClient stores keybinds
Client.luau bridges keybinds into InputServiceClient
```

Bad:

```txt
PlayerServiceClient requires InputServiceClient
InputServiceClient requires PlayerServiceClient
```

---

## Current Odyssey Pattern

```txt
PlayerService profile template
= stores saved keybinds

InputConfig
= describes valid actions and context priority

Client.luau
= passes PlayerServiceClient keybinds into InputServiceClient

InputServiceClient
= maps input objects to action names

Feature services
= bind to actions and perform gameplay behavior
```
