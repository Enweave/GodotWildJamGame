extends Node
class_name wjLevel

signal wj_level_won
signal wj_level_next
signal wj_level_lost


func _emit_wj_level_won():
    wj_level_won.emit()

func _emit_wj_level_lost():
    wj_level_lost.emit()

func _emit_wj_level_next(level_path: String):
    WjAutoloadGameState.set_level_to_load(level_path)
    wj_level_next.emit()
