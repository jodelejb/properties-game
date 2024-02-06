extends Node

@export var bodies: Array[PhysicsBody3D]
@export var meshes: Array[MeshInstance3D]
@onready var parent = $".."


@export var active_colors: Array[Globals.colors]



# Called when the node enters the scene tree for the first time.
func _ready():
	print(bodies)
	if "active_colors" in parent:
		active_colors = parent.active_colors
	var col = []# [Globals.red,Globals.green,Globals.blue,Globals.cyan,Globals.magenta,Globals.yellow,Globals.white]
	var albedo_color = "00000077"
	if Globals.colors.red in active_colors:
		#col.append(Globals.red)
		albedo_color = "FF" + albedo_color.substr(2)
	if Globals.colors.green in active_colors:
		#col.append(Globals.green)
		albedo_color = albedo_color.substr(0,2) + "FF" + albedo_color.substr(4)
	if Globals.colors.blue in active_colors:
		#col.append(Globals.blue)
		albedo_color = albedo_color.substr(0,4) + "FF" + albedo_color.substr(6)
		
	#get the proper color collision
	if Globals.colors.red in active_colors:
		if Globals.colors.blue in active_colors:
			if Globals.colors.green in active_colors:
				col.append(Globals.white)
			else:
				col.append(Globals.purple)
		elif Globals.colors.green in active_colors:
			col.append(Globals.yellow)
		else:
			col.append(Globals.red)
	elif Globals.colors.green in active_colors:
		if Globals.colors.blue in active_colors:
			col.append(Globals.cyan)
		else:
			col.append(Globals.green)
	elif Globals.colors.blue in active_colors:
		col.append(Globals.blue)
		
	for b in bodies:
		b.collision_layer = Globals.get_collision(col)
	#print(albedo_color)
	for m in meshes:
		m.mesh.material.albedo_color = albedo_color
