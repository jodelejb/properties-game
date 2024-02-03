extends Marker3D

@export_file("*.tscn") var object_to_spawn: String
@export var parent_node: Node3D
var object: PackedScene
var spawned_objects: Array = []

@export var reset_button: InteractableButton
@export var initially_applied_properties: Array[Globals.properties]

var enabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	object = load(object_to_spawn)
	if reset_button:
		reset_button.status_changed.connect(reset)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func spawn():
	if not enabled: return
	spawned_objects = []
	var obj = object.instantiate()
	spawned_objects.append(obj)
	#var obj = load(object_to_spawn).instantiate()
	add_child.call_deferred(obj)
	await obj.tree_entered
	await obj.ready
	obj.pm.append_props(initially_applied_properties)
	#obj.global_position = global_position
	if "destroyed" in obj:
		obj.destroyed.connect(spawn)


func _on_start_delay_timeout():
	enabled = true
	spawn()

func reset():
	if reset_button.active:
		var so = spawned_objects.duplicate()
		for obj in so:
			if obj != null:
				if "destroy" in obj:
					obj.destroy()
				else:
					obj.qudeue_free()
	pass
