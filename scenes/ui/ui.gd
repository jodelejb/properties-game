extends CanvasLayer

@export var player: CharacterBody3D

@onready var selected_property = $MarginContainer/SelectedProperty
@onready var property_label_container = $MarginContainer2/PropertyLabelContainer

var debug_label_settings = preload("res://scenes/dev/debug_text.tres")

func _ready():
	player.held_property_changed.connect(update_held_prop)
	player.stored_properties_changed.connect(update_stored_props)
	update_stored_props()
	
func update_held_prop(prop):
	selected_property.text = ""
	for key in Globals.properties:
		if prop == Globals.properties[key]:
			selected_property.text = key
			break
	pass
	
func update_stored_props():
	for lbl in property_label_container.get_children():
		lbl.queue_free()
	for key in Globals.properties:
		if Globals.properties[key] in player.stored_properties:
			var lbl = Label.new()
			lbl.text = key
			lbl.label_settings = debug_label_settings
			property_label_container.add_child(lbl)
	
