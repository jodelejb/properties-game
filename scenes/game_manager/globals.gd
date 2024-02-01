extends Node

var lol: int = 69
var low_grav: float = 15

enum properties {gravity, red, green, blue, bridge}
enum pm_types {base, source, sink}

#layers
var static_objects: int = 1-1
var player: int = 2-1
var enemies: int = 3-1
var int_obj: int = 4-1
var zones: int = 5-1
var bridge: int = 6-1

var red: int = 7-1
var green: int = 8-1
var blue: int = 9-1
var cyan: int = 10-1
var magenta: int = 11-1
var yellow: int = 12-1
var white: int = 13-1

func get_collision(col: Array) -> int:
	var collision = 0
	for c in col:
		collision += pow(2,c)
	return collision
