extends StaticBody3D
class_name InteractableButton

signal status_changed
@onready var detection = $Detection
var active = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if detection.has_overlapping_bodies():
		if not active:
			active = true
			status_changed.emit()
		activated(delta)
	else:
		if active:
			active = false
			status_changed.emit()
		deactivated(delta)

func press():
	pass

func activated(delta):
	pass
	
func deactivated(delta):
	pass
