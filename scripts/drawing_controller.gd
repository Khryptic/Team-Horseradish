extends Node2D

signal trampoline_drawn(trampoline: Trampoline)
signal bullet_time_activated

@onready var trampoline: Trampoline = $"Trampoline"
@onready var drawing_guide: Area2D = $"Drawing Guide"
@onready var drawing_zone: Area2D = $"TrampolineDrawingZone"
@onready var drawing_zone_polygon: CollisionPolygon2D = $"TrampolineDrawingZone/CollisionPolygon2D"

@export var max_trampoline_length: int = 300
@export var bullet_time_scale: float = 0.1
@export var bullet_time_duration: float = 1
@export var bullet_time_fade_to_normal = 0.5
var bullet_time_since_activation = 0

var trampoline_segment_collider: SegmentShape2D

var trampoline_lives: int = 3 # how many times the ball can bounce on trampoline

var starting_mouse_pos: Vector2 # where the player started drawing from
var old_mouse_pos: Vector2 # the mouse pos from the previous frame

var _is_mouse_down: bool

var is_start_point_in_drawing_zone: bool = false # if the mouse was in drawing zone on mouse down
# this is needed in case the player starts drawing outside of drawing zone and releases mouse in zone

var can_draw: bool = true # Prevents players from spam-drawing trampolines 

#var is_ball_in_drawing_zone: bool # if the ball is in the drawing zone, activate bullet time

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
	if GameManager.CURRENT_STATE != GameManager.GAME_STATE.PLAYING:
		return
	var mouse_pos := get_global_mouse_position()
	starting_mouse_pos = mouse_pos
	
	var is_mouse_in_drawing_zone: bool = Geometry2D.is_point_in_polygon(mouse_pos, drawing_zone_polygon.polygon)
	
	if (is_mouse_in_drawing_zone):

		# Show the drawing guide
		drawing_guide.point_a = mouse_pos
		drawing_guide.point_b = mouse_pos
		drawing_guide.default_color = Color(1, 1, 1, 0.4)
		
		#slow down time while drawing
		Engine.time_scale = bullet_time_scale
		bullet_time_since_activation = 0 
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.BULLET_TIME)
		bullet_time_activated.emit()
		
		is_start_point_in_drawing_zone = true
	else:
		# if started drawing outside zone
		is_start_point_in_drawing_zone = false

func _while_mouse_down():
	if GameManager.CURRENT_STATE != GameManager.GAME_STATE.PLAYING:
		return
		
	var mouse_pos := get_global_mouse_position()

	var is_mouse_in_drawing_zone: bool = Geometry2D.is_point_in_polygon(mouse_pos, drawing_zone_polygon.polygon)

	if (is_start_point_in_drawing_zone):
		var end_point := get_trampoline_endpoint(starting_mouse_pos, mouse_pos)
		drawing_guide.default_color = Trampoline.get_trampoline_color(trampoline_lives, 0.4)
		drawing_guide.point_b = end_point

	# Start point not in drawing zone. Check if mouse has entered it
	elif(is_mouse_in_drawing_zone):

		# Get exact point where the mouse entered the drawing zone
		var mouse_entry_point = Math.segment_intersects_polygon(old_mouse_pos, mouse_pos, drawing_zone_polygon.polygon)
		if (mouse_entry_point != null):

			# Nudge the start point so it's not exactly on the edge of the drawing zone
			# This prevents false positives when checking if the mouse has left the zone
			var line_dir: Vector2 = (mouse_pos - old_mouse_pos).normalized()
			var nudged_entry_point: Vector2 = mouse_entry_point + line_dir * 0.01
			starting_mouse_pos = nudged_entry_point
		else:
			push_error("Error: mouse entry point is null")
			starting_mouse_pos = mouse_pos

		# Set starting point data and begin drawing
		is_start_point_in_drawing_zone = true
		drawing_guide.point_a = starting_mouse_pos
		drawing_guide.point_b = starting_mouse_pos
		drawing_guide.default_color = Color(1, 1, 1, 0.4)

	old_mouse_pos = mouse_pos

func _on_mouse_released():
	if GameManager.CURRENT_STATE != GameManager.GAME_STATE.PLAYING:
		return

	# Return to normal speed
	Engine.time_scale = 1
	bullet_time_since_activation = 999
		
	drawing_guide.reset()
	#if(red_x.visible): red_x.visible = false
		
	if (is_start_point_in_drawing_zone):
		
		var end_point := get_trampoline_endpoint(starting_mouse_pos, get_global_mouse_position())
		
		# Prevent trampoline from being too small
		if (absf(end_point.x - starting_mouse_pos.x) < 10 ||
			can_draw == false):
			is_start_point_in_drawing_zone = false
			return
		
		# Check which direction the player drew the trampoline
		elif(starting_mouse_pos.x < end_point.x):
			trampoline.point_a = starting_mouse_pos
			trampoline.point_b = end_point
		else:
			trampoline.point_a = end_point
			trampoline.point_b = starting_mouse_pos
		
		# set trampoline lives
		trampoline.lives = trampoline_lives
					
		# Emit the signal
		trampoline_drawn.emit(trampoline)
		StartCooldownTimer()

		is_start_point_in_drawing_zone = false
		GameManager.clear_on_pegs()
		ScoreManager.reset_mult_count()		
		
	# Trampoline is invalid	
	else:
		drawing_guide.reset()

func get_trampoline_endpoint(start_pos: Vector2, mouse_pos: Vector2) -> Vector2:
	
	var end_point := mouse_pos
	var shortest_length_squared := (mouse_pos - start_pos).length_squared()

	var is_mouse_in_drawing_zone: bool = Geometry2D.is_point_in_polygon(mouse_pos, drawing_zone_polygon.polygon)

	# Mouse has left the drawing zone
	if (!is_mouse_in_drawing_zone and is_start_point_in_drawing_zone):

		# Find the edge of the drawing zone
		var mouse_exit_point = Math.segment_intersects_polygon(start_pos, mouse_pos, drawing_zone_polygon.polygon)
		if (mouse_exit_point != null):
			end_point = mouse_exit_point
		else:
			push_error("Error: mouse entry point is null")
			end_point = mouse_pos

		# Update shortest length
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

func StartCooldownTimer():
	$DrawCooldownTimer.start()
	can_draw = false

func _on_draw_cooldown_timer_timeout() -> void:
	can_draw = true
