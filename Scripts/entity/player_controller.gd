extends CharacterBody2D

var speed = 400 # pixels/sec

func _physics_process(delta):
	var dir = Input.get_vector("left", "right", "up", "down")
	velocity = dir * speed
	
	move_and_slide()
