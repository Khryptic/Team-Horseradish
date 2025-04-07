extends RigidBody2D

@export var destination: Vector2
@export var acceleration_towards_destination: float
@export var max_speed: float

func _physics_process(delta: float) -> void:

    constant_force = (destination - position).normalized() * acceleration_towards_destination

    if(linear_velocity.length() > max_speed):
        linear_velocity = linear_velocity.normalized() * max_speed

    if(position.distance_to(destination) < 20):
        queue_free()