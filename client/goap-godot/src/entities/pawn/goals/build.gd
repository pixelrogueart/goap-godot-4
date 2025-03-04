class_name BuildGoal
extends GoapGoal


func is_valid() -> bool:
	if _actor.world_node.build_queue.size() > 0:
		return true
	return false
