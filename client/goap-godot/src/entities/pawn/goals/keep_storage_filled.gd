class_name KeepStorageFilled
extends GoapGoal


func is_valid() -> bool:
	var entities = _actor.find_entities("storage")
	if entities.is_empty():
		return false
	return entities[0].wood_amount < entities[0].storage_space


func get_priority() -> int:
	return priority


func get_desired_state() -> Dictionary:
	return desired_state
