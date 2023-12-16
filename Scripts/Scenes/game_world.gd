extends Node2D

func _ready():
	pass

func _process(delta):

	if Input.is_action_just_pressed("debug"):
		World.debug_mode = !World.debug_mode
		print("World debug mode set to " + str(World.debug_mode))
