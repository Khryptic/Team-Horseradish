extends Node

signal score_updated(new_score)

var score: int = 0
var mult: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Point multiplier functions
func add_points(amount: int, mult: int):
	score += amount * mult
	emit_signal("score_updated", score)

func GetMult():
	return mult
	
func increaseMult():
	mult += 1

func ResetMult():
	mult = 0
