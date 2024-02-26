extends RigidBody3D

# Node references
@onready var standing_collider: CollisionShape3D = $Standing  # Reference to standing collider
@onready var crouching_collider: CollisionShape3D = $Crouching  # Reference to crouching collider
@onready var height_check: RayCast3D = $HeightCheck  # Raycast for checking height
@onready var neck = $Neck  # Reference to neck node
@onready var head = $Neck/Head  # Reference to head node
@onready var cam = $Neck/Head/Eyes/Camera3D  # Reference to camera
@onready var eyes: Node3D = $Neck/Head/Eyes  # Reference to eyes node
@onready var pickup: RayCast3D = $Neck/Head/Pickup  # Raycast for picking up objects
@onready var holding: Marker3D = $Neck/Head/Holding  # Reference to marker for holding objects
@onready var property_cast: RayCast3D = $Neck/Head/PropertyCast  # Raycast for properties
@onready var pm = $PropertyManager  # Reference to property manager
@onready var hm = $HoldManager  # Reference to hold manager
@onready var bridge_jump_timer = $BridgeJumpTimer  # Timer for bridge jump
@onready var coyote_timer = $CoyoteTimer  # Timer for coyote time (allowing jump after leaving ground)
@onready var jump_timer = $JumpTimer  # Timer for tracking jump time
@onready var thrown_timer = $ThrownTimer  # Timer for tracking thrown object
@onready var ground = $Ground  # Reference to ground node
@onready var fps_cam = $Neck/Head/Eyes/Camera3D/SubViewportContainer/SubViewport/ViewModelCamera  # First-person view camera

# Variables for character state and behavior
var del: float  # Delta time
var on_floor: bool = false  # Flag indicating whether the character is on the floor
var wall: bool = false  # Flag indicating whether the character is against a wall
var max_floor_angle: float = 55  # Maximum angle for the floor before the character begins slipping
var invert_axis: Vector3  # Axis for inverting character orientation
var invert_focus: float  # Focus point for inverting character orientation about
var invert_quat: Quaternion  # Quaternion for inverting character orientation
var inverted: bool = false  # Flag indicating whether the character orientation is inverted
var head_rotated: bool = true  # Flag indicating whether the character's head is rotated

# Movement speeds and parameters
var current_speed: float = 5.0  # Current movement speed
const jump_vel: float = 8.0  # Jump velocity
var bridge_jump: bool = false  # Flag indicating whether bridge jump is enabled
var bridge_jump_base_modifier = 1  # Base modifier for bridge jump
var can_jump: bool  # Flag indicating whether the character can jump
var just_on_ground: bool = true  # Flag indicating whether the character just landed on the ground
var just_jumped: bool = false  # Flag indicating whether the character just jumped
var just_thrown: bool = false  # Flag indicating whether the character just threw an object
var velocity_offset: Vector3 = Vector3.ZERO  # Offset for character velocity

# Movement speeds constants
const walk_speed: float = 5.0/5.0  # Walking speed
const sprint_speed: float = 6.0/5.0  # Sprinting speed
const crouch_speed: float = 3.0/5.0  # Crouching speed

var mouse_sense: float = 0.03  # Mouse sensitivity

var lerp_speed: float = 10.0  # Speed for lerping camera
var direction: Vector3 = Vector3.ZERO  # Direction vector
var input_dir  # Input direction vector

var head_height: float = .8  # Height of character's head
var crouching_depth: float = -1.0  # Depth of crouching

# Held object parameters
var held_object: RigidBody3D = null  # Reference to held object
var held_object_speed: float = 1600  # Speed of held object
var throw_speed: float = 15.0  # Speed of throwing an object

# Signal emitted when stored properties are changed
signal stored_properties_changed

# Signal emitted when held property is changed
signal held_property_changed

# Array to store properties
var stored_properties: Array[Globals.properties] = []

# Function to append a property to stored_properties array
func append_stored_prop(prop: Globals.properties) -> void:
	if prop not in stored_properties:
		stored_properties.append(prop)
		if len(stored_properties) == 1:
			held_property = prop  # Set held property if it's the first one
		stored_properties_changed.emit()  # Emit signal

# Function to append multiple properties to stored_properties array
func append_stored_props(props: Array[Globals.properties]) -> void:
	for prop in props:
		append_stored_prop(prop)

# Function to remove a property from stored_properties array
func remove_stored_prop(prop: Globals.properties) -> void:
	if prop in stored_properties:
		stored_properties.erase(prop)
		if len(stored_properties) == 0:
			held_property = null  # Reset held property if no properties are stored
		elif prop == held_property:
			held_property = stored_properties[0]  # Set new held property if removed property was held
		stored_properties_changed.emit()  # Emit signal

# Function to remove all stored properties
func remove_all_stored_props():
	for i in range(len(stored_properties)-1, -1, -1):
		remove_stored_prop(stored_properties[i])

# Variable to hold the currently held property
var held_property = null:
	get:
		return held_property
	set(value):
		held_property = value
		held_property_changed.emit(held_property)  # Emit signal when held property changes

# Enumeration for movement states
enum states {walking, sprinting, crouching, sliding, NULL}
var curr_state = states.NULL:
	get:
		return curr_state
	set(value):
		curr_state = value

# Head bobbing parameters
var head_bob_intense: float = 0
const head_bob_key: Array = [states.crouching, states.walking, states.sprinting]  # Head bob key
const head_bob_speeds: Array[float] = [10.0, 14.0, 22.0]  # Head bob speeds
const head_bob_intensity: Array[float] = [0.05, 0.1, 0.2]  # Head bob intensities
var head_bob_vec: Vector2 = Vector2.ZERO  # Vector for head bobbing
var head_bob_idx: float = 0.0  # Index for head bobbing

# Enumeration for equipment
enum equips {self_apply, object_apply, C4}
var current_equip: equips = equips.object_apply  # Default equipment
signal tool_changed  # Signal emitted when tool is changed

#spawns the player at the last surface they fully stopped upon
var dynamic_spawn_point: Vector3

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pm.applied_properties_changed.connect(check_properties)
		

func _physics_process(delta):
	# Update first-person camera position and rotation
	fps_cam.global_position = cam.global_position
	fps_cam.global_rotation = cam.global_rotation
	
	# Apply sway to first-person camera based on linear velocity
	fps_cam.global_sway(Vector3(0.0, linear_velocity.y * -8, 0.0))
	
	# Get input direction
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	del = delta  # Store delta time
	
	# Coyote time: start timer if character leaves ground and is able to jump
	if not is_on_floor() and just_on_ground and can_jump:
		coyote_timer.start()
	
	# Update flags when character lands on ground or jumps
	if is_on_floor() and not just_jumped:
		just_on_ground = true
		can_jump = true
	
	if not is_on_floor():
		just_on_ground = false
	
	# Handle movement states
	if Input.is_action_pressed("crouch"):
		# Crouch state
		current_speed = crouch_speed
		standing_collider.disabled = true
		crouching_collider.disabled = false
		head.position.y = lerp(head.position.y, head_height + crouching_depth, lerp_speed * delta)
		curr_state = states.crouching
	elif not height_check.is_colliding():
		# Standing state
		head.position.y = lerp(head.position.y, head_height, lerp_speed * delta)
		standing_collider.disabled = false
		crouching_collider.disabled = true
		if Input.is_action_pressed("sprint"):
			current_speed = sprint_speed
			curr_state = states.sprinting
		else:
			current_speed = walk_speed
			curr_state = states.walking
	
	# Calculate head bob intensities and speeds
	for i in len(head_bob_key):
		if curr_state == head_bob_key[i]:
			head_bob_intense = head_bob_intensity[i]
			head_bob_idx += head_bob_speeds[i] * delta
			break
	
	# Apply head bob
	if is_on_floor() && curr_state != states.sliding && input_dir != Vector2.ZERO:
		head_bob_vec.y = sin(head_bob_idx)
		head_bob_vec.x = sin(head_bob_idx/2) + 0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bob_vec.y * head_bob_intense /2.0 , lerp_speed * delta)
		eyes.position.x = lerp(eyes.position.x, head_bob_vec.x * head_bob_intense, lerp_speed * delta)
		fps_cam.sway(Vector3(eyes.position.x * 200, eyes.position.y * 200, 0.0))
	else:
		eyes.position = lerp(eyes.position, Vector3.ZERO, lerp_speed * delta)
		
	# Handle jump
	if Input.is_action_just_pressed("jump") and can_jump and hm.holder == null:
		can_jump = false
		just_jumped = true
		jump_timer.start()
		var bridge_jump_modifier = 1
		if bridge_jump:
			if Globals.properties.gravity in pm.applied_properties:
				bridge_jump_modifier = bridge_jump_base_modifier / 1.5
			else:
				bridge_jump_modifier = bridge_jump_base_modifier
			bridge_jump = false
		if Globals.properties.invert in pm.applied_properties:
			bridge_jump_modifier *= -1
		linear_velocity.y = jump_vel * bridge_jump_modifier
	
	# Rotate view due to invert property
	set_quaternion(lerp(quaternion, invert_quat, lerp_speed * delta))
	if not head_rotated:
		head.rotation.x = invert_focus
		head_rotated = true
	
	# Handle primary and secondary actions
	if Input.is_action_just_pressed("primary_action"):
		primary_action()
		
	if Input.is_action_just_pressed("secondary_action"):
		secondary_action()
		
	# Change current equipment based on input
	if Input.is_action_just_pressed("equip_self_apply"):
		current_equip = equips.self_apply
		tool_changed.emit()
	
	if Input.is_action_just_pressed("equip_object_apply"):
		current_equip = equips.object_apply
		tool_changed.emit()
	
	if Input.is_action_just_pressed("equip_c4"):
		current_equip = equips.C4
		tool_changed.emit()
	
	# Handle object pickup
	if Input.is_action_just_pressed("pick_up_object"):
		hm.pick_up(pickup.get_collider())
	
	# Handle interaction
	if Input.is_action_just_pressed("interact"):
		var body = pickup.get_collider()
		if body in get_tree().get_nodes_in_group("Interactable"):
			body.press()
	
	# Handle throwing objects
	if Input.is_action_just_pressed("throw"):
		if hm.held_object == null: return
		for child in hm.held_object.get_children():
			# bridges when thrown give a single high jump
			if child is Bridge:
				bridge_jump = true
				bridge_jump_timer.start()
				bridge_jump_base_modifier = (clamp(head.rotation_degrees.x + 45,0,90))/90 + 1
				break
		var throw_augmenter: float = sin((head.rotation.x + 90) * PI / 180) * 1
		var throw_aug_vec: Vector3 = Vector3(0, throw_augmenter, 0)
		hm.throw((holding.global_position + throw_aug_vec - head.global_position).normalized())
	
	# Scroll through stored properties
	var curridx = stored_properties.find(held_property, 0)
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
	
	# Toggle mouse mode
	if Input.is_action_just_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _integrate_forces(state):
	# Calculate movement direction based on input and character orientation
	direction = lerp(direction, (neck.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), del * lerp_speed)
	
	# Get the number of contact points with the environment
	var numcol = state.get_contact_count()
	on_floor = false
	wall = false
	var floor_angle: float = 0
	var floor_direction: Vector3
	var moving_collision: bool = false
	
	# Loop through all contact points
	for n in range(numcol):
		var obj = state.get_contact_collider_object(n)
		var col: Vector3 = state.get_contact_local_position(n) - ground.global_position
		
		# Check for floor and wall collisions
		if col.y < 0.35 and Vector2(col.x, col.z).length() < 0.35:
			on_floor = true
		if col.y > 0.5 and Vector2(col.x, col.z).length() > 0.49:
			wall = true
			
		# Set the dynamic spawn point to the last good location according to the following criteria
		if col.y < 0.01 and obj in get_tree().get_nodes_in_group("StaticTerrain") and obj.can_checkpoint and self in obj.checkpoint.get_overlapping_bodies():
			dynamic_spawn_point = ground.global_position
			#print(dynamic_spawn_point)
		
		# Handle object collision with held object
		if obj == hm.held_object and (col.y < 0.45 and Vector2(col.x, col.z).length() < 0.45):
			hm.held_object = null
			hm.can_hold = false
			hm.grab_timeout.start()
		
		# Calculate floor angle and direction
		if col.y < 0.5:
			floor_angle = 90 * lerpf(0, 1, sqrt(clamp(col.y, 0.0, 0.5) / 0.5))
			floor_direction = col.normalized()
			if curr_state == states.sprinting:
				floor_angle += 20 * direction.normalized().dot(Vector3(floor_direction.x, 0, floor_direction.z).normalized())
		
		# Handle velocity offsets for moving platforms
		if obj in get_tree().get_nodes_in_group("MovingPlatform"):
			velocity_offset = Vector3(obj.linear_velocity.x,0.0, obj.linear_velocity.z)
			moving_collision = true
	
	# Reset velocity offset if not on moving platform and not just thrown
	if not moving_collision and (is_on_floor() or is_on_wall()) and not just_thrown and linear_velocity.y < 6:
		velocity_offset = Vector3.ZERO
	
	# Apply forces based on movement direction
	if direction:
		if floor_angle > max_floor_angle:
			direction -= direction.dot(floor_direction) * Vector3(floor_direction.x, 0.0, floor_direction.z) * 0.5
		apply_force(direction * 65 * current_speed)
		apply_force(-10 * (Vector3(linear_velocity.x, 0, linear_velocity.z) - velocity_offset) * 1)
		if is_on_floor():
			physics_material_override.friction = clamp(0.7 - direction.length(), 0, 0.7)

		
		
# Check if character is on the floor
func is_on_floor() -> bool:
	return on_floor

# Check if character is against a wall
func is_on_wall() -> bool:
	return wall

# Primary action function
func primary_action():
	# Match current equipment and perform corresponding action
	match current_equip:
		equips.self_apply:
			apply_property(pm)  # Apply property if self apply equipment is selected
		equips.object_apply:
			cast_property()  # Cast property if object apply equipment is selected
		equips.C4:
			print("Applying C4")  # Placeholder action for C4 equipment

# Secondary action function
func secondary_action():
	# Match current equipment and perform corresponding action
	match current_equip:
		equips.self_apply:
			take_property(pm)  # Take property if self apply equipment is selected
		equips.object_apply:
			steal_property()  # Steal property if object apply equipment is selected
		equips.C4:
			print("Taking C4")  # Placeholder action for C4 equipment

# Cast property function
func cast_property() -> void:
	var collider = property_cast.get_collider()
	if collider in get_tree().get_nodes_in_group("CanProperty"):
		if "pm" in collider:
			apply_property(collider.pm)  # Apply property to collider's property manager
		else:
			print("Property manager not found")

# Steal property function
func steal_property() -> void:
	var collider = property_cast.get_collider()
	if collider in get_tree().get_nodes_in_group("CanProperty"):
		if "pm" in collider:
			take_property(collider.pm)  # Take property from collider's property manager
		else:
			print("Property manager not found")

# Apply property function
func apply_property(other_pm: PropertyManager) -> void:
	# Check if the property manager is a source, which cannot receive properties
	if other_pm.pm_type == Globals.pm_types.source:
		return
	# Check if there's a held property and it's not already applied to the property manager
	if held_property != null and held_property not in other_pm.applied_properties:
		other_pm.append_prop(held_property)  # Add held property to the property manager
		pm.remove_prop(held_property)  # Remove held property from stored properties

# Take property function
func take_property(other_pm: PropertyManager) -> void:
	# Check if the property manager is a sink, which cannot have properties removed
	if other_pm.pm_type == Globals.pm_types.sink:
		return
	# Iterate through applied properties and add them to stored properties
	for p in other_pm.applied_properties:
		if p not in stored_properties:
			pm.append_prop(p)  # Add property to stored properties
			other_pm.remove_prop(p)  # Remove property from property manager
			break  # Exit loop after removing one property

func _on_jump_timer_timeout():
	just_jumped = false
	# Reset the 'just_jumped' flag to false when the jump timer times out

func _on_thrown_timer_timeout():
	# Reset the 'just_thrown' flag to false when the thrown timer times out
	just_thrown = false

func _on_coyote_timer_timeout():
	# Set the 'can_jump' flag to false when the coyote timer times out
	can_jump = false

# Check properties function to handle property changes
func check_properties():
	remove_all_stored_props()
	for prop in pm.applied_properties:
		if prop not in stored_properties:
			append_stored_prop(prop)
	# Check if the 'invert' property has been applied or removed and adjust accordingly
	if (Globals.properties.invert in pm.applied_properties and not inverted) or (Globals.properties.invert not in pm.applied_properties and inverted):
		set_invert_quat()
		head_rotated = false
		inverted = !inverted
	

# Set invert quaternion function to update the invert quaternion based on property changes
func set_invert_quat():
	# Set the invert quaternion based on the current rotation and 'invert' property
	invert_axis = Vector3(sin(neck.global_rotation.y), 0, cos(neck.global_rotation.y))
	invert_focus = -1 * head.rotation.x
	var rot = 0
	if Globals.properties.invert in pm.applied_properties: rot = PI
	invert_quat = Quaternion(invert_axis, rot)
	


