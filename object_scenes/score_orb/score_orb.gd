extends RigidBody2D

@export var acceleration_towards_destination: float
@export var max_speed: float

@onready var score_label: Label = $/root/Game.score_label

var destination: Vector2

func _ready():
	destination = score_label.global_position

func _physics_process(_delta: float) -> void:

	constant_force = (destination - position).normalized() * acceleration_towards_destination

	if(linear_velocity.length() > max_speed):
		linear_velocity = linear_velocity.normalized() * max_speed

	if(position.distance_to(destination) < 20):
		queue_free()
