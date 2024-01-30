extends Node
class_name PropertyManager

@onready var phys_body: PhysicsBody3D = $".."
@onready var property_rotation = $PropertyRotation
@onready var property_display = $PropertyRotation/PropertyDisplay


@export var pm_type = Globals.pm_types.base

var base_collision_mask
#enum properties {gravity, red, green, blue}

signal applied_properties_changed()
var applied_properties: Array[Globals.properties] = []#[Globals.properties.red]:
func append_prop(prop: Globals.properties) -> void:
	if pm_type != Globals.pm_types.base: return
	if prop not in applied_properties:
		applied_properties.append(prop)
		set_properties()
		applied_properties_changed.emit()
		
func append_props(props: Array[Globals.properties]) -> void:
	for prop in props:
		append_prop(prop)
		
func remove_prop(prop: Globals.properties) -> void:
	if pm_type != Globals.pm_types.base: return
	if prop in applied_properties:
		applied_properties.erase(prop)
		set_properties()
		applied_properties_changed.emit()
		
func remove_all_properties():
	for i in range(len(applied_properties)-1,-1,-1):
		remove_prop(applied_properties[i])

		
func set_properties() -> void:
	#gravity property
	property_display.text = ""
	if Globals.properties.gravity in applied_properties:
		property_display.text += " Gravity"
		if "gravity" in phys_body:
			phys_body.gravity = Globals.low_grav
		if "gravity_scale" in phys_body:
			phys_body.gravity_scale = Globals.low_grav/ProjectSettings.get_setting("physics/3d/default_gravity")
	else:
		if "gravity" in phys_body:
			phys_body.gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
		if "gravity_scale" in phys_body:
			phys_body.gravity_scale = 1.0
		
	#barrier collision properties
	var color_col = []
	if Globals.properties.red not in applied_properties:
		color_col.append(Globals.red)
	if Globals.properties.green not in applied_properties:
		color_col.append(Globals.green)
	if Globals.properties.blue not in applied_properties:
		color_col.append(Globals.blue)
		
	if Globals.properties.red in applied_properties:
		property_display.text += " Red"
	if Globals.properties.green in applied_properties:
		property_display.text += " Green"
	if Globals.properties.blue in applied_properties:
		property_display.text += " Blue"
	phys_body.collision_mask = base_collision_mask + Globals.get_collision(color_col)

func _ready():
	base_collision_mask = phys_body.collision_mask
	phys_body.collision_mask += Globals.get_collision([Globals.red, Globals.blue, Globals.green])
	set_properties()
	phys_body.add_to_group("CanProperty")
	if "base_properties" in phys_body:
		var pmt = pm_type
		pm_type = Globals.pm_types.base
		append_props(phys_body.base_properties)
		pm_type = pmt
	
	
func _process(delta):
	property_rotation.position = phys_body.global_position + Vector3(0,0.8,0)
	var player = get_tree().get_first_node_in_group("Player")
	if not phys_body == player:
		property_rotation.look_at(player.head.global_position)
	

