extends Marker3D

@export_file("*.tscn") var object_to_spawn: String
@export var parent_node: Node3D
var object: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	object = load(object_to_spawn)
	spawn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func spawn():
	var obj = object.instantiate()
	#var obj = load(object_to_spawn).instantiate()
	obj.global_position = global_position
	parent_node.add_child.call_deferred(obj)
	if "destroyed" in obj:
		obj.destroyed.connect(spawn)
