extends Label

func _process(delta):
	if World.debug_mode == false:
		visible = false
	else:
		visible = true
	text = "FPS: " + str(Engine.get_frames_per_second())
