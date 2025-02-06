extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.lives_updated.connect(_on_lives_updated)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_lives_updated(lives: int):
	text = "Lives: " + str(lives)
	
