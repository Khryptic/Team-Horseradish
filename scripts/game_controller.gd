extends Node2D

@onready var ball_prefab = preload("res://scenes/bounce_ball.tscn")
@onready var respawn_point = $Respawn

@export var score_label: Label
@export var title_label: Label

var ball_ref: Ball

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	GameManager.respawn_ball.connect(_spawn_ball)
	GameManager.round_clear.connect(_on_round_cleared)
	start_new_level()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _spawn_ball() -> void:
	
	var new_ball := ball_prefab.instantiate()
	new_ball.global_position = respawn_point.global_position
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

func start_new_level():
	#reset score
	ScoreManager.reset_all()
	
	#set timer
	var timer = Timer.new()
	timer.wait_time = 2 # amount of seconds to display
	timer.one_shot = true
	add_child(timer)
	timer.start()
	timer.timeout.connect(_add_pegs.bind(GameManager.using_random))

	#show label
	if (PegManager.specific_level_to_play == 0):
		title_label.text = "Arcade"
	else:
		title_label.text = "Level " + str(PegManager.specific_level_to_play)
	title_label.show()

func _add_pegs(add_random: bool):
	title_label.hide()

	if (add_random):
		PegManager._add_random_pegs_to_scene()
		
	else:
		PegManager._add_pegs_to_scene()

func _on_trampoline_increase_final_peg_size() -> void:
	if (PegManager.current_pegs.size() == 1 && PegManager.has_peg_increased_size == false):
		var peg = PegManager.current_pegs[0]
		peg.increase_size()
		PegManager.has_peg_increased_size = true
		
func _on_round_cleared():
	#show label
	title_label.text = "Round cleared"
	title_label.show()
	
	#set timer
	var round_clear_timer = Timer.new()
	round_clear_timer.wait_time = 3 # amount of seconds to display
	round_clear_timer.one_shot = true
	add_child(round_clear_timer)
	round_clear_timer.start()
	round_clear_timer.timeout.connect(start_new_level)
	pass

func _on_danger_zone_area_entered(body):
	ball_ref.danger()

func _on_drawing_controller_bullet_time_activated():
	if (ball_ref != null): ball_ref.bullet_time_activated()
