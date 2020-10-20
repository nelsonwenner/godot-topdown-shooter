extends Area2D


func _on_Detection_body_exited(_body):
	if not _body.is_in_group("Player"): return
	
	if -4549.213 > _body.position.y:
		get_node("../PortRoom").position.x = -960.566
