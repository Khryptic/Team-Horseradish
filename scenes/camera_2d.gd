extends Camera2D

@export var base_pos: Vector2

func _ready():
    position = base_pos

func _on_mobile_safe_area_updated(safe_area: Rect2):

    # Just move the camera up so there is more space at the top
    position.y = base_pos.y - safe_area.position.y