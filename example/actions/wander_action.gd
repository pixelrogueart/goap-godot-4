extends GoapAction

const MARGIN = 60.0

func _ready() -> void:
	effects = {ExampleStateKeys.HAS_WANDERED: true}

func enter() -> void:
	var viewport_size = _actor.get_viewport_rect().size
	var target = Vector2(
		randf_range(MARGIN, viewport_size.x - MARGIN),
		randf_range(MARGIN, viewport_size.y - MARGIN)
	)
	_actor.move_to(target)

func perform(_delta) -> bool:
	return _actor.has_reached_target()

func get_cost(_blackboard) -> int:
	return 1
