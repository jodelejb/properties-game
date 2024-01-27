extends CanvasLayer

@export var player: CharacterBody3D

@onready var selected_property = $MarginContainer/VBoxContainer/SelectedProperty
@onready var property_label_container = $MarginContainer2/VBoxContainer/PropertyLabelContainer
@onready var self_applied_props_container = $MarginContainer3/VBoxContainer/SelfAppliedPropsContainer

var debug_label_settings = preload("res://scenes/dev/debug_text.tres")

func _ready():
	player.held_property_changed.connect(update_held_prop)
	player.stored_properties_changed.connect(update_stored_props)
	player.pm.applied_properties_changed.connect(update_applied_props)
	update_stored_props()
	update_applied_props()
	
func update_held_prop(prop) -> void:
	selected_property.text = ""
	for key in Globals.properties:
		if prop == Globals.properties[key]:
			selected_property.text = key
			break
			
func update_stored_props() -> void:
	update_props(property_label_container,player.stored_properties)
	
func update_applied_props() -> void:
	update_props(self_applied_props_container, player.pm.applied_properties)
			
func update_props(vbox: VBoxContainer, props: Array[Globals.properties]) -> void:
	for lbl in vbox.get_children():
		lbl.queue_free()
	for key in Globals.properties:
		if Globals.properties[key] in props:
			var lbl = Label.new()
			lbl.text = key
			lbl.label_settings = debug_label_settings
			vbox.add_child(lbl)
	
