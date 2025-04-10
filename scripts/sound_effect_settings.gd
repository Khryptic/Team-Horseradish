extends Resource
class_name SoundEffect

# To add new sound effect make sure to add type to this enum
enum SOUND_EFFECT_TYPE{
	PEG_HIT,
	TRAMPOLINE_BOUNCE,
	PEG_SPAWN,
	PEG_DESTROY,
	BULLET_TIME
}


@export_range(0, 10) var limit : int = 5
@export var type : SOUND_EFFECT_TYPE
@export var sound_effect : AudioStreamMP3
@export_range(-40, 20) var volume = 0
@export_range(0.0, 4.0, .01) var pitch_scale = 1.0
@export_range(0.0, 1.0, .01) var pitch_randomness = 0.0


var audio_count = 0

func change_audio_count(amount : int):
	audio_count = max(0, audio_count + amount)
	
func has_open_limit() -> bool:
	return audio_count < limit
	
func on_audio_finished():
	change_audio_count(-1)
