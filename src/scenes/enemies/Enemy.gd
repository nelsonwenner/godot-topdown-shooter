extends "res://scripts/Actor.gd"

export (int) var detect_radius
export(String) var path_patrol
export (int) var speed = 120

onready var map_navigation = get_parent().get_node("../Environment/Path/Navigation2D")
onready var path_follow = get_parent().get_node("../Environment/" + path_patrol)
onready var weapon = preload("res://src/scenes/weapons/weapon.tscn")
onready var positionWeapon = get_node("EnemyPositionWeapon")
onready var player = get_parent().get_node("player")
onready var blood_one = get_node("BloodOne")
onready var blood_two = get_node("BloodTwo")
onready var blood_death = get_node("BloodDeath")

var weapon_instance = null

var can_shoot = true

var player_in_range
var player_in_sight
var player_seen
var destination
var starting_position

var hit_position

enum {
	Rest,
	Patrol,
	Attack,
	Search,
	Return
}

var state:int = Patrol

var max_hp = 400
var path_to_destination

func _ready():
	self.current_hp = max_hp
	starting_position = get_global_position()
	get_node("ShootWeaponTime").wait_time = 0.4
	var shape = CircleShape2D.new()
	shape.radius = detect_radius
	get_node("Visibility/CollisionShape2D").shape = shape
	init_weapon()


func init_weapon():
	weapon_instance = weapon.instance()
	weapon_instance.init(self,"AK47",
		load("res://arts/weapon/gun-01.png"),
		1,500,1,700,0,36,20
	)
	add_child(weapon_instance)
	weapon_instance.position = positionWeapon.position
	weapon_instance.scale.x = 1
	weapon_instance.scale.y = 1


func _process(_delta):
	if self.death:
		return
	else:
		match state:
			Rest:
				get_node("AnimatedSpriteLegs").animation = 'idle'
				get_node("AnimatedSpriteLegs").rotation_degrees = 0
			Patrol:
				if path_patrol:
					get_node("AnimatedSpriteLegs").animation = 'run'
					get_node("AnimatedSpriteLegs").rotation_degrees = 0
					speed = 70
					var position_before = position
					path_follow.set_offset(path_follow.get_offset() + speed * _delta)
					position = path_follow.get_global_position()
					var relative_path = position - position_before
					var relative_path_angle = rad2deg(relative_path.angle_to_point(Vector2(0,0)))
					rotation_degrees = relative_path_angle
			Attack:
				get_node("AnimatedSpriteLegs").animation = 'idle'
				get_node("AnimatedSpriteLegs").rotation_degrees = 0
				if can_shoot:
					speed = 120
					weapon_instance.shoot(player.position)
			Search:
				get_node("AnimatedSpriteLegs").animation = 'run'
				speed = 120
				_search(_delta)
			Return:
				if path_to_destination:
					get_node("AnimatedSpriteLegs").animation = 'run'
				else:
					get_node("AnimatedSpriteLegs").animation = 'idle'
					get_node("AnimatedSpriteLegs").rotation_degrees = 0
				yield(get_tree().create_timer(3), "timeout")
				if state == 4:
					speed = 120
					_returnToStartingPoint(_delta)


func _physics_process(_delta):
	if !self.death:
		_sightCheck()
		update()
	var relative_path
	var relative_path_angle
	
	if path_to_destination:
		relative_path = path_to_destination[0] - position
		relative_path_angle = rad2deg(relative_path.angle_to_point(Vector2(0,0)))
		get_node("AnimatedSpriteLegs").rotation_degrees = relative_path_angle - rotation_degrees


func _search(delta):
	path_to_destination = _moveAlongPath(delta, destination)
	
	if path_to_destination.size() == 0:
		player_seen = false
		if get_global_position() == starting_position:
			state = Patrol
		else:
			state = Return


func _returnToStartingPoint(delta):
	path_to_destination = _moveAlongPath(delta, starting_position)
		
	if path_to_destination.size() == 0:
		#clean path_follow
		path_follow.set_offset(0)
		state = Patrol


func _moveAlongPath(delta, destination):
	var output = map_navigation.get_simple_path(get_global_position(), destination)
	var starting_point = get_global_position()
	var move_distance = speed * delta
	
	for point in range(output.size()):
		var distance_to_next_point = starting_point.distance_to(output[0])
		if move_distance <= distance_to_next_point and move_distance >= 0.0:
			position = starting_point.linear_interpolate(output[0], move_distance / distance_to_next_point)
			rotation = (player.position - position).angle()
			break
		move_distance -= distance_to_next_point
		starting_point = output[0]
		output.remove(0)
	return output


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
					if get_global_position() == starting_position or state == Patrol:
						state = Patrol
					else:
						state = Return


func animationHit(damage):
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


func onDeath():
	get_node("Visibility/CollisionShape2D").set_deferred("desabled", true)
	get_node("Collision").set_deferred("desabled", true)
	get_node(".").collision_mask = false
	get_node("Sprite").visible = false
	get_node("AnimatedSpriteLegs").visible = false
	weapon_instance.visible = false
	blood_death.visible = true
	blood_death.play("blodedeath")
	yield(get_tree().create_timer(0.6), "timeout")
	blood_death.stop()
	get_node("DeadEnemyTime").start()
	self.death = true
	.onDeath()


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


func _on_DeadEnemyTime_timeout():
	if self.death:
		queue_free()
