extends GoapAction
class_name MoveToAction

@export var target_group: String
@export var move_close: bool 

func get_cost(_blackboard) -> int:
	return cost


func get_preconditions() -> Dictionary:
	return preconditions


func get_effects() -> Dictionary:
	return effects


func perform(actor, delta) -> bool:
	var closest_entity = actor.world_node.get_closest_entity(target_group, actor)

	if closest_entity == null:
		return false

	if move_close:
		if actor.world_node.is_next_to_grid_position(actor, _world_state.get_state("arrive_location")):
			return true
	else:
		if actor.world_node.is_at_grid_position(actor, _world_state.get_state("arrive_location")):
			return true

	actor.set_move_target(closest_entity.global_position)
	return false
