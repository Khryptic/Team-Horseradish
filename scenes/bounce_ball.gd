class_name Ball extends Node2D

@export var maxFallSpeed: float

@onready var rigidbody: RigidBody2D = $RigidBody2D
@onready var star_particles: GPUParticles2D = $StarParticles

func _ready() -> void:
	setFreeze(true)

func setFreeze(isFrozen: bool) -> void:
	rigidbody.set_deferred("freeze", isFrozen)

func crit() -> void:
	star_particles.position = rigidbody.position
	star_particles.rotation = rigidbody.linear_velocity.angle() + PI/2
	star_particles.restart()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if(state.linear_velocity.y >= maxFallSpeed):
		state.linear_velocity.y = maxFallSpeed
