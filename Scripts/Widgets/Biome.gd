extends Label

func _process(delta):
	text = "Biome: " + str(World.get_player_standing_biome())
