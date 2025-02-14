extends Node2D

var opacity : float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y += delta * 20
	opacity -= delta
	modulate = Color(255, 255, 255, opacity)
	
	if (opacity <= 0):
		queue_free()
	
	
