extends wjCharacterBase


func calc_movement(delta):
	super.calc_movement(delta)
	velocity.x = lerp(velocity.x, 0.0, 0.1)
	velocity.z = lerp(velocity.z, 0.0, 0.1)
