extends StaticBody2D

var is_light_on : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("peg_sensor").peg_hit.connect(_turn_off_light)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _turn_off_light():
	get_node("Sprite2D").self_modulate = Color(0, 0, 0, 1)
	is_light_on = false
	get_node("peg_sensor").points_worth = 1
