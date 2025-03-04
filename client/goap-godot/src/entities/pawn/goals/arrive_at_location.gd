class_name ArriveAtLocationGoal
extends GoapGoal

func is_valid() -> bool:
	if not "arrive_location" in _world_state._state:
		return false
	return _actor.world_node.is_at_grid_position(_actor, _world_state.get_state("arrive_location"))


func get_priority() -> int:
	return priority


func get_desired_state() -> Dictionary:
	return desired_state
