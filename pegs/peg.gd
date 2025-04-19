class_name Peg extends StaticBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite2D: Sprite2D = $AnimationScale/Sprite2D
@onready var circle_shader: Sprite2D = $CircleShader
@onready var peg_sensor: Area2D = $PegSensor

@export var score_orb_scene: PackedScene
@export var burst_particles_scene: PackedScene
@export var peg_sprite: PegSprite

@export var final_peg_scaler: float
@export var min_orb_speed: float
@export var max_orb_speed: float
@export var min_orb_count: int
@export var max_orb_count: int

var is_light_on : bool = true

# Load different peg textures
var peg_scaler: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	sprite2D.set_texture(peg_sprite.sprite)
	circle_shader.set_instance_shader_parameter('color', peg_sprite.color)

	peg_sensor.peg_hit.connect(_on_peg_hit)
	GameManager.clear_pegs.connect(_remove_peg)

	peg_scaler = Vector2(final_peg_scaler, final_peg_scaler)
	
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.PEG_SPAWN)

func _on_peg_hit(_body: RigidBody2D):

	sprite2D.set_texture(peg_sprite.hit_sprite)

	animation_player.stop()
	animation_player.play("ball_hit")

	Input.vibrate_handheld(1, 0.1)

	if is_light_on:
		ScoreManager.increase_mult(1)
		PegManager.unlight_peg()
	is_light_on = false
	
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.PEG_HIT)

func spawn_score_orb():
	# Create score orb
	var orb: RigidBody2D = score_orb_scene.instantiate()

	orb.modulate = peg_sprite.color
	
	# Parent the new orb to the canvas layer so it renders above UI
	var canvas: CanvasLayer = $/root/Game/CanvasLayer
	canvas.call_deferred("add_child", orb)

	# Convert the peg's global position to the canvas layer's coordinate space
	var camera = get_viewport().get_camera_2d()
	var canvas_position = canvas.transform.affine_inverse() * camera.global_transform.affine_inverse() * global_position
	
	# Set the orb's position in the canvas
	orb.global_position = canvas_position

	# Set a random starting velocity with a random direction and speed
	var rand_angle = randf_range(0, 2*PI)
	var rand_dir: Vector2 = Vector2(cos(rand_angle), sin(rand_angle))
	var rand_speed = randf_range(min_orb_speed, max_orb_speed)
	orb.linear_velocity = rand_dir.normalized() * rand_speed

func _remove_peg():
	if(!is_light_on):
		
		for i in range(randi_range(min_orb_count, max_orb_count)):
			spawn_score_orb()

		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.PEG_DESTROY)
		PegManager._remove_peg(self) #tell peg manager to stop keeping reference of this peg bcus its dead now

		# Play the peg destroy animation
		var particles: GPUParticles2D = burst_particles_scene.instantiate()
		get_tree().current_scene.add_child(particles)
		particles.texture = peg_sprite.burst_sprite
		particles.global_position = global_position

		queue_free()


func increase_size():
	$AnimationScale/Sprite2D.scale *= peg_scaler
	$CollisionShape2D.scale *= peg_scaler
	$PegSensor/CollisionShape2D.scale *= peg_scaler