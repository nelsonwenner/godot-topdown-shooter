extends KinematicBody2D

var SPEED = 100

func _physics_process(_delta):
	var look_to = get_global_mouse_position() - global_position
	rotation = atan2(look_to.x, look_to.y * -1)
	
	var direction = Vector2(0,0)
	
	if Input.is_action_pressed("player_down"):
		direction.y += SPEED
	elif Input.is_action_pressed("player_up"):
		direction.y -= SPEED
	if Input.is_action_pressed("player_right"):
		direction.x += SPEED
	elif Input.is_action_pressed("player_left"):
		direction.x -= SPEED
		
	move_and_slide(direction)
