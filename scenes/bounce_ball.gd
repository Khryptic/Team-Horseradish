class_name Ball extends Node2D

@export var maxFallSpeed: float

@onready var rigidbody: RigidBody2D = $RigidBody2D

func _ready() -> void:
	setFreeze(true)

func setFreeze(isFrozen: bool) -> void:
	rigidbody.set_deferred("freeze", isFrozen)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if(state.linear_velocity.y >= maxFallSpeed):
		state.linear_velocity.y = maxFallSpeed