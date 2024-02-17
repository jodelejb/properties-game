extends Camera3D

@onready var fps_rig = $FpsRig
@onready var shotgun = $FpsRig/Shotgun
@onready var arms = $FpsRig/Arms
@onready var self_cast = $FpsRig/SelfCast
@export var player: RigidBody3D

var sway_clamp: float = 0.08

# Called when the node enters the scene tree for the first time.
func _ready():
	player.tool_changed.connect(update_view_model)
	update_view_model()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fps_rig.position = lerp(fps_rig.position,Vector3.ZERO,delta*10)

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

func update_view_model():
	shotgun.visible = false
	arms.visible = false
	self_cast.visible = false
	match player.current_equip:
		player.equips.self_apply:
			self_cast.visible = true
		player.equips.object_apply:
			shotgun.visible = true
			arms.visible = true
		player.equips.C4:
			pass
	pass
