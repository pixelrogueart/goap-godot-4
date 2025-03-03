class_name PawnIdleState
extends PawnBaseState


func enter() -> void:
	_pawn.velocity = Vector2.ZERO
	super.enter()


func physics_process(_delta: float) -> void:
	super.physics_process(_delta)


func process(_delta: float) -> void:
	super.process(_delta)


func input(_event: InputEvent) -> void:
	super.input(_event)


func exit() -> void:
	super.exit()
