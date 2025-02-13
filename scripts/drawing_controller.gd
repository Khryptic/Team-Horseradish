extends Node2D

signal trampoline_drawn

@export var trampoline_strength: float

@onready var trampoline_collision: CollisionShape2D = $Trampoline/CollisionShape2D
@onready var trampoline_line: Line2D = $Trampoline/Line2D
var trampoline_segment_collider: SegmentShape2D

var trampoline_lives: int

func _ready() -> void:
	trampoline_segment_collider = trampoline_collision.shape

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	# Player started drawing
	if(Input.is_action_just_pressed("Draw")):
		var mouse_pos := get_global_mouse_position()
		
		# Start drawing the trampoline's sprite
		trampoline_line.clear_points()
		trampoline_line.add_point(mouse_pos)
		trampoline_line.add_point(mouse_pos)	
		trampoline_line.default_color = Color(1, 1, 1, 0.4)
		
		#slow down time while drawing
		Engine.time_scale = 0.1
		
	# Player is actively drawing
	elif(Input.is_action_pressed("Draw")):
		trampoline_line.set_point_position(1, get_global_mouse_position())
		
	# Player is finished drawing
	elif(Input.is_action_just_released("Draw")):
		var mouse_pos := get_global_mouse_position()
		
		var left_side: Vector2
		var right_side: Vector2
		
		# Check which direction the player drew the trampoline
		if(trampoline_line.get_point_position(0).x < mouse_pos.x):
			left_side = trampoline_line.get_point_position(0)
			right_side = mouse_pos
		else:
			left_side = mouse_pos
			right_side = trampoline_line.get_point_position(0)
		
		# Set trampoline collider
		trampoline_segment_collider.a = left_side
		trampoline_segment_collider.b = right_side
		
		# Set trampoline sprite
		trampoline_line.set_point_position(0, left_side)
		trampoline_line.set_point_position(1, right_side)
		trampoline_line.default_color = Color(1, 1, 1, 1)
		
		# Return to normal speed
		Engine.time_scale = 1
		
		# set trampoline lives based off length of trampoline
		var trampoline_length: int = (trampoline_segment_collider.a - trampoline_segment_collider.b).length()
		if (trampoline_length > 300):
			trampoline_lives = 1
		elif (trampoline_length > 200):
			trampoline_lives = 1
		else:
			trampoline_lives = 1
			
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
		
