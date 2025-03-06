class_name BlueprintEntity
extends Entity

var items_gathered: Dictionary
var items_needed: Dictionary

var finished = false

func set_icon(image):
	$Sprite2D.texture = image

func get_next_item():
	for i in items_needed.keys():
		var needed = items_needed[i]
		var current_amount = items_gathered[i]
		if current_amount > needed:
			continue
		return i

func place_item(item: ItemEntity):
	if item.item_id in items_needed.keys():
		item.available = false
		items_gathered[item.item_id] += 1

func build(entity: Entity):
	finished = true
	return true
