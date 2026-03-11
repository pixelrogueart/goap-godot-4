extends GoapAction

const HUNT_DURATION = 1.5

var _timer := 0.0

func _ready() -> void:
	effects = {ExampleStateKeys.HAS_RAW_FOOD: true}

func enter() -> void:
	_timer = 0.0
	var prey_pos = _actor.get_nearest_prey()
	if prey_pos != Vector2.ZERO:
		_actor.move_to(prey_pos)

func perform(delta) -> bool:
	if not _actor.has_reached_target():
		return false
	_timer += delta
	return _timer >= HUNT_DURATION

func exit() -> void:
	_actor.kill_nearest_prey()

func get_cost(_blackboard) -> int:
	return 4
