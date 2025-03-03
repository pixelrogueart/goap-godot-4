class_name TreeEntity
extends Node2D

var health: int = 3

func _ready() -> void:
	$ChoppedSprite2D.hide()

func update_state() -> void:
	if health > 0:
		$ChoppedSprite2D.hide()
		$GrownSprite2D.show()
	else:
		$ChoppedSprite2D.show()
		$GrownSprite2D.hide()

func chop():
	health -= 1 
	update_state()
	$AnimationPlayer.play("chop")
	return health <= 0
