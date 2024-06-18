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
var is_dead = false


func calc_movement(_delta):
	pass

func _physics_process(delta):
	# Add the gravity.
	calc_movement(delta)

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
