class_name GoapAction
extends Node


var _world_state: GoapWorldState
var _actor

@export var effects: Dictionary
@export var preconditions: Dictionary
@export var cost: int = 1


func init(actor, world_state) -> void:
	_actor = actor
	_world_state = world_state


func get_action_name(): return self.name


func is_valid() -> bool:
	return true


func get_cost(_blackboard) -> int:
	return 1000


func get_preconditions() -> Dictionary:
	return {}


func get_effects() -> Dictionary:
	return {}


func perform(_actor, _delta) -> bool:
	return false
