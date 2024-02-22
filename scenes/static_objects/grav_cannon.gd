extends StaticBody3D

@onready var hm = $HoldManager
@onready var grab_range: Area3D = $GrabRange
@onready var throw_timer: Timer = $ThrowTimer
@onready var disabled_timer = $DisabledTimer
@onready var hold_point = $HoldPoint
@onready var cannon_body = $MeshInstance3D2
@onready var cyl_collision = $CylCollision

@export var throw_speed: float = 20

@export var buttons: Array[InteractableButton]

var active: bool = true
var can_grab: bool = true

var inactive_color: Color = Color(0,0,0)
var inactive_grab_color: Color = Color(.3,.3,0)
var normal_color: Color = Color(1,1,1)
var grab_color: Color = Color(1,1,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	hm.held_changed.connect(released)
	if len(buttons) == 0:
		active = true
	else:
		for btn in buttons:
			btn.status_changed.connect(update_status)
		update_status()
	#grab_range.body_entered.connect(grab_object)
	pass # Replace with function body.

func update_status():
	active = true
	for btn in buttons:
		if not btn.active: active = false
		cannon_body.mesh.material.albedo_color = inactive_color
	if active == true and hm.held_object != null:
		throw_timer.start()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if active:
		cannon_body.mesh.material.albedo_color = normal_color
	else:
		cannon_body.mesh.material.albedo_color = inactive_color
	for body in grab_range.get_overlapping_bodies():
		if active:
			cannon_body.mesh.material.albedo_color = grab_color
		else:
			cannon_body.mesh.material.albedo_color = inactive_grab_color
		#if can_grab:
			
		if body.hm.holder == null:
			if body == get_tree().get_first_node_in_group("Player") and not active: return
			grab_object(body)
		
	#print(hm.held_object)
	pass


func grab_object(object):
	if hm.held_object == null and can_grab:
		throw_timer.wait_time = 1.0
		if object == get_tree().get_first_node_in_group("Player"): 
			if not Input.is_action_just_pressed("activate"): return
			throw_timer.wait_time = 0.5
			#object.linear_velocity.y += 0.2
		
		cyl_collision.disabled = true
		hm.pick_up(object)
		can_grab = false
		if active:
			throw_timer.start()



func _on_throw_timer_timeout():
	cyl_collision.disabled = false
	hm.throw((hold_point.global_position - global_position).normalized())
	disabled_timer.start()
	pass # Replace with function body.


func _on_disabled_timer_timeout():
	can_grab = true
	pass # Replace with function body.
	
func released():
	if hm.held_object == null:
		disabled_timer.start()


func _on_grab_range_body_entered(body):
	if body == get_tree().get_first_node_in_group("Player") and active:
		Globals.ui.note.text = "Q to enter grav lift"


func _on_grab_range_body_exited(body):
	if body == get_tree().get_first_node_in_group("Player"):
		Globals.ui.note.text = ""
