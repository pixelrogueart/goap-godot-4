extends Node2D

const MOVE_SPEED = 120.0
const ARRIVAL_DISTANCE = 8.0

const HUNGER_RATE = 0.04
const HUNGER_THRESHOLD = 0.6
const TIREDNESS_RATE = 0.025
const TIREDNESS_THRESHOLD = 0.7
const FIRE_DECAY_RATE = 0.03

const BODY_RADIUS = 18.0
const EYE_OFFSET_X = 6.0
const EYE_OFFSET_Y = -4.0
const EYE_RADIUS = 3.5
const PUPIL_RADIUS = 1.8
const BAR_WIDTH = 44.0
const BAR_HEIGHT = 4.0
const BAR_Y = -32.0

var hunger := 0.0
var tiredness := 0.0
var fire_fuel := 0.0
var wood_count := 0

var tree_positions: Array = []
var prey_positions: Array = []
var campfire_position := Vector2.ZERO

var _move_target := Vector2.ZERO
var _is_moving := false
var _agent: GoapAgent
var _current_goal_name := ""
var _current_action_name := ""


func _ready():
	_setup_goap()


func _setup_goap():
	var goals_node = Node.new()
	goals_node.name = "Goals"
	add_child(goals_node)

	var actions_node = Node.new()
	actions_node.name = "Actions"
	add_child(actions_node)

	_add_goal(goals_node, preload("res://example/goals/eat_goal.gd"), "Eat")
	_add_goal(goals_node, preload("res://example/goals/sleep_goal.gd"), "Sleep")
	_add_goal(goals_node, preload("res://example/goals/maintain_fire_goal.gd"), "MaintainFire")
	_add_goal(goals_node, preload("res://example/goals/wander_goal.gd"), "Wander")

	_add_action(actions_node, preload("res://example/actions/chop_tree_action.gd"), "ChopTree")
	_add_action(actions_node, preload("res://example/actions/light_fire_action.gd"), "LightFire")
	_add_action(actions_node, preload("res://example/actions/hunt_action.gd"), "Hunt")
	_add_action(actions_node, preload("res://example/actions/cook_food_action.gd"), "CookFood")
	_add_action(actions_node, preload("res://example/actions/eat_action.gd"), "Eat")
	_add_action(actions_node, preload("res://example/actions/sleep_action.gd"), "Sleep")
	_add_action(actions_node, preload("res://example/actions/wander_action.gd"), "Wander")

	_agent = GoapAgent.new()
	_agent.name = "Agent"
	_agent.goals_node = goals_node
	_agent.actions_node = actions_node
	add_child(_agent)
	_agent.init(self)

	_agent.goal_changed.connect(func(g): _current_goal_name = g.name if g else "")
	_agent.action_changed.connect(func(a): _current_action_name = a.name if a else "")


func _add_goal(parent: Node, script: GDScript, goal_name: String):
	var g = script.new()
	g.name = goal_name
	parent.add_child(g)


func _add_action(parent: Node, script: GDScript, action_name: String):
	var a = script.new()
	a.name = action_name
	parent.add_child(a)


func _process(delta):
	_update_needs(delta)
	_update_fire(delta)
	_update_movement(delta)
	_agent.process(delta)
	queue_redraw()


func _update_needs(delta):
	hunger = min(hunger + delta * HUNGER_RATE, 1.0)
	tiredness = min(tiredness + delta * TIREDNESS_RATE, 1.0)
	var ws = _agent.get_world_state()
	if ws:
		ws.set_state(ExampleStateKeys.IS_HUNGRY, hunger > HUNGER_THRESHOLD)
		ws.set_state(ExampleStateKeys.IS_TIRED, tiredness > TIREDNESS_THRESHOLD)


func _update_fire(delta):
	if fire_fuel > 0:
		fire_fuel = max(fire_fuel - delta * FIRE_DECAY_RATE, 0.0)
	var ws = _agent.get_world_state()
	if ws:
		ws.set_state(ExampleStateKeys.FIRE_LIT, fire_fuel > 0)


func _update_movement(delta):
	if not _is_moving:
		return
	global_position = global_position.move_toward(_move_target, MOVE_SPEED * delta)
	if has_reached_target():
		_is_moving = false


func move_to(target: Vector2):
	_move_target = target
	_is_moving = true


func has_reached_target() -> bool:
	return global_position.distance_to(_move_target) < ARRIVAL_DISTANCE


func get_nearest_tree() -> Vector2:
	return _get_nearest(tree_positions)


func get_nearest_prey() -> Vector2:
	return _get_nearest(prey_positions)


func _get_nearest(positions: Array) -> Vector2:
	var nearest := Vector2.ZERO
	var min_dist := INF
	for pos in positions:
		var dist = global_position.distance_to(pos)
		if dist < min_dist:
			min_dist = dist
			nearest = pos
	return nearest


func chop_nearest_tree():
	var nearest = get_nearest_tree()
	if nearest != Vector2.ZERO:
		tree_positions.erase(nearest)
		wood_count += 1
		_agent.get_world_state().set_state(ExampleStateKeys.HAS_WOOD, true)


func kill_nearest_prey():
	var nearest = get_nearest_prey()
	if nearest != Vector2.ZERO:
		prey_positions.erase(nearest)
		_agent.get_world_state().set_state(ExampleStateKeys.HAS_RAW_FOOD, true)


func light_fire():
	if wood_count > 0:
		wood_count -= 1
		fire_fuel = 1.0
		_agent.get_world_state().set_state(ExampleStateKeys.HAS_WOOD, wood_count > 0)
		_agent.get_world_state().set_state(ExampleStateKeys.FIRE_LIT, true)


func _draw():
	_draw_target_line()
	_draw_body()
	_draw_eyes()
	_draw_mouth()
	_draw_sleep_indicator()
	_draw_bars()
	_draw_inventory()
	_draw_status()


func _draw_target_line():
	if not _is_moving:
		return
	var target_local = _move_target - global_position
	draw_line(Vector2.ZERO, target_local, Color(1, 1, 1, 0.08), 1.0)
	draw_circle(target_local, 3.0, Color(1, 1, 1, 0.15))


func _draw_body():
	var base_color = Color(0.35, 0.6, 0.85)
	if tiredness > TIREDNESS_THRESHOLD:
		base_color = base_color.lerp(Color(0.4, 0.35, 0.65), 0.5)
	if hunger > HUNGER_THRESHOLD:
		base_color = base_color.lerp(Color(0.85, 0.4, 0.3), 0.4)
	draw_circle(Vector2.ZERO, BODY_RADIUS, base_color)
	draw_arc(Vector2.ZERO, BODY_RADIUS, 0, TAU, 32, base_color.lightened(0.3), 2.0)


func _draw_eyes():
	var is_sleeping = _current_action_name == "Sleep"
	var look_dir = Vector2.ZERO
	if _is_moving and not is_sleeping:
		look_dir = (_move_target - global_position).normalized() * 1.5

	for side in [-1.0, 1.0]:
		var eye_pos = Vector2(side * EYE_OFFSET_X, EYE_OFFSET_Y)
		if is_sleeping:
			draw_line(eye_pos + Vector2(-3, 0), eye_pos + Vector2(3, 0), Color.WHITE, 2.0)
		else:
			draw_circle(eye_pos, EYE_RADIUS, Color.WHITE)
			draw_circle(eye_pos + look_dir, PUPIL_RADIUS, Color(0.15, 0.15, 0.2))


func _draw_mouth():
	if hunger > HUNGER_THRESHOLD:
		draw_arc(Vector2(0, 12), 5, deg_to_rad(200), deg_to_rad(340), 8, Color.WHITE, 2.0)
	elif _current_action_name == "Eat":
		draw_circle(Vector2(0, 10), 3, Color.WHITE)
	else:
		draw_arc(Vector2(0, 7), 5, deg_to_rad(20), deg_to_rad(160), 8, Color.WHITE, 2.0)


func _draw_sleep_indicator():
	if _current_action_name != "Sleep":
		return
	var font = ThemeDB.fallback_font
	var offsets = [Vector2(15, -20), Vector2(22, -30), Vector2(28, -38)]
	var sizes = [9, 11, 13]
	for i in range(3):
		var alpha = 0.4 + i * 0.2
		draw_string(font, offsets[i], "Z", HORIZONTAL_ALIGNMENT_LEFT, -1, sizes[i], Color(0.7, 0.8, 1.0, alpha))


func _draw_bars():
	_draw_bar(0, hunger, Color(0.85, 0.5, 0.2), Color(0.85, 0.2, 0.2))
	_draw_bar(1, tiredness, Color(0.4, 0.5, 0.85), Color(0.3, 0.2, 0.65))


func _draw_bar(index: int, value: float, color_low: Color, color_high: Color):
	var y = BAR_Y - index * (BAR_HEIGHT + 2)
	var bar_pos = Vector2(-BAR_WIDTH / 2.0, y)
	draw_rect(Rect2(bar_pos, Vector2(BAR_WIDTH, BAR_HEIGHT)), Color(0.12, 0.12, 0.16))
	var fill_color = color_low.lerp(color_high, value)
	draw_rect(Rect2(bar_pos, Vector2(BAR_WIDTH * value, BAR_HEIGHT)), fill_color)
	draw_rect(Rect2(bar_pos, Vector2(BAR_WIDTH, BAR_HEIGHT)), Color(0.5, 0.5, 0.55, 0.4), false, 1.0)


func _draw_inventory():
	var font = ThemeDB.fallback_font
	var items = []
	if wood_count > 0:
		items.append("W:%d" % wood_count)
	if _agent.get_world_state().get_state(ExampleStateKeys.HAS_RAW_FOOD, false):
		items.append("Raw")
	if _agent.get_world_state().get_state(ExampleStateKeys.HAS_COOKED_FOOD, false):
		items.append("Cooked")
	if items.is_empty():
		return
	var text = " ".join(items)
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 9)
	draw_string(font, Vector2(-text_size.x / 2.0, BODY_RADIUS + 14), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.65, 0.75, 0.6))


func _draw_status():
	var font = ThemeDB.fallback_font
	var text = _current_goal_name
	if _current_action_name != "":
		text += " > " + _current_action_name
	if text == "":
		text = "Idle"
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11)
	var text_pos = Vector2(-text_size.x / 2.0, BAR_Y - 2 * (BAR_HEIGHT + 2) - 6)
	draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.8, 0.8, 0.9))

