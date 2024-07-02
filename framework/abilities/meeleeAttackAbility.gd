extends wjAbilityBase

@export var knockback_strength: float = 3.0

var this_enemy_can_attack := true


func apply_knockback(target: wjCharacterBase):
    var new_velocity = Vector3(1, 0, 1) * global_position.direction_to(target.global_position) * knockback_strength
    
    # TODO CLAMP VELOCITY
    target.velocity += new_velocity

func activate(_callback: Callable = Callable(), _args: Array = []) -> bool:
    var success = super.activate()
    if success:
        for target in %Area3D.get_overlapping_bodies():
            if target is wjCharacterBase and target != user:
                if target.faction in valid_target_factions:
                    apply_knockback(target)
                    target.take_damage(ability_damage, user)
    
    return success


func _on_area_3d_body_entered(body:Node3D):
    if body is wjCharacterBase:
        if body.faction in valid_target_factions and this_enemy_can_attack:
            sens_ability_viable.emit()

            if user is wjEnemy and $AttackCooldownTimer.is_stopped():
                this_enemy_can_attack = false
                $AttackCooldownTimer.start()
                if !$AttackCooldownTimer.timeout.is_connected(on_attack_cooldown_timeout):
                    $AttackCooldownTimer.timeout.connect(on_attack_cooldown_timeout)


func on_attack_cooldown_timeout():
    this_enemy_can_attack = true
    var attack_area: Area3D = $Area3D
    for body: Node3D in attack_area.get_overlapping_bodies():
        _on_area_3d_body_entered(body)
