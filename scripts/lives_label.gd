extends Label

@export var lives_icons: Array[Sprite2D] # Stores Icons for lives
@export var life_icon_end_tween : Vector2
@export var tween_duration : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.lives_changed.connect(_tween_life_icon_to_starting_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _tween_life_icon_to_starting_position():
	if is_instance_valid(lives_icons[(GameManager.lives - 1)]):
		var life_icon : Sprite2D = lives_icons[(GameManager.lives - 1)]
		var tween = life_icon.create_tween()
		tween.tween_property(life_icon, "position", life_icon_end_tween, tween_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(_on_tween_finished)


func _on_tween_finished():
	var life_icon : Sprite2D = lives_icons[(GameManager.lives - 1)]
	life_icon.hide() 
	life_icon.queue_free()
	GameManager.emit_respawn_ball()
