extends Node3D

@onready var head = $Head
@onready var player = $".."
var mouse_sense: float = 0.03
@onready var view_model_camera = $Head/Eyes/Camera3D/SubViewportContainer/SubViewport/ViewModelCamera

func _input(event):
	# mouse movement to camera movement
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-1 * event.relative.x * mouse_sense))
		head.rotate_x(deg_to_rad(-1 * event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-90),deg_to_rad(90))
		view_model_camera.sway(Vector3(event.relative.x,event.relative.y,0.0))
		pass
