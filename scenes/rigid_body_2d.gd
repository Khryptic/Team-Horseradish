extends RigidBody2D

signal rigidbody_created(collision_shape: CollisionShape2D, is_center: bool)

func _ready() -> void:
	setFreeze(true)

func setFreeze(isFrozen:bool) -> void:
	set_deferred("freeze", isFrozen)
