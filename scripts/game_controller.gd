extends Node2D

@onready var ball_prefab = preload("res://scenes/bounce_ball.tscn")

var ballStart: Vector2
var ball_ref
var new_ball

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ball_ref = get_tree().get_first_node_in_group("ball").get_child(0)
	ball_ref.add_to_group("ball")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _respawn() -> void:
	new_ball = ball_prefab.instantiate()
	new_ball.position = $Respawn.global_position
	new_ball.get_child(0).add_to_group("ball")
	call_deferred("add_child", new_ball)
	GameManager.lose_life()
		
	ball_ref = new_ball.get_child(0)

func _on_drawing_controller_trampoline_drawn() -> void:
	ball_ref.setFreeze(false)

func _on_bounds_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		ScoreManager.reset_mult_count()
		body.call_deferred("free")
		_respawn()
		
