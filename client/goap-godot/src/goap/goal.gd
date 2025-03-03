class_name GoapGoal
extends Node


var _world_state: GoapWorldState

func is_valid() -> bool:
	return true


func priority() -> int:
	return 1


func get_desired_state() -> Dictionary:
	return {}
