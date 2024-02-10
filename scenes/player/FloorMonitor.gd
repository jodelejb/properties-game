extends RigidBody3D

@onready var player: RigidBody3D = $".."

func _process(delta):
	position = Vector3(0,.469,0)
	linear_velocity = player.linear_velocity
