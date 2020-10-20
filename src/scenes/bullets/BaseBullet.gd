extends KinematicBody2D

onready var bullet_impact = preload("res://src/scenes/bullets/BulletImpact.tscn")

var origin = Vector2(0,0)
var dir = Vector2(0,0)
var max_distance = -1
var KNOCKBACK = 0
var SPEED = 800
var DAMAGE = 50
var owner_bullet
var stray = 0.3

const collisions = ['Wall', 'Balcone']

var is_boss = false

func init(owner,direction,velocity,pos,rota,distance,damage,knockb,size):
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
	if owner_bullet == "Boss":
		get_node("Sprite").visible = false
		get_node("bulletBoss").visible = true
		owner_bullet = "Enemy"
		is_boss = true
		
	scale.x = 0.20
	scale.y = 0.20
	

func _physics_process(_delta):
	move_and_slide(dir * SPEED)
	if (origin - position).length() > max_distance:
		queue_free()
		
	
func _on_Area_body_entered(_body):
	var bodies = get_node("AreaBulletBody").get_overlapping_bodies()
	for body in bodies:
		if body.name in collisions:
			if is_boss:
				queue_free()
			bulletImpact()
			queue_free()
			
	if _body.is_in_group("Enemies") and owner_bullet == "Player":
		_body.onHit(DAMAGE)
		bulletImpact()
		queue_free()
	
	elif _body.is_in_group("Player") and owner_bullet == "Enemy":
		_body.onHit(DAMAGE)
		self.hide()
	

func bulletImpact():
	var particle = bullet_impact.instance()
	particle.global_position = global_position
	get_parent().add_child(particle)
	particle.z_index = 100
