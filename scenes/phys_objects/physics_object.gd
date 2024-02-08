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
func _process(_delta):
	if global_position.y < -150: destroy()
	#if len(get_colliding_bodies()) == 0:
		#linear_velocity.y += 0.000000000001
		
func _physics_process(delta):
	if len(get_colliding_bodies()) == 0:
		apply_force(Vector3(0,-0.000000000000001,0))
	
func destroy():
	hm.holder = null
	queue_free()
	destroyed.emit()
