class_name GoapAgent
extends Node


var _goals = []
var _current_goal
var _current_plan
var _current_plan_step = 0

var _actor
var _world_state

var _action_planner: GoapActionPlanner
@export var actions: Array[GoapAction]
@export var goals: Array[GoapGoal]


func _process(delta):
	var goal = _get_best_goal()
	if _current_goal == null or goal != _current_goal:
		if _actor:
			var blackboard = {
				"global_position": _actor.global_position,
				}

			for s in _world_state._state:
				blackboard[s] = _world_state._state[s]

			_current_goal = goal
			_current_plan = _action_planner.get_plan(_current_goal, blackboard)
			_current_plan_step = 0
	else:
		_follow_plan(_current_plan, delta)


func init(actor):
	_world_state = GoapWorldState.new()
	_actor = actor
	_goals = goals
	_action_planner = GoapActionPlanner.new()
	_action_planner.set_actions(actions)
	for goal in _goals:
		goal.init(_actor, _world_state)
	for action in actions:
		action.init(_actor, _world_state)


func _get_best_goal():
	var highest_priority

	for goal in _goals:
		if goal.is_valid() and (highest_priority == null or goal.get_priority() > highest_priority.get_priority()):
			highest_priority = goal

	return highest_priority


func _follow_plan(plan, delta):
	if plan.size() == 0:
		return

	var is_step_complete = plan[_current_plan_step].perform(_actor, delta)
	if is_step_complete and _current_plan_step < plan.size() - 1:
		_current_plan_step += 1
