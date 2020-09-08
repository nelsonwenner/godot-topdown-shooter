extends KinematicBody2D

var origin = Vector2(0,0)
var dir = Vector2(0,0)
var max_distance = -1
var KNOCKBACK = 0
var SPEED = 800
var DMG = 100

const collisions = ['Wall', 'Balcone']

func _ini(direction,velocity,pos,rota,distance,damage,knockb,col,size):
	scale = Vector2(size,size)
	get_node("MeshInstance2D").modulate = col
	DMG = damage
	origin = pos
	position = pos
	rotation = rota
	dir = direction
	SPEED = velocity
	max_distance = distance
	KNOCKBACK = knockb


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
			
			
