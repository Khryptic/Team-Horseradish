extends Area2D

@onready var red_x: Sprite2D = $"Red X"
@onready var line: Line2D = $Line2D

var point_a: Vector2:
	set(value):
		point_a = value
		line.points[0] = value
	get:
		return point_a

var point_b: Vector2:
	set(value):
		point_b = value
		line.points[1] = value
	get:
		return point_b

var default_color: Color = Color(1, 1, 1, 0.4):
	set(value): line.default_color = value
	get: return line.default_color

func _ready() -> void:
	line.add_point(Vector2(-10000, -10000))
	line.add_point(Vector2(-10000, -10000))

func reset():
	point_a = Vector2(-10000, -10000)
	point_b = Vector2(-10000, -10000)