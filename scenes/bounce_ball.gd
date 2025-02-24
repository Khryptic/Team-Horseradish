extends Node2D

@onready var rigidbody: RigidBody2D = $RigidBody2D

func freezeBall(isFrozen: bool) -> void:
	rigidbody.setFreeze(isFrozen)