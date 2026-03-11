class_name GoapActionPlanner
extends Node

var _actions: Array

func set_actions(actions: Array):
	_actions = actions


func get_plan(goal: GoapGoal, blackboard = {}) -> Array:
	if not goal:
		return []
	
	var desired_state: Dictionary = goal.get_desired_state().duplicate()

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
	var best_plan = null
	for p in plans:
		if best_plan == null or p.cost < best_plan.cost:
			best_plan = p
	
	if best_plan != null:
		return best_plan.actions
	
	return []

func _build_plans(step, blackboard):
	var has_followup = false

	var state = step.state.duplicate()

	for s in step.state:
		var blackboard_value = blackboard.get(s)
		var desired_value = state[s]

		var is_state_satisfied = false
		if typeof(desired_value) == TYPE_BOOL:

			var blackboard_as_bool = false
			if blackboard_value != null:
				if typeof(blackboard_value) == TYPE_BOOL:
					blackboard_as_bool = blackboard_value
				elif typeof(blackboard_value) == TYPE_INT or typeof(blackboard_value) == TYPE_FLOAT:
					blackboard_as_bool = blackboard_value != 0
				else:
					blackboard_as_bool = true 
			is_state_satisfied = blackboard_as_bool == desired_value
		else:
			is_state_satisfied = blackboard_value == desired_value
		
		if is_state_satisfied:
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
		var cost = 0
		if p.action.has_method("get_cost"):
			cost = p.action.get_cost(blackboard)
		plans.push_back({ "actions": [p.action], "cost": cost })
		return plans

	for c in p.children:
		for child_plan in _transform_tree_into_array(c, blackboard):
			if p.action.has_method("get_cost"):
				child_plan.actions.push_back(p.action)
				child_plan.cost += p.action.get_cost(blackboard)
			plans.push_back(child_plan)
	return plans
