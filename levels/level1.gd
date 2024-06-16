extends wjLevel

@export var level2scene : PackedScene

func _on_button_2_pressed():
	_emit_wj_level_next(level2scene)
