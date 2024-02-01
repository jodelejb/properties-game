extends InteractableButton

@onready var button: StaticBody3D = $Button

const lerp_speed: float = 20
const button_height_inactive: float = 0.15
const button_height_active: float = 0.06

func activated(delta):
	button.position.y = lerp(button.position.y,button_height_active, lerp_speed * delta) 

func deactivated(delta):
	button.position.y = lerp(button.position.y,button_height_inactive, lerp_speed * delta)
