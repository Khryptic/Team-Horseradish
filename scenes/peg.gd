extends StaticBody2D

var is_light_on : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("peg_sensor").peg_hit.connect(_turn_off_light)
	GameManager.clear_pegs.connect(_remove_peg)
	get_node("Sprite2D").self_modulate = Color(0, 0, 0, 1)





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _turn_off_light():
	get_node("Sprite2D").self_modulate = Color(255, 255, 255, 1)
	is_light_on = true
	get_node("peg_sensor").points_worth = 1

func _remove_peg():
	if(is_light_on):
		queue_free()
		PegManager._update_peg_count()
