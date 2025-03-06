class_name Entity
extends CharacterBody2D

@export var is_solid: bool = true

var available = true
var world_node: WorldManager
var _last_position: Vector2


func _process(delta: float) -> void:
	if _last_position != global_position:
		if !world_node:
			return
		if is_solid:
			world_node.grid.set_point_solid(world_node.to_grid_coords(global_position),true)
		world_node.grid.set_point_solid(world_node.to_grid_coords(_last_position),false)
		_last_position = global_position


func tween_to_grid_position(_position, _speed = 0.3) -> void:
	if !_position:
		printerr("Position not valid.")
		return
	var new_position = world_node.snap_to_grid(_position)
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", new_position, _speed)

func tween_to_position(_position, _speed = 0.3) -> void:
	if !_position:
		printerr("Position not valid.")
		return
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", _position, _speed)

func is_available(entity: Entity) -> bool:
	return available
