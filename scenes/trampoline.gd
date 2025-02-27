class_name Trampoline extends Area2D

@export var trampoline_strength: float
@export var normal_speed_mult: float
@export var crit_speed_mult: float
@export var crit_lower_percentage: float
@export var crit_upper_percentage: float

@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var line: Line2D = $Line2D

var collider_shape: SegmentShape2D

# how many times the ball can bounce on trampoline
var lives: int:
	set(value):
		lives = value
		line.default_color = get_trampoline_color(lives, 1)
		if (lives <= 0):
			reset()
			
	get: return lives

var point_a: Vector2:
	set(value):
		collider_shape.a = value
		line.points[0] = value
	get:
		return collider_shape.a

var point_b: Vector2:
	set(value):
		collider_shape.b = value
		line.points[1] = value
	get:
		return collider_shape.b

func reset():
	point_a = Vector2(-10000, -10000)
	point_b = Vector2(-10000, -10000)

func _ready() -> void:
	line.add_point(Vector2(-10000, -10000))
	line.add_point(Vector2(-10000, -10000))

	collider_shape = collider.shape

func _on_body_entered(body: Node2D) -> void:
	if(body is RigidBody2D):
		# Calculate normal to the trampoline
		var segment_vec := point_b - point_a
		var segment_normal := Vector2(segment_vec.y, -segment_vec.x).normalized()
		
		# Set the body's velocity
		if(body.global_position > lerp(line.get_point_position(0), line.get_point_position(1), crit_lower_percentage) && 
		body.global_position < lerp(line.get_point_position(0), line.get_point_position(1), crit_upper_percentage)):
			body.linear_velocity = segment_normal * trampoline_strength * crit_speed_mult
		else:
			body.linear_velocity = segment_normal * trampoline_strength * normal_speed_mult
		
		# Remove a trampoline life
		lives -= 1
		
		# reset point multiplier
		ScoreManager.reset_mult_count()
		
		# tell game manager ball has bounced (used for clearing pegs)
		GameManager.clear_on_pegs()


static func get_trampoline_color(remaining_lives: int, opacity: float) -> Color:

	var trampoline_colors = {
		3: Color(1, 1, 1, opacity),
		2: Color(1, 1, 0, opacity),
		1: Color(0.9, 0.5, 0, opacity),
		0: Color(1, 0, 0, opacity)
	}

	return trampoline_colors[remaining_lives]
