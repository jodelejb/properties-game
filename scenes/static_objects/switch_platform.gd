extends PathFollow3D

@export var buttons: Array[InteractableButton]
@export var speed: float = 3

var active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for btn in buttons:
		btn.status_changed.connect(update_status)
	update_status()
	
func update_status():
	active = true
	for btn in buttons:
		if not btn.active: active = false
		
func _process(delta):
	if active:
		progress_ratio = lerp(progress_ratio,1.0,speed*delta)
		#progress_ratio = 1
		#print(progress_ratio)
	else:
		progress_ratio = lerp(progress_ratio,0.0,speed*delta)
		#progress_ratio = 0
