class_name KeepFirepitBurningGoal
extends GoapGoal

func is_valid() -> bool:
	return _actor.find_entities("firepit").size() == 0


func get_priority() -> int:
	return priority


func get_desired_state() -> Dictionary:
	return desired_state
