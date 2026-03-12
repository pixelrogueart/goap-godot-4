## Central GOAP brain that selects goals, builds plans, and executes actions.
##
## Attach this node to any actor and assign [member goals_node] and
## [member actions_node] to containers holding [GoapGoal] and [GoapAction]
## children respectively. Call [method init] once after the scene is ready,
## then call [method process] every frame.[br][br]
## [b]Signals:[/b][br]
## - [signal plan_changed] — emitted when a new action plan is generated.[br]
## - [signal goal_changed] — emitted when the active goal switches.[br]
## - [signal action_changed] — emitted when the currently running action changes.
@icon("res://addons/goap/icons/goap_agent.svg")
class_name GoapAgent
extends Node

const DEBUG_PREFIX := "goap_debug"

## Emitted when a new action plan is generated or cleared.
signal plan_changed(new_plan: Array)

## Emitted when the active [GoapGoal] changes.
signal goal_changed(new_goal: GoapGoal)

## Emitted when the currently executing [GoapAction] changes.
signal action_changed(new_action: GoapAction)

## Node whose children are the available [GoapAction]s.
@export var actions_node: Node

## Node whose children are the available [GoapGoal]s.
@export var goals_node: Node

## When [code]true[/code], sends runtime data to the editor debugger panel.
@export var debug_enabled := true

var _goals = []
var _current_goal
var _current_plan = []
var _current_plan_step = 0
var _actor
var _world_state: GoapWorldState
var _action_planner: GoapActionPlanner
var _finished_last_plan = false
var _last_blackboard = {}

## The last [GoapAction] that finished executing.
var previous_action: GoapAction = null
var _debug_id := ""


## Main tick — call once per frame from [code]_process[/code] or [code]_physics_process[/code].
func process(delta):
	var goal = _get_best_goal()
	if _finished_last_plan:
		if _current_goal and _current_goal.has_method("exit"):
			_current_goal.exit()
		_current_goal = null
		_finished_last_plan = false
	if !goal: return
	if _current_goal != goal:
		plan_changed.emit([])
		goal_changed.emit(goal)
	if _current_goal and !_current_goal.is_valid():
		if _current_goal.has_method("exit"):
			_current_goal.exit()
		_current_goal = null
	if _current_goal == null or goal != _current_goal:
		if _actor:
			if _current_plan.size() > 0 and _current_plan_step < _current_plan.size() - 1:
				var running = _current_plan[_current_plan_step]
				if running is GoapAction and running.get_meta("_entered", false):
					running.exit()
					running.set_meta("_entered", false)
			if _current_goal and _current_goal != goal and _current_goal.has_method("exit"):
				_current_goal.exit()
			
			_current_goal = goal
			if _current_goal.has_method("enter"):
				_current_goal.enter()

			var blackboard = {
				"global_position": _actor.global_position,
				}
			for s in _world_state._state:
				blackboard[s] = _world_state._state[s]
	
			var desired_state = goal.get_desired_state()
			var is_already_satisfied = true
			if desired_state.is_empty(): is_already_satisfied = false
			for state_key in desired_state:
				if blackboard.get(state_key) != desired_state[state_key]:
					is_already_satisfied = false
					break
			if is_already_satisfied:
				if _current_goal.has_method("exit"):
					_current_goal.exit()
				_current_goal = null
				return
			
			_current_plan = _action_planner.get_plan(_current_goal, blackboard)
			plan_changed.emit(_current_plan)
			_current_plan_step = 0
			_last_blackboard = blackboard
			if _current_plan.size() == 0:
				if _current_goal.has_method("on_goal_failed"):
					_current_goal.on_goal_failed()
				if _current_goal.has_method("exit"):
					_current_goal.exit()
				_current_goal = null
			elif _current_plan.size() == 1:
				if _current_goal.has_method("on_goal_achieved"):
					_current_goal.on_goal_achieved()
				_finished_last_plan = true
	else:
		_follow_plan(_current_plan, delta)


## Initialises the agent with the owning [param actor] node.[br]
## Creates the [GoapWorldState], discovers goals and actions from the
## exported node containers, and registers with the editor debugger.
func init(actor):
	_actor = actor
	_world_state = GoapWorldState.new()
	_debug_id = str(get_path())
	var actions = []
	for child in goals_node.get_children():
		if not child is GoapGoal:
			continue
		_goals.push_back(child)
		child.agent = self
	for child in actions_node.get_children():
		if not child is GoapAction:
			continue
		actions.push_back(child)
		child.agent = self
	_action_planner = GoapActionPlanner.new()
	_action_planner.set_actions(actions)

	for goal in _goals:
		goal.init(_actor, _world_state)

	for action in actions:
		action.init(_actor, _world_state)

	_connect_debug_signals()
	_send_debug_register(actions)


## Returns the highest-priority, valid, enabled [GoapGoal], or [code]null[/code].
func _get_best_goal():
	var highest_priority = null
	var _debug_text = ""
	for goal in _goals:
		if goal.enabled and goal.is_valid() and (highest_priority == null or \
				goal.get_priority() > highest_priority.get_priority()):
			highest_priority = goal
		_debug_text += "\n Is %s valid? %s "%[goal.get_action_name(), goal.is_valid()]
	return highest_priority


## Steps through the current action plan, executing one action at a time.
func _follow_plan(plan, delta):
	if plan.size() == 0:
		print("Warning: _follow_plan called with empty plan")
		_finished_last_plan = true
		return

	if _current_goal and _current_goal.has_method("perform"):
		_current_goal.perform(delta)


	if _current_plan_step < plan.size() - 1:
		var current_action = plan[_current_plan_step]

		if current_action.has_method("enter") and (not current_action.has_meta("_entered") or not current_action.get_meta("_entered")):
			current_action.enter()
			action_changed.emit(current_action)
			current_action.set_meta("_entered", true)
	
		var is_step_complete = current_action.perform(delta)
		if is_step_complete:
			previous_action = current_action
			if current_action.has_method("exit"):
				action_changed.emit(null)
				current_action.exit()
			current_action.set_meta("_entered", false)
			if current_action.has_method("set_effects"):
				current_action.set_effects(current_action.get_effects())
			if not _verify_action_effects(current_action):
				var blackboard = {
					"global_position": _actor.global_position,
				}
				for s in _world_state._state:
					blackboard[s] = _world_state._state[s]
				
				_current_plan = _action_planner.get_plan(_current_goal, blackboard)
				plan_changed.emit(_current_plan)
				_current_plan_step = 0
				
				if _current_plan.size() == 0:
					if _current_goal and _current_goal.has_method("on_goal_failed"):
						_current_goal.on_goal_failed()
					if _current_goal and _current_goal.has_method("exit"):
						_current_goal.exit()
					_current_goal = null
					_current_plan = []
					_current_plan_step = 0
				return

			_current_plan_step += 1

			if _current_goal:
				var desired_state = _current_goal.get_desired_state()
				var is_goal_satisfied = true
				for state_key in desired_state:
					if _world_state.get_state(state_key) != desired_state[state_key]:
						is_goal_satisfied = false
						break

				if is_goal_satisfied:
					if _current_goal.has_method("on_goal_achieved"):
						_current_goal.on_goal_achieved()
					_finished_last_plan = true
					return

	if _current_plan_step >= plan.size() - 1:
		if _current_goal:
			var desired_state = _current_goal.get_desired_state()
			var is_goal_satisfied = true
			for state_key in desired_state:
				if _world_state.get_state(state_key) != desired_state[state_key]:
					is_goal_satisfied = false
					break
			
			if is_goal_satisfied:

				if _current_goal.has_method("on_goal_achieved"):
					_current_goal.on_goal_achieved()
				_finished_last_plan = true
			else:
				_current_goal = null
				_current_plan = []
				_current_plan_step = 0


## Returns the currently active [GoapGoal], or [code]null[/code].
func get_current_goal() -> GoapGoal:
	return _current_goal


## Returns the [GoapAction] currently being executed, or [code]null[/code].
func get_current_action() -> GoapAction:
	if _current_plan.size() > 0 and _current_plan_step < _current_plan.size():
		var current_item = _current_plan[_current_plan_step]

		if current_item is GoapAction:
			return current_item
	return null

## Returns the agent's [GoapWorldState] instance.
func get_world_state() -> GoapWorldState:
	return _world_state


## Returns [code]true[/code] if the action's declared effects match the world state.
func _verify_action_effects(action: GoapAction) -> bool:
	var effects = action.get_effects()
	for effect_key in effects:
		var expected_value = effects[effect_key]
		var actual_value = _world_state.get_state(effect_key)
		if actual_value != expected_value:
			return false
	
	return true


func debug_select() -> void:
	_send_debug("select", [])


func _send_debug(msg_type: String, data: Array) -> void:
	if not debug_enabled or not EngineDebugger.is_active():
		return
	EngineDebugger.send_message(DEBUG_PREFIX + ":" + msg_type, [_debug_id] + data)


func _connect_debug_signals():
	goal_changed.connect(_on_debug_goal_changed)
	plan_changed.connect(_on_debug_plan_changed)
	action_changed.connect(_on_debug_action_changed)
	_world_state.state_updated.connect(_on_debug_world_state_updated)


func _send_debug_register(actions: Array):
	var goal_data := []
	for g in _goals:
		goal_data.append({
			"name": g.get_action_name(),
			"priority": g.get_priority(),
			"desired_state": g.get_desired_state(),
			"cost": g.get_cost({}),
		})
	var action_data := []
	for a in actions:
		action_data.append({
			"name": a.get_action_name(),
			"cost": a.cost,
			"preconditions": a.get_preconditions(),
			"effects": a.get_effects(),
		})
	_send_debug("registry", [goal_data, action_data])


func _on_debug_goal_changed(new_goal: GoapGoal):
	if new_goal:
		_send_debug("goal", [new_goal.get_action_name(), new_goal.get_priority(), new_goal.get_desired_state()])
	else:
		_send_debug("goal", ["", 0, {}])


func _on_debug_plan_changed(plan: Array):
	var plan_data := []
	for item in plan:
		if item is GoapAction:
			plan_data.append({
				"name": item.get_action_name(),
				"cost": item.cost,
				"preconditions": item.get_preconditions(),
				"effects": item.get_effects(),
			})
		elif item is GoapGoal:
			plan_data.append({
				"name": item.get_action_name(),
				"cost": item.cost,
			})
	_send_debug("plan", [plan_data])


func _on_debug_action_changed(new_action: GoapAction):
	var action_name = new_action.get_action_name() if new_action else ""
	_send_debug("action", [action_name])
	_send_debug("step", [_current_plan_step, _current_plan.size()])


func _on_debug_world_state_updated():
	_send_debug("world_state", [_world_state._state.duplicate()])
