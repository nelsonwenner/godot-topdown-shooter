extends Area2D

onready var weapon = get_tree().current_scene.get_node('Items/Weapon')

func _on_Ammunition_body_entered(_body):
	var bodies = get_node(".").get_overlapping_bodies()
	for body in bodies:
		if body.name == "player":
			if weapon.WEAPON_TYPE == "AK47":
				weapon.add_ammunition(36)
			queue_free()
