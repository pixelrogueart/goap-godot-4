extends GoapGoal

func _ready() -> void:
	desired_state = {ExampleStateKeys.IS_FED: true}

func is_valid() -> bool:
	if not _world_state:
		return false
	return _world_state.get_state(ExampleStateKeys.IS_HUNGRY, false)

func get_priority() -> int:
	return 10

func on_goal_achieved() -> void:
	_world_state.set_state(ExampleStateKeys.IS_FED, false)
	_world_state.set_state(ExampleStateKeys.HAS_RAW_FOOD, false)
	_world_state.set_state(ExampleStateKeys.HAS_COOKED_FOOD, false)
	_world_state.set_state(ExampleStateKeys.IS_HUNGRY, false)
