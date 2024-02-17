extends CanvasLayer

@export var player: RigidBody3D

@onready var selected_property = $MarginContainer/VBoxContainer/SelectedProperty
@onready var property_label_container = $MarginContainer2/VBoxContainer/PropertyLabelContainer
@onready var self_applied_props_container = $MarginContainer3/VBoxContainer/SelfAppliedPropsContainer
@onready var equipped_tool = $MarginContainer4/VBoxContainer/EquippedTool
@onready var note = $VBoxContainer/Notification

var debug_label_settings = preload("res://scenes/dev/debug_text.tres")

func _ready():
	player.held_property_changed.connect(update_held_prop)
	player.stored_properties_changed.connect(update_stored_props)
	player.pm.applied_properties_changed.connect(update_applied_props)
	player.tool_changed.connect(update_tool)
	update_stored_props()
	update_applied_props()
	update_tool()
	
func update_held_prop(prop) -> void:
	selected_property.text = ""
	for key in Globals.properties:
		if prop == Globals.properties[key]:
			selected_property.text = key
			break
			
func update_stored_props() -> void:
	update_props(property_label_container,player.stored_properties, false)
	
func update_applied_props() -> void:
	update_props(self_applied_props_container, player.pm.applied_properties, true)
			
func update_props(vbox: VBoxContainer, props: Array[Globals.properties], combine_colors: bool) -> void:
	for lbl in vbox.get_children():
		lbl.queue_free()
	if combine_colors:
		var color = update_color(props)
		if color != "":
			var lbl = Label.new()
			lbl.text = color
			lbl.label_settings = debug_label_settings
			vbox.add_child(lbl)
	for key in Globals.properties:
		if combine_colors: if Globals.properties[key] in [Globals.properties.red,Globals.properties.green,Globals.properties.blue]: continue
		if Globals.properties[key] in props:
			var lbl = Label.new()
			lbl.text = key
			lbl.label_settings = debug_label_settings
			vbox.add_child(lbl)
			
func update_color(applied_properties: Array[Globals.properties]) -> String:
	if Globals.properties.red in applied_properties:
		if Globals.properties.blue in applied_properties:
			if Globals.properties.green in applied_properties:
				return "White"
			else:
				return "Magenta"
		elif Globals.properties.green in applied_properties:
			return "Yellow"
		else:
			return "Red"
	elif Globals.properties.green in applied_properties:
		if Globals.properties.blue in applied_properties:
			return "Cyan"
		else:
			return "Green"
	elif Globals.properties.blue in applied_properties:
		return "Blue"
	return ""
	
func update_tool() -> void:
	match player.current_equip:
		player.equips.self_apply:
			equipped_tool.text = "Self-Apply"
		player.equips.object_apply:
			equipped_tool.text = "Object-Apply"
		player.equips.C4:
			equipped_tool.text = "C4-Apply"
			pass
	pass
