extends Node2D

func _ready():
	get_node("Particles2D").emitting = true
	yield(get_tree().create_timer(1),"timeout")
	queue_free()
