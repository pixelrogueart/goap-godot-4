class_name ItemEntity
extends Entity

@export var item_id: String


func grab(entity: PawnEntity):
	available = false
	entity.hauled_item = self
	return true


func drop(entity: PawnEntity):
	available = true
	entity.hauled_item = null
	return true
