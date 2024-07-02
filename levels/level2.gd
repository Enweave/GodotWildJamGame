extends wjLevel

@export var levelEndScenePath : String

@export var player_respawn: Node3D
@export var player: wjPlayer



func _on_respawn_dialogue_end(_resource: DialogueResource):
	player.global_transform.origin = player_respawn.global_transform.origin
	player.reset_health()
	

func _on_player_character_died():
	# set timeout
	await get_tree().create_timer(1).timeout
	
	var balloon = load("res://dialogue/balloon_with_slide.tscn").instantiate()
	var dialogue_resource = load("res://dialogue/respawn.dialogue")
	get_tree().current_scene.add_child(balloon)
	
	balloon.start(dialogue_resource, "start")
	
	DialogueManager.dialogue_ended.connect(_on_respawn_dialogue_end)


func _on_snow_fox_character_died():
	await get_tree().create_timer(1).timeout
	_emit_wj_level_next(levelEndScenePath)
