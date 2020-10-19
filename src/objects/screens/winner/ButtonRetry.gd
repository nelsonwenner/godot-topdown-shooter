extends Button


func _on_ButtonRetry_button_up():
	PlayerData.reset()
	get_tree().change_scene("res://src/scenes/levels/World.tscn")
	
