extends StaticBody3D

@onready var mesh: MeshInstance3D = $MeshInstance3D

enum colors {red, green, blue}
@export var active_colors: Array[colors]



# Called when the node enters the scene tree for the first time.
func _ready():
	var col = []# [Globals.red,Globals.green,Globals.blue,Globals.cyan,Globals.magenta,Globals.yellow,Globals.white]
	var albedo_color = "00000077"
	if colors.red in active_colors:
		#col.append(Globals.red)
		albedo_color = "FF" + albedo_color.substr(2)
	if colors.green in active_colors:
		#col.append(Globals.green)
		albedo_color = albedo_color.substr(0,2) + "FF" + albedo_color.substr(4)
	if colors.blue in active_colors:
		#col.append(Globals.blue)
		albedo_color = albedo_color.substr(0,4) + "FF" + albedo_color.substr(6)
		
	#get the proper color collision
	if colors.red in active_colors:
		if colors.blue in active_colors:
			if colors.green in active_colors:
				col.append(Globals.white)
			else:
				col.append(Globals.purple)
		elif colors.green in active_colors:
			col.append(Globals.yellow)
		else:
			col.append(Globals.red)
	elif colors.green in active_colors:
		if colors.blue in active_colors:
			col.append(Globals.cyan)
		else:
			col.append(Globals.green)
	elif colors.blue in active_colors:
		col.append(Globals.blue)
		
	collision_layer = Globals.get_collision(col)
	#print(albedo_color)
	mesh.mesh.material.albedo_color = albedo_color
	
	#print("col " + str(collision_layer))
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
