extends Node

@onready var phys_body: PhysicsBody3D = $".."

signal held_object_changed(current_held_object: PhysicsBody3D)
var held_object: PhysicsBody3D:
	get:
		return held_object
	set(value):
		held_object = value
		held_object_changed.emit(phys_body)
func sync_held_object(current_holder: PhysicsBody3D):
	pass

signal holder_changed(current_holder: PhysicsBody3D)
var holder: PhysicsBody3D:
	get:
		return holder
	set(value):
		holder = value
		holder_changed.emit(holder)
func sync_holder(current_held_object: PhysicsBody3D):
	pass

@export var held_object_speed: float = 10.0
@export var throw_speed: float = 15.0
@export var hold_point: Marker3D

func _physics_process(delta):
	follow()

func pick_up(collider):
	if held_object != null:
		held_object = null
		return
	#var collider = pickup.get_collider()
	if collider != null:
		print("attempting to pick up " + collider.name)
		held_object = collider

func throw(throw_vec: Vector3):
	if held_object == null: return
	#var look_vec = (holding.global_position - head.global_position).normalized()
	var obj_speed = held_object.linear_velocity.length()
	if obj_speed < throw_speed:
		held_object.linear_velocity += throw_vec*(throw_speed - obj_speed)
	held_object = null
	
func follow():
	if held_object != null:
		var a = held_object.global_position
		var b = hold_point.global_position
		held_object.linear_velocity = (b-a) * held_object_speed
