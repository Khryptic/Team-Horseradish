extends Node2D

signal trampoline_drawn

@export var trampoline_strength: float

@onready var trampoline_collision: CollisionShape2D = $Trampoline/CollisionShape2D
@onready var trampoline_line: Line2D = $Trampoline/Line2D
var trampoline_segment_collider: SegmentShape2D
var trampoline_start: Vector2

var trampoline_lives: int

func _ready() -> void:
	trampoline_segment_collider = trampoline_collision.shape

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("Draw")):
		var mouse_pos := get_global_mouse_position()
		
		# Save starting pos of mouse
		trampoline_start = mouse_pos
		
		#slow down time while drawing
		Engine.time_scale = 0.1
		
	elif(Input.is_action_just_released("Draw")):
		var mouse_pos := get_global_mouse_position()
		
		var left_side: Vector2
		var right_side: Vector2
		
		# Check which direction the player drew the trampoline
		if(trampoline_start.x < mouse_pos.x):
			left_side = trampoline_start
			right_side = mouse_pos
		else:
			left_side = mouse_pos
			right_side = trampoline_start
		
		trampoline_segment_collider.a = left_side
		trampoline_segment_collider.b = right_side
		
		# Set trampoline sprite
		trampoline_line.clear_points()
		trampoline_line.add_point(left_side)
		trampoline_line.add_point(right_side)
		
		trampoline_drawn.emit()
		
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
		
