extends Area3D

signal player_reset

func _on_body_entered(body):
	if body in get_tree().get_nodes_in_group("Player"):
		player_reset.emit()
	if "destroy" in body:
		body.destroy()
