extends GoapAction
class_name InteractAction


@export var target_group: String
@export var method_interaction: String


func is_valid() -> bool:
	return _actor.find_entities(target_group).size() > 0


func get_cost(blackboard) -> int:
	if blackboard.has("global_position"):
		var closest_entity = _actor.find_closest_entity(target_group)
		return int(closest_entity.global_position.distance_to(blackboard.global_position) / 7)
	return cost


func get_preconditions() -> Dictionary:
	return preconditions


func get_effects() -> Dictionary:
	return effects


func perform(actor, delta) -> bool:
	var _closest_entity = _actor.find_closest_entity(target_group)
	if _closest_entity:
		if actor.world_node.is_next_to_grid_position(actor, _closest_entity.global_position):
			if _closest_entity.call(method_interaction):
				return true
			return false
		else:
			if actor.current_state != "Move":
				actor.set_move_target(_closest_entity.global_position)
	return false
