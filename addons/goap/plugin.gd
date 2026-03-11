@tool
extends EditorPlugin

const DebuggerPlugin = preload("res://addons/goap/debugger/goap_editor_debugger_plugin.gd")

var _debugger_plugin

func _enter_tree() -> void:
	_debugger_plugin = DebuggerPlugin.new()
	add_debugger_plugin(_debugger_plugin)

func _exit_tree() -> void:
	remove_debugger_plugin(_debugger_plugin)
	_debugger_plugin = null
