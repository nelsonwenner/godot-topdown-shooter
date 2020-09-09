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

var WEAPON_TYPE = "AK47"

func _ini(
		weapon_type,
		shoot_weapon_time,
		reload_weapon_time,
		bullet_quantity,
		bullet_speed,
		bullet_size,
		shoot_range,
		knockback,
		max_slot,
		damage,
		stray
	):
	
	SHOOT_WEAPON_TIME = shoot_weapon_time
	RELOAD_WEAPON_TIME = reload_weapon_time
	BULLET_SPEED = bullet_speed
	WEAPON_TYPE = weapon_type
	BULLETS = bullet_quantity
	BULLET_SIZE = bullet_size
	SHOOT_RAGE = shoot_range
	KNOCKBACK = knockback
	MAX_SLOT = max_slot
	DAMAGE = damage
	STRAY = stray
