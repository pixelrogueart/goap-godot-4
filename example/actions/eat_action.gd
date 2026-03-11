extends GoapAction

const EAT_DURATION = 1.5

var _timer := 0.0

func _ready() -> void:
	effects = {ExampleStateKeys.IS_FED: true}
	preconditions = {ExampleStateKeys.HAS_COOKED_FOOD: true}

func enter() -> void:
	_timer = 0.0

func perform(delta) -> bool:
	_timer += delta
	_actor.hunger = max(_actor.hunger - delta * 0.4, 0.0)
	return _timer >= EAT_DURATION

func get_cost(_blackboard) -> int:
	return 1
