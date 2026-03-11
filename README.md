# GOAP for Godot 4

A **Goal-Oriented Action Planning** plugin for Godot 4.x written entirely in GDScript.

GOAP lets your NPCs decide *what* to do by planning sequences of actions at runtime instead of following hand-authored behaviour trees or state machines. The planner picks the cheapest chain of actions that transitions the current world state into the desired goal state.

---

## Features

- **Backward-chaining A\* planner** – automatically finds the cheapest action sequence for any goal.
- **Priority-based goal selection** – the agent always pursues the highest-priority valid goal.
- **Runtime re-planning** – if the world changes mid-plan the agent can re-plan on the fly.
- **Editor debugger panel** – inspect world state, active plan, and action flow in real time while the game runs.
- **Planner explorer** – visualise every possible action tree for each goal directly in the editor.
- **Multi-agent support** – switch between agents in the debugger via the dropdown selector.
- **Zero external dependencies** – pure GDScript, no addons required.

---

## Installation

1. Copy the `addons/goap/` folder into your project's `addons/` directory.
2. Open **Project → Project Settings → Plugins** and enable the **GOAP** plugin.

---

## Project Structure

```
addons/goap/
  plugin.cfg              # Plugin metadata
  plugin.gd               # Registers the debugger plugin
  goap_agent.gd           # Core agent – goal selection, planning, execution
  goap_action.gd          # Base class for actions
  goap_action_planner.gd  # A* backward-search planner
  goap_goal.gd            # Base class for goals
  goap_world_state.gd     # Key-value world state with change signal
  debugger/
    goap_editor_debugger_plugin.gd  # Editor-side message router
    goap_editor_debug_panel.gd      # Runtime tab (world state + plan graph)
    goap_planner_explorer.gd        # Static plan-tree explorer tab
```

---

## Quick-Start Guide

### 1. Define State Keys

Create a constants class so your goals and actions reference the same strings:

```gdscript
class_name StateKeys

const IS_HUNGRY  = "is_hungry"
const IS_FED     = "is_fed"
const HAS_FOOD   = "has_food"
```

### 2. Create a Goal

Extend `GoapGoal`. Set `desired_state` to the world-state conditions you want satisfied, override `is_valid()` to control when the goal activates, and set a `priority`.

```gdscript
extends GoapGoal

func _ready() -> void:
    desired_state = {StateKeys.IS_FED: true}

func is_valid() -> bool:
    return _world_state.get_state(StateKeys.IS_HUNGRY, false)

func get_priority() -> int:
    return 10

func on_goal_achieved() -> void:
    _world_state.set_state(StateKeys.IS_HUNGRY, false)
    _world_state.set_state(StateKeys.IS_FED, false)
```

### 3. Create Actions

Extend `GoapAction`. Declare `effects` (what the action produces) and `preconditions` (what must already be true). Implement `enter()`, `perform()`, and `exit()`.

```gdscript
extends GoapAction

func _ready() -> void:
    effects = {StateKeys.IS_FED: true}
    preconditions = {StateKeys.HAS_FOOD: true}

func enter() -> void:
    # start eating animation
    pass

func perform(delta) -> bool:
    # return true when done
    return true

func get_cost(_blackboard) -> int:
    return 2
```

The planner chains actions whose effects satisfy other actions' preconditions. In the example above the planner would first look for an action whose effects include `HAS_FOOD = true`, then chain it before the eat action.

### 4. Set Up the Scene Tree

```
NPC (Node2D or CharacterBody2D)
  └── GoapAgent
        ├── Goals
        │     ├── EatGoal
        │     └── WanderGoal
        └── Actions
              ├── FindFoodAction
              ├── EatAction
              └── WanderAction
```

- Set `GoapAgent.goals_node` → `Goals`
- Set `GoapAgent.actions_node` → `Actions`

### 5. Initialise and Tick

```gdscript
func _ready() -> void:
    $GoapAgent.init(self)

func _process(delta) -> void:
    $GoapAgent.process(delta)
```

### 6. Reading and Writing World State

Actions and goals access the shared `GoapWorldState` through the `_world_state` variable that is set automatically via `init()`.

```gdscript
# Inside an action or goal
_world_state.set_state(StateKeys.IS_HUNGRY, true)
var hungry = _world_state.get_state(StateKeys.IS_HUNGRY, false)
```

---

## How the Planner Works

1. The agent picks the highest-priority valid goal.
2. The planner reads the goal's `desired_state` and the current world state (blackboard).
3. It searches **backward** from the desired state – for each unsatisfied condition it looks for actions whose `effects` can satisfy it.
4. If those actions have `preconditions`, the search continues recursively.
5. All valid paths are collected and the one with the **lowest total cost** is selected.
6. The resulting plan is an ordered array of actions executed one by one.

---

## Editor Debugger

When `debug_enabled` is `true` on a `GoapAgent`, runtime data is sent to the editor automatically.

### Runtime Tab

- **World State sidebar** – live key-value list with colour-coded indicators (green = true, red = false, blue = other values).
- **Plan graph** – connected `GraphNode`s showing the current plan. Nodes are colour-coded: yellow = running, green = done, blue = pending.

### Planner Tab

- **Goal list** – select any registered goal.
- **Action tree** – shows every possible action chain the planner could generate for that goal, with preconditions and effects on each node.

### Multi-Agent

If multiple agents exist in the scene, use the **Agent** dropdown at the top of the GOAP tab to switch between them. Each agent's state is cached, so switching is instant.

---

## API Reference

All classes use Godot 4 `##` documentation comments. Open the built-in help (<kbd>F1</kbd> or **Search Help**) and search for `Goap` to browse the full auto-generated API.

| Class | Description |
|---|---|
| `GoapAgent` | Core brain – goal selection, planning, action execution |
| `GoapGoal` | Base goal with desired state, priority, and lifecycle hooks |
| `GoapAction` | Base action with preconditions, effects, cost, and lifecycle hooks |
| `GoapWorldState` | Dictionary-backed state store with `state_updated` signal |
| `GoapActionPlanner` | A* backward-chaining planner (internal, managed by agent) |

---

## Example

The `example/` folder contains a self-contained survival demo rendered entirely with `_draw()` (no sprites needed):

- **Goals:** Eat (priority 10), Sleep (8), MaintainFire (5), Wander (1)
- **Actions:** ChopTree → LightFire, Hunt → CookFood → Eat, Sleep, Wander
- **Needs system:** hunger and tiredness increase over time; the NPC plans accordingly.
- **Environment:** trees and prey spawn periodically; a campfire must be kept lit to cook food.

Run `example/main.tscn` to see it in action.

---

## License

MIT
