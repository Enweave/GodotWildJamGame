extends wjCharacterBase

class_name wjPlayer

@export var ability_attack_melee_scene: PackedScene = null
var ability_attack_melee: wjAbilityBase = null
@export var ability_attack_ranged_scene: PackedScene = null
var ability_attack_ranged: wjAbilityBase = null
@export var ability_extra_scene: PackedScene = null
var ability_extra: wjAbilityBase = null

var wordlspace : PhysicsDirectSpaceState3D 

@export_category("SpriteFrames")
@export var general_bow_frames: SpriteFrames
@export var general_sword_frames: SpriteFrames
var current_weapon: String = "sword"
var swing_anim_variant: int = 1

func _ready():
	character_body.update_health_display(str(health))
	if ability_attack_melee_scene != null:
		ability_attack_melee = ability_attack_melee_scene.instantiate()
		character_body.attach_ability(ability_attack_melee, self)
	if ability_attack_ranged_scene != null:
		ability_attack_ranged = ability_attack_ranged_scene.instantiate()
		character_body.attach_ability(ability_attack_ranged, self)
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
		if hit_result.collider is wjCharacterBase:
			current_target = hit_result.collider as wjCharacterBase
		else:
			current_target = null
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
		velocity.x = move_toward(velocity.x, 0, self.MOVE_LERP * 2)
		velocity.z = move_toward(velocity.z, 0, self.MOVE_LERP * 2)


func get_attack_anim_name() -> String:
	if current_weapon == "bow":
		return "attack"
	return "swing" + str(swing_anim_variant)

func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		swing_anim_variant = randi_range(1, 3)
		if current_weapon != "sword":
			current_weapon = "sword"
			sprite.sprite_frames = general_sword_frames
		use_ability_with_slowdown.call_deferred(ability_attack_melee)
	elif event.is_action_pressed("attack_ranged"):
		if current_weapon != "bow":
			current_weapon = "bow"
			sprite.sprite_frames = general_bow_frames
		use_ability_with_slowdown.call_deferred(ability_attack_ranged)
	elif event.is_action_pressed("dash"):
		use_ability_extra()
