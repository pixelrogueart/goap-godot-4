class_name TreeEntity
extends Entity

@onready var log_scene = load("res://src/entities/item/item.tscn")

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


func chop(entity: Entity):
	health -= 1 
	update_state()
	$AnimationPlayer.play("chop")
	if health <= 0:
		var log = log_scene.instantiate()
		world_node.entities_layer.add_child(log)
		log.global_position = self.global_position
		log.world_node = world_node
		log.item_id = "wood"
	return health <= 0


func is_available(entity: Entity) -> bool:
	return health > 0


func _process(delta: float) -> void:
	if self.health > 0:
		world_node.world_state.set_state("has_available_tree", true)
