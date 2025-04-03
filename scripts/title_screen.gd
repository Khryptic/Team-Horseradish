extends Button

@export var scene_to_change_to : SceneManager.SCENE
@export var level_num : int

func _on_pressed():
	$"../../AnimationPlayer".play("button_press")


func _on_animation_player_animation_finished(button_press):
	print(level_num)
	if (level_num > 0):

		PegManager.play_specific_level(level_num)
	SceneManager.change_scene(scene_to_change_to)
	
