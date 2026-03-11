extends GoapAction

const CHOP_DURATION = 2.0

var _timer := 0.0

func _ready() -> void:
	effects = {ExampleStateKeys.HAS_WOOD: true}

func enter() -> void:
	_timer = 0.0
	var tree_pos = _actor.get_nearest_tree()
	if tree_pos != Vector2.ZERO:
		_actor.move_to(tree_pos)

func perform(delta) -> bool:
	if not _actor.has_reached_target():
		return false
	_timer += delta
	return _timer >= CHOP_DURATION

func exit() -> void:
	_actor.chop_nearest_tree()

func get_cost(_blackboard) -> int:
	return 3
