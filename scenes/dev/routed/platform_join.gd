extends Node3D
class_name Joiner

@export_file("*.tscn") var level_to_load: String
@onready var area_3d: Area3D = $Area3D
#@onready var delayed_start = $DelayedStart
@onready var direction = $Direction



@export var starting_point: bool

var enabled: bool = false

signal attach_level(lvl)


func _on_area_3d_body_entered(body):
	if not enabled: return
	if starting_point: return
	attach_level.emit(load(level_to_load))
	get_tree()

func _ready():
	if starting_point: add_to_group("Starting")
	else: add_to_group("Ending")
	direction.visible = false


func _on_enable_timer_timeout():
	enabled = true
	pass # Replace with function body.
