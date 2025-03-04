class_name SleepGoal
extends GoapGoal


func is_valid() -> bool:
	var entities = _actor.find_entities("house")
	if entities.is_empty():
		return false
	if !_world_state.get_state("tired") and !_world_state.get_state("sleeping"):
		return false
	return true


func get_priority() -> int:
	var sleeping = _world_state.get_state("sleeping", false)
	var tired = _world_state.get_state("tired", false)
	if sleeping:
		return 2
	if tired:
		return 2
	if !tired and _world_state.get_state("energy") < 50:
		return 1
	return priority


func get_desired_state() -> Dictionary:
	return desired_state
