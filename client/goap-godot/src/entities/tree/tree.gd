class_name TreeEntity
extends Node2D

var health: int = 3

func can_chop() -> bool:
	return health > 0

func chop():
	health -= 1 
	print("CHOPPED TREE!")
