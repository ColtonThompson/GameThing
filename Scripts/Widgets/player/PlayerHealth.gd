extends Label

func update_text():
	text = "Life: " + str(World.player_current_health) + "/" + str(World.player_max_health)

func _process(delta):
	update_text()
