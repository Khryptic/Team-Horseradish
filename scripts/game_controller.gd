extends Node2D

@onready var ball_prefab = preload("res://scenes/bounce_ball.tscn")
@onready var respawn_point = $Respawn

@export var ball_ref: Ball

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	_add_random_set_of_pegs()
	GameManager.start_new_level
	GameManager.respawn_ball.connect(_spawn_ball)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	print(DisplayServer.window_get_size())
	pass

func _spawn_ball() -> void:
	
	var new_ball := ball_prefab.instantiate()
	new_ball.position = respawn_point.global_position
	call_deferred("add_child", new_ball)
	new_ball.connect("ball_died", _on_ball_died)
	ball_ref = new_ball


func _on_ball_died() -> void:

	GameManager.lose_life()
	if(GameManager.lives <= 0): return

	ScoreManager.reset_mult_count()
	GameManager.clear_on_pegs()

func _on_drawing_controller_trampoline_drawn(_trampoline: Trampoline) -> void:
	if(ball_ref != null): ball_ref.setFreeze(false)

func _add_random_set_of_pegs():
	PegManager._add_pegs_to_scene()

func _on_trampoline_increase_final_peg_size() -> void:
	if (PegManager.unlit_pegs == 1 && PegManager.has_peg_increased_size == false):
		var peg = get_tree().get_nodes_in_group("peg")[0]
		peg.increase_size()
		PegManager.has_peg_increased_size = true
