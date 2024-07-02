extends Node
class_name wjLevelLoader

## Container where the level instance will be added.
@export var level_container : Node
@export var default_level_path: String

var current_level : wjLevel

signal wj_level_load_started
signal wj_level_loaded(wjLevel)


func _attach_level(level_resource : Resource) -> wjLevel:
	assert(level_container != null, "level_container is null")
	var instance = level_resource.instantiate()
	level_container.call_deferred("add_child", instance)
	return instance as wjLevel


func _clear_current_level():
	if is_instance_valid(current_level):
		current_level.queue_free()
	current_level = null

func load_level():
	await _clear_current_level()
	var level_to_load_path: String
	
	if WjAutoloadGameState.level_to_load_path != '':
		level_to_load_path = WjAutoloadGameState.level_to_load_path
	else:
		if default_level_path == '':
			push_error("default_level is not set")
			return
		level_to_load_path = default_level_path

	SceneLoader.load_scene(level_to_load_path, true)
	wj_level_load_started.emit()

	await(SceneLoader.scene_loaded)	
	current_level = _attach_level(SceneLoader.get_resource())
	wj_level_loaded.emit(current_level)

func _ready():
	if level_container == null:
		push_error("level_container is not set")
		return
	load_level()
