extends Area3D

signal player_reset(props: Array[Globals.properties], keep_stored: bool)

func _on_body_entered(body):
	if body in get_tree().get_nodes_in_group("Player"):
		#print(body.pm.applied_properties[0])
		player_reset.emit(body.pm.applied_properties.duplicate(), true)
	if "destroy" in body:
		body.destroy()
