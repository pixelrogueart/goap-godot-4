class_name GoapActionPlanner
extends Node


var _actions: Array
var _log

func set_actions(actions: Array):
	_actions = actions


func console_message(text) -> void:
	print(text)

func get_plan(goal: GoapGoal, blackboard = {}) -> Array:
	console_message("Goal: %s" % goal.get_action_name())
	var desired_state = goal.get_desired_state().duplicate()

	if desired_state.is_empty():
		return []

	return _find_best_plan(goal, desired_state, blackboard)



func _find_best_plan(goal, desired_state, blackboard):

	var root = {
		"action": goal,
		"state": desired_state,
		"children": []
	}

	if _build_plans(root, blackboard.duplicate()):
		var plans = _transform_tree_into_array(root, blackboard)
		return _get_cheapest_plan(plans)

	return []


func _get_cheapest_plan(plans):
	var best_plan
	for p in plans:
		_print_plan(p)
		if best_plan == null or p.cost < best_plan.cost:
			best_plan = p
	return best_plan.actions


func _build_plans(step, blackboard):
	var has_followup = false

	var state = step.state.duplicate()

	for s in step.state:
		if state[s] == blackboard.get(s):
			state.erase(s)

	if state.is_empty():
		return true

	for action in _actions:
		if not action.is_valid():
			continue

		var should_use_action = false
		var effects = action.get_effects()
		var desired_state = state.duplicate()

		for s in desired_state:
			if desired_state[s] == effects.get(s):
				desired_state.erase(s)
				should_use_action = true

		if should_use_action:

			var preconditions = action.get_preconditions()
			for p in preconditions:
				desired_state[p] = preconditions[p]

			var s = {
				"action": action,
				"state": desired_state,
				"children": []
				}

			if desired_state.is_empty() or _build_plans(s, blackboard.duplicate()):
				step.children.push_back(s)
				has_followup = true

	return has_followup


func _transform_tree_into_array(p, blackboard):
	var plans = []

	if p.children.size() == 0:
		print(p)
		print(p.action)
		plans.push_back({ "actions": [p.action], "cost": p.action.get_cost(blackboard) })
		return plans

	for c in p.children:
		for child_plan in _transform_tree_into_array(c, blackboard):
			if p.action.has_method("get_cost"):
				child_plan.actions.push_back(p.action)
				child_plan.cost += p.action.get_cost(blackboard)
			plans.push_back(child_plan)
	return plans


func _print_plan(plan):
	var actions = []
	for a in plan.actions:
		actions.push_back(a.get_action_name())
	print({"cost": plan.cost, "actions": actions})
	console_message({"cost": plan.cost, "actions": actions})
