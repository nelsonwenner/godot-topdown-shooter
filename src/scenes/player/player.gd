extends KinematicBody2D

var SPEED = 130

func _ready():
	scale.x = 0.6
	scale.y = 0.6


func _process(_delta):
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
