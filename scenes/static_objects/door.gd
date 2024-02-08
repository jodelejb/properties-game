extends StaticBody3D
class_name Door

#@onready var door = $Door
#@onready var door_col = $CollisionShape3D

@export var buttons: Array[InteractableButton]
@export var inverted: bool = false

var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for btn in buttons:
		btn.status_changed.connect(update_status)
	update_status()

func update_status():
	active = true
	for btn in buttons:
		if not btn.active: active = false
	
	if not inverted:
		if active: open()
		else: close()
	else:
		if active: close()
		else: open()
		
		
func open():
	pass
	#door.visible = false
	#door_col.disabled = true
	
func close():
	pass
	#door.visible = true
	#door_col.disabled = false
