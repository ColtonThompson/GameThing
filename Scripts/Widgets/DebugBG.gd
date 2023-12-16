extends ColorRect

func _process(delta):
	if World.debug_mode == false:
		visible = false
	else:
		visible = true
