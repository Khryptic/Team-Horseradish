extends Panel

func _on_pause_button_pressed():
	if (GameManager.CURRENT_STATE == GameManager.GAME_STATE.LEVEL_END_MENU):
		return
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # lets mouse exit window
	
	get_tree().paused = true
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.CLICK)
	show()

func _on_resume_button_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED) # confines mouse to window
	hide()
	get_tree().paused = false
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.CLICK)

func _on_restart_button_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED) # confines mouse to window
	get_tree().paused = false
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.CLICK)
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
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.CLICK)
	SceneManager.change_scene(SceneManager.SCENE.TITLE_SCREEN)
