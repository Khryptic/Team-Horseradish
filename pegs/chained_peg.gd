extends Peg

@export var chained_sprite: PegSprite

var is_chained: bool = true

func _ready():
	
	super._ready()

	sprite2D.set_texture(chained_sprite.sprite)
	circle_shader.set_instance_shader_parameter('color', chained_sprite.color)

func _on_peg_hit(_body: RigidBody2D):

	if(is_chained and is_light_on):
		
		
		is_light_on = false

	super._on_peg_hit(_body)


	if(is_chained):
		
		# Use chained sprites
		sprite2D.set_texture(peg_sprite.hit_sprite)

		animation_player.stop()
		animation_player.play("ball_hit")

		Input.vibrate_handheld(1, 0.1)

		if is_light_on:
			ScoreManager.increase_mult(1)
			PegManager.unlight_peg()
		
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.PEG_HIT)

	else:
		super._on_peg_hit(_body)

func _remove_peg():

