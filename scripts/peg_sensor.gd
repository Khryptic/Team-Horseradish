extends Area2D

var floating_text = preload("res://scenes/floating_text.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#func _on_area_entered(area: Area2D) -> void:
	#if area.is_in_group("ball"):
		#ScoreManager.add_points(1, ScoreManager.get_mult())
		#ScoreManager.increase_mult()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		_display_hit_text()
		ScoreManager.add_points(1, ScoreManager.get_mult())
		ScoreManager.increase_mult()

func _display_hit_text():
	var text = floating_text.instantiate()
	var text_label = text.get_node("Label") as Label
	text_label.text = str(1 * ScoreManager.get_mult())
	add_child(text)
