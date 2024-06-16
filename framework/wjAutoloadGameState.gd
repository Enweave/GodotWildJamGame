extends Node

var level_to_load: PackedScene = null

func reset():
	level_to_load = null

func set_level_to_load(level: PackedScene):
	level_to_load = level

