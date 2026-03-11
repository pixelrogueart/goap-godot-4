class_name GoapAgent
extends Node


signal plan_changed(new_plan: Array)
signal goal_changed(new_goal: GoapGoal)
signal action_changed(new_action: GoapAction)


@export var actions_node: Node 
@export var goals_node: Node

var _goals = []
var _current_goal
var _current_plan = []
var _current_plan_step = 0
var _actor
var _world_state: GoapWorldState
var _action_planner: GoapActionPlanner
var _finished_last_plan = false
var _last_blackboard = {}
var previous_action: GoapAction = null


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


func init(actor):
	_actor = actor
	_world_state = GoapWorldState.new()
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


func _get_best_goal():
	var highest_priority = null
	var _debug_text = ""
	for goal in _goals:
		if goal.enabled and goal.is_valid() and (highest_priority == null or \
				goal.get_priority() > highest_priority.get_priority()):
			highest_priority = goal
		_debug_text += "\n Is %s valid? %s "%[goal.get_action_name(), goal.is_valid()]
	return highest_priority


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


func get_current_goal() -> GoapGoal:
	return _current_goal


func get_current_action() -> GoapAction:
	if _current_plan.size() > 0 and _current_plan_step < _current_plan.size():
		var current_item = _current_plan[_current_plan_step]

		if current_item is GoapAction:
			return current_item
	return null

func get_world_state() -> GoapWorldState:
	return _world_state


func _verify_action_effects(action: GoapAction) -> bool:
	var effects = action.get_effects()
	for effect_key in effects:
		var expected_value = effects[effect_key]
		var actual_value = _world_state.get_state(effect_key)
		if actual_value != expected_value:
			return false
	
	return true
