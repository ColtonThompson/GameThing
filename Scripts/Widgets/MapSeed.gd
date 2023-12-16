extends Label

func _process(delta):
	if World.debug_mode == false:
		visible = false
	else:
		visible = true
	text = "Map Seed: " + str(World.map_seed)
