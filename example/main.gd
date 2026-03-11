extends Node2D

const BG_COLOR = Color(0.08, 0.1, 0.12)

const TREE_TRUNK_COLOR = Color(0.45, 0.3, 0.15)
const TREE_LEAF_COLOR = Color(0.15, 0.55, 0.2)
const TREE_LEAF_DARK = Color(0.1, 0.4, 0.15)

const PREY_BODY_COLOR = Color(0.75, 0.6, 0.4)
const PREY_EAR_COLOR = Color(0.85, 0.7, 0.5)

const FIRE_RING_COLOR = Color(0.35, 0.3, 0.25)
const FIRE_STONE_COLOR = Color(0.3, 0.28, 0.22)

const RESPAWN_INTERVAL = 8.0

var _npc: Node2D
var _tree_respawn_timer := 0.0
var _prey_respawn_timer := 0.0

var _initial_tree_positions = [
	Vector2(120, 130), Vector2(180, 280), Vector2(80, 420),
	Vector2(250, 100), Vector2(300, 380), Vector2(150, 520),
]

var _initial_prey_positions = [
	Vector2(750, 120), Vector2(850, 300), Vector2(700, 450),
	Vector2(900, 180), Vector2(800, 500),
]

var _campfire_pos = Vector2(500, 320)


func _ready():
	_spawn_npc()


func _process(delta):
	_respawn_resources(delta)
	queue_redraw()


func _spawn_npc():
	var NpcScene = preload("res://example/npc.gd")
	_npc = NpcScene.new()
	_npc.name = "NPC"
	_npc.tree_positions = _initial_tree_positions.duplicate()
	_npc.prey_positions = _initial_prey_positions.duplicate()
	_npc.campfire_position = _campfire_pos
	_npc.global_position = Vector2(500, 300)
	add_child(_npc)


func _respawn_resources(delta):
	_tree_respawn_timer += delta
	_prey_respawn_timer += delta

	if _tree_respawn_timer >= RESPAWN_INTERVAL and _npc.tree_positions.size() < _initial_tree_positions.size():
		for pos in _initial_tree_positions:
			if not _npc.tree_positions.has(pos):
				_npc.tree_positions.append(pos)
				_tree_respawn_timer = 0.0
				break

	if _prey_respawn_timer >= RESPAWN_INTERVAL and _npc.prey_positions.size() < _initial_prey_positions.size():
		for pos in _initial_prey_positions:
			if not _npc.prey_positions.has(pos):
				_npc.prey_positions.append(pos)
				_prey_respawn_timer = 0.0
				break


func _draw():
	var viewport_size = get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), BG_COLOR)
	_draw_ground_patches()
	for pos in _npc.tree_positions:
		_draw_tree(pos)
	for pos in _npc.prey_positions:
		_draw_prey(pos)
	_draw_campfire(_campfire_pos)


func _draw_ground_patches():
	var grass_color = Color(0.1, 0.15, 0.1, 0.3)
	var patches = [Vector2(200, 300), Vector2(600, 200), Vector2(400, 480), Vector2(800, 400)]
	for p in patches:
		draw_circle(p, 60, grass_color)


func _draw_tree(pos: Vector2):
	draw_rect(Rect2(pos + Vector2(-4, -5), Vector2(8, 25)), TREE_TRUNK_COLOR)
	var layers = [
		{"offset": Vector2(0, -28), "size": 22.0, "color": TREE_LEAF_DARK},
		{"offset": Vector2(0, -22), "size": 18.0, "color": TREE_LEAF_COLOR},
		{"offset": Vector2(0, -32), "size": 14.0, "color": TREE_LEAF_COLOR.lightened(0.15)},
	]
	for layer in layers:
		var center = pos + layer.offset
		var tri = PackedVector2Array([
			center + Vector2(0, -layer.size),
			center + Vector2(-layer.size * 0.8, layer.size * 0.5),
			center + Vector2(layer.size * 0.8, layer.size * 0.5),
		])
		draw_colored_polygon(tri, layer.color)


func _draw_prey(pos: Vector2):
	draw_circle(pos, 10, PREY_BODY_COLOR)
	draw_circle(pos + Vector2(-5, -8), 4, PREY_EAR_COLOR)
	draw_circle(pos + Vector2(5, -8), 4, PREY_EAR_COLOR)
	draw_circle(pos + Vector2(-3, -2), 2, Color(0.15, 0.15, 0.2))
	draw_circle(pos + Vector2(3, -2), 2, Color(0.15, 0.15, 0.2))


func _draw_campfire(pos: Vector2):
	for i in range(8):
		var angle = i * TAU / 8.0
		var stone_pos = pos + Vector2(cos(angle), sin(angle)) * 20
		draw_circle(stone_pos, 5, FIRE_STONE_COLOR)

	if _npc.fire_fuel > 0:
		var intensity = _npc.fire_fuel
		var flame_colors = [
			Color(1.0, 0.3, 0.05, 0.6 * intensity),
			Color(1.0, 0.6, 0.1, 0.7 * intensity),
			Color(1.0, 0.85, 0.2, 0.5 * intensity),
		]
		draw_circle(pos, 12 * intensity, flame_colors[0])
		draw_circle(pos + Vector2(0, -4), 8 * intensity, flame_colors[1])
		draw_circle(pos + Vector2(0, -8), 5 * intensity, flame_colors[2])

		var glow = Color(1.0, 0.5, 0.1, 0.08 * intensity)
		draw_circle(pos, 50 * intensity, glow)
	else:
		draw_circle(pos, 6, Color(0.2, 0.18, 0.15))
		draw_circle(pos + Vector2(-3, 2), 3, Color(0.15, 0.13, 0.1))
