class_name StorageEntity
extends Entity


var wood_amount = 0
var storage_space = 3


func insert_wood(entity: Entity):
	wood_amount += 1
	update_state()
	print("Inserted Wood! Wood amount: %s"%wood_amount)
	return storage_space <= wood_amount


func update_state() -> void: 
	if wood_amount > 0:
		$Sprite2D/MedievalEnvironment06.show()
	if wood_amount == storage_space:
		$Sprite2D/MedievalEnvironment07.show()


func has_space():
	return wood_amount < storage_space
