extends "res://scripts/Actor.gd"

export (int) var detect_radius

onready var weapon = preload("res://src/scenes/weapons/weapon.tscn")
onready var positionWeapon = get_node("BossPositionWeapon")
onready var player = get_parent().get_node("player")

enum {
	Rest,
	Attack,
}

var weapon_instance = null
var player_in_range
var max_hp = 1000

var hit_position

var can_shoot = true

var state:int = Rest

func _ready():
	self.current_hp = max_hp
	get_node("ShootWeaponTime").wait_time = 0.3
	var shape = CircleShape2D.new()
	shape.radius = detect_radius
	get_node("Detection/CollisionShape2D").shape = shape
	init_weapon()


func init_weapon():
	weapon_instance = weapon.instance()
	weapon_instance.init(self,"AK47",
		load("res://arts/weapon/gun-01.png"),
		10,500,0,500,1,36,10
	)
	add_child(weapon_instance)
	weapon_instance.position = positionWeapon.position
	weapon_instance.visible = false
	weapon_instance.scale.x = 0.9
	weapon_instance.scale.y = 0.9


func _process(_delta):
	if self.death: return
	else:
		match state:
			Rest:
				pass
			Attack:
				if can_shoot:
					weapon_instance.shoot(player.position)


func _physics_process(_delta):
	if !self.death:
		_sightCheck()

	
func _sightCheck():
	if player_in_range:
		var space_state = get_world_2d().direct_space_state
		var sight_check = space_state.intersect_ray(position, 
			player.position, [self], collision_mask)
		if sight_check:
			hit_position = sight_check.position
			if sight_check.collider.name == "player":
				rotation = (player.position - position).angle()
				state = Attack
			else:
				state = Rest


func onDeath():
	get_node("Detection/CollisionShape2D").set_deferred("desabled", true)
	get_node("Explode").play("explode")
	yield(get_tree().create_timer(1), "timeout")
	self.death = true
	self.modulate = '432222'
	PlayerData.set_winner(1)
	.onDeath()
	

func _on_Detection_body_entered(_body):
	if _body == player:
		player_in_range = true


func _on_Detection_body_exited(_body):
	if _body == player:
		player_in_range = false


func _on_ShootWeaponTime_timeout():
	can_shoot = true
