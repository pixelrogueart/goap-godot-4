class_name GoapGoal
extends Node

var _actor
var _world_state: GoapWorldState
@export var priority: int
@export var desired_state: Dictionary

func get_action_name(): return self.name


func init(actor, world_state) -> void:
	_actor = actor
	_world_state = world_state


func is_valid() -> bool:
	return true


func get_priority() -> int:
	return priority


func get_desired_state() -> Dictionary:
	return desired_state
