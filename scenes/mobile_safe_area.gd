extends Control

signal safe_area_updated(safe_area: Rect2)

func _ready() -> void:

    var window: Window = get_window()

    if OS.has_feature("android") || OS.has_feature("ios"):

        # Get the safe area and convert from pixels to viewport coordinates
        var window_safe_area := Rect2(DisplayServer.get_display_safe_area())
        var view_to_window := get_viewport_rect().size / Vector2(window.size) 
        var viewport_safe_area := Rect2(window_safe_area.position * view_to_window, window_safe_area.size * view_to_window)

        # Update the position and size of the control box to match the safe area
        position = viewport_safe_area.position
        set_deferred("size", viewport_safe_area.size) 

        safe_area_updated.emit(viewport_safe_area)