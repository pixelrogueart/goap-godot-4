## A* backward-search planner that builds action chains for [GoapGoal]s.
##
## Given a goal's [member GoapGoal.desired_state] and the current world state
## (blackboard), the planner searches all registered [GoapAction]s to find
## the cheapest sequence whose effects satisfy the desired state.[br][br]
## You don't interact with this class directly — [GoapAgent] creates and
## manages it internally.
@icon("res://addons/goap/icons/goap_action_planner.svg")
class_name GoapActionPlanner
extends Node

var _actions: Array


## Registers the array of [GoapAction]s available for planning.
func set_actions(actions: Array):
	_actions = actions


## Builds and returns the cheapest action plan for [param goal].[br]
## Returns an empty [Array] if no valid plan exists.
func get_plan(goal: GoapGoal, blackboard = {}) -> Array:
	if not goal:
		return []
	
	var desired_state: Dictionary = goal.get_desired_state().duplicate()

	if desired_state.is_empty():
		return []

	return _find_best_plan(goal, desired_state, blackboard)

## Finds the best plan for [param goal] given [param desired_state].
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

## Returns the plan with the lowest total cost.
func _get_cheapest_plan(plans):
	var best_plan = null
	for p in plans:
		if best_plan == null or p.cost < best_plan.cost:
			best_plan = p
	
	if best_plan != null:
		return best_plan.actions
	
	return []

## Recursively expands the search tree, returning [code]true[/code] if at
## least one complete path to a satisfied state was found.
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


## Converts the recursive tree into a flat array of plans with total costs.
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
