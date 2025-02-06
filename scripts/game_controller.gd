extends Node2D

@onready var out_bounds: CollisionShape2D = $"Bottom bounds"/CollisionShape2D
@onready var ball_prefab = preload("res://scenes/bounce_ball.tscn")

var ballStart: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _respawn() -> void:
	var new_ball = ball_prefab.instantiate()
	new_ball.position = $"Respawn Anchor".global_position
	add_child(new_ball)

func _on_bottom_bounds_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		_respawn()
