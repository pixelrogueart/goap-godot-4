class_name ItemEntity
extends Entity

@export var item_id: String


func set_icon(texture: CompressedTexture2D) -> void:
	$Sprite2D.texture = texture

func grab(entity: PawnEntity):
	available = false
	entity.hauled_item = self
	return true


func drop(entity: PawnEntity):
	entity.hauled_item = null
	var blueprint = world_node.get_entity_at_position(self.global_position, "blueprint")
	if blueprint:
		blueprint.place_item(self)
	return true
