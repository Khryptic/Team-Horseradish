extends Node

signal multiply_score_just_earned(mult_score_just_earned)

var total_score: int = 0
var mult = 1;
var score_just_earned: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Point multiplier functions
func add_points(amount: int):
	score_just_earned += amount
	
func reset_mult_text():
	pass
func get_mult():
	return mult
	
func increase_mult(amount: int):
	mult += amount
	reset_mult_text()

func reset_mult_count():
	emit_signal("multiply_score_just_earned", score_just_earned * mult)
	total_score += score_just_earned * mult
	score_just_earned = 0
	mult = 1
	reset_mult_text()
	
