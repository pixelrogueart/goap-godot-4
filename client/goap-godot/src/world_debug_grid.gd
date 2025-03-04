extends Node2D

var grid_size = Vector2i(64, 64)
var cell_length = 64


func _ready():
	#add_labels()
	queue_redraw()


func _process(delta):
	pass


func _draw():
	# Background
	draw_rect(Rect2(0, 0, grid_size.x * cell_length, grid_size.y * cell_length), Color.GRAY, false)

	# Draw vertical lines
	for i in range(grid_size.x + 1):  # +1 to draw the last border line
		var from = Vector2(i * cell_length, 0)
		var to = Vector2(from.x, grid_size.y * cell_length)
		draw_line(from, to, Color.BLACK, 1)

	# Draw horizontal lines
	for i in range(grid_size.y + 1):  # +1 to draw the last border line
		var from = Vector2(0, i * cell_length)
		var to = Vector2(grid_size.x * cell_length, from.y)
		draw_line(from, to, Color.BLACK, 1)


func add_labels():
	for x in grid_size.x:
		for y in grid_size.y:
			var index_label = Label.new()
			index_label.position = Vector2(x * grid_size.x, y * grid_size.y)
			index_label.text = "(" + str(x) + "," + str(y) + ")"
			add_child(index_label)
			
			var value_label = Label.new()
			value_label.position = Vector2(x * cell_length + 5, y * cell_length + 25)
			value_label.text = "0"
			add_child(value_label)
			var current_grid = Vector2(x, y)
			var distance_from_center = current_grid.direction_to(Vector2(4, 4))
			var snapped_value = snapped(min(abs(distance_from_center.x), abs(distance_from_center.y)), 0.01)
			value_label.text = str(snapped_value)
