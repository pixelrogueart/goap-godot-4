extends GoapAction

const COOK_DURATION = 2.0

var _timer := 0.0

func _ready() -> void:
	effects = {ExampleStateKeys.HAS_COOKED_FOOD: true}
	preconditions = {ExampleStateKeys.HAS_RAW_FOOD: true, ExampleStateKeys.FIRE_LIT: true}

func enter() -> void:
	_timer = 0.0
	_actor.move_to(_actor.campfire_position)

func perform(delta) -> bool:
	if not _actor.has_reached_target():
		return false
	_timer += delta
	return _timer >= COOK_DURATION

func get_cost(_blackboard) -> int:
	return 2
