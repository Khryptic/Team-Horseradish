extends Node2D

@onready var ball_prefab = preload("res://scenes/bounce_ball.tscn")

var ballStart: Vector2
var ball_ref

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ball_ref = get_tree().get_first_node_in_group("ball")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _respawn() -> void:
	var new_ball = ball_prefab.instantiate()
	new_ball.position = $"Respawn Anchor".global_position
	new_ball.add_to_group("ball")
	add_child(new_ball)
	
	ball_ref = get_tree().get_first_node_in_group("ball")

func _on_bottom_bounds_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		body.queue_free()
		_respawn()


func _on_drawing_controller_trampoline_drawn() -> void:
	ball_ref.freeze = false
