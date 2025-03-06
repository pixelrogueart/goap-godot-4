extends GoapAction
class_name CompleteBlueprintAction

enum HaulState {
	GET_MATERIAL,
	GRAB,
	DROP
}

@export var items_needed: Array
## {item_id: amount}
@export var item_id: String

var grab_location: Vector2
var drop_location: Vector2

var current_item: int = 0
var current_state = HaulState.GET_MATERIAL

var cooldown_timer: Timer = Timer.new()

func _ready() -> void:
	add_child(cooldown_timer)
	cooldown_timer.one_shot = true

func is_valid() -> bool:
	return true


func get_cost(blackboard) -> int:
	if blackboard.has("global_position"):
		if !items_needed.is_empty():
			var closest_item = _actor.find_closest_item(items_needed[current_item])
			if closest_item:
				return int(closest_item.global_position.distance_to(blackboard.global_position) / 7)
			var closest_provider = _actor.find_closest_provider_for_material(item_id)
			if closest_provider:
				return int(closest_provider.global_position.distance_to(blackboard.global_position) / 7)
	return cost


func perform(actor, delta) -> bool:
	var current_item_id = items_needed[current_item]
	var current_target: Vector2 = drop_location
	var closest_item = _actor.find_closest_item(items_needed[current_item])
	if closest_item:
		current_state = HaulState.GRAB
	match current_state:
		HaulState.GET_MATERIAL:
			var material_provider = _actor.find_closest_provider_for_material(current_item_id)
			if material_provider:
				current_target = material_provider.global_position
				if actor.world_node.is_next_to_grid_position(actor,current_target):
					if cooldown_timer.is_stopped():
						_actor.stop_moving()
						material_provider.call(material_provider.material_provider_method, _actor)
						cooldown_timer.start(material_provider.interaction_time)
					return false
		HaulState.GRAB:
			var item = _actor.find_closest_item(current_item_id)
			if item:
				grab_location = item.global_position
				current_target = grab_location
				if actor.world_node.is_next_to_grid_position(actor,grab_location):
					if item.grab(_actor):
						current_state = HaulState.DROP
		HaulState.DROP:
			current_target = drop_location
			if actor.world_node.is_next_to_grid_position(actor,drop_location):
				var item = actor.hauled_item
				if !item:
					return false
				if item.drop(_actor):
					item.tween_to_position(drop_location, 0.3)
					print("Current Item: %s Items Needed: %s"%[current_item,items_needed.size()])
					if current_item == items_needed.size() - 1:
						set_effects()
						current_item = 0
						return true
					else:
						current_item += 1
						current_state = HaulState.GET_MATERIAL
						return false
	if actor.current_state != "Move":
		actor.set_target_to_entity(current_target)
	return false
