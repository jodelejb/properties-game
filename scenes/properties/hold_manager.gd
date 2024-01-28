extends Node

@onready var phys_body: PhysicsBody3D = $".."

var held_object: PhysicsBody3D:
	get:
		return held_object
	set(value):
		if held_object == value: return
		#var old_held_object = held_object
		if held_object != null: held_object.hm.holder = null
		held_object = value
		if held_object != null: held_object.hm.holder = phys_body

var holder: PhysicsBody3D:
	get:
		return holder
	set(value):
		if holder == value: return
		#if holder != null: holder.hm.held_object = phys_body
		holder = value
		if holder != null: holder.hm.held_object = phys_body
		print("holder set to " + str(holder))

@export var held_object_speed: float = 10.0
@export var throw_speed: float = 15.0
@export var hold_point: Marker3D

func _ready():
	phys_body.add_to_group("Holding")

func _physics_process(delta):
	follow()

func pick_up(collider):
	if held_object != null:
		held_object = null
		return
	#var collider = pickup.get_collider()
	if collider != null:
		print("attempting to pick up " + collider.name)
		if collider in get_tree().get_nodes_in_group("Holding") and "hm" in collider:
			held_object = collider

func throw(throw_vec: Vector3):
	if held_object == null: return
	#var look_vec = (holding.global_position - head.global_position).normalized()
	var obj_speed = held_object.linear_velocity.length()
	if obj_speed < throw_speed:
		held_object.linear_velocity += throw_vec*(throw_speed - obj_speed)
	held_object = null
	
func follow():
	if holder != null:
		var a = phys_body.global_position
		var b = holder.hm.hold_point.global_position
		phys_body.linear_velocity = (b-a) * held_object_speed
