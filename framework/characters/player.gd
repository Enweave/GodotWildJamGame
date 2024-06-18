extends wjCharacterBase

class_name wjPlayer


var cached_aim_direction : Quaternion = Quaternion()
var wordlspace : PhysicsDirectSpaceState3D 


func _ready():
	self.attack_damage = 25
	self.knockback_strength = 40.0
	self.move_speed = 10.0
	%CameraPivot.rotation_degrees.y = 0

	wordlspace = get_world_3d().get_direct_space_state()

func get_aim_direction() -> Quaternion:
	var aim_direction = self.global_transform.basis.get_rotation_quaternion()

	# mouse logic
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = %Camera.project_ray_origin(mouse_position)
	var ray = PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_origin + %Camera.project_ray_normal(mouse_position) * 2000,
		0b1
	)
	
	var hit_result = wordlspace.intersect_ray(ray)
	
	if hit_result:
		var _hit_position = hit_result.position
		_hit_position.y = self.global_position.y
		var _direction = self.global_transform.origin.direction_to(_hit_position)
		aim_direction = Quaternion(Vector3.FORWARD, _direction)
		
	return aim_direction


func calc_movement(delta):
	super.calc_movement(delta)
	# Set player look direction.
	$character_body/meleeArea.set_quaternion(get_aim_direction())
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * self.move_speed, self.MOVE_LERP)
		velocity.z = lerp(velocity.z, direction.z * self.move_speed, self.MOVE_LERP)

		if self.is_attacking:
			velocity.x = clamp(abs(velocity.x), 0, self.move_speed / 4) * sign(velocity.x)
			velocity.z = clamp(abs(velocity.z), 0, self.move_speed / 4) * sign(velocity.z)
	else:
		velocity.x = move_toward(velocity.x, 0, self.move_speed)
		velocity.z = move_toward(velocity.z, 0, self.move_speed)


func _unhandled_input(event):
	if event is InputEventMouseButton && event.is_pressed():
		attack()
