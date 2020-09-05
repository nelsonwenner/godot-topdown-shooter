extends KinematicBody2D

var max_distance = -1
var origin = Vector2(0,0)
var dir = Vector2(0,0)
var SPEED = 800
var DMG = 100
var KNOCKBACK = 0

func _ini(direction,velocity,pos,distance,damage,knockb,col,size):
	scale = Vector2(size,size)
	$MeshInstance2D.modulate = col
	DMG = damage
	origin = pos
	position = pos
	dir = direction
	SPEED = velocity
	max_distance = distance
	KNOCKBACK = knockb

func _physics_process(delta):
	move_and_slide(dir * SPEED)
	if (origin - position).length() > max_distance:
		queue_free()
