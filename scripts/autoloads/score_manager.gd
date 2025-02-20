extends Node

signal score_updated(new_score)

var score: int = 0
var mult: int = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Point multiplier functions
func add_points(amount: int, mult: int):
	score += amount * mult
	emit_signal("score_updated", score, mult)
	
func reset_mult_text():
	emit_signal("score_updated", score, get_mult())

func get_mult():
	return mult
	
func increase_mult():
	mult += 1
	reset_mult_text()

func reset_mult_count():
	mult = 1
	reset_mult_text()
