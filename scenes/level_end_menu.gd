extends Panel



func _on_home_button_pressed() -> void:
	SceneManager.change_scene(SceneManager.SCENE.LEVEL_SELECT_MENU)


func _on_restart_button_pressed() -> void:
	# if restart is pressed than restart level just played
	print("hey i got clicked")
	hide()
	ScoreManager.total_score = 0
	ScoreManager.reset_mult_count()
	PegManager.reset()
	GameManager.start_new_level()
	pass # Replace with function body.

func _on_resume_button_pressed() -> void:
	# if resume button is presssed go to next level
	print("hey i got clicked")
	hide()
	GameManager.start_new_level()
