class_name KeepStorageFilled
extends GoapGoal

func is_valid() -> bool:
	return _actor.find_entities("storage").size() == 0


func get_priority() -> int:
	return priority


func get_desired_state() -> Dictionary:
	return desired_state
