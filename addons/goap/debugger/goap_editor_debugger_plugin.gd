@tool
extends EditorDebuggerPlugin

const MSG_PREFIX := "goap_debug"
const PanelScene = preload("res://addons/goap/debugger/goap_editor_debug_panel.gd")
const ExplorerScene = preload("res://addons/goap/debugger/goap_planner_explorer.gd")

var _panel: Control
var _explorer: Control

func _has_capture(prefix: String) -> bool:
	return prefix == MSG_PREFIX

func _capture(message: String, data: Array, _session_id: int) -> bool:
	if !_panel: return false
	var msg_type = message.replace(MSG_PREFIX + ":", "")
	match msg_type:
		"goal":
			_panel.on_goal_received(data[0], data[1], data[2])
		"plan":
			_panel.on_plan_received(data[0])
		"action":
			_panel.on_action_received(data[0])
		"step":
			_panel.on_step_received(data[0], data[1])
		"world_state":
			_panel.on_world_state_received(data[0])
		"registry":
			if _explorer:
				_explorer.set_registry(data[0], data[1])
		_:
			return false
	return true

func _setup_session(session_id: int) -> void:
	var session = get_session(session_id)

	var tabs = TabContainer.new()
	tabs.name = "GOAP"
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL

	_panel = PanelScene.new()
	_panel.name = "Runtime"
	tabs.add_child(_panel)

	_explorer = ExplorerScene.new()
	_explorer.name = "Planner"
	tabs.add_child(_explorer)

	session.add_session_tab(tabs)
