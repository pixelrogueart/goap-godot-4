class_name HaulGoal
extends GoapGoal


func is_valid() -> bool:
	var entities = _actor.find_entities("storage")
	if entities.is_empty():
		return false
	for i in entities:
		if i.has_space(_actor):
			return true
	return false
