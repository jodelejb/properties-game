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
	reset_player()
	
	for loader in get_tree().get_nodes_in_group("Loader"):
		loader.load_level.connect(load_level)
		
	for kb in get_tree().get_nodes_in_group("KillBarrier"):
		kb.player_reset.connect(reset_player)
		
func reset_player():
	var spawn = get_tree().get_first_node_in_group("PlayerSpawn")
	player.global_position = spawn.global_position
	player.rotation = spawn.rotation
	player.remove_all_stored_props()
	player.pm.remove_all_properties()
