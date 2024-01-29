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
	var spawn = get_tree().get_first_node_in_group("PlayerSpawn")
	player.global_position = spawn.global_position
	player.rotation = spawn.rotation
	
	for loader in get_tree().get_nodes_in_group("Loader"):
		loader.load_level.connect(load_level)
