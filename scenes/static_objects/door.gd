extends StaticBody3D

@onready var door = $Door
@onready var door_col = $CollisionShape3D

@export var buttons: Array[InteractableButton]

var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for btn in buttons:
		btn.status_changed.connect(update_status)

func update_status():
	active = true
	for btn in buttons:
		if not btn.active: active = false
	
	if active: open()
	else: close()
		
		
func open():
	door.visible = false
	door_col.disabled = true
	
func close():
	door.visible = true
	door_col.disabled = false
