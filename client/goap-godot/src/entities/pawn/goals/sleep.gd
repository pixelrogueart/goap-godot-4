class_name SleepGoal
extends GoapGoal


func is_valid() -> bool:
	var entities = _actor.find_entities("house")
	if entities.is_empty():
		return false
	if !_world_state.get_state("tired", false):
		return false
	return true


func get_priority() -> int:
	var priority = 0 if _world_state.get_state("energy", 100) > 15 else 2
	return priority


func get_desired_state() -> Dictionary:
	return desired_state
