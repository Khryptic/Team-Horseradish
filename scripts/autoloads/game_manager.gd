extends Node

signal lives_changed(new_lives)

var lives: int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func lose_life():
	lives -= 1
	emit_signal("lives_changed", lives)
