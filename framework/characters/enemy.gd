extends wjCharacterBase

class_name wjEnemy


@onready var nav_agent = $NavigationAgent3D
@onready var player = $"../Player"

var isPlayerInSight = false


func _on_navigation_agent_3d_velocity_computed(safe_velocity:Vector3):
	velocity.x = lerp(velocity.x, safe_velocity.x, 0.1)
	velocity.z = lerp(velocity.z, safe_velocity.z, 0.1)

func update_target_location(target: Node3D):
	nav_agent.target_location = target.global_transform.origin

func update_heading(target: Vector3):
	# rotate self to face target
	var _direction = (target - self.global_transform.origin).normalized()
	_direction.y = 0
	$character_body/meleeArea.set_quaternion(Quaternion(Vector3.FORWARD, _direction))


func calc_movement(delta):
	# super.calc_movement(delta)

	if isPlayerInSight && !is_dead:
		update_target_location(player)
		var current_location = self.global_transform.origin
		var next_location = nav_agent.get_next_path_position()
		var new_velocity = (next_location - current_location).normalized() * self.move_speed

		new_velocity = new_velocity.move_toward(velocity, self.move_speed * delta)
		nav_agent.velocity = new_velocity
		update_heading(next_location)
	else:
		nav_agent.velocity = Vector3.ZERO
		velocity.x = lerp(velocity.x, 0.0, 0.1)
		velocity.z = lerp(velocity.z, 0.0, 0.1)

func _on_vision_area_body_entered(body):
	if body is wjPlayer:
		isPlayerInSight = true

func _on_vision_area_body_exited(body):
	if body is wjPlayer:
		isPlayerInSight = false
