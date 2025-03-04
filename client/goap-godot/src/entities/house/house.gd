class_name HouseEntity
extends Entity

var available = true
var sleeping_entity: PawnEntity


func sleep(entity:Entity):
	sleeping_entity = entity
	available = false
	set_process(true)
	return true


func is_available():
	return available


func _process(delta: float) -> void:
	if sleeping_entity:
		if !world_node.is_at_grid_position(sleeping_entity,self.global_position):
			sleeping_entity.world_state.set_state("sleeping", false)
			available = true
			sleeping_entity = null
	else:
		set_process(false)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PawnEntity:
		body.world_state.set_state("sleeping", true)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is PawnEntity:
		body.world_state.set_state("sleeping", false)
