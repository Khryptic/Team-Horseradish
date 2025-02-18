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
