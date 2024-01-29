extends Node3D

@export_file("*.tscn") var level_to_load: String
@onready var area_3d: Area3D = $Area3D
@onready var delayed_start = $DelayedStart

var enabled: bool = false

signal load_level(lvl)

func _on_area_3d_body_entered(body):
	if not enabled: return
	load_level.emit(load(level_to_load))


func _on_delayed_start_timeout():
	enabled = true
