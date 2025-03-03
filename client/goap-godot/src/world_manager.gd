class_name WorldManager
extends Node2D

@export var tree_amount: int = 5
@export var draw_grid: bool = false

@onready var floor_layer: TileMapLayer = %FloorLayer
@onready var entities_layer: Node2D = %EntitiesLayer

var tree_scene = load("res://src/entities/tree.tscn")
var house_scene = load("res://src/entities/house.tscn")

var cell_size: int = 64
var grid: AStarGrid2D = AStarGrid2D.new()

var mouse_position:Vector2 = Vector2.ZERO
var last_pawn_position:Vector2 = Vector2.ZERO

func _ready() -> void:
	_generate_world()
	_generate_grid()
	_setup_entities()


func _draw() -> void:
	draw_circle(mouse_position, 3, Color.GRAY)  
	if draw_grid:
		for x in range(grid.region.size.x):
			for y in range(grid.region.size.y):
				var id = Vector2i(x, y)
				if grid.is_in_boundsv(id):
					var point_pos = get_point_position(id)
					if grid.is_point_solid(id):
						draw_circle(point_pos, 3, Color.RED)
					else:
						var color = Color.GRAY
						color.a = 0.5
						draw_circle(point_pos, 2, color)

func _setup_entities():
	for entity: Node2D in entities_layer.get_children():
		entity.global_position = snap_to_grid(entity.global_position)
		entity.world_node = self


func _generate_grid() -> void:
	var used_cells = floor_layer.get_used_cells()
	if used_cells.is_empty():
		return

	var min_x = used_cells[0].x
	var min_y = used_cells[0].y
	var max_x = used_cells[0].x
	var max_y = used_cells[0].y

	for cell in used_cells:
		min_x = min(min_x, cell.x)
		min_y = min(min_y, cell.y)
		max_x = max(max_x, cell.x)
		max_y = max(max_y, cell.y)

	var world_size = Vector2i(max_x - min_x + 1, max_y - min_y + 1)

	grid.region = Rect2i(0, 0, world_size.x, world_size.y)
	grid.cell_size = Vector2(cell_size, cell_size)
	grid.update()


func _generate_world():
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = snap_to_grid(get_global_mouse_position())
		queue_redraw()


func snap_to_grid(global_pos: Vector2) -> Vector2:
	var local_pos = to_local(global_pos)
	return to_global(Vector2(
		floor(local_pos.x / cell_size) * cell_size + cell_size / 2,
		floor(local_pos.y / cell_size) * cell_size + cell_size / 2
	))


func to_grid_coords(global_pos: Vector2) -> Vector2i:
	var local_pos = to_local(global_pos)
	return Vector2i(local_pos / cell_size)


func get_point_position(grid_pos: Vector2i) -> Vector2:
	var local_pos = Vector2(grid_pos) * Vector2(cell_size, cell_size) + Vector2(cell_size, cell_size) / 2
	return to_global(local_pos)


func to_grid_id(global_pos: Vector2) -> Vector2i:
	var local_pos = to_local(global_pos)
	return Vector2i(local_pos / cell_size)


func is_at_grid_position(node: Node2D, _position: Vector2) -> bool:
	var target_id = to_grid_id(_position)
	var pawn_id = to_grid_id(node.global_position)
	return target_id == pawn_id


func is_next_to_grid_position(node: Node2D, target_point: Vector2) -> bool:
	var target_id = to_grid_id(target_point)
	var pawn_id = to_grid_id(node.global_position)
	
	if abs(target_id.x - pawn_id.x) > 1 or abs(target_id.y - pawn_id.y):
		return false
	return true
