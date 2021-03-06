extends Area2D

onready var bullet = preload("res://src/scenes/bullets/BaseBullet.tscn")
onready var bullet_label = get_node("WeaponInfo/Bullets")

export var WEAPON_TYPE = "AK47"
export (Texture) var SPRITE_WEAPON

var BULLET_SPEED = 500
var SHOOT_RAGE = 700
var BULLET_SIZE = 1
var KNOCKBACK = 0
var BULLETS = 1
var DAMAGE = 50

var SHOOT_WEAPON_TIME = 0.3
var RELOAD_WEAPON_TIME = 2

var AMMUNITION = 0
var MAX_SLOT = 36
var SLOT = 0

var picked: bool
var can_pick: bool

var player_hand = null

var PLAYER = null
var ENEMY = null

var can_shoot = true 


func init(
		enemy_instance,
		weapon_type,
		sprite_weapon,
		bullet_quantity,
		bullet_speed,
		bullet_size,
		shoot_range,
		knockback,
		max_slot,
		damage
	):
	
	SPRITE_WEAPON = sprite_weapon
	BULLET_SPEED = bullet_speed
	WEAPON_TYPE = weapon_type
	BULLETS = bullet_quantity
	BULLET_SIZE = bullet_size
	SHOOT_RAGE = shoot_range
	ENEMY = enemy_instance
	KNOCKBACK = knockback
	MAX_SLOT = max_slot
	DAMAGE = damage


func _ready():
	if ENEMY: SLOT = MAX_SLOT
	get_node("ShootWeaponTime").wait_time = SHOOT_WEAPON_TIME
	get_node("ReloadWeaponTime").wait_time = RELOAD_WEAPON_TIME
	get_node("Sprite").texture = SPRITE_WEAPON
	z_index = 2


func _process(_delta):
	if !ENEMY && can_pick:
		if Input.is_action_just_pressed("pickup") && !picked:
			_pick(PLAYER, "PlayerPositionWeapon")
		
		if Input.is_action_pressed("shoot") and can_shoot:
			#print("position mouse => ", get_global_mouse_position())
			#print("position weapon => ", get_global_position())
			
			#var mouse_pos = get_global_mouse_position()
			#var weapon_pos = get_global_position()
			
			shoot(get_global_mouse_position())
			

func _physics_process(_delta):
	if !ENEMY && picked:
		_add_weapon_in_player()


func shoot(pos):
	if SLOT > 0:
		for i in BULLETS:
			var bullet_instance = bullet.instance()
			
			var weapon_position = get_node("WeaponPosition").get_global_position() + Vector2(0, 0).rotated(rotation)
			var weapon_rotation = get_node("WeaponPosition").get_global_rotation()
			
			var target = (pos - weapon_position).normalized()
			
			var owner_bullet = "Enemy" if ENEMY else "Player"
			
			if owner_bullet == "Player":
				rotation = atan2(target.y, target.x)
			
			if (owner_bullet == "Player" and picked) or owner_bullet == "Enemy":
				
				if ENEMY and (ENEMY.name == "Boss"):
					target = target.rotated(rand_range(bullet_instance.stray*-1,bullet_instance.stray))
					owner_bullet = "Boss"
					
				bullet_instance.init(
					owner_bullet,target,rand_range(BULLET_SPEED*0.9, BULLET_SPEED*1.1),
					weapon_position, weapon_rotation, SHOOT_RAGE, 
					DAMAGE, KNOCKBACK,BULLET_SIZE)
				
				get_node("BulletContainer").add_child(bullet_instance)
			
			if PLAYER:
				SLOT -= 1
				_update_canvas_munition()
		
		if PLAYER:
			can_shoot = false
			get_node("ShootWeaponTime").start()
			_animationShoot()
		else:
			ENEMY.can_shoot = false
			ENEMY.get_node('ShootWeaponTime').start()
			_animationShoot()
			

func _pick(picker_current, player_position_hand):
	player_hand = picker_current.get_node(player_position_hand)
	position = picker_current.get_global_position()
	bullet_label.visible = true
	picked = true
	z_index = 3


func _add_weapon_in_player():
		if PLAYER.death: queue_free()
		position = player_hand.get_global_position() + Vector2(0, 0).rotated(rotation)
		rotation = player_hand.get_global_rotation()
		_reload()


func _reload():
	if Input.is_action_just_pressed("reload") and SLOT <= 0 and AMMUNITION > 0:
		var animatedReload = PLAYER.get_node("AnimatedSprite")
		animatedReload.set_animation("reload")
		animatedReload.play("reload")
		get_node("ReloadWeaponTime").start()

		
func _animationShoot():
	get_node("AnimatedShoot").visible = true
	get_node("AnimatedShoot").play('flash')
	yield(get_tree().create_timer(0.3), "timeout")
	get_node("AnimatedShoot").stop()
	get_node("AnimatedShoot").frame = 5
	get_node("AnimatedShoot").visible = false


func _update_canvas_munition():
	bullet_label.text = str(SLOT) + " / " + str(AMMUNITION)

	
func add_ammunition(value):
	AMMUNITION += value
	_update_canvas_munition()


func _on_shoot_weapon_time_timeout():
	can_shoot = true


func _weaponOverlappingBodies():
	var bodies = get_node(".").get_overlapping_bodies()
	for body in bodies:
		if body.name == "player" && !picked:
			return body
	return null


func _on_weapon_body_entered(_body):
	var body = _weaponOverlappingBodies()
	if body:
		PLAYER = body
		can_pick = true


func _on_Weapon_body_exited(_body):
	var body = _weaponOverlappingBodies()
	if body:
		PLAYER = null
		can_pick = false


func _on_reload_weapon_time_timeout():
	SLOT = MAX_SLOT
	AMMUNITION -= MAX_SLOT
	_update_canvas_munition()
	var animatedReload = PLAYER.get_node("AnimatedSprite")
	animatedReload.set_animation("idle")
	animatedReload.stop()
	get_node("ReloadWeaponTime").stop()
