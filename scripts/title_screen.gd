extends Button

func _on_pressed():
	$"../../AnimationPlayer".play("button_press")


func _on_animation_player_animation_finished(_button_press):
	print("Animation finished")
	get_tree().change_scene_to_file("uid://c6usj5s4g5bdm")