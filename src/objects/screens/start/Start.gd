extends Control


func _ready():
	yield(get_tree().create_timer(0.5), "timeout")
	get_node("Music").play()


func _on_Timer_timeout():
	var start_game = get_node("StartGame")
	start_game.visible = not start_game.visible 


func _on_StartGame_button_up():
	get_tree().change_scene("res://src/scenes/levels/LevelOne.tscn")
