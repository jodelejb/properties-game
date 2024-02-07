extends InteractableButton
@onready var pivot: StaticBody3D = $Pivot

@onready var ball = $Pivot/BallMesh
var active_color: Color = Color(0,1,0)
var unactive_color: Color = Color(1,0,0)

var lever_limits: Array[float] = [15, -15]
var lerp_speed: float = 15

func _ready():
	update_color()

func _process(delta):
	if active:
		pivot.rotation_degrees.z = lerp(pivot.rotation_degrees.z,lever_limits[1],lerp_speed*delta)
		#pivot.rotation_degrees = Vector3(0,0,lever_limits[1])
		pass
	else:
		pivot.rotation_degrees.z = lerp(pivot.rotation_degrees.z,lever_limits[0],lerp_speed*delta)
		#pivot.rotation_degrees = Vector3(0,0,lever_limits[0])

func press():
	print("lever actuated")
	if not active:
		active = true
		status_changed.emit()
	elif active:
		active = false
		status_changed.emit()
	update_color()

func update_color():
	if active:
		ball.mesh.material.albedo_color = active_color
	else:
		ball.mesh.material.albedo_color = unactive_color
