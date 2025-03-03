extends GoapAction
class_name ObserveAction


@export var target_group: String
@export var target_property: String

func is_valid() -> bool:
	return _actor.find_entities(target_group).size() > 0


func get_cost(blackboard) -> int:
	return cost


func get_preconditions() -> Dictionary:
	return preconditions


func get_effects() -> Dictionary:
	return effects


func perform(actor, delta) -> bool:
	var _entity = _actor.find_entities(target_group)
	_world_state.set_state(target_group, _entity.size())
	return true
