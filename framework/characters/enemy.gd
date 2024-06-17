extends wjCharacterBase

@onready var nav_agent = $NavigationAgent3D
@onready var player : wjCharacterBase = %Player

func _on_navigation_agent_3d_velocity_computed(safe_velocity:Vector3):
	velocity = safe_velocity

func update_target_location(target: Node3D):
	nav_agent.target_location = target.global_transform.origin

func update_heading(target: Vector3):
	# rotate self to face target
	var _direction = (target - self.global_transform.origin).normalized()
	_direction.y = 0
	self.set_quaternion(Quaternion(Vector3.FORWARD, _direction))


func calc_movement(delta):
	super.calc_movement(delta)

	update_target_location(player)
	var current_location = self.global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED

	new_velocity = new_velocity.move_toward(velocity, SPEED * delta)
	nav_agent.velocity = new_velocity
	update_heading(next_location)
