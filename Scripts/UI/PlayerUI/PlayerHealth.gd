extends Label

func update_text():
	text = "Life: " + str(PlayerManager.player_current_health) + "/" + str(PlayerManager.player_max_health)

func _process(delta):
	update_text()
