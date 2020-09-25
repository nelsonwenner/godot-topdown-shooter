extends "res://scripts/Actor.gd"

var SPEED = 130
var max_hp = 400


func _ready():
	self.current_hp = max_hp


func _process(_delta):
	if self.death:
		print("Player death!!")
		return
	look_at(get_global_mouse_position())


func _physics_process(_delta):
	var motion = Vector2(0,0)
	
	if Input.is_action_pressed("player_up"):
		motion.y -= SPEED
	elif Input.is_action_pressed("player_down"):
		motion.y += SPEED
	if Input.is_action_pressed("player_right"):
		motion.x += SPEED
	elif Input.is_action_pressed("player_left"):
		motion.x -= SPEED
			
	motion = motion.normalized()
	motion = move_and_slide(motion * SPEED)


func onDeath():
	self.death = true
	.onDeath()
