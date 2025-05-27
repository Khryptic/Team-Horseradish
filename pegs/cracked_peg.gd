extends Peg

func _on_peg_hit(_body: RigidBody2D):

	Input.vibrate_handheld(10, 0.3)

	ScoreManager.increase_mult(1)
	PegManager.unlight_peg()
	
	is_light_on = false

	super._remove_peg()