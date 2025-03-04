class_name SleepGoal
extends GoapGoal

func is_valid() -> bool:
	var entities = _actor.find_entities("house")
	if entities.is_empty():
		return false
	return true

func get_priority() -> int:
	return priority


func get_desired_state() -> Dictionary:
	return desired_state
