extends GoapAction
class_name MoveToAction


func is_valid() -> bool:
	if "arrive_location" in _world_state._state:
		return true
	return false


func get_cost(_blackboard) -> int:
	return cost


func perform(actor, delta) -> bool:
	if actor.world_node.is_at_grid_position(actor, _world_state.get_state("arrive_location")):
		set_effects()
		return true
	actor.set_move_target(_world_state.get_state("arrive_location"))
	return false
