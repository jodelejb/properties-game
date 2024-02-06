extends Door
@onready var door = $Door
@onready var door_col = $CollisionShape3D

func open():
	door.visible = false
	door_col.disabled = true
	
func close():
	door.visible = true
	door_col.disabled = false
