extends wjCharacterBase

class_name wjEnemy

@export var ability_attack_melee_scene: PackedScene = null
var ability_attack_melee: wjAbilityBase = null
@onready var nav_agent = $NavigationAgent3D
var player = null

var isPlayerInSight = false

func telegraph_and_use_ability(ability: wjAbilityBase):
	character_body.update_action_display(ability.ability_description)
	await get_tree().create_timer(reaction_time_sec).timeout
	character_body.update_action_display('')
	use_attack_melee.call_deferred(ability_attack_melee)

func _on_sense_melee_attack_viable():
	if ability_attack_melee != null:
		telegraph_and_use_ability(ability_attack_melee)


func _ready():
	character_body = %character_body
	character_body.update_health_display(str(health))
	if ability_attack_melee_scene != null:
		ability_attack_melee = ability_attack_melee_scene.instantiate()
		character_body.attach_ability(ability_attack_melee)
		ability_attack_melee.valid_target_factions = can_attack_factions
		ability_attack_melee.sens_ability_viable.connect(_on_sense_melee_attack_viable)

func _on_navigation_agent_3d_velocity_computed(safe_velocity:Vector3):
	velocity.x = lerp(velocity.x, safe_velocity.x, 0.1)
	velocity.z = lerp(velocity.z, safe_velocity.z, 0.1)

func nav_update_target_location(target: Node3D):
	nav_agent.target_location = target.global_transform.origin

func calc_movement(delta):
	# super.calc_movement(delta)

	if isPlayerInSight && !is_dead && player != null:
		nav_update_target_location(player)
		var current_location = self.global_transform.origin
		var next_location = nav_agent.get_next_path_position()
		var new_velocity = (next_location - current_location).normalized() * self.move_speed

		self.looking_direction = new_velocity

		new_velocity = new_velocity.move_toward(velocity, self.move_speed * delta)
		nav_agent.velocity = new_velocity
		update_heading(next_location)
	else:
		nav_agent.velocity = Vector3.ZERO
		velocity.x = lerp(velocity.x, 0.0, 0.1)
		velocity.z = lerp(velocity.z, 0.0, 0.1)

func _on_vision_area_body_entered(body):
	if body is wjPlayer:
		player = body
		isPlayerInSight = true

func _on_vision_area_body_exited(body):
	if body is wjPlayer:
		isPlayerInSight = false
	