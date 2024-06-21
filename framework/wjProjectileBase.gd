extends RigidBody3D

class_name wjProjectileBase

var spawner_ability: wjAbilityBase = null
var impulse: Vector3 = Vector3(0,0,0)
@export var projectile_lifetime_sec: float = 1.0

func _ready():
    await get_tree().create_timer(projectile_lifetime_sec).timeout
    queue_free()

func setup(ability: wjAbilityBase, transform3d: Transform3D, impulse_vector: Vector3):
    spawner_ability = ability
    self.global_transform = transform3d
    impulse = impulse_vector
    
func fire():
    self.apply_impulse(impulse, Vector3(0,0,0))

func _on_body_entered(body:Node):
    if body.is_queued_for_deletion():
        return
    
    if body is wjCharacterBase and body != spawner_ability.user:
        if body.faction in spawner_ability.valid_target_factions:
            body.take_damage(spawner_ability.ability_damage, spawner_ability.user)
            queue_free()
