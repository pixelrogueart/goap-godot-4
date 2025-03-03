class_name SleepGoal
extends GoapGoal

func is_valid() -> bool:
	return _actor.world_node.is_at_grid_position(_actor, _world_state._state["target_position"])


func get_priority() -> int:
	return priority


func get_desired_state() -> Dictionary:
	return desired_state
