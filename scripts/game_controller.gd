extends Node2D

@onready var ball_prefab = preload("res://scenes/bounce_ball.tscn")
@onready var respawn_point = $Respawn

@export var ball_ref: Ball

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	_add_random_set_of_pegs()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _respawn() -> void:
	GameManager.lose_life()
	
	if(GameManager.lives <= 0):
		return
	
	var new_ball := ball_prefab.instantiate()
	new_ball.position = respawn_point.global_position
	call_deferred("add_child", new_ball)

	ball_ref = new_ball

func _on_drawing_controller_trampoline_drawn(_trampoline: Trampoline) -> void:
	if(ball_ref != null): ball_ref.setFreeze(false)

func _on_bounds_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		ScoreManager.reset_mult_count()
		body.call_deferred("free")
		_respawn()
		GameManager.clear_on_pegs()

func _add_random_set_of_pegs():
	PegManager._add_pegs_to_scene()
