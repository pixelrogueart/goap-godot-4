class_name ArriveAtLocationGoal
extends GoapGoal

func is_valid() -> bool:
	if not "arrive_location" in _world_state._state:
		return false
	return true


func get_priority() -> int:
	return priority


func get_desired_state() -> Dictionary:
	return desired_state
