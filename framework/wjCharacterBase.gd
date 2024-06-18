extends CharacterBody3D
class_name wjCharacterBase


const MOVE_LERP = 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var attack_damage: int = 10
@export var health: int = 100
@export var knockback_strength: float = 20.0
@export var move_speed: float = 5.0

var is_attacking = false
var is_dead = false


func calc_movement(_delta):
	pass

func _physics_process(delta):
	# Add the gravity.
	calc_movement(delta)

	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()


func attack():
	if is_attacking:
		return

	is_attacking = true
	# velocity *= Vector3(0.2, 1, 0.2)

	for enemy in $character_body/meleeArea.get_overlapping_bodies():
		if !(enemy is wjEnemy):
			continue
		
		enemy.velocity += Vector3(1, 0, 1) * ((enemy.global_position - global_position).normalized() * knockback_strength)
		enemy.take_damage(attack_damage)
	
	await(get_tree().create_timer(0.15).timeout)
	is_attacking = false


func take_damage(damage_amount: int):
	health -= damage_amount

	if health <= 0:
		is_dead = true

		# set_physics_process(false)
		await(get_tree().create_timer(1.0).timeout)
		queue_free()
