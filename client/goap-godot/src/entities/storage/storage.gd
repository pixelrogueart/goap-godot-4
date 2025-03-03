class_name StorageEntity
extends Node2D


var wood_amount = 0
var storage_space = 10


func insert_wood():
	wood_amount += 1
	update_state()
	print("Inserted Wood! Wood amount: %s"%wood_amount)
	return storage_space < wood_amount


func update_state() -> void: 
	if wood_amount > 0:
		$Sprite2D/MedievalEnvironment06.show()
	if wood_amount > 5:
		$Sprite2D/MedievalEnvironment07.show()
