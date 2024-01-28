extends InteractableButton

@onready var detection: Area3D = $Detection
@onready var button: StaticBody3D = $Button


const lerp_speed: float = 20
const button_height_inactive: float = 0.15
const button_height_active: float = 0.06

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if detection.has_overlapping_bodies():
		if not active:
			active = true
			status_changed.emit()
		button.position.y = lerp(button.position.y,button_height_active, lerp_speed * delta) 
	else:
		if active:
			active = false
			status_changed.emit()
		button.position.y = lerp(button.position.y,button_height_inactive, lerp_speed * delta) 
