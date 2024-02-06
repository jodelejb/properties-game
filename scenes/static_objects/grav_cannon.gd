extends StaticBody3D

@onready var hm = $HoldManager
@onready var grab_range: Area3D = $GrabRange
@onready var throw_timer: Timer = $ThrowTimer
@onready var disabled_timer = $DisabledTimer
@onready var hold_point = $HoldPoint
@onready var cannon_body = $MeshInstance3D2

@export var throw_speed: float = 20

var can_grab: bool = true

var normal_color: Color = Color(1,1,1)
var grab_color: Color = Color(1,1,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	#grab_range.body_entered.connect(grab_object)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	cannon_body.mesh.material.albedo_color = normal_color
	for body in grab_range.get_overlapping_bodies():
		if can_grab:
			cannon_body.mesh.material.albedo_color = grab_color
		if body.hm.holder == null:
			grab_object(body)
		
	#print(hm.held_object)
	pass


func grab_object(object):
	if hm.held_object == null and can_grab:
		hm.pick_up(object)
		can_grab = false
		throw_timer.start()



func _on_throw_timer_timeout():
	hm.throw((hold_point.global_position - global_position).normalized())
	disabled_timer.start()
	pass # Replace with function body.


func _on_disabled_timer_timeout():
	can_grab = true
	pass # Replace with function body.
