## Editor debugger plugin that receives GOAP runtime data from running agents.
##
## Registers as an [EditorDebuggerPlugin] and captures messages prefixed with
## [code]goap_debug:[/code]. Supports multiple agents via an [OptionButton]
## selector — each agent's state is cached independently so switching is instant.
@tool
extends EditorDebuggerPlugin

const MSG_PREFIX := "goap_debug"
const PanelScene = preload("res://addons/goap/debugger/goap_editor_debug_panel.gd")
const ExplorerScene = preload("res://addons/goap/debugger/goap_planner_explorer.gd")

var _panel: Control
var _explorer: Control
var _agent_selector: OptionButton
var _agents: Dictionary = {}
var _selected_agent_id := ""

func _has_capture(prefix: String) -> bool:
	return prefix == MSG_PREFIX

func _capture(message: String, data: Array, _session_id: int) -> bool:
	if !_panel or data.size() < 1:
		return false

	var agent_id := str(data[0])
	var payload := data.slice(1)
	var msg_type = message.replace(MSG_PREFIX + ":", "")

	if msg_type == "registry":
		_register_agent(agent_id, payload)
		return true

	if not _agents.has(agent_id):
		return false

	var agent_data: Dictionary = _agents[agent_id]

	match msg_type:
		"goal":
			agent_data.goal_name = payload[0]
			agent_data.goal_priority = payload[1]
			agent_data.goal_desired_state = payload[2]
		"plan":
			agent_data.plan = payload[0]
		"action":
			agent_data.action_name = payload[0]
		"step":
			agent_data.step_current = payload[0]
			agent_data.step_total = payload[1]
		"world_state":
			agent_data.world_state = payload[0]
		_:
			return false

	if agent_id == _selected_agent_id:
		_push_to_panel(agent_data, msg_type)

	return true


func _register_agent(agent_id: String, payload: Array):
	_agents[agent_id] = {
		"id": agent_id,
		"goals": payload[0],
		"actions": payload[1],
		"goal_name": "",
		"goal_priority": 0,
		"goal_desired_state": {},
		"plan": [],
		"action_name": "",
		"step_current": 0,
		"step_total": 0,
		"world_state": {},
	}
	_refresh_agent_list()
	if _selected_agent_id == "":
		_select_agent(agent_id)


func _refresh_agent_list():
	if not _agent_selector:
		return
	_agent_selector.clear()
	var idx := 0
	for id in _agents:
		var label = _get_agent_display_name(id)
		_agent_selector.add_item(label, idx)
		_agent_selector.set_item_metadata(idx, id)
		if id == _selected_agent_id:
			_agent_selector.select(idx)
		idx += 1


func _get_agent_display_name(agent_id: String) -> String:
	var parts = agent_id.split("/")
	if parts.size() >= 2:
		return parts[-2] + "/" + parts[-1]
	return agent_id


func _select_agent(agent_id: String):
	_selected_agent_id = agent_id
	if not _agents.has(agent_id):
		return
	var agent_data = _agents[agent_id]

	if _panel and _panel.has_method("clear"):
		_panel.clear()

	if _explorer:
		_explorer.set_registry(agent_data.goals, agent_data.actions)

	_push_to_panel(agent_data, "goal")
	_push_to_panel(agent_data, "plan")
	_push_to_panel(agent_data, "action")
	_push_to_panel(agent_data, "step")
	_push_to_panel(agent_data, "world_state")


func _push_to_panel(agent_data: Dictionary, msg_type: String):
	if not _panel:
		return
	match msg_type:
		"goal":
			_panel.on_goal_received(agent_data.goal_name, agent_data.goal_priority, agent_data.goal_desired_state)
		"plan":
			_panel.on_plan_received(agent_data.plan)
		"action":
			_panel.on_action_received(agent_data.action_name)
		"step":
			_panel.on_step_received(agent_data.step_current, agent_data.step_total)
		"world_state":
			_panel.on_world_state_received(agent_data.world_state)


func _on_agent_selected(idx: int):
	var agent_id = _agent_selector.get_item_metadata(idx)
	_select_agent(agent_id)


func _setup_session(session_id: int) -> void:
	var session = get_session(session_id)
	_agents.clear()
	_selected_agent_id = ""

	var root = VBoxContainer.new()
	root.name = "GOAP"
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var toolbar = HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 8)
	root.add_child(toolbar)

	var lbl = Label.new()
	lbl.text = "Agent:"
	lbl.add_theme_font_size_override("font_size", 13)
	toolbar.add_child(lbl)

	_agent_selector = OptionButton.new()
	_agent_selector.custom_minimum_size.x = 300
	_agent_selector.item_selected.connect(_on_agent_selected)
	toolbar.add_child(_agent_selector)

	var tabs = TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(tabs)

	_panel = PanelScene.new()
	_panel.name = "Runtime"
	tabs.add_child(_panel)

	_explorer = ExplorerScene.new()
	_explorer.name = "Planner"
	tabs.add_child(_explorer)

	session.add_session_tab(root)
