## Base class for all GOAP actions.
##
## Actions are the building blocks of GOAP plans. Each action declares
## [member preconditions] (what must be true before it can run) and
## [member effects] (what world-state changes it produces).[br][br]
## The planner chains actions together so that one action's effects satisfy
## the next action's preconditions, ultimately reaching a [GoapGoal]'s
## desired state.[br][br]
## [b]Lifecycle:[/b][br]
## 1. [method enter] — called once when the agent starts this action.[br]
## 2. [method perform] — called every frame; return [code]true[/code] when done.[br]
## 3. [method exit] — called once after [method perform] returns [code]true[/code],
##    or when the action is interrupted by a goal change.
class_name GoapAction
extends Node

var _world_state: GoapWorldState
var _actor

## The [GoapAgent] that owns this action.
var agent: GoapAgent

## Shortcut to the agent's currently active [GoapGoal].
var goal: GoapGoal:
	get:
		return agent._current_goal

## World-state changes this action produces when completed.
## Keys are state names, values are the target values.
var effects: Dictionary = {}

## World-state conditions that must be satisfied before this action can run.
## Keys are state names, values are the required values.
var preconditions: Dictionary = {}

## Planning cost — lower values make the planner prefer this action.
@export var cost: int = 1

## If [code]false[/code], the planner will skip this action entirely.
@export var enabled: bool = true


## Called by [GoapAgent] during initialization. Stores references to the
## owning actor node and the shared [GoapWorldState].
func init(actor, world_state) -> void:
	_actor = actor
	_world_state = world_state


## Returns this action's node name, used as its display identifier.
func get_action_name(): return self.name


## Returns [code]true[/code] if this action can be used in planning.
## Override to add dynamic validation (e.g. cooldowns, resource checks).
func is_valid() -> bool:
	return enabled


## Returns the cost of this action for plan evaluation.
## Override to make cost context-dependent.
func get_cost(_blackboard) -> int:
	return 1000


## Returns the [member preconditions] dictionary.
func get_preconditions() -> Dictionary:
	return preconditions


## Returns the [member effects] dictionary.
func get_effects() -> Dictionary:
	return effects


## Writes [param _effects] into the [GoapWorldState].
## Called automatically when the action completes.
func set_effects(_effects) -> void:
	for effect in _effects.keys():
		_world_state.set_state(effect, _effects[effect])


## Called once when the agent begins executing this action.
## Override to set up movement targets, animations, etc.
func enter() -> void:
	pass


## Called once when this action finishes or is interrupted.
## Override to clean up resources.
func exit() -> void:
	pass


## Called every frame while this action is active.[br]
## Return [code]true[/code] to signal completion and advance the plan.
func perform(_delta) -> bool:
	return false


## Convenience wrapper for [method GoapWorldState.get_state].
func get_state(value, default):
	return _world_state.get_state(value, default)


## Convenience wrapper for [method GoapWorldState.set_state].
func set_state(key, value):
	return _world_state.set_state(key, value)
