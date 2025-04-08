class_name Peg extends StaticBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $AnimationScale/Sprite2D
@onready var circle_shader: Sprite2D = $CircleShader
@export var final_peg_scaler: float
@export var min_orb_speed: float
@export var max_orb_speed: float
@export var min_orb_count: int
@export var max_orb_count: int

var is_light_on : bool = true

# Load different peg textures
const peg_yellow = preload("res://assets/SP_Peg_02a.PNG")
const peg_yellow_on = preload("res://assets/SP_Peg_04a.PNG")
const peg_blue = preload("res://assets/SP_Peg_02b.PNG")
const peg_blue_on = preload("res://assets/SP_Peg_04b.PNG")
const peg_red = preload("res://assets/SP_Peg_02c.PNG")
const peg_red_on = preload("res://assets/SP_Peg_04c.PNG")
const peg_green = preload("res://assets/SP_Peg_02d.PNG")
const peg_green_on = preload("res://assets/SP_Peg_04d.PNG")
const peg_purple = preload("res://assets/SP_Peg_02e.PNG")
const peg_purple_on = preload("res://assets/SP_Peg_04e.PNG")
const score_orb = preload("res://object_scenes/score_orb/score_orb.tscn")
var peg_scaler: Vector2

enum PegColor {
	YELLOW,
	BLUE,
	RED,
	GREEN,
	PURPLE
}

var peg_colors := {
	PegColor.YELLOW: Color(1, 1, 0.3725490196),
	PegColor.BLUE: Color(0.1843137255, 1, 1),
	PegColor.RED: Color(1, 0.3725490196, 0.3725490196),
	PegColor.GREEN: Color(0.5647058824, 1, 0.1843137255),
	PegColor.PURPLE: Color(1, 0.8, 1)
}

@onready var random_sprite = PegColor.values().pick_random()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("peg_sensor").peg_hit.connect(_on_peg_hit)
	GameManager.clear_pegs.connect(_remove_peg)

	circle_shader.set_instance_shader_parameter('color', peg_colors[random_sprite])

	# Get random peg sprite
	# sprite.set_texture(random_sprite)

	match random_sprite:
		PegColor.YELLOW:
			sprite.set_texture(peg_yellow)
		PegColor.BLUE:
			sprite.set_texture(peg_blue)
		PegColor.RED:
			sprite.set_texture(peg_red)
		PegColor.GREEN:
			sprite.set_texture(peg_green)
		PegColor.PURPLE:
			sprite.set_texture(peg_purple)
	
	peg_scaler = Vector2(final_peg_scaler, final_peg_scaler)
	
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.PEG_SPAWN)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_peg_hit():

	animation_player.stop()
	animation_player.play("ball_hit")

	Input.vibrate_handheld(1, 0.1)

	match random_sprite:
		PegColor.YELLOW:
			sprite.set_texture(peg_yellow_on)
		PegColor.BLUE:
			sprite.set_texture(peg_blue_on)
		PegColor.RED:
			sprite.set_texture(peg_red_on)
		PegColor.GREEN:
			sprite.set_texture(peg_green_on)
		PegColor.PURPLE:
			sprite.set_texture(peg_purple_on)

	if is_light_on:
		ScoreManager.increase_mult(1)
		PegManager.unlight_peg()
	is_light_on = false
	
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.PEG_HIT)

func spawn_score_orb():
	var orb: RigidBody2D = score_orb.instantiate()
	$/root/Game/CanvasLayer.call_deferred("add_child", orb)
	orb.global_position = get_viewport_transform() * global_position
	orb.modulate = peg_colors[random_sprite]
	
	var rand_angle = randf_range(0, 2*PI)
	var rand_dir: Vector2 = Vector2(cos(rand_angle), sin(rand_angle))
	var rand_speed = randf_range(min_orb_speed, max_orb_speed)
	orb.linear_velocity = rand_dir.normalized() * rand_speed

func _remove_peg():
	if(!is_light_on):
		
		for i in range(randi_range(min_orb_count, max_orb_count)):
			spawn_score_orb()

		queue_free()
		PegManager._remove_peg(self) #tell peg manager to stop keeping reference of this peg bcus its dead now

func increase_size():
	$AnimationScale/Sprite2D.scale *= peg_scaler
	$CollisionShape2D.scale *= peg_scaler
	$peg_sensor/CollisionShape2D.scale *= peg_scaler
	
