class_name RockEntity
extends Entity

@onready var stone_scene = load("res://src/entities/item/item.tscn")
@export var material_drop: String = "stone"
@export var material_provider_method: String = "mine"
@export var interaction_cost: int = 5
@export var interaction_time: float = 1.0
var health: int = 3


func mine(entity: Entity):
	health -= 1 
	$AnimationPlayer.play("mine")
	if health <= 0:
		var stone = stone_scene.instantiate()
		world_node.entities_layer.add_child(stone)
		stone.global_position = self.global_position
		stone.world_node = world_node
		stone.item_id = "stone"
		stone.set_icon(load("res://assets/kenney-medieval-rts/PNG/Default size/Environment/medievalEnvironment_07.png"))
		self.queue_free()
	return health <= 0


func is_available(entity: Entity) -> bool:
	return health > 0
