extends GoapGoal

func _ready() -> void:
	desired_state = {ExampleStateKeys.FIRE_LIT: true}

func is_valid() -> bool:
	if not _world_state:
		return false
	return not _world_state.get_state(ExampleStateKeys.FIRE_LIT, false)

func get_priority() -> int:
	return 5

func on_goal_achieved() -> void:
	pass
