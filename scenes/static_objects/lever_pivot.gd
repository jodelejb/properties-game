extends StaticBody3D

@onready var lever: InteractableButton = $".."

func press():
	lever.press()
