## Manages world state for GOAP planning and execution.
##
## States are stored as key-value pairs where keys are string identifiers
## and values can be any [Variant] type ([bool], [int], [float], [Vector2], etc.).[br]
## The planner reads world state to build a blackboard, and actions modify it
## via [method set_state] to reflect changes in the environment.
class_name GoapWorldState
extends Node

## Emitted whenever any state value is changed, added, or removed.
signal state_updated

var _state = {}


## Returns the value of a state entry, or [param default] if not found.
func get_state(state_name, default = null):
	return _state.get(state_name, default)


## Sets a state entry to [param value], creating it if it doesn't exist.
func set_state(state_name, value):
	_state[state_name] = value
	state_updated.emit()


## Removes a single state entry by name.
func erase_state(state_name):
	_state.erase(state_name)
	state_updated.emit()


## Removes all state entries.
func clear_state():
	_state = {}
	state_updated.emit()
