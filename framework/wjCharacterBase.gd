extends CharacterBody3D
class_name wjCharacterBase


const MOVE_LERP = 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var attack_damage: int = 10
@export var health: int = 100
@export var knockback_strength: float = 10.0
@export var move_speed: float = 5.0

@onready var attack_combo_timer: Timer = $character_body/AttackComboTimer
@onready var melee_area: Area3D = $character_body/MeleeArea
@onready var sprite: AnimatedSprite3D = $character_body/SpriteOrigin/Sprite

var current_combo_swing: int = 0
var is_attack_queued = false
var is_attacking = false
var is_dead = false


func _ready():
	attack_combo_timer.timeout.connect(on_combo_timeout)


func calc_movement(_delta):
	pass

func _physics_process(delta):
	# Add the gravity.
	calc_movement(delta)

	if not is_on_floor():
		velocity.y -= gravity * delta

	if !is_attacking:
		if velocity * Vector3(1, 0, 1) != Vector3.ZERO:
			if sprite.animation != "run":
				sprite.play("run")
		elif sprite.animation != "idle":
			sprite.play("idle")

	if velocity.x > 0 && !sprite.flip_h:
		sprite.flip_h = true
	elif velocity.x < 0 && sprite.flip_h:
		sprite.flip_h = false

	move_and_slide()

func update_heading(target: Vector3):
	# rotate self to face target
	var _direction = (target - self.global_transform.origin).normalized()
	_direction.y = 0
	self.set_quaternion(Quaternion(Vector3.FORWARD, _direction))

func attack():
	if is_attacking:
		is_attack_queued = true
		return

	is_attack_queued = false
	is_attacking = true
	attack_combo_timer.stop()

	current_combo_swing = (current_combo_swing + 1)
	if current_combo_swing > 3:
		current_combo_swing = 1
	print(current_combo_swing)
	sprite.play("swing" + str(current_combo_swing))

	for enemy in melee_area.get_overlapping_bodies():
		damage_enemy(enemy)

	if !melee_area.body_entered.is_connected(damage_enemy):
		melee_area.body_entered.connect(damage_enemy)

	await(sprite.animation_finished)
	is_attacking = false
	attack_combo_timer.start()

	if is_attack_queued:
		attack()
	elif melee_area.body_entered.is_connected(damage_enemy):
		melee_area.body_entered.disconnect(damage_enemy)


func damage_enemy(enemy: Node3D):
	if !(enemy is wjEnemy):
		return
	
	enemy.velocity += Vector3(1, 0, 1) * ((enemy.global_position - global_position).normalized() * knockback_strength)
	enemy.take_damage(attack_damage)


func take_damage(damage_amount: int):
	health -= damage_amount

	if health <= 0:
		is_dead = true

		await(get_tree().create_timer(1.0).timeout)
		queue_free()

func on_combo_timeout():
	current_combo_swing = 0
