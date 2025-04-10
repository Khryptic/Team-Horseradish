extends Node

enum SCENE{
	TITLE_SCREEN,
	LEVEL_SELECT_MENU,
	GAME,
}
var CURRENT_SCENE = SCENE.TITLE_SCREEN

# This may break if paths are changed
var scene_dict = {
	SCENE.TITLE_SCREEN: preload("res://scenes/title_screen.tscn"),
	SCENE.LEVEL_SELECT_MENU: preload("res://scenes/level_select.tscn"),
	SCENE.GAME: preload("res://scenes/main_scene.tscn")
}

func change_scene(scene_to_change_to: SCENE):
	if scene_to_change_to in scene_dict:
		CURRENT_SCENE = scene_to_change_to
		get_tree().change_scene_to_packed(scene_dict[scene_to_change_to])
	else:
		print("Error: Scene not found in dictionary.")
