class_name StorageEntity
extends Node2D


var wood_amount = 0
var storage_space = 10

func insert_wood():
	wood_amount += 1
	print("Inserted Wood! Wood amount: %s"%wood_amount)

func can_insert_wood() -> bool: 
	return storage_space > wood_amount
