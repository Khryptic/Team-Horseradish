extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ScoreManager.score_updated.connect(_on_score_updated)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_score_updated(score: int):
	text = "Score: " + str(score)
