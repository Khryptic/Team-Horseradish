extends StaticBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_light_on : bool = true

# Load different peg textures
const peg_yellow = preload("res://assets/SP_Peg_01a.PNG")
const peg_blue = preload("res://assets/SP_Peg_01b.PNG")
const peg_red = preload("res://assets/SP_Peg_01c.PNG")
const peg_green = preload("res://assets/SP_Peg_01d.PNG")
const peg_purple = preload("res://assets/SP_Peg_01e.PNG")
const peg_white = preload("res://assets/SP_Peg_01f.PNG")
var peg_sprites = [peg_yellow, peg_blue, peg_red, peg_green, peg_purple, peg_white]
var random_sprite = peg_sprites[randi() % peg_sprites.size()]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("peg_sensor").peg_hit.connect(_on_peg_hit)
	GameManager.clear_pegs.connect(_remove_peg)

	# Get random peg sprite
	get_node("Sprite2D").set_texture(random_sprite)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_peg_hit():

	animation_player.stop()
	animation_player.play("ball_hit")

	get_node("Sprite2D").self_modulate = Color8(80, 80, 80, 255)

	if is_light_on:
		get_node("peg_sensor").points_worth /= 10
	is_light_on = false
	

func _remove_peg():
	if(!is_light_on):
		queue_free()
		PegManager._update_peg_count()
