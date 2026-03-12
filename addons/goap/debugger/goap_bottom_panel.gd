@tool
extends VBoxContainer

const PanelScene = preload("res://addons/goap/debugger/goap_editor_debug_panel.gd")
const ExplorerScene = preload("res://addons/goap/debugger/goap_planner_explorer.gd")

var agent_selector: OptionButton
var debug_panel: Control
var explorer: Control

func _ready() -> void:
	size_flags_vertical = SIZE_EXPAND_FILL
	_build_ui()

func _build_ui() -> void:
	var toolbar = HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 8)
	add_child(toolbar)

	var lbl = Label.new()
	lbl.text = "Agent:"
	lbl.add_theme_font_size_override("font_size", 13)
	toolbar.add_child(lbl)

	agent_selector = OptionButton.new()
	agent_selector.custom_minimum_size.x = 300
	toolbar.add_child(agent_selector)

	var tabs = TabContainer.new()
	tabs.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(tabs)

	debug_panel = PanelScene.new()
	debug_panel.name = "Runtime"
	tabs.add_child(debug_panel)

	explorer = ExplorerScene.new()
	explorer.name = "Planner"
	tabs.add_child(explorer)
