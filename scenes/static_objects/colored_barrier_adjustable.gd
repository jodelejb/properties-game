@tool
extends StaticBody3D

@onready var mesh = $MeshInstance3D
@onready var collision = $CollisionShape3D

@export var size: Vector3 = Vector3(1,1,1)
@export var active_colors: Array[Globals.colors]
var prev_size: Vector3

func _ready():
	mesh.mesh = mesh.mesh.duplicate()
	collision.shape = collision.shape.duplicate()
	update_shape()
	prev_size = size
	
func _process(_delta):
	if Engine.is_editor_hint():
		update_shape()
		
func update_shape():
	if size == prev_size: return
	prev_size = size
	#var collision = CollisionShape3D.new()
	#var shape = BoxShape3D.new()
	#shape.resource_local_to_scene = true
	mesh.mesh.size = size
	#shape.size = size
	collision.shape.size = size
	#add_child(collision)
