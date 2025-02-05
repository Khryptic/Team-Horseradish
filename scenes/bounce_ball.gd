extends CharacterBody2D

@export_category("Ball Properties")
@export var speed: float = 100.0
@export var downVel: float = 100.0
@export var velRedMult: float = 0.9
@export var gravityConstant: float = 15.0

func _ready():
	velocity = Vector2(0, downVel).normalized() * speed

func _physics_process(delta: float) -> void:
	
	# Bounce ball if it collides with anything, losing a little momentum
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal()) * velRedMult

	# Add constant gravity
	velocity += Vector2(0, gravityConstant)
