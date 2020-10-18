extends Area2D

onready var weapon = get_tree().get_root().get_node('/root/' + get_tree().current_scene.name + '/Items/Weapon')

func _on_Ammunition_body_entered(_body):
	if not _body.is_in_group('Player'): return
	if weapon.WEAPON_TYPE == "AK47":
		weapon.add_ammunition(36)
	queue_free()
