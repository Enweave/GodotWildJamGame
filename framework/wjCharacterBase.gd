extends CharacterBody3D
class_name wjCharacterBase

var SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func calc_movement(delta):
	pass

func _physics_process(delta):
	# Add the gravity.
	calc_movement(delta)

	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()
