## Base class for GOAP goals using dictionary-based desired state.
##
## Goal Execution Model:
## 1. The planner creates a plan to satisfy this goal's desired_state
## 2. Actions in the plan are executed sequentially by the agent
## 3. After plan completion, perform() is called continuously until it returns true
## 4. When perform() returns true, on_goal_achieved() is called once
## 5. If planning fails, on_goal_failed() is called once
##
## Key Points:
## - perform() should contain the ongoing goal logic and return true when complete
## - on_goal_achieved() and on_goal_failed() are event callbacks, not continuous execution
## - Goals should handle their own timeouts and failure conditions in perform()
## - Use desired_state dictionary to specify what world state the plan should achieve

class_name GoapGoal
extends Node

## Reference to the actor (entity) that owns this goal
var _actor
## Reference to the world state manager
var _world_state: GoapWorldState
## Default validation state for the goal
var default_valid_state: bool = true
## Priority of this goal (higher values = higher priority)
@export var priority: int = 0
## Whether this goal is currently enabled and can be selected
@export var enabled: bool = true
## Base cost of achieving this goal (used for plan evaluation)
@export var cost: int = 0 
## Dictionary defining the desired world state this goal wants to achieve
var performing: bool = false
var desired_state: Dictionary = {}
var agent: GoapAgent
## Returns the name of this goal action.
## @return: The name of this goal
func get_action_name(): return self.name

## Initializes the goal with actor and world state references.
## actor: The entity that owns this goal
## world_state: The world state manager
func init(actor, world_state) -> void:
	_actor = actor
	_world_state = world_state

## Checks if this goal is currently valid and can be pursued.
## Returns: True if the goal is valid, false otherwise
func is_valid() -> bool:
	return default_valid_state

## Gets the priority of this goal.
## Returns: Priority value (higher = more important)
func get_priority() -> int:
	return priority

## Gets the desired world state this goal wants to achieve.
## Returns: Dictionary containing the desired state key-value pairs
func get_desired_state() -> Dictionary:
	return desired_state

## Sets the desired world state for this goal.
## new_desired_state: Dictionary containing the new desired state
## Returns: The updated desired state dictionary
func set_desired_state(new_desired_state: Dictionary) -> Dictionary:
	desired_state = new_desired_state
	return desired_state

## Gets the cost of achieving this goal.
## _blackboard: Current world state and context (unused in base implementation)
## Returns: Cost value for plan evaluation
func get_cost(_blackboard) -> int:
	return cost

## Called once when the goal is first selected and becomes active.
## Override this method to initialize goal-specific state or setup.
func enter() -> void:
	performing = true


## Called once when the goal is deselected or completed.
## Override this method to cleanup goal-specific state or resources.
func exit() -> void:
	performing = false
	pass


## Performs the goal's ongoing execution logic.
## Called continuously after the action plan is completed until it returns true.
## _delta: Time since last frame (unused in base implementation)
func perform(_delta) -> void:
	pass

func prepare() -> void:
	pass

func get_stare_duration() -> float:
	return 1.0

func get_interest_point() -> Node2D:
	return null

func on_goal_achieved() -> void:
	pass

func on_goal_failed() -> void:
	pass
