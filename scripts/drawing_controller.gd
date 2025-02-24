extends Node2D

signal trampoline_drawn

@onready var trampoline: Trampoline = $"Trampoline"
@onready var drawing_guide: Line2D = $"Drawing Guide"
@onready var red_x: Sprite2D = $"Drawing Guide/Red X"

@export var drawing_zone: Area2D
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
		
		var mouse_pos := get_global_mouse_position()
		var end_point := get_trampoline_endpoint(starting_mouse_pos, mouse_pos)
		var trampoline_length := (starting_mouse_pos - end_point).length()

		if (drawing_guide.points.size() >= 2):
			drawing_guide.points[1] = end_point
		
		if (!is_start_point_in_drawing_zone):
			# Trampoline is invalid
			drawing_guide.default_color = Trampoline.get_trampoline_color(0, 0.4)
		else:
			# Trampoline is valid
			drawing_guide.default_color = Trampoline.get_trampoline_color(get_trampoline_lives(trampoline_length), 0.4)

			# Put the X over the trampoline endpoint
			if (!is_mouse_in_drawing_zone):
				if(!red_x.visible): red_x.visible = true
				red_x.global_position = end_point
			else:
				if(red_x.visible): red_x.visible = false
		
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

func intersection_with_horizontal_line(point_a: Vector2, point_b: Vector2, y: float) -> Vector2:
	
	# Two point formula for a line solved for X. Since the Y is known, we can calculate the X to get the intercept.
	var x: float = (y - point_a.y) * (point_b.x - point_a.x) / (point_b.y - point_a.y) + point_a.x
	
	return Vector2(x, y)

func get_trampoline_endpoint(start_pos, mouse_pos) -> Vector2:
	if (!is_mouse_in_drawing_zone and is_start_point_in_drawing_zone):
		return intersection_with_horizontal_line(start_pos, mouse_pos, drawing_zone.global_position.y)

	return mouse_pos
