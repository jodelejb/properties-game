extends Node

var lol: int = 69
var low_grav: float = 10

enum properties {gravity, red, green, blue}

#layers
var static_objects: int = 1-1
var player: int = 2-1
var enemies: int = 3-1
var int_obj: int = 4-1
var zones: int = 5-1
var red: int = 6-1
var green: int = 7-1
var blue: int = 8-1

func get_collision(col: Array) -> int:
	var collision = 0
	for c in col:
		collision += pow(2,c)
	return collision
