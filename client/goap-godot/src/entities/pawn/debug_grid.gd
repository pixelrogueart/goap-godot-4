extends Node2D

var path = []
var mouse_position:Vector2 = Vector2.ZERO
var last_pawn_position:Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	if last_pawn_position != owner.global_position:
		queue_redraw()
		last_pawn_position = owner.global_position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = owner.world_node.snap_to_grid(get_global_mouse_position())
		queue_redraw()

func _draw() -> void:
	draw_circle(owner.world_node.snap_to_grid(owner.global_position), 3, Color.WHITE)  
	# Draw snapped mouse position
	draw_circle(mouse_position, 3, Color.GRAY) 
	## Draw path with center-aligned tiles
	if owner.path.size() > 1:
		var end_pos = owner.world_node.get_point_position(owner.path[owner.path.size()-1])
		var next_pos = owner.world_node.get_point_position(owner.path[0])
		#var end_pos = Game.game_world.get_point_position(path[path.size()-1])
		draw_circle(end_pos, 3, Color.GREEN)
		draw_circle(next_pos, 3, Color.YELLOW)
		for i in range(owner.path.size() - 1):
			var start_pos = owner.world_node.get_point_position(owner.path[i])
			end_pos = owner.world_node.get_point_position(owner.path[i + 1])
			draw_line(start_pos, end_pos, Color.WHITE, 1)
