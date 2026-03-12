@tool
extends EditorPlugin

const DebuggerPlugin = preload("res://addons/goap/debugger/goap_editor_debugger_plugin.gd")
const BottomPanel = preload("res://addons/goap/debugger/goap_bottom_panel.gd")

var _debugger_plugin
var _bottom_panel

func _enter_tree() -> void:
	_bottom_panel = BottomPanel.new()
	_bottom_panel.name = "GOAP"
	add_control_to_bottom_panel(_bottom_panel, "GOAP")

	_debugger_plugin = DebuggerPlugin.new()
	_debugger_plugin.bind_bottom_panel(_bottom_panel)
	add_debugger_plugin(_debugger_plugin)

func _exit_tree() -> void:
	remove_debugger_plugin(_debugger_plugin)
	_debugger_plugin = null
	remove_control_from_bottom_panel(_bottom_panel)
	_bottom_panel.queue_free()
	_bottom_panel = null
