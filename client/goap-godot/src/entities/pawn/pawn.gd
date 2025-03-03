class_name PawnEntity
extends CharacterBody2D

@onready var debug_state_label = %DebugStateLabel
@onready var debug_goap_label = %DebugGoapAction

@export var state_manager: StateManager
@export var reach_distance: int = 5

var world_node: WorldManager

var path: PackedVector2Array = []  # Stores the path for movement
var step_position = null
var target_position = null

var current_state: String


func _ready():
	state_manager.init(self)


func change_state(new_state: String):
	if current_state == new_state:
		return

	var node = state_manager.get_node(new_state)
	if not node:
		printerr("%s state not found."%new_state)
		return

	state_manager.change_state(node)
	current_state = new_state
	debug_state_label.text = current_state
	return node


func _unhandled_input(event: InputEvent) -> void:
	state_manager.input(event)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			set_move_target(get_global_mouse_position())


func _process(delta: float) -> void:
	state_manager.process(delta)


func _physics_process(delta: float) -> void:
	state_manager.physics_process(delta)


func has_path() -> bool:
	return path.size() > 0


func find_closest_entity(target_group: String): 
	pass


func find_entities(target_group: String) -> Array: 
	return []


func is_next_to_target() -> bool:
		#var targe_id = tile_map.local_to_map(target_point)
	var target_id = world_node.to_grid_id(target_position)
	#var pawn_id = tile_map.local_to_map(_pawn.global_position)
	var pawn_id = world_node.to_grid_id(global_position)
	if abs(target_id.x - pawn_id.x) > 1 or abs(target_id.y - pawn_id.y):
		return false
	return true


func has_reached_target() -> bool:
	return world_node.is_at_grid_position(self, target_position)


func tween_to_target(_speed = 0.3) -> void:
	var new_position = world_node.snap_to_grid(global_position)
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", new_position, _speed)


func calculate_path(target_pos: Vector2) -> Array:
	var start_id = world_node.to_grid_id(global_position)
	var end_id = world_node.to_grid_id(target_pos)
	var calculated_path = []
	target_position = target_pos
	if world_node.grid.is_in_boundsv(start_id) and world_node.grid.is_in_boundsv(end_id):
		calculated_path = world_node.grid.get_id_path(start_id, end_id)
	return calculated_path


func set_move_target(_new_target) -> void:
	var _target_position = null
	_target_position = _new_target
	path = calculate_path(_new_target)
	if path:
		change_state("Move")
