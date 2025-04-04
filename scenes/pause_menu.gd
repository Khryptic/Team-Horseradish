extends Panel

func _on_pause_button_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # lets mouse exit window

	get_tree().paused = true
	show()

func _on_resume_button_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED) # confines mouse to window
	hide()
	get_tree().paused = false

func _on_restart_button_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED) # confines mouse to window
	get_tree().paused = false
	get_tree().reload_current_scene()
	ScoreManager.total_score = 0
	ScoreManager.reset_mult_count()
	PegManager.reset()
	GameManager.start_new_level()
	
	# Commented out due to error when restarting; not sure if this is still necessary
	#$"../../../Drawing Controller".trampoline_segment_collider.a = Vector2(-10000, -10000)
	#$"../../../Drawing Controller".trampoline_segment_collider.b = Vector2(-10000, -10000)


func _on_home_button_pressed() -> void:
	hide()
	get_tree().paused = false
	SceneManager.change_scene(SceneManager.SCENE.TITLE_SCREEN)
