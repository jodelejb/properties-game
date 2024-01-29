extends Node3D

@export_file("*.tscn") var level_to_load: String

signal load_level(lvl)

func _on_area_3d_body_entered(body):
	print("player entered")
	load_level.emit(load(level_to_load))
	pass # Replace with function body.
