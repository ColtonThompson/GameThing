extends Label

func _process(delta):
	if World.debug_mode == false:
		visible = false
	else:
		visible = true
	text = "Tile POS: " + str(World.get_player_tile_position())
