extends RigidBody2D

signal rigidbody_created(collision_shape: CollisionShape2D, is_center: bool)

@export var maxFallSpeed: float

func _ready() -> void:
	setFreeze(true)

func setFreeze(isFrozen: bool) -> void:
	set_deferred("freeze", isFrozen)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if(state.linear_velocity.y >= maxFallSpeed):
		state.linear_velocity.y = maxFallSpeed
