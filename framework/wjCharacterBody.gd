extends CollisionShape3D

class_name wjCharacterBody

@export var sprite_texture : Texture

func attach_ability(ability: wjAbilityBase):
	%WeaponHotspot.add_child(ability)

func _ready():
	update_action_display('')
	update_health_display('')
	# TODO: Add the ability to change the sprite texture
	# %sprite.texture = sprite_texture

func update_health_display(health: String):
	%health.text = health

func update_action_display(action: String):
	%action.text = action
