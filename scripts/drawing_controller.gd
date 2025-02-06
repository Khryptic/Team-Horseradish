extends Node2D

@onready var trampoline_collision: CollisionShape2D = $Trampoline/CollisionShape2D
@onready var trampoline_line: Line2D = $Trampoline/Line2D

signal trampoline_drawn

var trampoline_segment_collider: SegmentShape2D
var trampoline_start: Vector2

func _ready() -> void:
	trampoline_segment_collider = trampoline_collision.shape

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("Draw")):
		var mouse_pos := get_global_mouse_position()
		
		# Save starting pos of mouse
		trampoline_start = mouse_pos
		
	elif(Input.is_action_just_released("Draw")):
		var mouse_pos := get_global_mouse_position()
		
		# Set trampoline collider
		trampoline_segment_collider.a = trampoline_start
		trampoline_segment_collider.b = mouse_pos
		
		# Set trampoline sprite
		trampoline_line.clear_points()
		trampoline_line.add_point(trampoline_start)
		trampoline_line.add_point(mouse_pos)
