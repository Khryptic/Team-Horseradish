extends Peg

@export var chained_sprite: PegSprite

@onready var sprite2D_overlay: Sprite2D = $AnimationScale/OverlaySprite2D

var is_chained: bool = true

func _ready():
	
	super._ready()

	sprite2D_overlay.set_texture(chained_sprite.sprite)
	circle_shader.set_instance_shader_parameter('color', chained_sprite.color)

func _on_peg_hit(_body: RigidBody2D):

	# If the peg is not chained, just act like a normal peg
	if(!is_chained):
		super._on_peg_hit(_body)
		
	else:
		sprite2D_overlay.set_texture(chained_sprite.hit_sprite)

		animation_player.stop()
		animation_player.play("ball_hit")

		Input.vibrate_handheld(1, 0.1)

		if is_light_on:
			ScoreManager.increase_mult(1)

		is_light_on = false
		
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.PEG_HIT)

func _remove_peg():
	
	if(is_chained):

		if(!is_light_on):
	
			is_chained = false
			is_light_on = true

			sprite2D_overlay.visible = false
			circle_shader.set_instance_shader_parameter('color', peg_sprite.color)

			peg_sensor.points_worth = 10

			for i in range(randi_range(min_orb_count, max_orb_count)):
				spawn_score_orb()
			
			AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.PEG_DESTROY)

			# Play the peg destroy animation
			var particles: GPUParticles2D = burst_particles_scene.instantiate()
			get_tree().current_scene.add_child(particles)
			particles.texture = chained_sprite.burst_sprite
			particles.global_position = global_position

	# Not chained, so just act like a normal peg
	else:
		super._remove_peg()

