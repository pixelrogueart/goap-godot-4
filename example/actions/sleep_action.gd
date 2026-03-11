extends GoapAction

const SLEEP_DURATION = 3.0

var _timer := 0.0

func _ready() -> void:
	effects = {ExampleStateKeys.IS_RESTED: true}

func enter() -> void:
	_timer = 0.0

func perform(delta) -> bool:
	_timer += delta
	_actor.tiredness = max(_actor.tiredness - delta * 0.3, 0.0)
	return _timer >= SLEEP_DURATION

func get_cost(_blackboard) -> int:
	return 1
