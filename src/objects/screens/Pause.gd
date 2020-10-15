extends Control


var paused = false setget set_paused


func _ready():
	var player_loser = PlayerData.connect("player_loser", self, "_playerdata_player_loser")
	

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		self.paused = not self.paused
		get_tree().set_input_as_handled()


func _playerdata_player_loser():
	self.paused = true
	get_node("PauseOverlay/Title").text = "You Loser"


func set_paused(value):
	paused = value
	get_tree().paused = value
	get_node("PauseOverlay").visible = value


func _on_ButtonRetry_button_up():
	get_tree().paused = false
	get_tree().reload_current_scene()
	

func _on_ButtonQuit_button_up():
	get_tree().quit()
