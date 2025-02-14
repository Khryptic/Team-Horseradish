extends Panel

func _on_pause_button_pressed():
	get_tree().paused = true
	show()

func _on_resume_button_pressed():
	
	hide()
	get_tree().paused = false

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
