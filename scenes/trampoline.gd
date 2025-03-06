class_name Trampoline extends Node2D

@export var trampoline_strength: float
@export var coyote_time_distance: float
@export var normal_speed_mult: float
@export var crit_speed_mult: float
@export var crit_lower_percentage: float
@export var crit_upper_percentage: float

@export var added_impulse: float

@onready var area2d: Area2D = $Area2D
@onready var hitbox: CollisionShape2D = $Area2D/CollisionShape2D
@onready var line: Line2D = $Line2D
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

var overlapping_ball_body: RigidBody2D = null

var hitbox_shape: RectangleShape2D

signal increase_final_peg_size()

# how many times the ball can bounce on trampoline
var lives: int:
	set(value):
		lives = value
		line.default_color = get_trampoline_color(lives, 1)
		animation.self_modulate = get_trampoline_color(lives, 1)
		# if (lives <= 0):
		# 	reset()
		# Moved this to _on_animation_finished()
			
	get: return lives

var point_a: Vector2:
	set(value):
		point_a = value
		line.points[0] = value
		update_hitbox()
		update_sprite()
	get:
		return point_a

var point_b: Vector2:
	set(value):
		point_b = value
		line.points[1] = value
		update_hitbox()
		update_sprite()
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

func update_sprite():
	animation.global_position = lerp(point_a, point_b, 0.5)
	animation.rotation = atan2(point_b.y - point_a.y, point_b.x - point_a.x)
	animation.scale.x = point_a.distance_to(point_b) / 437 ## 437 is the length of the trampoline asset

func _ready() -> void:
	line.add_point(Vector2(-10000, -10000))
	line.add_point(Vector2(-10000, -10000))
	hitbox_shape = hitbox.shape
	hitbox_height = coyote_time_distance

func _process(_delta: float) -> void:

	# If the ball was overlapping but now is not, deactivate coyote time
	if(overlapping_ball_body != null && !area2d.overlaps_body(overlapping_ball_body)):
		overlapping_ball_body = null
		hitbox_height = 5

func _on_body_entered(body: Node2D) -> void:
	if(!body.is_in_group("ball")): return

	overlapping_ball_body = body
	var ball: Ball = body.get_parent()
	
	# Calculate normal to the trampoline
	var segment_vec := point_b - point_a
	var segment_normal := Vector2(segment_vec.y, -segment_vec.x).normalized()
	
	# Set the body's velocity
	if(body.global_position > lerp(line.get_point_position(0), line.get_point_position(1), crit_lower_percentage) && 
	body.global_position < lerp(line.get_point_position(0), line.get_point_position(1), crit_upper_percentage)):
		body.linear_velocity = segment_normal * trampoline_strength * crit_speed_mult
		ball.crit()
		animation.play("Crit")
	else:
		body.linear_velocity = segment_normal * trampoline_strength * normal_speed_mult
		animation.play("Bounce")
	
		
	# Add some bias if trampoline is too steeo
	var segment_angle = segment_vec.angle()
	if (segment_angle >= abs(deg_to_rad(45.0)) && segment_angle <= abs(deg_to_rad(90.0))):
		# Impulse must be a negtive or else the ball will shoot downwards
		body.apply_impulse(Vector2(0.0, added_impulse))
		
	# Remove a trampoline life
	lives -= 1
	
	# Check for last peg
	increase_final_peg_size.emit()
	
	# reset point multiplier
	ScoreManager.reset_mult_count()
	
	# tell game manager ball has bounced (used for clearing pegs)
	GameManager.clear_on_pegs()

	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.TRAMPOLINE_BOUNCE)


func _on_trampoline_drawn(_trampoline: Trampoline) -> void:
	
	# Activate coyote time
	hitbox_height = coyote_time_distance

	# Wait a physics frame
	await get_tree().create_timer(0).timeout
	await get_tree().physics_frame

	# If the ball is not overlapping the trampoline, deactivate coyote time instantly
	if (overlapping_ball_body == null):

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

func _on_animation_finished():

	# reset if required after playing animation
	if (lives <= 0):
			reset()

	animation.play("Static")
