extends wjCharacterBase

class_name SnowFox

@export var ability_attack_melee_scene: PackedScene = null
var ability_attack_melee: wjAbilityBase = null
@onready var nav_agent = $NavigationAgent3D
@onready var bonk_cast: ShapeCast3D = $character_body/BonkCast
@onready var charge_target: Node3D = $"../FoxChargeTarget"
@onready var tunneling_timer: Timer = $TunnelingTimer
@onready var collision_shape: BoxShape3D = $character_body.shape

var isPlayerInSight = false
var is_tunneling := false
var is_attacking := false
var is_bonked := false
var bonk_vulnerable_time: float = 2.0

@export_category("Attack")
@export var attack_damage: int = 25
@export var attack_range: float = 7.5
@export var attack_time: float = 1.0
@export var attack_move_speed_multiplier: float = 2.0

var player: wjPlayer
var was_player_hit := false


func _on_sense_melee_attack_viable():
	if ability_attack_melee != null and !is_dead:
		telegraph_and_use_ability(ability_attack_melee)


func _ready():
	character_body.update_health_display(str(health))
	if ability_attack_melee_scene != null:
		ability_attack_melee = ability_attack_melee_scene.instantiate()
		character_body.attach_ability(ability_attack_melee, self)
		ability_attack_melee.sens_ability_viable.connect(_on_sense_melee_attack_viable)


func _on_navigation_agent_3d_velocity_computed(safe_velocity:Vector3):
	velocity.x = lerp(velocity.x, safe_velocity.x, 0.1)
	velocity.z = lerp(velocity.z, safe_velocity.z, 0.1)

func nav_update_target_location(target: Node3D):
	nav_agent.target_location = target.global_transform.origin

func calc_movement(delta):
	# super.calc_movement(delta)
	var target = current_target if current_target != null else charge_target

	if isPlayerInSight && !is_dead && target != null:
		nav_update_target_location(target)
		var current_location = self.global_transform.origin
		var next_location = nav_agent.get_next_path_position()
		var new_velocity = current_location.direction_to(next_location) * self.current_move_speed

		self.looking_direction = new_velocity

		new_velocity = new_velocity.move_toward(velocity, self.current_move_speed * delta)
		nav_agent.velocity = new_velocity
		# update_heading(next_location)

		check_tunneling(target)
	else:
		nav_agent.velocity = Vector3.ZERO
		velocity.x = lerp(velocity.x, 0.0, 0.1)
		velocity.z = lerp(velocity.z, 0.0, 0.1)
	
	check_bonk()


func check_tunneling(target: Node3D):
	if is_tunneling:
		if tunneling_timer.is_stopped() and global_position.distance_to(target.global_position) <= attack_range:
			is_tunneling = false
			collision_shape.size.x = 7
			attack()
	elif !is_attacking and !is_bonked:
		apply_track_animation = false
		is_tunneling = true
		try_switch_animation("tunneling")
		collision_shape.size.x = 0.5
		tunneling_timer.start()


func attack():
	is_attacking = true
	was_player_hit = false
	var dir_offset = global_position.direction_to(current_target.global_position) * Vector3(1, 0, 1) * 50
	charge_target.global_position = current_target.global_position + dir_offset
	current_target = null
	current_move_speed *= attack_move_speed_multiplier

	try_switch_animation("attack")
	await get_tree().create_timer(attack_time).timeout

	current_target = player
	velocity = Vector3.ZERO
	current_move_speed = self.move_speed
	apply_track_animation = true
	await get_tree().create_timer(0.5).timeout
	is_attacking = false


func check_bonk():
	if is_tunneling or is_bonked or !bonk_cast.is_colliding():
		return

	for i in bonk_cast.get_collision_count():
		var collider = bonk_cast.get_collider(i)
		if !collider or collider.is_queued_for_deletion():
			continue

		var is_player = collider == player
		var is_tree = collider.name.to_lower().contains("tree")

		if !is_player:
			bonk_cast.add_exception(collider)
		elif is_attacking:
			if !was_player_hit:
				was_player_hit = true
				player.take_damage(attack_damage, self)
			return

		if !is_tree:
			continue

		var tree_sprite: AnimatedSprite3D = collider.get_node("AnimatedSprite3D")
		tree_sprite.play("bonked")
		bonk()


func bonk():
	is_bonked = true
	apply_track_animation = false
	set_physics_process(false)

	try_switch_animation("bonk")
	await sprite.animation_finished
	await get_tree().create_timer(bonk_vulnerable_time).timeout

	is_bonked = false
	apply_track_animation = true
	set_physics_process(true)


func _on_vision_area_body_entered(body):
	if body is wjPlayer:
		player = body
		current_target = body
		isPlayerInSight = true

func _on_vision_area_body_exited(body):
	pass
	# if body is wjPlayer:
	# 	isPlayerInSight = false


func _on_being_attacked_by(damage_amount:float, attacker:wjCharacterBase = null):
	if attacker != null:
		current_target = attacker
		isPlayerInSight = true


func take_damage(damage_amount: float, attacker: wjCharacterBase = null):
	if !is_tunneling:
		super.take_damage(damage_amount, attacker)
