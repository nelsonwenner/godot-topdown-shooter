extends KinematicBody2D

var origin = Vector2(0,0)
var dir = Vector2(0,0)
var max_distance = -1
var KNOCKBACK = 0
var SPEED = 800
var DAMAGE = 50
var owner_bullet

const collisions = ['Wall', 'Balcone']

func _ini(owner,direction,velocity,pos,rota,distance,damage,knockb,size):
	scale = Vector2(size,size)
	DAMAGE = damage
	origin = pos
	position = pos
	rotation = rota
	dir = direction
	SPEED = velocity
	max_distance = distance
	owner_bullet = owner
	KNOCKBACK = knockb


func _ready():
	scale.x = 0.25
	scale.y = 0.25
	

func _physics_process(_delta):
	move_and_slide(dir * SPEED)
	if (origin - position).length() > max_distance:
		print("Bullet Destroyed in: Distance")
		queue_free()
		
	
func _on_Area_body_entered(_body):
	var bodies = get_node("AreaBulletBody").get_overlapping_bodies()
	for body in bodies:
		if body.name in collisions:
			print("Bullet Destroyed in: ", body.name)
			queue_free()
			
	if _body.is_in_group("Enemies") and owner_bullet == "Player":
		_body.onHit(DAMAGE)
		self.hide()
		print("Hit! => ", owner_bullet)
