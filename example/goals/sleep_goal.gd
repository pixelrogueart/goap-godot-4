extends GoapGoal

func _ready() -> void:
	desired_state = {ExampleStateKeys.IS_RESTED: true}

func is_valid() -> bool:
	if not _world_state:
		return false
	return _world_state.get_state(ExampleStateKeys.IS_TIRED, false)

func get_priority() -> int:
	return 8

func on_goal_achieved() -> void:
	_world_state.set_state(ExampleStateKeys.IS_RESTED, false)
	_world_state.set_state(ExampleStateKeys.IS_TIRED, false)
