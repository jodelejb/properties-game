extends SubViewport


# Called when the node enters the scene tree for the first time.
func _ready():
	size = DisplayServer.window_get_size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	size = DisplayServer.window_get_size()
