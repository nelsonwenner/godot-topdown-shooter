extends "res://scripts/Actor.gd"

onready var health_bar = get_node("Info/HealthBar")
onready var blood_death = get_node("BloodDeath")
onready var blood_one = get_node("BloodOne")
onready var blood_two = get_node("BloodTwo")


var SPEED = 130
var max_hp = 400


func _ready():
	self.current_hp = max_hp


func _process(_delta):
	if self.death: 
		PlayerData.losers += 1
		self.hide()
	
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
	
	if motion == Vector2(0,0):
		get_node("AnimatedSpriteLegs").animation = 'idle'
		get_node("AnimatedSpriteLegs").rotation_degrees = 0
	else:
		get_node("AnimatedSpriteLegs").rotation_degrees = -rotation_degrees + 90
		get_node("AnimatedSpriteLegs").animation = 'run'
		if motion.x > 0:
			if motion.y > 0:
				increaseAngleToLegsAnimation(-45)
			elif motion.y < 0:
				increaseAngleToLegsAnimation(45)
			else:
				increaseAngleToLegsAnimation(-90)
		elif motion.x < 0:
			if motion.y > 0:
				increaseAngleToLegsAnimation(45)
			elif motion.y < 0:
				increaseAngleToLegsAnimation(-45)
			else:
				increaseAngleToLegsAnimation(90)
		elif motion.y <= 0:
			increaseAngleToLegsAnimation(-180)
	
	motion = motion.normalized()
	motion = move_and_slide(motion * SPEED)


func onDeath():
	self.death = true
	.onDeath()


func animationHit(damage):
	health_bar.value = int((float(self.current_hp) / max_hp) * 100)
	blood_one.visible = true
	blood_two.visible = true
	blood_one.play("blood1")
	blood_two.play("blood2")
	yield(get_tree().create_timer(0.5), "timeout")
	blood_one.visible = false
	blood_two.visible = false
	blood_one.stop()
	blood_two.stop()
	blood_one.frame = 0
	blood_two.frame = 0
	.animationHit(damage)
	
	
func updateHp():
	self.current_hp = max_hp
	health_bar.value = 100
	.updateHp()

func increaseAngleToLegsAnimation(angle):
	get_node("AnimatedSpriteLegs").rotation_degrees += angle
