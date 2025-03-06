extends Node

signal lives_changed()
signal clear_pegs()
signal game_over()
signal respawn_ball()

var lives: int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	lives = 3
	lives_changed.emit()
	
func emit_respawn_ball():
	respawn_ball.emit()
