extends Node
class_name wjLevelLoader

## Container where the level instance will be added.
@export var level_container : Node
@export var default_level: PackedScene

var current_level : wjLevel

signal wj_level_load_started
signal wj_level_loaded(wjLevel)


func _attach_level(level : wjLevel):
	assert(level_container != null, "level_container is null")
	level_container.add_child(level)
	current_level = level

func _clear_current_level():
	if is_instance_valid(current_level):
		current_level.queue_free()
	current_level = null

func load_level():
	await _clear_current_level()

	var level_to_load: wjLevel
	wj_level_load_started.emit()

	if WjAutoloadGameState.level_to_load != null:
		level_to_load = WjAutoloadGameState.level_to_load.instantiate() as wjLevel
	else:
		if default_level == null:
			push_error("default_level is not set")
			return
		level_to_load = default_level.instantiate() as wjLevel

	await _attach_level(level_to_load)
	wj_level_loaded.emit(level_to_load)

func _ready():
	if level_container == null:
		push_error("level_container is not set")
		return
	load_level()
