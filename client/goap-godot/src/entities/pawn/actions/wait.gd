extends GoapAction
class_name WaitAction


func get_cost(_blackboard) -> int:
	return 1


func get_preconditions() -> Dictionary:
	return preconditions


func get_effects() -> Dictionary:
	return effects


func perform(actor, _delta) -> bool:
	return actor.change_state("Idle")
