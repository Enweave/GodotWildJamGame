extends wjAbilityBase

@export var projectile: PackedScene
var scene_root

var is_bow_drawn: bool = false


func _ready():
    scene_root = get_tree().get_root()

func activate() -> bool:
    var success = super.activate()
    if success:
        if is_bow_drawn:
            var _projectile = projectile.instantiate() as wjProjectileBase
            var forward: Vector3

            if user.current_target:
                var target_position = user.current_target.global_transform.origin
                forward = user.global_transform.origin.direction_to(target_position).normalized()
            else:
                forward = self.global_transform.basis.z.normalized()
            var impulse_vector = self.ability_range_meters * forward
            
            _projectile.setup(self, self.global_transform, impulse_vector)

            scene_root.add_child(_projectile)
            _projectile.fire()
            is_bow_drawn = false
        else:
            is_bow_drawn = true

    return success


