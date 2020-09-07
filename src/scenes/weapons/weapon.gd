extends Area2D

onready var bullet = preload("res://src/scenes/bullets/BaseBullet.tscn")
export var bullet_color:Color

var BULLET_SIZE = 1
var BULLETS = 1
var BULLET_SPEED = 500
var SHOOT_RAGE = 700
var KNOCKBACK = 0
var DAMAGE = 10
var STRAY = 0.1

var SHOOT_WEAPON_TIME = 0.1
var RELOAD_WEAPON_TIME = 2.5

var MAX_SLOT = 36
var SLOT = -1

var WEAPON_TYPE = "UZI"

var can_shoot = true 

var can_pick: bool
var picked = false
var player_hand
var player


func _ini(type,shoot_weapon_time,reload_weapon_time,bullet_quantity,bullet_speed,bullet_size,shoot_range,knockback,max_slot,damage,stray):
	SHOOT_WEAPON_TIME = shoot_weapon_time
	RELOAD_WEAPON_TIME = reload_weapon_time
	BULLETS = bullet_quantity
	BULLET_SPEED = bullet_speed
	BULLET_SIZE = bullet_size
	SHOOT_RAGE = shoot_range
	KNOCKBACK = knockback
	MAX_SLOT = max_slot
	WEAPON_TYPE = type
	DAMAGE = damage
	STRAY = stray

func _ready():
	$ShootWeaponTime.wait_time = SHOOT_WEAPON_TIME
	$ReloadWeaponTime.wait_time = RELOAD_WEAPON_TIME
	SLOT = MAX_SLOT


func _process(_delta):
	if can_pick:
		if Input.is_action_just_pressed("pickup") && !picked:
			_pick(player, "PlayerPositionWeapon")
			
		if Input.is_action_pressed("shoot") and can_shoot:
			_shoot()


func _physics_process(_delta):
	if picked:
		z_index = 2
		scale.x = 0.8
		scale.y = 0.5
		position = player_hand.get_global_position() + Vector2(0, 0).rotated(rotation)
		rotation = player_hand.get_global_rotation()
		_reload()
		

func _on_weapon_body_entered(_body):
	var bodies = $".".get_overlapping_bodies()
	for body in bodies:
		if body.name == "player" && !picked:
			player = body # set player var to the overlapping body
			can_pick = true


func _shoot():
	if SLOT > 0:
		for i in BULLETS:
			var bullet_instance = bullet.instance()
			var weapon_position = $WeaponPosition.get_global_position() + Vector2(0, 0).rotated(rotation)
			var weapon_rotation = $WeaponPosition.get_global_rotation() + deg2rad(90)
			
			var target = (get_global_mouse_position() - weapon_position).normalized()
			
			if STRAY > 0:
				target = target.rotated(rand_range(STRAY*-1,STRAY))
			
			bullet_instance._ini(
				target,rand_range(BULLET_SPEED*0.9, BULLET_SPEED*1.1),
				weapon_position, weapon_rotation,
				SHOOT_RAGE, DAMAGE, KNOCKBACK,
				bullet_color, BULLET_SIZE
			)
			$BulletContainer.add_child(bullet_instance)
			SLOT -= 1
			$CanvasLayer/munition.text = str(SLOT) + "/" + str(MAX_SLOT)
		can_shoot = false
		$ShootWeaponTime.start()
		
		
func _pick(picker_current, player_position_hand):
	player_hand = picker_current.get_node(player_position_hand) # reference player_hand
	position = picker_current.get_global_position()
	picked = true


func _reload():
	if Input.is_action_just_pressed("reload") && SLOT <= 0:
		$ReloadWeaponTime.start()
		print("reload...")
	
	
func _on_shoot_weapon_time_timeout():
	can_shoot = true


func _on_reload_weapon_time_timeout():
	SLOT = MAX_SLOT
	$CanvasLayer/munition.text = str(SLOT) + "/" + str(MAX_SLOT)
	$ReloadWeaponTime.stop()
	can_shoot = false
