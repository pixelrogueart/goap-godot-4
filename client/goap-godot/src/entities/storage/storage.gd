class_name StorageEntity
extends Entity


var item_amount = 0
var storage_space = 3


func store_item(entity: Entity, item_id):
	item_amount += 1
	entity.world_state.set_state("holding_item", false)
	return storage_space <= item_amount


func can_store(entity: Entity):
	var has_space = item_amount < storage_space
	return has_space


func has_space(entity: Entity):
	return item_amount < storage_space
