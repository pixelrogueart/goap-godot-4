extends GoapAction
class_name DropAction


@export var target_group: String
@export var item_id: String


@export var method_interaction: String
@export var validation_method: String


var drop_location: Vector2


func is_valid() -> bool:
	return true


func get_cost(blackboard) -> int:
	if blackboard.has("global_position"):
		var closest_entity = _actor.find_closest_entity(target_group)
		return int(closest_entity.global_position.distance_to(blackboard.global_position) / 7)
	return cost


func perform(actor, delta) -> bool:
	var _closest_entity = _actor.find_closest_entity(target_group)
	if _closest_entity:
		if actor.world_node.is_next_to_grid_position(actor,_closest_entity.global_position):
			_actor.stop_moving()
			if _actor.hauled_item:
				if _closest_entity.has_space(actor):
					var item:ItemEntity = _actor.hauled_item
					_actor.hauled_item.drop(_actor)
					_closest_entity.store_item(actor, item)
					item.tween_to_position(_closest_entity.global_position, 0.3)
					_world_state.set_state("has_item", false)
					#set_effects()
					return true
				else:
					_world_state.set_state("storage_filled", true)
					return true
			return false
		else:
			if actor.current_state != "Move":
				actor.set_target_to_entity(_closest_entity.global_position)
	return false
