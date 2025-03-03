class_name StateManager
extends Node

@export var starting_state: NodePath

var current_state: BaseState
var context

func change_state(new_state: BaseState) -> void:
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()

func has_state(state_name:String):
	for child in get_children():
		if child.name == state_name:
			return true
	return false

func init(_context) -> void:
	for child in get_children():
		child.context = _context
		child.init(_context)
	context = _context
	if !starting_state:
		starting_state = get_child(0).get_path()
	change_state(get_node(starting_state))

func physics_process(_delta: float) -> void:
	if current_state:
		current_state.physics_process(_delta)

func input(_event: InputEvent) -> void:
	if current_state:
		current_state.input(_event)

func process(_delta: float) -> void:
	if current_state:
		current_state.process(_delta)
