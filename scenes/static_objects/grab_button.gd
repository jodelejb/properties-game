extends InteractableButton

@onready var hm = $HoldManager


func _on_detection_body_entered(body):
	hm.pick_up(body)
