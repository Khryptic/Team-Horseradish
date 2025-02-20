extends RigidBody2D

signal rigidbody_created(collision_shape: CollisionShape2D, is_center: bool)

var linearVel: Vector2
var angularVel: float

func _ready() -> void:
	setFreeze(true)
	linearVel = linear_velocity
	angularVel = angular_velocity

func setFreeze(isFrozen: bool) -> void:
	set_deferred("freeze", isFrozen)
