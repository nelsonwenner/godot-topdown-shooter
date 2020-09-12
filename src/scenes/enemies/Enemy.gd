extends KinematicBody2D

onready var map_navigation = get_parent().get_node("../Environment/Navigator/Navigation2D")
onready var weapon = preload("res://src/scenes/weapons/weapon.tscn")
onready var player = get_parent().get_node("player")
onready var blood_one = get_node("BloodOne")
onready var blood_two = get_node("BloodTwo")
onready var blood_death = get_node("BloodDeath")


export (int) var detect_radius
var vis_color = Color(.867, .91, .247, 0.1)
var laser_color = Color(1.0, .329, .298)

var weapon_instance = null

var can_shoot = true

export (int) var speed = 120

var max_hp = 400
var current_hp
var percentage_hp

var player_in_range
var player_in_sight
var player_seen
var destination
var starting_position

var hit_position

var death = false

enum {
	Rest,
	Attack,
	Search,
	Return
}

var state:int = Rest


func _ready():
	starting_position = get_global_position()
	get_node("ShootWeaponTime").wait_time = 0.4
	var shape = CircleShape2D.new()
	shape.radius = detect_radius
	get_node("Visibility/CollisionShape2D").shape = shape
	init_weapon()
	current_hp = max_hp
	

func init_weapon():
	weapon_instance = weapon.instance()
	add_child(weapon_instance)
	weapon_instance._ini(self,"AK47",
		load("res://arts/weapon/gun-01.png"),
		1,500,1,700,0,36,20
	)
	weapon_instance.position.x = 113.265
	weapon_instance.position.y = 40.115
	weapon_instance.scale.x = 1
	weapon_instance.scale.y = 1


func onHit(damage):
	if !death:
		current_hp -= damage
		_animationBlood()
		if current_hp <= 0:
			_onDeath()


func _animationBlood():
	blood_one.visible = true
	blood_two.visible = true
	blood_one.play("blood1")
	blood_two.play("blood2")
	yield(get_tree().create_timer(0.5), "timeout")
	blood_one.visible = false
	blood_two.visible = false
	blood_one.stop()
	blood_two.stop()


func _onDeath():
	get_node("Visibility/CollisionShape2D").set_deferred("desabled", true)
	get_node("Collision").set_deferred("desabled", true)
	get_node("Sprite").visible = false
	weapon_instance.visible = false
	blood_death.visible = true
	blood_death.play("blodedeath")
	yield(get_tree().create_timer(0.6), "timeout")
	blood_death.stop()
	death = true


func _process(_delta):
	if death:
		return
	else:
		match state:
			Rest:
				pass
			Attack:
				if can_shoot:
					weapon_instance.shoot(player.position)
			Search:
				_search(_delta)
			Return:
				yield(get_tree().create_timer(3), "timeout")
				if state == 3:
					_returnToStartingPoint(_delta)


func _physics_process(_delta):
	if !death:
		_sightCheck()
		update()


func _search(delta):
	var path_to_destination = _moveAlongPath(delta, destination)
	
	if path_to_destination.size() == 0:
		player_seen = false
		if get_global_position() == starting_position:
			state = Rest
		else:
			state = Return
	

func _returnToStartingPoint(delta):		
	var path_to_starting_position = _moveAlongPath(delta, starting_position)
		
	if path_to_starting_position.size() == 0:
		state = Rest
		

func _moveAlongPath(delta, destination):
	var path_to_destination = map_navigation.get_simple_path(get_global_position(), destination)
	var starting_point = get_global_position()
	var move_distance = speed * delta
	
	for point in range(path_to_destination.size()):
		var distance_to_next_point = starting_point.distance_to(path_to_destination[0])
		if move_distance <= distance_to_next_point and move_distance >= 0.0:
			position = starting_point.linear_interpolate(path_to_destination[0], move_distance / distance_to_next_point)
			rotation = (player.position - position).angle()
			break
		move_distance -= distance_to_next_point
		starting_point = path_to_destination[0]
		path_to_destination.remove(0)
	return path_to_destination
	
	
func _sightCheck():
	if player_in_range:
		var space_state = get_world_2d().direct_space_state
		var sight_check = space_state.intersect_ray(position, 
			player.position, [self], collision_mask)
		if sight_check:
			hit_position = sight_check.position
			if sight_check.collider.name == "player":
				player_in_sight = true
				player_seen = true
				rotation = (player.position - position).angle()
				destination = map_navigation.get_closest_point(player.position)
				state = Attack
			else:
				player_in_sight = false
				if player_seen:
					state = Search
				else:
					if get_global_position() == starting_position:
						state = Rest
					else:
						state = Return
					

func _draw():
	"""
	draw_circle(Vector2(0, 0), detect_radius, vis_color)
	if player_in_range:
		draw_circle((hit_position - position).rotated(-rotation), 5, laser_color)
		draw_line(Vector2(), (hit_position - position).rotated(-rotation), laser_color)
	"""


func _on_Visibility_body_entered(_body):
	if _body == player:
		player_in_range = true
			
	
func _on_Visibility_body_exited(_body):
	if _body == player:
		player_in_range = false
		if player_seen:
			state = Search


func _on_ShootWeaponTime_timeout():
	can_shoot = true
