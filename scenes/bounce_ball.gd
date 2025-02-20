extends Node2D

func freezeBall(isFrozen: bool) -> void:
	$RigidBody2D.setFreeze(isFrozen)
