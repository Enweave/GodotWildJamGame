extends wjLevel


func _on_dialogue_end(resource: DialogueResource):
	_emit_wj_level_won()

func show_epilogue_dialogue():
	var balloon = load("res://dialogue/balloon_with_slide.tscn").instantiate()
	var dialogue_resource = load("res://dialogue/epilogue.dialogue")
	get_tree().current_scene.add_child(balloon)
	
	balloon.start(dialogue_resource, "start")
	DialogueManager.dialogue_ended.connect(_on_dialogue_end)

func _ready():
	call_deferred("show_epilogue_dialogue")