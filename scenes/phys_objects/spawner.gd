extends Marker3D

@export_file("*.tscn") var object_to_spawn: String
@export var parent_node: Node3D
var object: PackedScene

var enabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	object = load(object_to_spawn)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func spawn():
	if not enabled: return
	var obj = object.instantiate()
	#var obj = load(object_to_spawn).instantiate()
	add_child.call_deferred(obj)
	await obj.tree_entered
	#obj.global_position = global_position
	if "destroyed" in obj:
		obj.destroyed.connect(spawn)


func _on_start_delay_timeout():
	enabled = true
	spawn()
