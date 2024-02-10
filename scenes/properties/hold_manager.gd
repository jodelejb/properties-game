extends Node

@onready var phys_body: PhysicsBody3D = $".."

signal held_changed
var held_object: PhysicsBody3D:
	get:
		return held_object
	set(value):
		if held_object == value: return
		var old_held_object = held_object
		held_object = value
		#if held_object != null:
			#print(phys_body.name + "'s held object is " + held_object.name)
		#else:
			#print(phys_body.name + "'s held object is null")
		if old_held_object != null: 
			if old_held_object.hm.holder == phys_body:
				old_held_object.hm.holder = null
		if held_object != null: held_object.hm.holder = phys_body
		held_changed.emit()

signal holder_changed
var holder: PhysicsBody3D:
	get:
		return holder
	set(value):
		if holder == value: return
		var old_holder = holder
		holder = value
		#if holder != null:
			#print(phys_body.name + "'s holder is " + holder.name)
		#else:
			#print(phys_body.name + "'s holder is null")
		if old_holder != null: 
			if old_holder.hm.held_object == phys_body:
				old_holder.hm.held_object = null
		if holder != null: holder.hm.held_object = phys_body
		holder_changed.emit()
		#print("holder set to " + str(holder))

@export var held_object_speed: float = 800
@export var throw_speed: float = 15
@export var hold_point: Marker3D
@export var hold_length: float = 3

func _ready():
	phys_body.add_to_group("Holding")
	if "throw_speed" in phys_body:
		throw_speed = phys_body.throw_speed

func _physics_process(delta):
	follow(delta)

func pick_up(collider):
	if held_object != null:
		held_object = null
		return
	#var collider = pickup.get_collider()
	if collider != null:
		if collider in get_tree().get_nodes_in_group("Holding") and "hm" in collider:
			held_object = collider

func throw(throw_vec: Vector3):
	if held_object == null: return
	throw_vec = throw_vec.normalized()
	#var look_vec = (holding.global_position - head.global_position).normalized()
	if "linear_velocity" in held_object:
		var obj_speed = held_object.linear_velocity.length()
		if obj_speed < throw_speed:
			var throw_total = throw_vec*throw_speed
			if "velocity_offset" in held_object:
				held_object.velocity_offset = Vector3(throw_total.x,0,throw_total.z)
			held_object.linear_velocity = throw_total
	elif "velocity" in held_object:
		var obj_speed = held_object.velocity.length()
		if obj_speed < throw_speed:
			#held_object.velocity += throw_vec*(throw_speed - obj_speed)
			held_object.applied_velocities.append([throw_vec*throw_speed, held_object.vel_expiration.gravity, false])
	held_object = null
	
func follow(delta):
	if holder != null:
		var a = phys_body.global_position
		var b = holder.hm.hold_point.global_position
		if (b-a).length() > hold_length: 
			holder = null
			return
		if "linear_velocity" in phys_body:
			phys_body.linear_velocity = (b-a) * held_object_speed * delta
		if "velocity" in phys_body:
			#phys_body.velocity = (b-a) * held_object_speed * delta
			phys_body.applied_velocities.append([(b-a) * held_object_speed * delta, phys_body.vel_expiration.instant, false])
