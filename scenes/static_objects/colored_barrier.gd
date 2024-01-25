extends StaticBody3D

@onready var mesh: MeshInstance3D = $MeshInstance3D

enum colors {red, green, blue}
@export var active_colors: Array[colors]



# Called when the node enters the scene tree for the first time.
func _ready():
	var col = []
	var albedo_color = "00000077"
	if colors.red in active_colors:
		col.append(Globals.red)
		albedo_color = "FF" + albedo_color.substr(2)
	if colors.green in active_colors:
		col.append(Globals.green)
		albedo_color = albedo_color.substr(0,2) + "FF" + albedo_color.substr(4)
	if colors.blue in active_colors:
		col.append(Globals.blue)
		albedo_color = albedo_color.substr(0,4) + "FF" + albedo_color.substr(6)
	collision_layer = Globals.get_collision(col)
	print(albedo_color)
	mesh.mesh.material.albedo_color = albedo_color
	
	print("col " + str(collision_layer))
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
