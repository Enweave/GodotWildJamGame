extends wjAbilityBase

@export var knockback_strength: float = 3.0


func apply_knockback(target: wjCharacterBase):
    target.velocity += Vector3(1, 0, 1) * ((target.global_position - global_position).normalized() * knockback_strength)

func activate() -> bool:
    var success = super.activate()
    if success:
        for target in %Area3D.get_overlapping_bodies():
            if target is wjCharacterBase:
                if target.faction in valid_target_factions:
                    apply_knockback(target)
                    target.take_damage(ability_damage)
    
    return success


func _on_area_3d_body_entered(body:Node3D):
    if body is wjCharacterBase:
        if body.faction in valid_target_factions:
            sens_ability_viable.emit()
    
