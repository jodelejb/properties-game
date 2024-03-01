extends Node

# Reference to the player node
@onready var player = $Player

# Path to the starting stage scene file, exported for easy modification
@export_file("*.tscn") var starting_stage: String

var scene = null

var scenes = null

#prevents a race condition on computers where _process runs less often than _physics_process
var move_player: bool = false
var spawnpos: Vector3

func _ready():
	# Assign the UI node to the global UI variable and load the starting stage
	Globals.ui = $UI
	load_level(load(starting_stage))

# Load level function to instantiate and set up the scene
func load_level(stage):
	if scene != null:
		scene.queue_free()  # Free the current scene if it exists
		await scene.tree_exited  # Wait for the scene to exit
	scene = stage.instantiate() as Node3D # Instantiate the new scene
	add_child(scene)  # Add the new scene as a child of this node
	await scene.is_node_ready() # prevents race condition where the player
	reset_player([], false, false)  # Reset the player when loading a new level

	# Connect all loaders in the scene to the load_level function
	for loader in get_tree().get_nodes_in_group("Loader"):
		loader.load_level.connect(load_level)
		
	for end in get_tree().get_nodes_in_group("Joiner"):
		if not end.starting_point:
			end.attach_level.connect(attach_level)

	# Connect all KillBarrier nodes in the scene to the reset_player function
	for kb in get_tree().get_nodes_in_group("KillBarrier"):
		kb.player_reset.connect(reset_player_custom_spawn)
		
#for loading levels seamlessly
func attach_level(stage):
	var newstage = stage.instantiate() as Node3D
	await newstage.is_node_ready()
	var joins = []
	for child in newstage.get_children():
		for j in child.get_children():
			if j is Joiner:
				joins.append(j)
	
	var start: Vector3 = Vector3.ZERO
	var start_rotation: Vector3 = Vector3.ZERO
	var end: Vector3 = Vector3.ZERO
	var end_rotation: Vector3 = Vector3.ZERO
	for child in scene.get_children():
		for j in child.get_children():
			if j is Joiner and not j.starting_point:
				end = j.global_position
				end_rotation = j.global_rotation
				break
	for child in newstage.get_children():
		for j in child.get_children():
			if j in joins and j.starting_point:
				start = j.position
				start_rotation = j.rotation
			if j in joins and not j.starting_point:
				j.attach_level.connect(attach_level)
	var del_rotate: Vector3 = end_rotation - start_rotation
	newstage.rotation = del_rotate
	var del_origin: Vector2 = Vector2(cos(del_rotate.y),sin(del_rotate.y)) * start.length()
	newstage.position = end + Vector3(del_origin.x,0,-del_origin.y)
	add_child(newstage)
	scene = newstage

func reset_player_custom_spawn(props: Array[Globals.properties], keep_stored: bool):
	reset_player(props,keep_stored,true)

# Reset player function to respawn the player at a spawn point with optional properties
# custom spawn is dealing with a saved spawn point at the player's last acceptable location
func reset_player(props: Array[Globals.properties], keep_stored: bool, custom_spawn: bool):
	var spawn = get_tree().get_first_node_in_group("PlayerSpawn")  # Get the player spawn point
	print(spawn)
	print(spawn.global_position)
	if player.dynamic_spawn_point == spawn.global_position: 
		custom_spawn = false
	if custom_spawn:
		spawnpos = player.dynamic_spawn_point + (player.global_position - player.ground.global_position)
		move_player = true
	else:
		spawnpos = spawn.global_position + Vector3(0, 1, 0)  # Set player position slightly above spawn point
		move_player = true
		player.dynamic_spawn_point = spawn.global_position
	player.linear_velocity = Vector3.ZERO  # Reset player velocity
	if not custom_spawn:
		player.neck.global_rotation.y = spawn.rotation.y  # Set player neck rotation to match spawn point
		# Reset player rotation and properties, optionally keeping stored properties
		player.rotation = Vector3(0, 0, 0)
	if not keep_stored:
		player.remove_all_stored_props()
	player.pm.remove_all_properties()
	player.pm.append_props(props)  # Append new properties to the player

func _physics_process(delta):
	if move_player:
		player.global_position = spawnpos
		move_player = false
