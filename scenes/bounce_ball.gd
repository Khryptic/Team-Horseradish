extends Node2D

@onready var rigidbody: RigidBody2D = $RigidBody2D

func freezeBall(isFrozen: bool) -> void:
	rigidbody.setFreeze(isFrozen)

func _process(delta: float) -> void:
	if is_ball_stopped():
		GameManager.clear_on_pegs()

func is_ball_stopped() -> bool:
	if is_instance_valid(rigidbody):
		return rigidbody.linear_velocity.length() < 0.1	
	return false
		
