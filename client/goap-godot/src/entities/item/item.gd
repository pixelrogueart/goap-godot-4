class_name ItemEntity
extends Entity

@export var item_id: String
var available: bool = true


func grab(entity: PawnEntity):
	available = false
	entity.hauled_item = self
	return true


func drop(entity: PawnEntity):
	available = true
	entity.hauled_item = null
	return true


func is_available(entity: PawnEntity):
	return available
