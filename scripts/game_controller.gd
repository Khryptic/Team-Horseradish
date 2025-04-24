extends Node2D

@onready var ball_prefab = preload("res://scenes/bounce_ball.tscn")
@onready var respawn_point = $Respawn

@export var score_label: Label
@export var title_label: Label
@export var level_clear_menu: Panel

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
	add_child.call_deferred(new_ball)
	new_ball.ball_died.connect(_on_ball_died)
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
	PegManager.reset()
	
	#set timer
	var timer = Timer.new()
	timer.wait_time = 2 # amount of seconds to display
	timer.one_shot = true
	add_child(timer)
	timer.start()
	timer.timeout.connect(_add_pegs.bind(GameManager.using_random))

	#show label
	if (PegManager.specific_level_to_play == 0):
		title_label.text = ""
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
	#check high score
	var current_level_id: String = PegManager.all_peg_layouts[PegManager.specific_level_to_play].id - 1

	if ScoreManager.total_score > SaveManager.high_scores.get_or_add(current_level_id, 0):
		SaveManager.high_scores[current_level_id] = ScoreManager.total_score
		SaveManager.save_game()

	#show label
	title_label.text = "Level cleared!"
	title_label.show()
	
	#set timer
	var round_clear_timer = Timer.new()
	round_clear_timer.wait_time = 3 # amount of seconds to display
	round_clear_timer.one_shot = true
	add_child(round_clear_timer)
	round_clear_timer.start()
	
	if (PegManager.specific_level_to_play > 0):
		round_clear_timer.timeout.connect(_show_level_cleared_menu)
	else:
		round_clear_timer.timeout.connect(GameManager.start_random_level)

func _on_drawing_controller_bullet_time_activated():
	if (ball_ref != null): ball_ref.bullet_time_activated()

func _on_danger_zone_body_entered(body:Node2D) -> void:
	if (body.is_in_group("ball") and ball_ref != null):
		ball_ref.danger()
		
func _show_level_cleared_menu():
	title_label.hide()
	
	#get references to labels
	var goal1_label = level_clear_menu.get_node("StarGoal1") as Label
	var goal2_label = level_clear_menu.get_node("StarGoal2") as Label
	var goal3_label = level_clear_menu.get_node("StarGoal3") as Label
	var level_clear_score_label = level_clear_menu.get_node("Score") as Label
	var level_clear_label = level_clear_menu.get_node("LevelClear") as Label
	
	# show menu and update star goals and score count
	level_clear_menu.show()
	goal1_label.text = str(int(PegManager.star_goals[0]))
	goal2_label.text = str(int(PegManager.star_goals[1]))
	goal3_label.text = str(int(PegManager.star_goals[2]))
	level_clear_score_label.text = str(int(ScoreManager.total_score))
	level_clear_label.text = "Level " + str(PegManager.specific_level_to_play) + " Cleared!"


func _on_level_cleared_menu_restart_button_pressed() -> void:
	# if restart is pressed than restart level just played
	level_clear_menu.hide()
	ScoreManager.total_score = 0
	ScoreManager.reset_mult_count()
	PegManager.reset()
	GameManager.start_new_level()
	pass # Replace with function body.


func _on_level_cleared_menu_resume_button_pressed() -> void:
	# if resume button is presssed go to next level
	print("hey i got clicked")
	level_clear_menu.hide()
	GameManager.load_next_level()
	pass # Replace with function body.


func _on_level_cleared_menu_home_button_pressed() -> void:
	SceneManager.change_scene(SceneManager.SCENE.LEVEL_SELECT_MENU)
