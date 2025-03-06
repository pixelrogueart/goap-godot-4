class_name BuildGoal
extends GoapGoal


func is_valid() -> bool:
	if _actor.world_node.build_queue.size() > 0:
		## Generate build preconditions here
		var build_data = _actor.world_node.build_queue[_actor.world_node.build_queue.keys()[0]]
		if !build_data.entity.finished:
			_actor.generate_build_preconditions(build_data)
			return true
	return false
