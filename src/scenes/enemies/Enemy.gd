extends KinematicBody2D

onready var weapon = preload("res://src/scenes/weapons/weapon.tscn")

export (int) var detect_radius
var vis_color = Color(.867, .91, .247, 0.1)
var laser_color = Color(1.0, .329, .298)

var weapon_instance = null

var can_shoot = true

var hit_pos
var target


func _ready():
	$ShootWeaponTime.wait_time = 0.2
	$Sprite.self_modulate = Color(0.2, 0, 0)
	var shape = CircleShape2D.new()
	shape.radius = detect_radius
	$Visibility/CollisionShape2D.shape = shape
	_init_weapon()
	

func _init_weapon():
	weapon_instance = weapon.instance()
	weapon_instance.position.x = 40
	add_child(weapon_instance)
	weapon_instance._ini(
		self,"AK47",null,1,
		0.8,0.1,500,1,700,
		0,36,10,0.1
	)

func _physics_process(_delta):
	update()
	if target:
		_aim()

func _aim():
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, 
		target.position, [self], collision_mask)
	if result:
		hit_pos = result.position
		if result.collider.name == "player":
			get_node("Sprite").self_modulate.r = 1.0
			rotation = (target.position - position).angle()
			if can_shoot:
				weapon_instance.shoot(target.position)
	
	
func _draw():
	draw_circle(Vector2(0, 0), detect_radius, vis_color)
	if target:
		draw_circle((hit_pos - position).rotated(-rotation), 5, laser_color)
		draw_line(Vector2(), (hit_pos - position).rotated(-rotation), laser_color)


func _on_Visibility_body_entered(_body):
	if target: return
	var bodies = $"Visibility".get_overlapping_bodies()
	for body in bodies:
		if body.name == "player":
			target = body
			
	
func _on_Visibility_body_exited(_body):
	if _body == target:
		get_node("Sprite").self_modulate.r = 0.2
		target = null


func _on_ShootWeaponTime_timeout():
	can_shoot = true
