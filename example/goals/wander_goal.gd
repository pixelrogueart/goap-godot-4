extends GoapGoal

func _ready() -> void:
	desired_state = {ExampleStateKeys.HAS_WANDERED: true}
	priority = 1

func on_goal_achieved() -> void:
	_world_state.set_state(ExampleStateKeys.HAS_WANDERED, false)
