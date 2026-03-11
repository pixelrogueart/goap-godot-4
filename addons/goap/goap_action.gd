## Base class for GOAP actions.
##
## Actions represent atomic operations that can be performed to change the world state.
## Each action has preconditions (what must be true to execute) and effects (what changes after execution).
## Actions are executed sequentially as part of a plan to achieve a goal.
class_name GoapAction
extends Node

## Reference to the world state for reading current state and applying effects
var _world_state: GoapWorldState
## The actor (entity) that will perform this action
var _actor
## Reference to the GOAP agent managing this action
var agent: GoapAgent
var goal: GoapGoal:
	get:
		return agent._current_goal
## Dictionary of state changes this action will apply when completed
var effects: Dictionary = {}
## Dictionary of conditions that must be met for this action to be valid
var preconditions: Dictionary = {}
## Base cost of executing this action (lower is better for planning)
@export var cost: int = 1
## Whether this action is currently enabled and available for use
@export var enabled: bool = true


## Initializes the action with actor and world state references.
## @param actor: The entity that will perform this action
## @param world_state: The world state system for reading/writing state
func init(actor, world_state) -> void:
	_actor = actor
	_world_state = world_state


## Gets the display name of this action.
## @return: The node name as the action identifier
func get_action_name(): return self.name


## Checks if this action is currently valid and can be considered for planning.
## @return: True if the action is enabled and can be used
func is_valid() -> bool:
	return enabled


## Gets the cost of executing this action.
## @param _blackboard: Current planning context (unused in base implementation)
## @return: The cost value for planning calculations
func get_cost(_blackboard) -> int:
	return 1000


## Gets the preconditions required for this action to execute.
## @return: Dictionary of state conditions that must be satisfied
func get_preconditions() -> Dictionary:
	return preconditions


## Gets the effects this action will have on the world state.
## @return: Dictionary of state changes this action will apply
func get_effects() -> Dictionary:
	return effects


## Applies this action's effects to the world state.
## Called automatically when the action completes successfully.
func set_effects(_effects) -> void:
	for effect in _effects.keys():
		_world_state.set_state(effect, _effects[effect])



## Called when the action is entered (started by the agent).
## Override to implement custom enter logic.
func enter() -> void:
	pass

## Called when the action is exited (finished or interrupted).
## Override to implement custom exit logic.
func exit() -> void:
	pass

## Executes the action logic for one frame.
## Override this method to implement the actual action behavior.
## @param _delta: Time elapsed since last frame
## @return: True when the action is complete, false to continue next frame
func perform(_delta) -> bool:
	return false

func get_state(value, default):
	return _world_state.get_state(value, default)

func set_state(key, value):
	return _world_state.set_state(key, value)
