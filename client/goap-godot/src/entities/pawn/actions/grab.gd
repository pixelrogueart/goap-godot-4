extends GoapAction
class_name GrabAction


@export var target_group: String
@export var item_id: String


@export var method_interaction: String
@export var validation_method: String


var grab_location: Vector2


func is_valid() -> bool:
	return true


func get_cost(blackboard) -> int:
	if blackboard.has("global_position"):
		var closest_entity = _actor.find_closest_entity(target_group)
		if closest_entity:
			return int(closest_entity.global_position.distance_to(blackboard.global_position) / 7)
	return cost


func call_validation_method(_entity):
	if !validation_method:
		return true
	return _entity.call(validation_method)


func perform(actor, delta) -> bool:
	var _closest_entity = _actor.find_closest_entity(target_group)
	if _closest_entity and call_validation_method(_closest_entity):
		if actor.world_node.is_next_to_grid_position(actor,_closest_entity.global_position):
			_actor.stop_moving()
			if _closest_entity.call(method_interaction, actor):
				set_effects()
				var _entities = _actor.find_entities(target_group)
				_world_state.set_state("has_available_item", false)
				for item in _entities:
					if item.item_id == item_id:
						if item.is_available():
							_world_state.set_state("has_available_item", true)
						break
				return true
			return false
		else:
			if actor.current_state != "Move":
				actor.set_target_to_entity(_closest_entity.global_position)
	return false
