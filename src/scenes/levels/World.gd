extends Node2D

onready var ammunition = preload("res://src/objects/items/ammunition/Ammunition.tscn")
onready var life = preload("res://src/objects/items/life/Life.tscn")

var rng

var items = { }

func _ready():
	items[1] = ammunition
	items[2] = life
	
	rng = RandomNumberGenerator.new()
	set_camera_limits()
	rng.randomize()
	randomize()


func set_camera_limits():
	var map_size = get_node("Environment/CameraLimit/TileMap").get_used_rect()
	var cell_size = get_node("Environment/CameraLimit/TileMap").cell_size
	get_node("Characters/player/Camera2D").limit_left = map_size.position.x * cell_size.x
	get_node("Characters/player/Camera2D").limit_top = map_size.position.y * cell_size.y
	get_node("Characters/player/Camera2D").limit_right = map_size.end.x * cell_size.x
	get_node("Characters/player/Camera2D").limit_bottom = map_size.end.y * cell_size.y


func _on_TimerSpawnsPoints_timeout():
	var random_spawn_point = rng.randi_range(0, 7)
	var random_item = rng.randi_range(1, 2)
	
	var spawns_position = get_node("Environment/Spawnpoints/" + str(random_spawn_point)).position
	
	var exists_item_in_point = get_node_or_null("Items/" + str(random_spawn_point))
	
	if exists_item_in_point:
		exists_item_in_point.queue_free()
		return
	
	var item = items[random_item].instance()
	item.set_name(str(random_spawn_point))
	
	item.position = spawns_position
	
	get_node("Items").add_child(item)
