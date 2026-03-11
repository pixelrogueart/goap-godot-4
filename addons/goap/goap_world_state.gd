## GOAP World State management system.
##
## Manages the current state of the world for GOAP planning and execution.
## States are stored as key-value pairs where keys can be any identifier
## and values can be any Variant type (bool, int, float, Vector2, etc.).
class_name GoapWorldState
extends Node

signal state_updated

## Internal dictionary storing all world state data
var _state = {
}


## Gets a state value by name.
## state_name: The identifier for the state to retrieve
## default: Default value to return if state doesn't exist
## Returns: The state value or default if not found
func get_state(state_name, default = null):
	return _state.get(state_name, default)

## Sets a state value.
## state_name: The identifier for the state to set
## value: The value to assign to this state
func set_state(state_name, value):
	_state[state_name] = value
	state_updated.emit()

## Removes a specific state from the world state.
## state_name: The identifier for the state to remove
func erase_state(state_name):
	_state.erase(state_name)
	state_updated.emit()


## Clears all states from the world state.
func clear_state():
	_state = {}
	state_updated.emit()
