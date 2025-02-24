extends Node

signal lives_changed(new_lives)
signal clear_pegs()
signal game_over()

var lives: int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func lose_life():
	lives -= 1
	lives_changed.emit(lives)
	
	if(lives <= 0):
		game_over.emit()

func clear_on_pegs():
	clear_pegs.emit()