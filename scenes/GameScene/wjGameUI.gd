extends Control

@export var win_scene : PackedScene
@export var lose_scene : PackedScene


func _ready():
	# wjAutoloadGameState.reset()
	InGameMenuController.scene_tree = get_tree()

func _on_level_lost():
	InGameMenuController.open_menu(lose_scene, get_viewport())

func _on_level_won():
	InGameMenuController.open_menu(win_scene, get_viewport())

func _on_level_next():
	$wjLevelLoader.load_level()

func _on_level_loader_level_load_started():
	$LoadingScreen.reset()

func _on_level_loader_level_loaded(current_level: wjLevel):
	if not current_level.is_node_ready():
		await current_level.ready
	if current_level.has_signal("wj_level_won"):
		current_level.wj_level_won.connect(_on_level_won)
	if current_level.has_signal("wj_level_lost"):
		current_level.wj_level_lost.connect(_on_level_lost)
	if current_level.has_signal("wj_level_next"):
		current_level.wj_level_next.connect(_on_level_next)
	$LoadingScreen.close()



