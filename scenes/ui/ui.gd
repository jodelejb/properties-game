extends CanvasLayer

@export var player: CharacterBody3D

@onready var selected_property = $MarginContainer/SelectedProperty

func _ready():
	player.held_property_changed.connect(update_held_prop)
	
func update_held_prop(prop):
	for key in Globals.properties:
		if prop == Globals.properties[key]:
			selected_property.text = key
			break
	pass
	
