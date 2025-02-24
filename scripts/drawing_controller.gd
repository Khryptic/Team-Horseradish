extends Node2D

signal trampoline_drawn

@onready var trampoline: Trampoline = $"Trampoline"
@onready var drawing_guide: Line2D = $"Drawing Guide"

@export var large_length: int = 300
@export var med_length: int = 200

var starting_mouse_pos: Vector2 # where the player started drawing from

var is_mouse_in_drawing_zone: bool # if the mouse is in drawing zone
var is_start_point_in_drawing_zone: bool # if the mouse was in drawing zone on mouse down
# this is needed in case the player starts drawing outside of drawing zone and releases mouse in zone 

var is_ball_in_drawing_zone: bool # if the ball is in the drawing zone, activate bullet time

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
			drawing_guide.default_color = Trampoline.get_trampoline_color(0, 0.4)
		else:
			drawing_guide.default_color = Trampoline.get_trampoline_color(get_trampoline_lives((starting_mouse_pos - get_global_mouse_position()).length()), 0.4)
		
	# Player is finished drawing
	elif(Input.is_action_just_released("Draw")):
		# Return to normal speed
		Engine.time_scale = 1
			
		drawing_guide.clear_points()
			
			
		if (is_mouse_in_drawing_zone && is_start_point_in_drawing_zone):	
			var mouse_pos := get_global_mouse_position()
			
			# Check which direction the player drew the trampoline
			if(starting_mouse_pos.x < mouse_pos.x):
				trampoline.point_a = starting_mouse_pos
				trampoline.point_b = mouse_pos
			else:
				trampoline.point_a = mouse_pos
				trampoline.point_b = starting_mouse_pos
			
			# set trampoline lives based off length of trampoline
			var trampoline_length: float = (trampoline.point_a - trampoline.point_b).length()
			trampoline.lives = get_trampoline_lives(trampoline_length)
						
			# Emit the signal
			trampoline_drawn.emit()
			
		# Trampoline is invalid	
		else:
			drawing_guide.clear_points()
					
		is_start_point_in_drawing_zone = false

func _on_trampoline_drawing_zone_mouse_exited() -> void:
	is_mouse_in_drawing_zone = false

func _on_trampoline_drawing_zone_mouse_entered() -> void:
	is_mouse_in_drawing_zone = true



func _on_trampoline_drawing_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		is_ball_in_drawing_zone = true
		if (is_start_point_in_drawing_zone):
			Engine.time_scale = 0.1



func _on_trampoline_drawing_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("ball"):
		is_ball_in_drawing_zone = false
		Engine.time_scale = 1

func get_trampoline_lives(length: float) -> int:
	if (length > large_length):
		return 1
	elif (length > med_length):
		return 2
	else:
		return 3
