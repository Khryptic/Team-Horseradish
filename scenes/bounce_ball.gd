extends CharacterBody2D

var speed = 100.0

func _ready():
	velocity = Vector2(0, 100).normalized() * speed

func _physics_process(delta: float) -> void:
	
	# Bounce ball if it collides with anything, losing a little momentum
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal()) * 0.9

	# Add constant gravity
	velocity += Vector2(0, 45)
