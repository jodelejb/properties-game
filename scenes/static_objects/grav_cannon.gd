extends StaticBody3D

@onready var hm = $HoldManager
@onready var grab_range: Area3D = $GrabRange
@onready var throw_timer: Timer = $ThrowTimer
@onready var hold_point = $HoldPoint

@export var throw_speed: float = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	grab_range.body_entered.connect(grab_object)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#print(hm.held_object)
	pass


func grab_object(object):
	if hm.held_object == null:
		hm.pick_up(object)
		throw_timer.start()



func _on_throw_timer_timeout():
	hm.throw((hold_point.global_position - global_position).normalized())
	pass # Replace with function body.
