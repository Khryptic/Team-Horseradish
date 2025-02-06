extends Node

signal score_updated(new_score)

var score: int = 0
var streak: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func addPoints(amount: int):
	score += amount
	emit_signal("score_updated", score)
	print("Score: ", score)
