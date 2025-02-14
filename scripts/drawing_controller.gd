extends Node2D

signal trampoline_drawn

@export var trampoline_strength: float

@onready var trampoline_collision: CollisionShape2D = $Trampoline/CollisionShape2D
@onready var trampoline_line: Line2D = $Trampoline/Line2D
@onready var drawing_guide: Line2D = $"Drawing Guide"

@export var large_length: int = 300
@export var med_length: int = 200

var trampoline_segment_collider: SegmentShape2D

var trampoline_lives: int # how many times the ball can bounce on trampoline

var starting_mouse_pos: Vector2 # where the player started drawing from

var is_mouse_in_drawing_zone: bool # if the mouse is in drawing zone
var is_start_point_in_drawing_zone: bool # if the mouse was in drawing zone on mouse down
# this is needed in case the player starts drawing outside of drawing zone and releases mouse in zone 

var is_ball_in_drawing_zone: bool # if the ball is in the drawing zone, activate bullet time

func _ready() -> void:
	trampoline_segment_collider = trampoline_collision.shape

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	# Player started drawing
	if(Input.is_action_just_pressed("Draw")):
		if (is_mouse_in_drawing_zone):
			var mouse_pos := get_global_mouse_position()
			starting_mouse_pos = mouse_pos
			
			# Show the drawing guide
			drawing_guide.clear_points()
			drawing_guide.add_point(mouse_pos)
			drawing_guide.add_point(mouse_pos)
			drawing_guide.default_color = Color(1, 1, 1, 0.4)
			
			#slow down time while drawing
			if (is_ball_in_drawing_zone):
				Engine.time_scale = 0.1
			
			is_start_point_in_drawing_zone = true
		else:
			# if started drawing outside zone
			is_start_point_in_drawing_zone = false
		
	# Player is actively drawing
	elif(Input.is_action_pressed("Draw")):
		
		if (drawing_guide.points.size() > 0):
			drawing_guide.set_point_position(1, get_global_mouse_position())
		
		# Trampoline is invalid
		if (!is_mouse_in_drawing_zone or !is_start_point_in_drawing_zone):
			drawing_guide.default_color = Color(1, 0, 0, 0.4)
		else:
			drawing_guide.default_color = get_trampoline_color(get_trampoline_lives((starting_mouse_pos - get_global_mouse_position()).length()), 0.4)
		
	# Player is finished drawing
	elif(Input.is_action_just_released("Draw")):
		# Return to normal speed
		Engine.time_scale = 1
			
		drawing_guide.clear_points()
			
			
		if (is_mouse_in_drawing_zone && is_start_point_in_drawing_zone):	
			var mouse_pos := get_global_mouse_position()
			var left_side: Vector2
			var right_side: Vector2
			
			# Check which direction the player drew the trampoline
			if(starting_mouse_pos.x < mouse_pos.x):
				left_side = starting_mouse_pos
				right_side = mouse_pos
			else:
				left_side = mouse_pos
				right_side = starting_mouse_pos
					
			# Set trampoline collider
			trampoline_segment_collider.a = left_side
			trampoline_segment_collider.b = right_side
		
			# Set trampoline sprite
			trampoline_line.clear_points()
			trampoline_line.add_point(left_side)
			trampoline_line.add_point(right_side)
			
						# set trampoline lives based off length of trampoline
			var trampoline_length: int = (trampoline_segment_collider.a - trampoline_segment_collider.b).length()
			trampoline_lives = get_trampoline_lives(trampoline_length)
			
			#Get color for trampoline	
			trampoline_line.default_color = get_trampoline_color(trampoline_lives, 1)
			
			trampoline_drawn.emit()
			
		# Trampoline is invalid	
		else:
			trampoline_line.clear_points()
			
		# Emit the signal
		trampoline_drawn.emit()

func _on_trampoline_body_entered(body: Node2D) -> void:
	
	if(body is RigidBody2D):
		
		# Calculate normal to the trampoline
		var segment_vec := trampoline_segment_collider.b - trampoline_segment_collider.a
		var segment_normal := Vector2(segment_vec.y, -segment_vec.x).normalized()
		
		# Set the body's velocity
		body.linear_velocity = segment_normal * trampoline_strength
		
		# delete trampoline
		trampoline_lives -= 1
		if (trampoline_lives <= 0):
			trampoline_line.clear_points()
			trampoline_segment_collider.a = Vector2(-10000, -10000)
			trampoline_segment_collider.b = Vector2(-10000, -10000)
		
		# reset point multiplier
		ScoreManager.reset_mult_count()


func _on_trampoline_drawing_zone_mouse_exited() -> void:
	is_mouse_in_drawing_zone = false

func _on_trampoline_drawing_zone_mouse_entered() -> void:
	is_mouse_in_drawing_zone = true



func _on_trampoline_drawing_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		is_ball_in_drawing_zone = true
	



func _on_trampoline_drawing_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("ball"):
		is_ball_in_drawing_zone = false
		Engine.time_scale = 1

func get_trampoline_color(lives: int, opacity: float) -> Color:
	var new_color: Color
	match lives:
		3: 
			new_color = Color(1, 1, 1, opacity)
		2: 
			new_color = Color(1, 1, 0, opacity)
		1:
			new_color = Color(0.9, 0.5, 0, opacity)
	return new_color

func get_trampoline_lives(length: int) -> int:
	if (length > large_length):
		return 1
	elif (length > med_length):
		return 2
	else:
		return 3
	
