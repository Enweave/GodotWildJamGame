extends CharacterBody3D
class_name wjCharacterBase

signal character_died
signal being_attacked_by(damage_amount: float, attacker: wjCharacterBase)

enum wjFactionEnum {
	PLAYER,
	ENEMY,
	NEUTRAL,
	DESTRUCTIBLE
}

const MOVE_LERP = 0.25

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var max_health : float = 100
@onready var health: float = max_health
@export var faction: wjFactionEnum = wjFactionEnum.NEUTRAL
@export var can_attack_factions: Array = [wjFactionEnum.ENEMY]
@export var move_speed: float = 5.0
@export var move_speed_slowdown_multiplier: float = 0.3
@export var reaction_time_sec: float = 0.2

@onready var current_move_speed: float = move_speed
@onready var character_body : wjCharacterBody = %character_body
@onready var sprite: AnimatedSprite3D = $character_body/SpriteOrigin/Sprite

var controller_direction : Vector3 = Vector3.ZERO
var is_dead = false
var looking_direction: Vector3
var current_target: wjCharacterBase = null
var is_telegraphing = false

@export var apply_track_animation: bool = true
var anim_is_attacking = false
var attack_anim_name = "swing1"


func calc_movement(_delta):
	pass

func _physics_process(delta):
	# Add the gravity.
	calc_movement(delta)
	
	update_sptite_heading()
	update_animation_state()
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()

func update_heading(target: Vector3):
	# rotate self to face target
	var _direction = (target - self.global_transform.origin).normalized()
	_direction.y = 0
	self.set_quaternion(Quaternion(Vector3.FORWARD, _direction))


func take_damage(damage_amount: float, attacker: wjCharacterBase = null):
	health -= damage_amount
	
	being_attacked_by.emit(damage_amount, attacker)

	if character_body != null:
		character_body.update_health_display(str(health))

	if health <= 0:
		is_dead = true
		character_died.emit()
		await get_tree().create_timer(1.0).timeout
		queue_free()


func use_ability_with_slowdown(ability: wjAbilityBase = null):
	if ability != null:
		var success = ability.activate()
		if success:
			anim_is_attacking = true
			self.current_move_speed = self.move_speed * move_speed_slowdown_multiplier
			await get_tree().create_timer(ability.ability_cooldown_sec).timeout
			anim_is_attacking = false
			self.current_move_speed = self.move_speed
	return false

func get_attack_anim_name() -> String:
	return 'attack'

func try_switch_animation(anim_name: String):
	if sprite.sprite_frames.has_animation(anim_name):
		if sprite.animation != anim_name: 
			sprite.play(anim_name)


func update_sptite_heading():
	if looking_direction.x > 0 && !sprite.flip_h:
		sprite.flip_h = true
	elif looking_direction.x < 0 && sprite.flip_h:
		sprite.flip_h = false


func update_animation_state():
	if apply_track_animation:
		if is_dead:
			try_switch_animation("dead")
		elif anim_is_attacking:
			try_switch_animation(get_attack_anim_name())
		elif velocity.length() > 0:
			try_switch_animation("run")
		else:
			try_switch_animation("idle")
	


func telegraph_and_use_ability(ability: wjAbilityBase):
	if not is_telegraphing:
		is_telegraphing = true
		character_body.update_action_display(ability.ability_description)
		await get_tree().create_timer(reaction_time_sec).timeout
		character_body.update_action_display('')
		is_telegraphing = false
		if !is_dead:	
			use_ability_with_slowdown.call_deferred(ability)