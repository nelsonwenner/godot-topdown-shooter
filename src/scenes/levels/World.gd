extends Node2D

onready var ammunition = preload("res://src/objects/items/ammunition/Ammunition.tscn")
onready var life = preload("res://src/objects/items/life/Life.tscn")
onready var enemy = preload("res://src/scenes/enemies/Enemy.tscn")

var rng

var items = { }

func _ready():
	items[1] = ammunition
	items[2] = life
	
	rng = RandomNumberGenerator.new()
	set_camera_limits()
	rng.randomize()
	randomize()
	
	PlayerData.connect("player_winner", self, "_playerdata_player_winner")
	

func set_camera_limits():
	var map_size = get_node("Environment/CameraLimit/TileMap").get_used_rect()
	var cell_size = get_node("Environment/CameraLimit/TileMap").cell_size
	get_node("Characters/player/Camera2D").limit_left = map_size.position.x * cell_size.x
	get_node("Characters/player/Camera2D").limit_top = map_size.position.y * cell_size.y
	get_node("Characters/player/Camera2D").limit_right = map_size.end.x * cell_size.x
	get_node("Characters/player/Camera2D").limit_bottom = map_size.end.y * cell_size.y


func _playerdata_player_winner():
	get_node("TimerWinner").start()


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


func _on_TimerSpawnsEnemies_timeout():
	if PlayerData.winner: return
	
	var random_patrol = rng.randi_range(25, 26)
	var random_enemy = rng.randi_range(1, 2)
	
	var spawns_patrol_point = get_node("Environment/PatrolPAth/Patrol" + str(random_patrol) + "/Path2D/PathFollow2D").position
	
	var exists_enemy_in_point = get_node_or_null("Characters/enemyBoss" + str(random_enemy))
	
	if exists_enemy_in_point: return
	
	var enemy_instance = enemy.instance()
	enemy_instance.set_name("enemyBoss" + str(random_enemy))
	enemy_instance.path_patrol = "PatrolPAth/Patrol" + str(random_patrol) + "/Path2D/PathFollow2D"
	enemy_instance.position = spawns_patrol_point
	
	get_node("Characters").add_child(enemy_instance)


func _on_TimerWinner_timeout():
	get_node("TimerWinner").stop()
	get_tree().change_scene("res://src/objects/screens/winner/Winner.tscn")
