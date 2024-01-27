extends CharacterBody3D

@onready var head = $Head
@onready var standing_collider: CollisionShape3D = $Standing
@onready var crouching_collider: CollisionShape3D = $Crouching
@onready var height_check: RayCast3D = $HeightCheck
@onready var cam = $Head/Eyes/Camera3D
@onready var eyes: Node3D = $Head/Eyes
@onready var pickup: RayCast3D = $Head/Pickup
@onready var holding = $Head/Holding
@onready var property_cast: RayCast3D = $Head/PropertyCast
@onready var pm = $PropertyManager

var current_speed: float = 5.0
const jump_vel: float = 8.0

const walk_speed: float = 5.0
const sprint_speed: float = 8.0
const crouch_speed: float = 3.0

var mouse_sense: float = 0.03

var lerp_speed: float = 10.0
var direction: Vector3 = Vector3.ZERO

var head_height: float = 1.8
var crouching_depth: float = -1.0

var held_object: RigidBody3D = null
var held_object_speed: float = 10.0

signal stored_properties_changed
signal held_property_changed
var stored_properties: Array[Globals.properties] = [] # [Globals.properties.gravity, Globals.properties.red, Globals.properties.green, Globals.properties.blue]
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

var held_property = null:
	get:
		return held_property
	set(value):
		held_property = value
		held_property_changed.emit(held_property)
		

#states
enum state {walking, sprinting, crouching, sliding, NULL}
var curr_state = state.NULL:
	get:
		return curr_state
	set(value):
		curr_state = value

#head bobbing:
#var head_bob_speed: float = 0
var head_bob_intense: float = 0

const head_bob_key: Array = [state.crouching, state.walking, state.sprinting]

const head_bob_speeds: Array[float] = [10.0, 14.0, 22.0]
const head_bob_intensity: Array[float] = [0.05, 0.1, 0.2]

var head_bob_vec: Vector2 = Vector2.ZERO
var head_bob_idx: float = 0.0


		

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-1 * event.relative.x * mouse_sense))
		head.rotate_x(deg_to_rad(-1 * event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))
		pass

func _physics_process(delta):
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	#movement states
	if Input.is_action_pressed("crouch"):
		current_speed = lerp(current_speed, crouch_speed, lerp_speed*delta)
		standing_collider.disabled = true
		crouching_collider.disabled = false
		head.position.y = lerp(head.position.y, head_height + crouching_depth, lerp_speed*delta)
		curr_state = state.crouching
	elif !height_check.is_colliding():
		head.position.y = lerp(head.position.y, head_height, lerp_speed*delta)
		standing_collider.disabled = false
		crouching_collider.disabled = true
		if Input.is_action_pressed("sprint"):
			current_speed = lerp(current_speed, sprint_speed, lerp_speed*delta)
			curr_state = state.sprinting
		else:
			current_speed = lerp(current_speed, walk_speed, lerp_speed*delta)
			curr_state = state.walking
	
	# get head bob intensities and speeds
	for i in len(head_bob_key):
		if curr_state == head_bob_key[i]:
			head_bob_intense = head_bob_intensity[i]
			head_bob_idx += head_bob_speeds[i] * delta
			break
		
	# apply the head bob
	if is_on_floor() && curr_state != state.sliding && input_dir != Vector2.ZERO:
		head_bob_vec.y = sin(head_bob_idx)
		head_bob_vec.x = sin(head_bob_idx/2) + 0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bob_vec.y * head_bob_intense /2.0 , lerp_speed*delta)
		eyes.position.x = lerp(eyes.position.x, head_bob_vec.x * head_bob_intense, lerp_speed*delta)
	else:
		eyes.position = lerp(eyes.position,Vector3.ZERO,lerp_speed*delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_vel

	#Apply movement
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	move_and_slide()
	
	#pickup
	if Input.is_action_just_pressed("primary_action"):
		primary_action()
		
	if Input.is_action_just_pressed("secondary_action"):
		secondary_action()
		
	#pickup
	if Input.is_action_just_pressed("self_apply_property"):
		apply_property(pm)
		
	if Input.is_action_just_pressed("self_take_property"):
		take_property(pm)
	
	if Input.is_action_just_pressed("pick_up_object"):
		pick_up()
		
	if held_object != null:
		var a = held_object.global_position
		var b = holding.global_position
		held_object.linear_velocity = (b-a) * held_object_speed
		pass
		
	#scroll through properties
	var curridx = stored_properties.find(held_property,0)
		
	if Input.is_action_just_pressed("prop_rotate_forward"):
		if curridx != len(stored_properties)-1:
			held_property = stored_properties[curridx+1]
		else:
			held_property = stored_properties[0]
			
	if Input.is_action_just_pressed("prop_rotate_backwards"):
		if curridx != 0:
			held_property = stored_properties[curridx-1]
		else:
			held_property = stored_properties[-1]
	
func pick_up():
	if held_object != null:
		held_object = null
		return
	var collider = pickup.get_collider()
	if collider != null:
		print("attempting to pick up " + collider.name)
		held_object = collider
		
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
			
func apply_property(pm: PropertyManager) -> void:
	if pm.pm_type == Globals.pm_types.source: return
	if held_property != null and held_property not in pm.applied_properties:
		pm.append_prop(held_property) #as Array[Globals.properties]
		remove_stored_prop(held_property)
	
func take_property(pm: PropertyManager) -> void:
	if pm.pm_type == Globals.pm_types.sink: return
	for p in pm.applied_properties:
		if p not in stored_properties:
			append_stored_prop(p)
			pm.remove_prop(p) #as Array[Globals.properties]
			break


