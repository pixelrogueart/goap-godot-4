class_name StorageEntity
extends Entity


var item_amount = 0
var storage_space = 3
var item: ItemEntity

func store_item(entity: Entity, _item):
	item_amount += 1
	item = _item
	item.available = false
	return storage_space <= item_amount


func can_store(entity: Entity):
	var has_space = item_amount < storage_space
	return has_space


func has_space(entity: Entity):
	return item_amount < storage_space
