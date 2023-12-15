extends CharacterBody2D

signal chunk_update_required

const max_speed = 125
const accel = 5000
const friction = 1500

var last_direction = "down"

var input = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Handles the input events 
func get_input():
	input.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	input.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	return input.normalized()
	
func handle_player_movement(delta):
	input = get_input()
	
	# No input
	if input == Vector2.ZERO:
		# If we are moving, we should start slowing down
		if velocity.length() > (friction * delta):
			velocity -= velocity.normalized() * (friction * delta)
		# Not moving so we are stopped
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (input * accel * delta)
		velocity = velocity.limit_length(max_speed)
		
		
	handleAnimations(input)
	move_and_slide()
	
func handleAnimations(input):
	var animation = $AnimatedSprite2D
	
	if input == Vector2.ZERO:
		if last_direction == "down":
			animation.set_flip_h(false)
			animation.play("idle_down")
		elif last_direction == "up":
			animation.set_flip_h(false)
			animation.play("idle_up")
		elif last_direction == "left":
			animation.set_flip_h(true)
			animation.play("idle_right") # Flip for opposite dir
		elif last_direction == "right":
			animation.set_flip_h(false)
			animation.play("idle_right")
	else:
		if input.x > 0: # walking right
			animation.set_flip_h(false)
			animation.play("walk_right")
			last_direction = "right"
		elif input.x < 0: # walking left
			animation.set_flip_h(true)
			animation.play("walk_right") # Flip for opposite dir
			last_direction = "left"
		elif input.y > 0: # walking down
			animation.set_flip_h(false)
			animation.play("walk_down")
			last_direction = "down"
		elif input.y < 0: # walking up
			animation.set_flip_h(false)
			animation.play("walk_up")
			last_direction = "up"	
	
# Updates every frame
func _physics_process(delta):
	World.set_player_tile_position(get_tile_position().x, get_tile_position().y)
	handle_player_movement(delta)
	
# Gets what tile the player is standing on
func get_tile_position():
	var pos_x = position.x / World.tile_width
	var pos_y = position.y / World.tile_height
	return Vector2i(pos_x, pos_y)
