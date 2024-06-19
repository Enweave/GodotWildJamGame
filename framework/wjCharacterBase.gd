extends CharacterBody3D
class_name wjCharacterBase

signal character_died

enum wjFactionEnum {
	PLAYER,
	ENEMY,
	NEUTRAL,
	DESTRUCTIBLE
}

const MOVE_LERP = 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var health: float = 100
@export var faction: wjFactionEnum = wjFactionEnum.NEUTRAL
@export var can_attack_factions: Array = [wjFactionEnum.ENEMY]
@export var move_speed: float = 5.0
@export var reaction_time_sec: float = 1.
@onready var current_move_speed: float = move_speed

var controller_direction : Vector3 = Vector3.ZERO
var character_body : wjCharacterBody = null
@onready var sprite: AnimatedSprite3D = $character_body/SpriteOrigin/Sprite

var is_dead = false
var anim_is_attacking = false
var attack_anim_name = "swing1"

func calc_movement(_delta):
	pass

func _physics_process(delta):
	# Add the gravity.
	calc_movement(delta)

	track_animation_state()
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()

func update_heading(target: Vector3):
	# rotate self to face target
	var _direction = (target - self.global_transform.origin).normalized()
	_direction.y = 0
	self.set_quaternion(Quaternion(Vector3.FORWARD, _direction))


func take_damage(damage_amount: int):
	health -= damage_amount
	
	if character_body != null:
		character_body.update_health_display(str(health))

	if health <= 0:
		is_dead = true
		character_died.emit()
		await(get_tree().create_timer(1.0).timeout)
		queue_free()


func use_attack_melee(ability: wjAbilityBase = null):
	if ability != null:
		var success = ability.activate()
		if success:
			anim_is_attacking = true
			change_attack_anim_name()
			self.current_move_speed = self.move_speed / 2
			await get_tree().create_timer(ability.ability_cooldown_sec).timeout
			anim_is_attacking = false
			self.current_move_speed = self.move_speed
	return false

func change_attack_anim_name():
	attack_anim_name = "swing" + str(randi_range(1, 3))

func track_animation_state():

	if anim_is_attacking:
		if sprite.animation != attack_anim_name:
			sprite.play(attack_anim_name)
	elif velocity.length() > 0:
		if sprite.animation != "run":
			sprite.play("run")
	elif sprite.animation != "idle":
		sprite.play("idle")

	if velocity.x > 0 && !sprite.flip_h:
		sprite.flip_h = true
	elif velocity.x < 0 && sprite.flip_h:
		sprite.flip_h = false
