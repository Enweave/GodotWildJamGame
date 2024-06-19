extends wjCharacterBase

class_name wjPlayer

@export var ability_attack_melee_scene: PackedScene = null
var ability_attack_melee: wjAbilityBase = null
@export var ability_attack_ranged_scene: PackedScene = null
var ability_attack_ranged: wjAbilityBase = null
@export var ability_extra_scene: PackedScene = null
var ability_extra: wjAbilityBase = null

var wordlspace : PhysicsDirectSpaceState3D 

func _ready():
	character_body.update_health_display(str(health))
	if ability_attack_melee_scene != null:
		ability_attack_melee = ability_attack_melee_scene.instantiate()
		character_body.attach_ability(ability_attack_melee, self)
		ability_attack_melee.valid_target_factions = can_attack_factions
	if ability_attack_ranged_scene != null:
		ability_attack_ranged = ability_attack_ranged_scene.instantiate()
		character_body.attach_ability(ability_attack_ranged, self)
		ability_attack_melee.valid_target_factions = can_attack_factions
	if ability_extra_scene != null:
		ability_extra = ability_extra_scene.instantiate()
		character_body.attach_ability(ability_extra, self)

	%CameraPivot.rotation_degrees.y = 0

	wordlspace = get_world_3d().get_direct_space_state()


func use_ability_extra():
	if ability_extra != null:
		ability_extra.activate()

func update_heading_from_mouse():
	var aim_direction = self.global_transform.basis.get_rotation_quaternion()

	# mouse logic
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = %Camera.project_ray_origin(mouse_position)
	var ray = PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_origin + %Camera.project_ray_normal(mouse_position) * 2000
		,0b101
	)
	
	var hit_result = wordlspace.intersect_ray(ray)
	
	if hit_result:
		var _hit_position = hit_result.position
		_hit_position.y = self.global_position.y
		var _direction = self.global_transform.origin.direction_to(_hit_position)
		aim_direction = Quaternion(Vector3.FORWARD, _direction)
		
		self.set_quaternion(aim_direction)
	
	self.looking_direction = Vector3(-aim_direction.y, 0, 0)


func calc_movement(delta):
	super.calc_movement(delta)
	update_heading_from_mouse()
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	controller_direction = (Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if controller_direction:
		velocity.x = lerp(velocity.x, controller_direction.x * self.current_move_speed, self.MOVE_LERP)
		velocity.z = lerp(velocity.z, controller_direction.z * self.current_move_speed, self.MOVE_LERP)
	else:
		velocity.x = move_toward(velocity.x, 0, self.current_move_speed)
		velocity.z = move_toward(velocity.z, 0, self.current_move_speed)


func _unhandled_input(event):
	if event is InputEventMouseButton && event.is_pressed():
		use_attack_melee.call_deferred(ability_attack_melee)

	if Input.is_action_pressed("dash"):
		use_ability_extra()
