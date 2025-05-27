extends Sprite2D

class_name LevelButton

func set_level_to_go_to(level_num: int):
	var button_reference = get_node("SpButton01a").get_node("Button2") as SceneChangingButton
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.CLICK)
	button_reference.text = str(level_num)
	button_reference.level_num = level_num
