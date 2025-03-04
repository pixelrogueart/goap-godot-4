class_name StorageEntity
extends Entity


var item_amount = 0
var storage_space = 3


func store_item(entity: Entity, item_id):
	item_amount += 1
	entity.world_state.set_state("holding_item", false)
	update_state()
	return storage_space <= item_amount


func update_state() -> void: 
	if item_amount > 0:
		$Sprite2D/MedievalEnvironment06.show()
	if item_amount == storage_space:
		$Sprite2D/MedievalEnvironment07.show()


func can_store(entity: Entity):
	var has_space = item_amount < storage_space
	return has_space


func has_space(entity: Entity):
	return item_amount < storage_space
