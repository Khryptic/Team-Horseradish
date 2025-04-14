extends Peg

func _on_peg_hit(_body: RigidBody2D):
    
    # Call the parent method to handle the peg hit logic
    super._on_peg_hit(_body)

    var push_dir: Vector2 = (_body.position - position).normalized()
    _body.apply_central_impulse(push_dir * 1000)