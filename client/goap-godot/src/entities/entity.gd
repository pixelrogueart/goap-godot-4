class_name Entity
extends CharacterBody2D

@export var is_solid: bool = true

var world_node: WorldManager
var _last_position: Vector2

func _process(delta: float) -> void:
	if _last_position != global_position:
		if !world_node:
			return
		if is_solid:
			world_node.grid.set_point_solid(world_node.to_grid_coords(_last_position),false)
			world_node.grid.set_point_solid(world_node.to_grid_coords(global_position),true)
		_last_position = global_position
