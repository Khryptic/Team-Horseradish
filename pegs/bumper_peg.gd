extends Peg

@export var bumper_strength: int = 500

func _on_peg_hit(body: RigidBody2D):
    
    # Call the parent method to handle the peg hit logic
    super._on_peg_hit(body)
    AudioManager.create_2d_audio_at_location(position, SoundEffect.SOUND_EFFECT_TYPE.BUMPER_HIT)
    var push_dir: Vector2 = (body.global_position - global_position).normalized()
    body.linear_velocity = push_dir * bumper_strength