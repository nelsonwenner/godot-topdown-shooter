extends Area2D

var can_pick: bool
var picked = false
var player_hand
var player

func _process(_delta):
	if can_pick:
		if Input.is_action_just_pressed("pickup") && !picked:
			pick(player, "player_position_weapon")

func _physics_process(_delta):
	if picked:
		z_index = 2
		scale.x = 0.8
		scale.y = 0.5
		position = player_hand.get_global_position() + Vector2(0, 0).rotated(rotation)
		rotation = player_hand.get_global_rotation()
		
		
func _on_weapon_body_entered(_body):
	var bodies = $".".get_overlapping_bodies()
	for body in bodies:
		if body.name == "player" && !picked:
			player = body # set player var to the overlapping body
			can_pick = true


func pick(picker_current, player_position_hand):
	player_hand = picker_current.get_node(player_position_hand) # reference player_hand
	position = picker_current.get_global_position()
	picked = true
