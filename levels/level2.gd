extends wjLevel

@export var player_respawn: Node3D
@export var player: wjPlayer

func _on_player_character_died():
    # set timeout
    await get_tree().create_timer(0.2).timeout
    player.global_transform.origin = player_respawn.global_transform.origin
    player.reset_health()
