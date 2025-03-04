class_name PawnEntity
extends Entity

@onready var debug_state_label = %DebugStateLabel
@onready var debug_goap_label = %DebugGoapAction
@onready var debug_goal_goap_label = %DebugGoalGoapLabel

@export var state_manager: StateManager
@export var goap_agent: GoapAgent
@export var reach_distance: int = 5


var world_state: GoapWorldState = GoapWorldState.new()

var path: PackedVector2Array = []  # Stores the path for movement
var step_position = null
var target_position = null

var current_state: String

var hauled_item: ItemEntity



func _ready():
	state_manager.init(self)
	goap_agent.init(self)
	world_state.set_state("has_item", false)
	world_state.set_state("has_available_space", true)
	world_state.set_state("tired", false)
	world_state.set_state("energy", 0)


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
			goap_agent._world_state.set_state("arrived_at_location", false)
			goap_agent._world_state.set_state("arrive_location", get_global_mouse_position())


func _process(delta: float) -> void:
	super._process(delta)
	if goap_agent._current_plan:
		debug_goap_label.text = goap_agent._current_plan[goap_agent._current_plan_step].name
	else:
		debug_goap_label.text = ""
	if goap_agent._current_goal:
		debug_goal_goap_label.text = goap_agent._current_goal.name
	state_manager.process(delta)
	hold_item()
	DebugManager.debug_node.update_world_log(goap_agent._world_state._state)
	if world_state.get_state("energy") == 0:
		world_state.set_state("tired", true)

func hold_item():
	if hauled_item:
		hauled_item.tween_to_position(self.global_position, 0.1)


func _physics_process(delta: float) -> void:
	state_manager.physics_process(delta)


func has_path() -> bool:
	return path.size() > 0


func find_closest_entity(group_name):
	var elements = find_entities(group_name)
	var closest_element
	var closest_distance = 10000000

	for element in elements:
		var distance = self.global_position.distance_to(element.global_position)
		if  distance < closest_distance and element.is_available():
			closest_distance = distance
			closest_element = element

	return closest_element


func find_entities(target_group: String) -> Array: 
	return get_tree().get_nodes_in_group(target_group)


func is_next_to_target() -> bool:
	var target_id = world_node.to_grid_id(target_position)
	var pawn_id = world_node.to_grid_id(global_position)
	if abs(target_id.x - pawn_id.x) > 1 or abs(target_id.y - pawn_id.y):
		return false
	return true


func has_reached_target() -> bool:
	#print("Reached target: %s"%world_node.is_at_grid_position(self, target_position))
	return world_node.is_at_grid_position(self, target_position)


func stop_moving() -> void:
	tween_to_grid_position(target_position)
	change_state("Idle")


func calculate_path(target_pos: Vector2) -> Array:
	var start_id = world_node.to_grid_id(global_position)
	var end_id = world_node.to_grid_id(target_pos)
	var calculated_path = []
	target_position = target_pos
	if world_node.grid.is_in_boundsv(start_id) and world_node.grid.is_in_boundsv(end_id):
		calculated_path = world_node.grid.get_id_path(start_id, end_id)
	return calculated_path


func set_move_target(_new_target) -> void:
	path = calculate_path(_new_target)
	if path:
		change_state("Move")


func set_target_to_entity(_new_target) -> void:
	var updated_target = world_node.get_point_position(world_node.find_closest_available_position(world_node.to_grid_id(self.global_position), world_node.to_grid_id(_new_target),1))
	path = calculate_path(updated_target)
	if path:
		change_state("Move")
