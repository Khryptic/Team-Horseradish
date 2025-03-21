class_name Ball extends Node2D

signal ball_died

@export var maxFallSpeed: float

@onready var rigidbody: RigidBody2D = $RigidBody2D
@onready var star_particles: GPUParticles2D = $StarParticles
@onready var smoke_particles: GPUParticles2D = $RigidBody2D/SmokeParticles
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	setFreeze(true)
	GameManager.round_clear.connect(tween_to_spawn_point)

func _process(_delta: float) -> void:
		
	if(smoke_particles.emitting):
		smoke_particles.global_rotation = 0;

	# Anti-softlock
	if is_ball_stopped():
		GameManager.clear_on_pegs()

func _on_area_entered(area: Node2D) -> void:
	if(!area.is_in_group("killzone")): return
	
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

func _physics_process(_delta: float) -> void:
	if(rigidbody.linear_velocity.y >= maxFallSpeed):
		rigidbody.linear_velocity.y = maxFallSpeed
		
func tween_to_spawn_point():
	var tween = rigidbody.create_tween()
	var end_point: Vector2 = Vector2(0,0) # REPLACE WITH REFERENCE
	tween.tween_property(rigidbody, "position", end_point, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_on_tween_finished)


func _on_tween_finished():
	setFreeze(true)
		
