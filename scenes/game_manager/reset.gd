extends Node

@export_file("*.tscn") var level_to_load: String
@export var button: InteractableButton
signal load_level(lvl)

func _ready():
	button.status_changed.connect(reload)

func reload():
	if not button.active: return
	load_level.emit(load(level_to_load))
