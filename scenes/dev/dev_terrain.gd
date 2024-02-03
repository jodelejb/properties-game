extends StaticBody3D

@onready var mesh = $MeshInstance3D
@onready var collision = $CollisionShape3D

@export var size: Vector3 = Vector3(1,1,1)

func _ready():
	update_shape()
	
func _process(_delta):
	if Engine.is_editor_hint():
		update_shape()
		
func update_shape():
	#var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.resource_local_to_scene = true
	mesh.mesh.size = size
	shape.size = size
	collision.shape = shape
	#add_child(collision)
