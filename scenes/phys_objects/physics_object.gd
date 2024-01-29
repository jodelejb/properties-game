extends RigidBody3D
class_name PhysObject

@onready var pm = $PropertyManager
@onready var hm = $HoldManager

@export var base_properties: Array[Globals.properties]
signal destroyed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func destroy():
	queue_free()
	destroyed.emit()
