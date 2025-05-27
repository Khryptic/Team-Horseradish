class_name Ball extends Node2D

signal ball_died

@export var maxFallSpeed: float

@onready var rigidbody: RigidBody2D = $RigidBody2D
@onready var star_particles: GPUParticles2D = $StarParticles
@onready var smoke_particles: GPUParticles2D = $RigidBody2D/SmokeParticles
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var face_animations: AnimatedSprite2D = $RigidBody2D/AnimatedSprite2D

var isPhaseModeOn: bool = false;

func _ready() -> void:
	setFreeze(true)
	GameManager.round_clear.connect(tween_to_spawn_point)
	rigidbody.set_collision_mask_value(2,true)
	

func _process(_delta: float) -> void:
		
	if(smoke_particles.emitting):
		smoke_particles.global_rotation = 0;
	
	if(isPhaseModeOn && rigidbody.linear_velocity.y > 0):
		toggle_phase_mode(false)		
		
	# Anti-softlock
	if is_ball_stopped():
		GameManager.clear_on_pegs()

func _on_area_entered(area: Node2D) -> void:
	if(area.is_in_group("peg")):
		if face_animations.animation == "Hit":
			face_animations.frame = 0
		else:
			face_animations.play("Hit")

	if(!area.is_in_group("killzone")): 
		return
	
	ball_died.emit()
	queue_free()

func is_ball_stopped() -> bool:
	if is_instance_valid(rigidbody):
		return rigidbody.linear_velocity.length() < 0.1	
	return false

func setFreeze(isFrozen: bool) -> void:
	rigidbody.set_deferred("freeze", isFrozen)

func crit() -> void:
	star_particles.position = rigidbody.position
	star_particles.rotation = rigidbody.linear_velocity.angle() + PI/2
	animation_player.stop()
	animation_player.play("crit")
	face_animations.play("Crit")
	
	toggle_phase_mode(true)

func bounce() -> void:
	face_animations.play("Bounce")

func bullet_time_activated() -> void:
	face_animations.play("Bullet Time")

func danger() -> void:
	face_animations.play("Scared")
	
func _physics_process(_delta: float) -> void:
	if(rigidbody.linear_velocity.y >= maxFallSpeed):
		rigidbody.linear_velocity.y = maxFallSpeed
		
func tween_to_spawn_point():
	rigidbody.set_collision_layer_value(1,false)
	var tween = rigidbody.create_tween()
	var end_point: Vector2 = Vector2(0,0) # REPLACE WITH REFERENCE
	tween.tween_property(rigidbody, "position", end_point, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_on_tween_finished)	
	face_animations.play("Idle")



func _on_tween_finished():
	rigidbody.set_collision_layer_value(1,true)
	setFreeze(true)
	
func toggle_phase_mode(value: bool):
	isPhaseModeOn = value
	rigidbody.set_collision_mask_value(1,!isPhaseModeOn)
	if (isPhaseModeOn == true):
		modulate.a= 0.5;
	else:
		modulate.a= 1.0;
