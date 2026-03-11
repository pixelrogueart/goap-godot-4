## Base class for all GOAP goals.
##
## A goal defines a [member desired_state] — a set of world-state conditions
## the planner must satisfy. The planner builds a chain of [GoapAction]s that
## transitions the current [GoapWorldState] into the desired one.[br][br]
## [b]Lifecycle:[/b][br]
## 1. [method enter] — called once when the agent selects this goal.[br]
## 2. The planner builds a plan; actions execute sequentially.[br]
## 3. [method perform] — called every frame while the plan runs (use for
##    parallel goal logic like timers).[br]
## 4. [method on_goal_achieved] — called once when the desired state is met.[br]
## 5. [method on_goal_failed] — called once if no valid plan can be found.[br]
## 6. [method exit] — called once when the goal is deselected or finished.[br][br]
## Override [method is_valid] to enable/disable a goal dynamically (e.g. only
## pursue "Eat" when the NPC is hungry).
@icon("res://addons/goap/icons/goap_goal.svg")
class_name GoapGoal
extends Node

var _actor
var _world_state: GoapWorldState

## If [code]true[/code], [method is_valid] returns [code]true[/code] by default.
var default_valid_state: bool = true

## Selection priority — the agent always picks the highest-priority valid goal.
@export var priority: int = 0

## If [code]false[/code], this goal is never considered by the agent.
@export var enabled: bool = true

## Base cost used during plan evaluation.
@export var cost: int = 0

## [code]true[/code] while this goal is the active goal being executed.
var performing: bool = false

## The world-state conditions that the planner must satisfy.[br]
## Example: [code]{ "is_fed": true }[/code]
var desired_state: Dictionary = {}

## The [GoapAgent] that owns this goal.
var agent: GoapAgent


## Returns this goal's node name, used as its display identifier.
func get_action_name(): return self.name


## Called by [GoapAgent] during initialization.
func init(actor, world_state) -> void:
	_actor = actor
	_world_state = world_state


## Returns [code]true[/code] if this goal can currently be pursued.[br]
## Override to add dynamic conditions (e.g. world-state checks).
func is_valid() -> bool:
	return default_valid_state


## Returns the selection [member priority] of this goal.
func get_priority() -> int:
	return priority


## Returns the [member desired_state] dictionary.
func get_desired_state() -> Dictionary:
	return desired_state


## Replaces [member desired_state] and returns the new dictionary.
func set_desired_state(new_desired_state: Dictionary) -> Dictionary:
	desired_state = new_desired_state
	return desired_state


## Returns the planning [member cost] for this goal.
func get_cost(_blackboard) -> int:
	return cost


## Called once when the agent selects this goal.[br]
## Override to initialize goal-specific state.
func enter() -> void:
	performing = true


## Called once when the goal is deselected or completed.[br]
## Override to clean up goal-specific state.
func exit() -> void:
	performing = false


## Called every frame while the plan is running.[br]
## Use for parallel goal logic (timers, monitoring, etc.).
func perform(_delta) -> void:
	pass


## Called before planning begins. Override for pre-plan setup.
func prepare() -> void:
	pass


## Called once when all desired-state conditions are met.
func on_goal_achieved() -> void:
	pass


## Called once if the planner cannot find a valid plan.
func on_goal_failed() -> void:
	pass
