extends Camera3D

@onready var fps_rig = $FpsRig

var sway_clamp: float = 0.08

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fps_rig.position = lerp(fps_rig.position,Vector3.ZERO,delta*5)

func sway(sway_amount: Vector3):
	fps_rig.position.x -= sway_amount.x * 0.00003
	fps_rig.position.y += sway_amount.y * 0.00003
	fps_rig.position.z += sway_amount.z * 0.00003
	fps_rig.position.x = clamp(fps_rig.position.x, -sway_clamp, sway_clamp)
	fps_rig.position.y = clamp(fps_rig.position.y, -sway_clamp, sway_clamp)
	fps_rig.position.z = clamp(fps_rig.position.z, -sway_clamp, sway_clamp)
	pass


func global_sway(sway_amount: Vector3):
	fps_rig.global_position.x -= sway_amount.x * 0.00003
	fps_rig.global_position.y += sway_amount.y * 0.00003
	fps_rig.global_position.z += sway_amount.z * 0.00003
	fps_rig.position.x = clamp(fps_rig.position.x, -sway_clamp, sway_clamp)
	fps_rig.position.y = clamp(fps_rig.position.y, -sway_clamp, sway_clamp)
	fps_rig.position.z = clamp(fps_rig.position.z, -sway_clamp, sway_clamp)
