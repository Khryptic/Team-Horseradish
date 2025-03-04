class_name Ball extends Node2D

signal ball_died

@export var maxFallSpeed: float

@onready var rigidbody: RigidBody2D = $RigidBody2D
@onready var star_particles: GPUParticles2D = $StarParticles
@onready var smoke_particles: GPUParticles2D = $RigidBody2D/SmokeParticles
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	setFreeze(true)

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

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if(state.linear_velocity.y >= maxFallSpeed):
		state.linear_velocity.y = maxFallSpeed
