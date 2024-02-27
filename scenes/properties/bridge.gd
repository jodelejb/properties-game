extends Node3D
class_name Bridge

@onready var piece_delay = $PieceDelay

var bridge_piece: PackedScene = preload("res://scenes/properties/bridge_piece.tscn")
var last_location: Vector3
var spawn_point: Node3D
var bridge_node: Node3D

var piece_length = 0.2

var can_bridge: bool = false

@onready var phys_body: PhysicsBody3D = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	bridge_node = get_tree().get_first_node_in_group("Bridge")
	if phys_body == get_tree().get_first_node_in_group("Player"):
		position.y -= 0.99
	spawn_point = self
	last_location = spawn_point.global_position
	if "hm" in phys_body:
		phys_body.hm.holder_changed.connect(hold_changed)
	hold_changed()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (spawn_point.global_position-last_location).length() > piece_length:
		if "hm" in phys_body:
			if phys_body.hm.holder != null: return
		if not can_bridge: return
		if "linear_velocity" in phys_body:
			if Vector2(phys_body.linear_velocity.x, phys_body.linear_velocity.z).length() < 0.05: return
		elif "velocity" in phys_body:
			if Vector2(phys_body.velocity.x, phys_body.velocity.z).length() < 0.05: return
		var bp  = bridge_piece.instantiate() as StaticBody3D
		bp.set_deferred("global_position",spawn_point.global_position)
		var vel
		if "linear_velocity" in phys_body:
			vel = phys_body.linear_velocity
		elif "velocity" in phys_body:
			vel = phys_body.velocity
		var xzproj: Vector2 = Vector2(vel.dot(Vector3(1,0,0)),vel.dot(Vector3(0,0,1)))
		var xzproj3d: Vector3 = Vector3(xzproj.x,0,xzproj.y)
		var norm2d
		if xzproj == Vector2.ZERO:
			norm2d = Vector2(1,0)
		else:
			norm2d = xzproj.rotated(PI/2)
		var norm = Vector3(norm2d.x,0,norm2d.y)
		var angle_y = Vector3(1,0,0).signed_angle_to(norm,Vector3(0,1,0))
		var angle_x = xzproj3d.signed_angle_to(vel,norm)
		bp.rotate_y(angle_y)
		bp.quaternion = Quaternion(norm.normalized(),angle_x)*Quaternion(Vector3(0,1,0),angle_y)
		bridge_node.add_child(bp)
		last_location = spawn_point.global_position
		
func hold_changed():
	if "hm" not in phys_body: return
	if phys_body.hm.holder == null:
		can_bridge = false
		piece_delay.start()


func _on_piece_delay_timeout():
	can_bridge = true
