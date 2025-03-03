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
			_actor.stop_moving()
			if cooldown_timer.is_stopped():
				if !_closest_entity.call(validation_method):
					for effect in effects.keys():
						_world_state.set_state(effect, effects[effect])
					return true
				else:
					_closest_entity.call(method_interaction)
					cooldown_timer.start(interaction_cooldown)
			return false
		else:
			if actor.current_state != "Move":
				actor.set_target_to_entity(_closest_entity.global_position)
	return false
