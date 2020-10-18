extends Area2D


func _on_Life_body_entered(_body):
	if not _body.is_in_group('Player'): return
	_body.updateHp()
	queue_free()
