@tool
extends VBoxContainer

const SIDEBAR_WIDTH := 320
const LABEL_FONT_SIZE := 12

const COLOR_TRUE := Color(0.2, 0.85, 0.35)
const COLOR_FALSE := Color(0.85, 0.2, 0.2)
const COLOR_SET := Color(0.3, 0.7, 1.0)
const COLOR_NOT_SET := Color(0.35, 0.35, 0.4)
const ROW_BG_EVEN := Color(0.1, 0.1, 0.13, 0.6)
const ROW_BG_ODD := Color(0.08, 0.08, 0.1, 0.6)

const COLOR_GOAL := Color(0.2, 0.85, 0.6)
const COLOR_CURRENT := Color(1.0, 0.85, 0.15)
const COLOR_COMPLETED := Color(0.35, 0.55, 0.35)
const COLOR_PENDING := Color(0.4, 0.5, 0.75)
const COLOR_PRECONDITION := Color(1.0, 0.55, 0.25)
const COLOR_EFFECT := Color(0.25, 0.9, 0.55)
const COLOR_SLOT_IN := Color(0.5, 0.7, 1.0)
const COLOR_SLOT_OUT := Color(0.5, 1.0, 0.7)

const NODE_WIDTH := 240.0
const NODE_SPACING := 300.0
const Y_CENTER := 150.0

var _graph: GraphEdit
var _graph_node_map: Dictionary = {}
var _world_state_list: VBoxContainer
var _state_rows: Dictionary = {}

var _current_goal_name := ""
var _current_action_name := ""
var _current_plan: Array = []
var _current_step := 0
var _current_total := 0
var _current_world_state: Dictionary = {}

func _ready() -> void:
	_build_ui()

func clear() -> void:
	_current_goal_name = ""
	_current_action_name = ""
	_current_plan = []
	_current_step = 0
	_current_total = 0
	_current_world_state = {}
	_state_rows.clear()
	if _world_state_list:
		for child in _world_state_list.get_children():
			child.queue_free()
	if _graph:
		_graph.clear_connections()
		for key in _graph_node_map:
			if is_instance_valid(_graph_node_map[key]):
				_graph_node_map[key].queue_free()
		_graph_node_map.clear()

func _build_ui() -> void:
	add_theme_constant_override("separation", 0)
	size_flags_vertical = SIZE_EXPAND_FILL

	var split = HSplitContainer.new()
	split.size_flags_vertical = SIZE_EXPAND_FILL
	split.split_offset = SIDEBAR_WIDTH
	add_child(split)

	split.add_child(_build_world_state_sidebar())

	_graph = GraphEdit.new()
	_graph.size_flags_horizontal = SIZE_EXPAND_FILL
	_graph.size_flags_vertical = SIZE_EXPAND_FILL
	_graph.right_disconnects = false
	_graph.minimap_enabled = true
	_graph.snapping_enabled = false
	_graph.show_grid = true
	_graph.panning_scheme = GraphEdit.SCROLL_ZOOMS
	split.add_child(_graph)

func _build_world_state_sidebar() -> PanelContainer:
	var sidebar_panel = PanelContainer.new()
	sidebar_panel.custom_minimum_size.x = SIDEBAR_WIDTH
	sidebar_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.06, 0.06, 0.08, 1.0)))

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	sidebar_panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	margin.add_child(vbox)

	var header = Label.new()
	header.text = "WORLD STATE"
	header.add_theme_font_size_override("font_size", 15)
	header.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0))
	vbox.add_child(header)
	vbox.add_child(HSeparator.new())

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	_world_state_list = VBoxContainer.new()
	_world_state_list.add_theme_constant_override("separation", 0)
	_world_state_list.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.add_child(_world_state_list)

	return sidebar_panel

func _create_state_row(state_key: String, odd: bool) -> Dictionary:
	var container = PanelContainer.new()
	container.add_theme_stylebox_override("panel", _make_panel_style(ROW_BG_ODD if odd else ROW_BG_EVEN))

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	container.add_child(hbox)

	var indicator = ColorRect.new()
	indicator.custom_minimum_size = Vector2(10, 10)
	indicator.size_flags_vertical = SIZE_SHRINK_CENTER
	indicator.color = COLOR_NOT_SET
	hbox.add_child(indicator)

	var name_label = Label.new()
	name_label.text = state_key
	name_label.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
	name_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
	name_label.size_flags_horizontal = SIZE_EXPAND_FILL
	hbox.add_child(name_label)

	var value_label = Label.new()
	value_label.text = "NOT SET"
	value_label.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
	value_label.add_theme_color_override("font_color", COLOR_NOT_SET)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.custom_minimum_size.x = 90
	hbox.add_child(value_label)

	return {"container": container, "indicator": indicator, "name_label": name_label, "value_label": value_label}


func on_goal_received(goal_name: String, priority: int, desired_state: Dictionary) -> void:
	_current_goal_name = goal_name

func on_plan_received(plan_data: Array) -> void:
	_current_plan = plan_data
	_rebuild_graph()

func on_action_received(action_name: String) -> void:
	_current_action_name = action_name
	_apply_graph_styles()

func on_step_received(current: int, total: int) -> void:
	_current_step = current
	_current_total = total

func on_world_state_received(ws: Dictionary) -> void:
	_current_world_state = ws
	_refresh_world_state()


func _rebuild_graph() -> void:
	_graph.clear_connections()
	for key in _graph_node_map:
		if is_instance_valid(_graph_node_map[key]):
			_graph_node_map[key].queue_free()
	_graph_node_map.clear()

	if _current_goal_name == "" and _current_plan.is_empty(): return

	var x := 0.0

	if _current_goal_name != "":
		var goal_node = _create_graph_goal_node()
		goal_node.position_offset = Vector2(x, Y_CENTER)
		_graph.add_child(goal_node)
		_graph_node_map["goal"] = goal_node
		x += NODE_SPACING

	for i in range(_current_plan.size()):
		var action_data: Dictionary = _current_plan[i]
		var key = "action_%s" % i
		var node = _create_graph_action_node(action_data, i)
		node.position_offset = Vector2(x, Y_CENTER)
		_graph.add_child(node)
		_graph_node_map[key] = node
		x += NODE_SPACING

	_connect_graph_nodes()
	_apply_graph_styles()

func _create_graph_goal_node() -> GraphNode:
	var node = GraphNode.new()
	node.title = "GOAL: %s" % _current_goal_name
	node.name = "goal"
	node.resizable = false
	node.custom_minimum_size.x = NODE_WIDTH

	var connector = _make_graph_label("", Color.TRANSPARENT)
	connector.custom_minimum_size.y = 4
	node.add_child(connector)
	var slot_idx = node.get_child_count() - 1
	node.set_slot(slot_idx, false, 0, Color.WHITE, true, 0, COLOR_SLOT_OUT)
	return node

func _create_graph_action_node(data: Dictionary, idx: int) -> GraphNode:
	var node = GraphNode.new()
	node.title = data.get("name", "Action")
	node.name = "action_%s" % idx
	node.resizable = false
	node.custom_minimum_size.x = NODE_WIDTH
	node.set_meta("plan_index", idx)
	node.set_meta("action_name", data.get("name", ""))

	var in_connector = _make_graph_label("", Color.TRANSPARENT)
	in_connector.custom_minimum_size.y = 4
	node.add_child(in_connector)
	node.set_slot(0, true, 0, COLOR_SLOT_IN, false, 0, Color.WHITE)

	var cost_lbl = _make_graph_label("Cost: %s" % data.get("cost", 0), Color(0.85, 0.85, 0.6))
	node.add_child(cost_lbl)

	var preconditions: Dictionary = data.get("preconditions", {})
	if !preconditions.is_empty():
		node.add_child(_make_graph_section("PRECONDITIONS"))
		for key in preconditions:
			node.add_child(_make_graph_label("  %s = %s" % [key, preconditions[key]], COLOR_PRECONDITION))

	var effects: Dictionary = data.get("effects", {})
	if !effects.is_empty():
		node.add_child(_make_graph_section("EFFECTS"))
		for key in effects:
			node.add_child(_make_graph_label("  %s = %s" % [key, effects[key]], COLOR_EFFECT))

	var out_connector = _make_graph_label("", Color.TRANSPARENT)
	out_connector.custom_minimum_size.y = 4
	node.add_child(out_connector)
	var slot_idx = node.get_child_count() - 1
	node.set_slot(slot_idx, false, 0, Color.WHITE, true, 0, COLOR_SLOT_OUT)

	return node

func _connect_graph_nodes() -> void:
	if _graph_node_map.has("goal") and _graph_node_map.has("action_0"):
		_graph.connect_node("goal", 0, "action_0", 0)
	for i in range(_current_plan.size() - 1):
		var from_key = "action_%s" % i
		var to_key = "action_%s" % (i + 1)
		if _graph_node_map.has(from_key) and _graph_node_map.has(to_key):
			_graph.connect_node(from_key, 0, to_key, 0)

func _apply_graph_styles() -> void:
	for key in _graph_node_map:
		var node: GraphNode = _graph_node_map[key]
		if key == "goal":
			_style_graph_node(node, COLOR_GOAL, "GOAL")
			continue

		var plan_idx: int = node.get_meta("plan_index", -1)
		var node_action_name: String = node.get_meta("action_name", "")

		if _current_action_name != "" and node_action_name == _current_action_name:
			_style_graph_node(node, COLOR_CURRENT, "RUNNING")
		elif _current_step > 0 and plan_idx < _current_step:
			_style_graph_node(node, COLOR_COMPLETED, "DONE")
		else:
			_style_graph_node(node, COLOR_PENDING, "PENDING")

func _style_graph_node(node: GraphNode, color: Color, status_text: String) -> void:
	var panel_style = _make_node_style(color, false)
	var panel_selected = _make_node_style(color, true)
	var titlebar_style = _make_titlebar_style(color, false)
	var titlebar_selected = _make_titlebar_style(color, true)

	node.add_theme_stylebox_override("panel", panel_style)
	node.add_theme_stylebox_override("panel_selected", panel_selected)
	node.add_theme_stylebox_override("titlebar", titlebar_style)
	node.add_theme_stylebox_override("titlebar_selected", titlebar_selected)

	var base_title = node.title.split(" [")[0]
	node.title = "%s [%s]" % [base_title, status_text]


func _refresh_world_state() -> void:
	var row_idx = _state_rows.size()
	for ws_key in _current_world_state:
		if !_state_rows.has(ws_key):
			var row = _create_state_row(ws_key, row_idx % 2 == 1)
			_world_state_list.add_child(row.container)
			_state_rows[ws_key] = row
			row_idx += 1

	for key in _state_rows:
		var row = _state_rows[key]
		var is_set = _current_world_state.has(key)

		if !is_set:
			row.indicator.color = COLOR_NOT_SET
			row.value_label.text = "NOT SET"
			row.value_label.add_theme_color_override("font_color", COLOR_NOT_SET)
			row.name_label.add_theme_color_override("font_color", Color(0.45, 0.45, 0.5))
			continue

		var value = _current_world_state[key]
		var color = _get_value_color(value)
		row.indicator.color = color
		row.value_label.text = _format_value(value)
		row.value_label.add_theme_color_override("font_color", color)
		row.name_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))

func _get_value_color(value) -> Color:
	if value == null: return COLOR_NOT_SET
	if typeof(value) == TYPE_STRING and value == "null": return COLOR_NOT_SET
	if typeof(value) == TYPE_BOOL:
		return COLOR_TRUE if value else COLOR_FALSE
	if typeof(value) == TYPE_ARRAY:
		return COLOR_TRUE if !value.is_empty() else COLOR_FALSE
	return COLOR_SET

func _format_value(value) -> String:
	if value == null: return "null"
	if typeof(value) == TYPE_STRING and value == "null": return "null"
	if typeof(value) == TYPE_BOOL: return "TRUE" if value else "FALSE"
	if typeof(value) == TYPE_ARRAY:
		if value.is_empty(): return "[]"
		var items: Array = []
		for v in value:
			items.append(str(v))
		return "[%s]" % ", ".join(items)
	return str(value)


func _make_graph_label(text: String, color: Color) -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 12)
	return label

func _make_graph_section(text: String) -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(0.55, 0.55, 0.65))
	label.add_theme_font_size_override("font_size", 11)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label

func _make_panel_style(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(2)
	return style

func _make_node_style(color: Color, selected: bool) -> StyleBoxFlat:
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

func _make_titlebar_style(color: Color, selected: bool) -> StyleBoxFlat:
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
