extends CSGBox3D

@export var clouds_to_spawn = 3
@export_file("*.tscn") var cloud_file: String
var cloud
#var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	cloud = load(cloud_file)
	spawn_clouds()
	
func spawn_clouds():
	while clouds_to_spawn >= 0:
		clouds_to_spawn -= 1
		var x: float = randf_range(-size.x / 2, size.x / 2)
		var y: float = randf_range(-size.y / 2, size.y / 2)
		var z: float = randf_range(-size.x / 2, size.x / 2)
		var pos: Vector3 = Vector3(x,y,z)
		var c = cloud.instantiate()
		add_child(c)
		c.position = pos
	pass
