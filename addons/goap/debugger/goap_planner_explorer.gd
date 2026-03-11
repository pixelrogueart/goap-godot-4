@tool
extends HSplitContainer

const SIDEBAR_WIDTH := 260
const NODE_WIDTH := 260.0
const NODE_H_SPACING := 320.0
const NODE_V_SPACING := 60.0
const LABEL_FONT_SIZE := 12

const COLOR_GOAL := Color(0.2, 0.85, 0.6)
const COLOR_ACTION := Color(0.4, 0.5, 0.75)
const COLOR_PRECONDITION := Color(1.0, 0.55, 0.25)
const COLOR_EFFECT := Color(0.25, 0.9, 0.55)
const COLOR_SLOT_IN := Color(0.5, 0.7, 1.0)
const COLOR_SLOT_OUT := Color(0.5, 1.0, 0.7)
const COLOR_SATISFIED := Color(0.2, 0.85, 0.35)
const COLOR_UNSATISFIED := Color(0.85, 0.2, 0.2)

var _goal_list: ItemList
var _graph: GraphEdit
var _graph_nodes: Dictionary = {}
var _goals: Array = []
var _actions: Array = []
var _selected_goal: Dictionary = {}
var _node_counter := 0

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	size_flags_vertical = SIZE_EXPAND_FILL

	var sidebar = PanelContainer.new()
	sidebar.custom_minimum_size.x = SIDEBAR_WIDTH
	sidebar.add_theme_stylebox_override("panel", _make_style(Color(0.06, 0.06, 0.08, 1.0)))
	add_child(sidebar)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	sidebar.add_child(vbox)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 4)
	vbox.add_child(margin)

	var header = Label.new()
	header.text = "GOALS"
	header.add_theme_font_size_override("font_size", 15)
	header.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0))
	margin.add_child(header)

	_goal_list = ItemList.new()
	_goal_list.size_flags_vertical = SIZE_EXPAND_FILL
	_goal_list.item_selected.connect(_on_goal_selected)
	_goal_list.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
	vbox.add_child(_goal_list)

	_graph = GraphEdit.new()
	_graph.size_flags_horizontal = SIZE_EXPAND_FILL
	_graph.size_flags_vertical = SIZE_EXPAND_FILL
	_graph.right_disconnects = false
	_graph.minimap_enabled = true
	_graph.snapping_enabled = false
	_graph.show_grid = true
	_graph.panning_scheme = GraphEdit.SCROLL_ZOOMS
	add_child(_graph)

	split_offset = SIDEBAR_WIDTH


func set_registry(goals: Array, actions: Array) -> void:
	_goals = goals
	_actions = actions
	_rebuild_goal_list()


func _rebuild_goal_list() -> void:
	_goal_list.clear()
	for goal in _goals:
		_goal_list.add_item(goal.name)


func _on_goal_selected(idx: int) -> void:
	if idx < 0 or idx >= _goals.size(): return
	_selected_goal = _goals[idx]
	_rebuild_graph()


func _rebuild_graph() -> void:
	_graph.clear_connections()
	for key in _graph_nodes:
		if is_instance_valid(_graph_nodes[key]):
			_graph_nodes[key].queue_free()
	_graph_nodes.clear()
	_node_counter = 0

	if _selected_goal.is_empty(): return

	var desired_state: Dictionary = _selected_goal.get("desired_state", {})
	if desired_state.is_empty(): return

	var goal_node = _create_goal_node(_selected_goal)
	goal_node.position_offset = Vector2(0, 150)
	_graph.add_child(goal_node)
	_graph_nodes["goal"] = goal_node

	var goal_out_slot = goal_node.get_child_count() - 1
	_build_action_tree(desired_state, "goal", goal_out_slot, 1, {})


func _build_action_tree(required_state: Dictionary, parent_key: String, parent_slot: int, depth: int, visited: Dictionary) -> void:
	var matching_actions = _find_actions_for_state(required_state)
	var y_offset = 0.0
	var start_y = 150.0 - (matching_actions.size() - 1) * NODE_V_SPACING * 0.5

	for action_data in matching_actions:
		var action_name = action_data.name
		if visited.has(action_name): continue

		var node_key = "action_%s_%s" % [_node_counter, action_name]
		_node_counter += 1

		var node = _create_action_node(action_data, required_state)
		node.position_offset = Vector2(depth * NODE_H_SPACING, start_y + y_offset)
		_graph.add_child(node)
		_graph_nodes[node_key] = node

		_graph.connect_node(parent_key, parent_slot, node_key, 0)

		var unmet_preconditions = _get_unmet_preconditions(action_data, required_state)
		if !unmet_preconditions.is_empty():
			var next_visited = visited.duplicate()
			next_visited[action_name] = true
			var out_slot = node.get_child_count() - 1
			_build_action_tree(unmet_preconditions, node_key, out_slot, depth + 1, next_visited)

		y_offset += _estimate_node_height(action_data) + NODE_V_SPACING


func _find_actions_for_state(required_state: Dictionary) -> Array:
	var result: Array = []
	for action in _actions:
		var effects: Dictionary = action.get("effects", {})
		for key in required_state:
			if effects.has(key) and _values_match(effects[key], required_state[key]):
				result.append(action)
				break
	return result


func _get_unmet_preconditions(action_data: Dictionary, _parent_state: Dictionary) -> Dictionary:
	var preconditions: Dictionary = action_data.get("preconditions", {})
	var effects: Dictionary = action_data.get("effects", {})
	var unmet: Dictionary = {}
	for key in preconditions:
		if !effects.has(key):
			unmet[key] = preconditions[key]
	return unmet


func _values_match(a, b) -> bool:
	if typeof(a) == TYPE_STRING and typeof(b) != TYPE_STRING:
		return str(b) == a
	if typeof(b) == TYPE_STRING and typeof(a) != TYPE_STRING:
		return str(a) == b
	return a == b


func _create_goal_node(goal_data: Dictionary) -> GraphNode:
	var node = GraphNode.new()
	node.title = "GOAL: %s" % goal_data.name
	node.name = "goal"
	node.resizable = false
	node.custom_minimum_size.x = NODE_WIDTH

	var desired: Dictionary = goal_data.get("desired_state", {})
	if !desired.is_empty():
		node.add_child(_make_section_label("DESIRED STATE"))
		for key in desired:
			node.add_child(_make_kv_label(key, desired[key], COLOR_PRECONDITION))

	var connector = _make_spacer()
	node.add_child(connector)
	var slot_idx = node.get_child_count() - 1
	node.set_slot(slot_idx, false, 0, Color.WHITE, true, 0, COLOR_SLOT_OUT)

	_apply_node_style(node, COLOR_GOAL)
	return node


func _create_action_node(action_data: Dictionary, satisfying_state: Dictionary) -> GraphNode:
	var node = GraphNode.new()
	var action_name = action_data.get("name", "Action")
	node.title = action_name
	node.name = "action_%s_%s" % [_node_counter, action_name]
	node.resizable = false
	node.custom_minimum_size.x = NODE_WIDTH

	var in_connector = _make_spacer()
	node.add_child(in_connector)
	node.set_slot(0, true, 0, COLOR_SLOT_IN, false, 0, Color.WHITE)

	var cost = action_data.get("cost", 0)
	node.add_child(_make_kv_label("Cost", cost, Color(0.85, 0.85, 0.6)))

	var effects: Dictionary = action_data.get("effects", {})
	if !effects.is_empty():
		node.add_child(_make_section_label("EFFECTS"))
		for key in effects:
			var color = COLOR_SATISFIED if satisfying_state.has(key) else COLOR_EFFECT
			node.add_child(_make_kv_label(key, effects[key], color))

	var preconditions: Dictionary = action_data.get("preconditions", {})
	if !preconditions.is_empty():
		node.add_child(_make_section_label("PRECONDITIONS"))
		for key in preconditions:
			node.add_child(_make_kv_label(key, preconditions[key], COLOR_PRECONDITION))

	var out_connector = _make_spacer()
	node.add_child(out_connector)
	var out_slot = node.get_child_count() - 1
	node.set_slot(out_slot, false, 0, Color.WHITE, true, 0, COLOR_SLOT_OUT)

	_apply_node_style(node, COLOR_ACTION)
	return node


func _estimate_node_height(action_data: Dictionary) -> float:
	var lines = 2
	lines += action_data.get("effects", {}).size() + 1
	lines += action_data.get("preconditions", {}).size() + 1
	return lines * 22.0


func _make_section_label(text: String) -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(0.55, 0.55, 0.65))
	label.add_theme_font_size_override("font_size", 11)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label


func _make_kv_label(key, value, color: Color) -> Label:
	var label = Label.new()
	label.text = "  %s = %s" % [key, value]
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
	return label


func _make_spacer() -> Control:
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 4
	return spacer


func _apply_node_style(node: GraphNode, color: Color) -> void:
	node.add_theme_stylebox_override("panel", _make_node_panel(color, false))
	node.add_theme_stylebox_override("panel_selected", _make_node_panel(color, true))
	node.add_theme_stylebox_override("titlebar", _make_titlebar(color, false))
	node.add_theme_stylebox_override("titlebar_selected", _make_titlebar(color, true))


func _make_node_panel(color: Color, selected: bool) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(color.r * 0.15, color.g * 0.15, color.b * 0.15, 0.92)
	style.border_color = color if selected else color.darkened(0.3)
	style.set_border_width_all(2 if selected else 1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 6
	style.content_margin_bottom = 8
	return style


func _make_titlebar(color: Color, selected: bool) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(color.r * 0.35, color.g * 0.35, color.b * 0.35, 0.95)
	style.border_color = color if selected else color.darkened(0.2)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style


func _make_style(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(2)
	return style
