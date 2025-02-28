class_name Trampoline extends Node2D

@export var trampoline_strength: float
@export var coyote_time_distance: float
@export var normal_speed_mult: float
@export var crit_speed_mult: float
@export var crit_lower_percentage: float
@export var crit_upper_percentage: float

@onready var area2d: Area2D = $Area2D
@onready var hitbox: CollisionShape2D = $Area2D/CollisionShape2D
@onready var line: Line2D = $Line2D

var overlapping_ball: RigidBody2D = null

var hitbox_shape: RectangleShape2D

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
		point_a = value
		line.points[0] = value
		update_hitbox()
	get:
		return point_a

var point_b: Vector2:
	set(value):
		point_b = value
		line.points[1] = value
		update_hitbox()
	get:
		return point_b

## Sets the hitbox height, keeping the top aligned with the trampoline
var hitbox_height: float:
	set(value):
		hitbox_shape.size.y = value
		hitbox.position.y = value / 2
	get:
		return hitbox_shape.size.y

func reset():
	point_a = Vector2(-10000, -10000)
	point_b = Vector2(-10000, -10000)

func update_hitbox():
	area2d.global_position = lerp(point_a, point_b, 0.5)
	area2d.rotation = atan2(point_b.y - point_a.y, point_b.x - point_a.x)
	hitbox_shape.size.x = point_a.distance_to(point_b)

func _ready() -> void:
	line.add_point(Vector2(-10000, -10000))
	line.add_point(Vector2(-10000, -10000))
	hitbox_shape = hitbox.shape
	hitbox_height = coyote_time_distance

func _process(delta: float) -> void:

	# If the ball was overlapping but now is not, deactivate coyote time
	if(overlapping_ball != null && !area2d.overlaps_body(overlapping_ball)):
		overlapping_ball = null
		hitbox_height = 5

func _on_body_entered(body: Node2D) -> void:
	if(!body is RigidBody2D): return

	overlapping_ball = body
	
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

func _on_trampoline_drawn(_trampoline: Trampoline) -> void:
	
	# Activate coyote time
	hitbox_height = coyote_time_distance

	# Wait a physics frame
	await get_tree().create_timer(0).timeout
	await get_tree().physics_frame

	# If the ball is not overlapping the trampoline, deactivate coyote time instantly
	if (overlapping_ball == null):

		# Deactivate coyote time instantly
		hitbox_height = 5

static func get_trampoline_color(remaining_lives: int, opacity: float) -> Color:

	var trampoline_colors = {
		3: Color(1, 1, 1, opacity),
		2: Color(1, 1, 0, opacity),
		1: Color(0.9, 0.5, 0, opacity),
		0: Color(1, 0, 0, opacity)
	}

	return trampoline_colors[remaining_lives]