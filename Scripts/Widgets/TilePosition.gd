extends Label

func _process(delta):
	text = "Tile POS: " + str(World.get_player_tile_position())
