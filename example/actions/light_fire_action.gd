extends GoapAction

const LIGHT_DURATION = 1.0

var _timer := 0.0

func _ready() -> void:
	effects = {ExampleStateKeys.FIRE_LIT: true}
	preconditions = {ExampleStateKeys.HAS_WOOD: true}

func enter() -> void:
	_timer = 0.0
	_actor.move_to(_actor.campfire_position)

func perform(delta) -> bool:
	if not _actor.has_reached_target():
		return false
	_timer += delta
	return _timer >= LIGHT_DURATION

func exit() -> void:
	_actor.light_fire()

func get_cost(_blackboard) -> int:
	return 2
