extends PathFollow3D

@export var speed: float

func _process(delta):
	progress += speed*delta
