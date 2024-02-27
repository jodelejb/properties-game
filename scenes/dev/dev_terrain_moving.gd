@tool
extends RigidBody3D

@onready var shadow_on_2 = $ShadowOn2
@onready var mesh = $MeshInstance3D
@onready var collision = $CollisionShape3D

@export var size: Vector3 = Vector3(1,1,1)
@export var pathnode: PathFollow3D

var prev_size: Vector3
var follow_speed: float = 1000

func _ready():
	mesh.mesh = mesh.mesh.duplicate()
	shadow_on_2.mesh = shadow_on_2.mesh.duplicate()
	collision.shape = collision.shape.duplicate()
	update_shape()
	prev_size = size
	
func _process(delta):
	if Engine.is_editor_hint():
		update_shape()
		return
		
func _physics_process(delta):
	linear_velocity = (pathnode.global_position - global_position) * follow_speed * delta
	
func update_shape():
	if size == prev_size: return
	prev_size = size
	#var collision = CollisionShape3D.new()
	#var shape = BoxShape3D.new()
	#shape.resource_local_to_scene = true
	mesh.mesh.size = size
	shadow_on_2.mesh.size = size
	#shape.size = size
	collision.shape.size = size
	#add_child(collision)
