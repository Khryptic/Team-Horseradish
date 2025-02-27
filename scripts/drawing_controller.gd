extends Node2D

signal trampoline_drawn

@onready var trampoline: Trampoline = $"Trampoline"
@onready var drawing_guide: Trampoline = $"Drawing Guide"
@onready var red_x: Sprite2D = $"Drawing Guide/Red X"

@export var drawing_zone: Area2D
@export var max_trampoline_length: int = 300
@export var large_length: int = 300
@export var med_length: int = 200

@export var bullet_time_scale: float = 0.1
@export var bullet_time_duration: float = 1
@export var bullet_time_fade_to_normal = 0.5
var bullet_time_since_activation = 0

var trampoline_segment_collider: SegmentShape2D

var trampoline_lives: int # how many times the ball can bounce on trampoline

var starting_mouse_pos: Vector2 # where the player started drawing from

var _is_mouse_down: bool

var is_mouse_in_drawing_zone: bool # if the mouse is in drawing zone
var is_start_point_in_drawing_zone: bool # if the mouse was in drawing zone on mouse down
# this is needed in case the player starts drawing outside of drawing zone and releases mouse in zone 

var is_ball_in_drawing_zone: bool # if the ball is in the drawing zone, activate bullet time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	# Double-check that the player is still drawing to prevent false-positives
	if(!Input.is_action_pressed("Draw")):
		_is_mouse_down = false

	if(_is_mouse_down):
		_while_mouse_down()

	# check if bullet time is running out
	bullet_time_since_activation += _delta * (1 / Engine.time_scale)
	if (bullet_time_since_activation >= bullet_time_duration):
		# if bullet time duration has passed, tween back
		# to full speed based off bullet_time_fade_to_normal
		var time : float = bullet_time_since_activation - bullet_time_duration
		var percent_of_tween_complete : float = 1 + ((time-bullet_time_fade_to_normal)/bullet_time_fade_to_normal)
		var distance_tweened : float = 1 - bullet_time_scale
		var time_scale : float = bullet_time_scale + percent_of_tween_complete * distance_tweened
		Engine.time_scale = clamp(time_scale,bullet_time_scale,1)
		
func _unhandled_input(event: InputEvent) -> void:

	# Player started drawing
	if(event.is_action_pressed("Draw")):
		_is_mouse_down = true
		_on_mouse_down()
		
	# Player is finished drawing
	elif(event.is_action_released("Draw")):
		_is_mouse_down = false
		_on_mouse_released()

func _on_mouse_down():
	if (is_mouse_in_drawing_zone):
		var mouse_pos := get_global_mouse_position()
		starting_mouse_pos = mouse_pos
		
		# Show the drawing guide
		drawing_guide.point_a = mouse_pos
		drawing_guide.point_b = mouse_pos
		drawing_guide.default_color = Color(1, 1, 1, 0.4)
		
		#slow down time while drawing
		if (is_ball_in_drawing_zone):
			Engine.time_scale = bullet_time_scale
			bullet_time_since_activation = 0 
		
		is_start_point_in_drawing_zone = true
	else:
		# if started drawing outside zone
		is_start_point_in_drawing_zone = false

func _while_mouse_down():
	var mouse_pos := get_global_mouse_position()
	var end_point := get_trampoline_endpoint(starting_mouse_pos, mouse_pos)
	var trampoline_length := (starting_mouse_pos - end_point).length()

	drawing_guide.point_b = end_point
	
	if (!is_start_point_in_drawing_zone):
		# Trampoline is invalid
		drawing_guide.default_color = Trampoline.get_trampoline_color(0, 0.4)
	else:
		# Trampoline is valid
		drawing_guide.default_color = Trampoline.get_trampoline_color(get_trampoline_lives(trampoline_length), 0.4)

		# Put the X over the trampoline endpoint
		if (end_point.y <= drawing_zone.global_position.y):
			if(!red_x.visible): red_x.visible = true
			red_x.global_position = end_point
		else:
			if(red_x.visible): red_x.visible = false

func _on_mouse_released():
	# Return to normal speed
		Engine.time_scale = 1
		bullet_time_since_activation = 999
			
		drawing_guide.reset()
		if(red_x.visible): red_x.visible = false
			
		if (is_start_point_in_drawing_zone):	
			var end_point := get_trampoline_endpoint(starting_mouse_pos, get_global_mouse_position())
			
			# Check which direction the player drew the trampoline
			if(starting_mouse_pos.x < end_point.x):
				trampoline.point_a = starting_mouse_pos
				trampoline.point_b = end_point
			else:
				trampoline.point_a = end_point
				trampoline.point_b = starting_mouse_pos
			
			# set trampoline lives based off length of trampoline
			var trampoline_length: float = (trampoline.point_a - trampoline.point_b).length()
			trampoline.lives = get_trampoline_lives(trampoline_length)
						
			# Emit the signal
			trampoline_drawn.emit()
			
		# Trampoline is invalid	
		else:
			drawing_guide.reset()
					
		is_start_point_in_drawing_zone = false

func _on_trampoline_drawing_zone_mouse_exited() -> void:
	is_mouse_in_drawing_zone = false

func _on_trampoline_drawing_zone_mouse_entered() -> void:
	is_mouse_in_drawing_zone = true

func _on_trampoline_drawing_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		is_ball_in_drawing_zone = true
		if (is_start_point_in_drawing_zone):
			Engine.time_scale = bullet_time_scale
			bullet_time_since_activation = 0
		
	



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

func get_trampoline_endpoint(start_pos: Vector2, mouse_pos: Vector2) -> Vector2:
	
	var end_point := mouse_pos
	var shortest_length_squared := (mouse_pos - start_pos).length_squared()

	# Trampoline is above drawing zone
	if (!is_mouse_in_drawing_zone and is_start_point_in_drawing_zone):
		end_point = intersection_with_horizontal_line(start_pos, mouse_pos, drawing_zone.global_position.y)
		shortest_length_squared = (end_point - start_pos).length_squared()

	# Trampoline is too long
	if (mouse_pos - start_pos).length_squared() > max_trampoline_length * max_trampoline_length:
		var direction: Vector2 = (mouse_pos - start_pos).normalized()
		var length_squared := max_trampoline_length * max_trampoline_length
		
		# If this is the shortest length yet, this is the end point
		if(length_squared < shortest_length_squared):
			shortest_length_squared = length_squared
			end_point = start_pos + direction * max_trampoline_length

	return end_point
