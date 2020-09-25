extends KinematicBody2D

class_name Actor

var current_hp
var percentage_hp

var death = false


func onHit(damage):
	if !death:
		current_hp -= damage
		animationHit()
		if current_hp <= 0:
			onDeath()
			
			
func animationHit():
	"""
	Overrider method
	"""
	
func onDeath():
	"""
	Overrider method
	"""
