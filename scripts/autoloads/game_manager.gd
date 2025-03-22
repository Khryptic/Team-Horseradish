extends Node

signal lives_changed()
signal clear_pegs()
signal game_over()
signal respawn_ball()
signal round_clear()

enum GAME_STATE{
	PLAYING,
	PAUSED,
	TRANSITION
}

var lives: int = 3
var CURRENT_STATE : GAME_STATE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ProjectSettings.set_setting("display/window/size/window_height_override", DisplayServer.screen_get_size()[0])
	CURRENT_STATE = GAME_STATE.TRANSITION
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func lose_life():
	lives -= 1
	lives_changed.emit()
	
	if(lives <= 0):
		game_over.emit()

func clear_on_pegs():
	clear_pegs.emit()
	
func start_new_level():
	CURRENT_STATE = GAME_STATE.TRANSITION

	lives = 3
	lives_changed.emit()
	get_tree().reload_current_scene()
	ScoreManager.score = 0
	ScoreManager.reset_mult_count()
	
func emit_respawn_ball():
	respawn_ball.emit()
	CURRENT_STATE = GAME_STATE.PLAYING

	
func start_round():
	CURRENT_STATE = GAME_STATE.PLAYING

	
func emit_round_clear():
	round_clear.emit()
	CURRENT_STATE = GAME_STATE.TRANSITION
