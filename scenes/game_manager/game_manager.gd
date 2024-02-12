extends Node

@onready var player = $Player

@export_file("*.tscn") var starting_stage: String

var scene = null

func _ready():
	load_level(load(starting_stage))
	
func load_level(stage):
	if scene != null:
		scene.queue_free()
		await scene.tree_exited
	scene = stage.instantiate()
	add_child(scene)
	reset_player([], false)
	
	for loader in get_tree().get_nodes_in_group("Loader"):
		loader.load_level.connect(load_level)
		
	for kb in get_tree().get_nodes_in_group("KillBarrier"):
		kb.player_reset.connect(reset_player)
		
func reset_player(props: Array[Globals.properties], keep_stored: bool):
	var spawn = get_tree().get_first_node_in_group("PlayerSpawn")
	player.global_position = spawn.global_position + Vector3(0,1,0)
	player.linear_velocity = Vector3.ZERO
	player.neck.global_rotation = spawn.rotation
	if not keep_stored: player.remove_all_stored_props()
	player.pm.remove_all_properties()
	player.pm.append_props(props)
	player.set_invert_quat()
