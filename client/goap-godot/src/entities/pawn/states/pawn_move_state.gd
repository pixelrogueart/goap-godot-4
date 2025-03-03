class_name PawnMoveState
extends PawnBaseState

@export var move_speed: int = 128


func enter() -> void:
	update_step_position()
	super.enter()


func physics_process(_delta: float) -> void:
	super.physics_process(_delta)
	var direction = (_pawn.step_position - _pawn.global_position).normalized()
	_pawn.velocity = direction * move_speed
	if _pawn.world_node.is_at_grid_position(_pawn, _pawn.step_position) and _pawn.global_position.distance_to(_pawn.step_position) <= _pawn.reach_distance:
		_pawn.global_position = _pawn.step_position
		_pawn.velocity = Vector2.ZERO
		_pawn.calculate_path(_pawn.target_position)
		if _pawn.path.size() > 0:
			update_step_position()
			_pawn.path.remove_at(0)
	_pawn.move_and_slide()


	if _pawn.has_reached_target():
		_pawn.tween_to_target()
		_pawn.change_state("Idle")
		return


func process(_delta: float) -> void:
	super.process(_delta)


func input(_event: InputEvent) -> void:
	super.input(_event)


func exit() -> void:
	super.exit()


func update_step_position():
	if _pawn.path.size() <= 1:
		_pawn.velocity = Vector2.ZERO
		return
	var next_grid_pos = _pawn.path[0 + 1]
	_pawn.step_position = _pawn.world_node.get_point_position(next_grid_pos)
