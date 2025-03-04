class_name MoveGoal
extends GoapGoal

func is_valid() -> bool:
	if not "arrive_location" in _world_state._state:
		return false
	if not "arrived_at_location" in _world_state._state:
		return false
	if _world_state.get_state("arrived_at_location"):
		return false
	return true
