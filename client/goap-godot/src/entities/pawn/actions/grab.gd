extends GoapAction
class_name GrabAction


@export var target_group: String
@export var item_id: String


@export var method_interaction: String
@export var validation_method: String


var grab_location: Vector2


func is_valid() -> bool:
	var target_group_entities = _actor.find_entities(target_group)
	if target_group_entities.size() > 0:
		for i in target_group_entities:
			if i.item_id == item_id and i.is_available():
				return true
	return false


func get_cost(blackboard) -> int:
	if blackboard.has("global_position"):
		var closest_entity = _actor.find_closest_entity(target_group)
		return int(closest_entity.global_position.distance_to(blackboard.global_position) / 7)
	return cost


func call_validation_method(_entity):
	if !validation_method:
		return true
	return _entity.call(validation_method, _actor)


func perform(actor, delta) -> bool:
	var _closest_entity = _actor.find_closest_entity(target_group)
	if _closest_entity and call_validation_method(_closest_entity):
		if actor.world_node.is_next_to_grid_position(actor,_closest_entity.global_position):
			_actor.stop_moving()
			if _closest_entity.call(method_interaction, actor):
				set_effects()
				return true
			return false
		else:
			if actor.current_state != "Move":
				actor.set_target_to_entity(_closest_entity.global_position)
	return false
