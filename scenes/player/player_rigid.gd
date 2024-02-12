extends RigidBody3D

#node references
@onready var standing_collider: CollisionShape3D = $Standing
@onready var crouching_collider: CollisionShape3D = $Crouching
@onready var height_check: RayCast3D = $HeightCheck
@onready var neck = $Neck
@onready var head = $Neck/Head
@onready var cam = $Neck/Head/Eyes/Camera3D
@onready var eyes: Node3D = $Neck/Head/Eyes
@onready var pickup: RayCast3D = $Neck/Head/Pickup
@onready var holding: Marker3D = $Neck/Head/Holding
@onready var property_cast: RayCast3D = $Neck/Head/PropertyCast
@onready var pm = $PropertyManager
@onready var hm = $HoldManager
@onready var bridge_jump_timer = $BridgeJumpTimer
@onready var coyote_timer = $CoyoteTimer
@onready var jump_timer = $JumpTimer
#@onready var floor_monitor_area = $FloorMonitorArea
@onready var thrown_timer = $ThrownTimer
@onready var ground = $Ground

var del: float

var on_floor: bool = false
var wall: bool = false
var max_floor_angle: float = 55
var invert_axis: Vector3
var invert_focus: float
var invert_quat: Quaternion
var inverted: bool = false
var head_rotated: bool = true

#movement speeds
var current_speed: float = 5.0
const jump_vel: float = 8.0
var bridge_jump: bool = false
var bridge_jump_base_modifier = 1
var can_jump: bool
var just_on_ground: bool = true
var just_jumped: bool = false
var just_thrown: bool = false
var velocity_offset: Vector3 = Vector3.ZERO

const walk_speed: float = 5.0/5.0
const sprint_speed: float = 8.0/5.0
const crouch_speed: float = 3.0/5.0

var mouse_sense: float = 0.03

var lerp_speed: float = 10.0
var direction: Vector3 = Vector3.ZERO
var input_dir

var head_height: float = .8
var crouching_depth: float = -1.0

#held object parameters. Maybe to move to phys object?
var held_object: RigidBody3D = null
var held_object_speed: float = 1600
var throw_speed: float = 15.0

signal stored_properties_changed
signal held_property_changed
var stored_properties: Array[Globals.properties] = []
func append_stored_prop(prop: Globals.properties) -> void:
	if prop not in stored_properties:
		stored_properties.append(prop)
		if len(stored_properties) == 1: held_property = prop
		stored_properties_changed.emit()
		
func append_stored_props(props: Array[Globals.properties]) -> void:
	for prop in props:
		append_stored_prop(prop)
		
func remove_stored_prop(prop: Globals.properties) -> void:
	if prop in stored_properties:
		stored_properties.erase(prop)
		if len(stored_properties) == 0: 
			held_property = null
		elif prop == held_property:
			held_property = stored_properties[0]
		stored_properties_changed.emit()
		
func remove_all_stored_props():
	for i in range(len(stored_properties)-1,-1,-1):
		remove_stored_prop(stored_properties[i])

var held_property = null:
	get:
		return held_property
	set(value):
		held_property = value
		held_property_changed.emit(held_property)
		

#movement states
enum states {walking, sprinting, crouching, sliding, NULL}
var curr_state = states.NULL:
	get:
		return curr_state
	set(value):
		curr_state = value
		
#head bobbing:
var head_bob_intense: float = 0

const head_bob_key: Array = [states.crouching, states.walking, states.sprinting]

const head_bob_speeds: Array[float] = [10.0, 14.0, 22.0]
const head_bob_intensity: Array[float] = [0.05, 0.1, 0.2]

var head_bob_vec: Vector2 = Vector2.ZERO
var head_bob_idx: float = 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pm.applied_properties_changed.connect(check_properties)
		

func _physics_process(delta):
	#floor_check.set_collision_layer_value(32, not floor_check.get_collision_layer_value(32))
	#PhysicsServer3D.area_set_monitorable(floor_check, false)
	#PhysicsServer3D.area_set_monitorable(floor_check, true)
	#print(is_on_floor())
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	del = delta
	
	if not is_on_floor() and just_on_ground and can_jump:
		coyote_timer.start()
	
	if is_on_floor() and not just_jumped: 
		just_on_ground = true
		can_jump = true
	
	if not is_on_floor():
		just_on_ground = false
	
	#movement states
	if Input.is_action_pressed("crouch"):
		current_speed = crouch_speed #lerp(current_speed, crouch_speed, lerp_speed*delta)
		standing_collider.disabled = true
		crouching_collider.disabled = false
		head.position.y = lerp(head.position.y, head_height + crouching_depth, lerp_speed*delta)
		curr_state = states.crouching
	elif !height_check.is_colliding():
		head.position.y = lerp(head.position.y, head_height, lerp_speed*delta)
		standing_collider.disabled = false
		crouching_collider.disabled = true
		if Input.is_action_pressed("sprint"):
			current_speed = sprint_speed #lerp(current_speed, sprint_speed, lerp_speed*delta)
			curr_state = states.sprinting
		else:
			current_speed = walk_speed #lerp(current_speed, walk_speed, lerp_speed*delta)
			curr_state = states.walking
			
	# get head bob intensities and speeds
	for i in len(head_bob_key):
		if curr_state == head_bob_key[i]:
			head_bob_intense = head_bob_intensity[i]
			head_bob_idx += head_bob_speeds[i] * delta
			break
		
	# apply the head bob
	if is_on_floor() && curr_state != states.sliding && input_dir != Vector2.ZERO:
		head_bob_vec.y = sin(head_bob_idx)
		head_bob_vec.x = sin(head_bob_idx/2) + 0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bob_vec.y * head_bob_intense /2.0 , lerp_speed*delta)
		eyes.position.x = lerp(eyes.position.x, head_bob_vec.x * head_bob_intense, lerp_speed*delta)
	else:
		eyes.position = lerp(eyes.position,Vector3.ZERO,lerp_speed*delta)
			
		# Handle jump.
	if Input.is_action_just_pressed("jump") and can_jump and hm.holder == null:
		can_jump = false
		just_jumped = true
		jump_timer.start()
		var bridge_jump_modifier = 1
		if bridge_jump:
			if Globals.properties.gravity in pm.applied_properties:
				bridge_jump_modifier = bridge_jump_base_modifier / 1.5#1.3
			else:
				bridge_jump_modifier = bridge_jump_base_modifier
			bridge_jump = false
		if Globals.properties.invert in pm.applied_properties:
			bridge_jump_modifier *= -1
		linear_velocity.y = jump_vel * bridge_jump_modifier
	
	#Rotate view due to invert property
	print(invert_quat)
	set_quaternion(lerp(quaternion,invert_quat,lerp_speed*delta))
	if not head_rotated:
		head.rotation.x = invert_focus
		head_rotated = true
		
	#pickup
	if Input.is_action_just_pressed("primary_action"):
		primary_action()
		
	if Input.is_action_just_pressed("secondary_action"):
		secondary_action()
		
	
	if Input.is_action_just_pressed("self_apply_property"):
		apply_property(pm)
		
	if Input.is_action_just_pressed("self_take_property"):
		take_property(pm)
	
	#pickup
	if Input.is_action_just_pressed("pick_up_object"):
		hm.pick_up(pickup.get_collider())
	
	if Input.is_action_just_pressed("interact"):
		var body = pickup.get_collider()
		
		#if body is InteractableButton:
		if body in get_tree().get_nodes_in_group("Interactable"):
			body.press()
		
	if Input.is_action_just_pressed("throw"):
		if hm.held_object == null: return
		for child in hm.held_object.get_children():
			if child is Bridge:
				bridge_jump = true
				bridge_jump_timer.start()
				bridge_jump_base_modifier = (clamp(head.rotation_degrees.x + 45,0,90))/90 + 1
				break
		var throw_augmenter: float = sin((head.rotation.x + 90)*PI/180) * 1
		var throw_aug_vec: Vector3 = Vector3(0,throw_augmenter,0)
		hm.throw((holding.global_position + throw_aug_vec - head.global_position).normalized())
		
	#scroll through properties
	var curridx = stored_properties.find(held_property,0)
		
	#scroll through held properties to choose which to apply
	if Input.is_action_just_pressed("prop_rotate_forward"):
		if len(stored_properties) == 0: return
		if curridx != len(stored_properties)-1:
			held_property = stored_properties[curridx+1]
		else:
			held_property = stored_properties[0]	
	if Input.is_action_just_pressed("prop_rotate_backwards"):
		if len(stored_properties) == 0: return
		if curridx != 0:
			held_property = stored_properties[curridx-1]
		else:
			held_property = stored_properties[-1]
	
	if Input.is_action_just_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _integrate_forces(state):
	direction = lerp(direction,(neck.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),del*lerp_speed)
	var numcol = state.get_contact_count()
	on_floor = false
	wall = false
	var floor_angle: float = 0
	var floor_direction: Vector3
	for n in range(numcol):
		var obj = state.get_contact_collider_object(n)
		
		#get floor and wall collisions
		var col: Vector3 = state.get_contact_local_position(n) - ground.global_position
		
		if col.y < 0.35 and Vector2(col.x,col.z).length() < 0.35: on_floor = true
		if col.y > 0.5 and Vector2(col.x,col.z).length() > 0.49: wall = true
		
		# to fix prop flying
		if obj == hm.held_object and (col.y < 0.45 and Vector2(col.x,col.z).length() < 0.45):
			hm.held_object = null
			hm.can_hold = false
			hm.grab_timeout.start()
			
		if col.y < 0.5:
			floor_angle = 90*lerpf(0,1,sqrt(clamp(col.y,0.0,0.5)/0.5))
			floor_direction = col.normalized()
			if curr_state == states.sprinting:
				floor_angle += 20 * direction.normalized().dot(Vector3(floor_direction.x,0,floor_direction.z).normalized())
	print(linear_velocity.y)
	if (is_on_floor() or is_on_wall()) and not just_thrown and linear_velocity.y < 6:
		velocity_offset = Vector3.ZERO
	if direction:
		if floor_angle > max_floor_angle:
			direction -= direction.dot(floor_direction)*Vector3(floor_direction.x,0.0,floor_direction.z)*0.5
		apply_force(direction*65*current_speed)
		apply_force(-10*(Vector3(linear_velocity.x,0,linear_velocity.z) - velocity_offset)*1)
		if is_on_floor():
			physics_material_override.friction = clamp(0.7-direction.length(),0,0.7)
		
		
func is_on_floor() -> bool:
	return on_floor
	
func is_on_wall() -> bool:
	return wall
	
#primary action. Likely to include more functions later
func primary_action():
	var collider = property_cast.get_collider()
	if collider in get_tree().get_nodes_in_group("CanProperty"):
		if "pm" in collider:
			apply_property(collider.pm)
		else:
			print("property manager not found")
	
func secondary_action():
	var collider = property_cast.get_collider()
	if collider in get_tree().get_nodes_in_group("CanProperty"):
		if "pm" in collider:
			take_property(collider.pm)
		else:
			print("property manager not found")
		
#applies a property to the selected property manager. removes it from stored when done
func apply_property(other_pm: PropertyManager) -> void:
	#sources are infinite property resources and hence cannot receive a property
	if other_pm.pm_type == Globals.pm_types.source: return
	if held_property != null and held_property not in other_pm.applied_properties:
		other_pm.append_prop(held_property) #as Array[Globals.properties]
		remove_stored_prop(held_property)
	
#removes a property from the selected property manager in order of the list of properties
#likely will need to be refactored to allow for choice later
func take_property(other_pm: PropertyManager) -> void:
	#sinks are an infinite well of one property and thus cannot have their properties removed
	if other_pm.pm_type == Globals.pm_types.sink: return
	for p in other_pm.applied_properties:
		if p not in stored_properties:
			append_stored_prop(p)
			other_pm.remove_prop(p) #as Array[Globals.properties]
			break
			

func _on_rigid_body_3d_body_entered(_body):
	pass
	#floor = true


func _on_rigid_body_3d_body_exited(_body):
	pass
	#floor = false


func _on_jump_timer_timeout():
	just_jumped = false


func _on_thrown_timer_timeout():
	just_thrown = false

func _on_coyote_timer_timeout():
	can_jump = false
	
func check_properties():
	if (Globals.properties.invert in pm.applied_properties and not inverted) or (Globals.properties.invert not in pm.applied_properties and inverted):
		#invert_axis = Vector3(sin(neck.global_rotation.y),0,cos(neck.global_rotation.y))
		#invert_focus = -1*head.rotation.x
		#var rot = 0
		#if Globals.properties.invert in pm.applied_properties: rot = PI
		#invert_quat = Quaternion(invert_axis,rot)
		set_invert_quat()
		head_rotated = false
		inverted = !inverted
	#elif Globals.properties.invert not in pm.applied_properties and inverted:
		#invert_axis = Vector3(sin(neck.global_rotation.y),0,cos(neck.global_rotation.y))
		
func set_invert_quat():
	invert_axis = Vector3(sin(neck.global_rotation.y),0,cos(neck.global_rotation.y))
	invert_focus = -1*head.rotation.x
	var rot = 0
	if Globals.properties.invert in pm.applied_properties: rot = PI
	invert_quat = Quaternion(invert_axis,rot)

