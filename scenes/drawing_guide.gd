extends Trampoline

@export var coyote_time_distance: float = 50

@onready var red_x: Sprite2D = $"Red X"

var _most_recent_ball: Node2D = null

var default_color: Color = Color(1, 1, 1, 0.4):
	set(value): line.default_color = value
	get: return line.default_color

func _on_body_entered(body: Node2D) -> void:

	if(body is RigidBody2D):
		_most_recent_ball = body
		print("Coyote Time Active!")
	

func _on_trampoline_drawn(trampoline: Trampoline) -> void:
	
	if (_most_recent_ball == null): return

	var closest_point := Math.closest_point_on_line(trampoline.point_a, trampoline.point_b, _most_recent_ball.global_position, true)
	var dist_squared := closest_point.distance_squared_to(_most_recent_ball.global_position)	

	if (dist_squared < coyote_time_distance * coyote_time_distance and _most_recent_ball.global_position.y > closest_point.y):
		trampoline._on_body_entered(_most_recent_ball)
		trampoline.lives += 1