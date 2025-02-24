extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.lives_changed.connect(_on_lives_changed)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Resets lives text and the lives counter
func _on_lives_changed(lives: int):
	text = "Lives: " + str(lives)
