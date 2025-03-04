extends GoapAction
class_name InteractAction


@export var target_group: String

@export var method_interaction: String
@export var validation_method: String

@export var interaction_cooldown: float = 1.0

var cooldown_timer: Timer = Timer.new()

func _ready() -> void:
	add_child(cooldown_timer)
	cooldown_timer.one_shot = true

func is_valid() -> bool:
	var target_group_entities = _actor.find_entities(target_group)
	if _actor.find_entities(target_group).size() < 0:
		return false
	if validation_method:
		return call_validation_method(target_group_entities[0])
	return true


func get_cost(blackboard) -> int:
	if blackboard.has("global_position"):
		var closest_entity = _actor.find_closest_entity(target_group)
		return int(closest_entity.global_position.distance_to(blackboard.global_position) / 7)
	return cost


func call_validation_method(_entity):
	if !validation_method:
		return true
	return _entity.call(validation_method)


func perform(actor, delta) -> bool:
	var _closest_entity = _actor.find_closest_entity(target_group)
	if _closest_entity and call_validation_method(_closest_entity):
		var arrived = false
		if _closest_entity.is_solid:
			arrived = actor.world_node.is_next_to_grid_position(actor,_closest_entity.global_position)
		else:
			arrived = actor.world_node.is_at_grid_position(actor, _closest_entity.global_position)
		if arrived:
			_actor.stop_moving()
			if cooldown_timer.is_stopped():
				if _closest_entity.call(method_interaction, actor):
					set_effects()
					return true
				cooldown_timer.start(interaction_cooldown)
			return false
		else:
			if actor.current_state != "Move":
				if _closest_entity.is_solid:
					actor.set_target_to_entity(_closest_entity.global_position)
				else:
					actor.set_move_target(_closest_entity.global_position)
	return false
