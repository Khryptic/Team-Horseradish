extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.connect("game_over", on_game_over)

func on_game_over():
	visible = true
	$Timer.start()

func _on_timer_timeout() -> void:
	GameManager.start_new_level()
