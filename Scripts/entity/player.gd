extends CharacterBody2D

signal chunk_update_required

const max_speed = 400
const accel = 5000
const friction = 1500

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
		
	move_and_slide()

# Updates every frame
func _physics_process(delta):
	World.set_player_tile_position(get_tile_position().x, get_tile_position().y)
	handle_player_movement(delta)
	
# Gets what tile the player is standing on
func get_tile_position():
	var pos_x = position.x / World.tile_width
	var pos_y = position.y / World.tile_height
	return Vector2i(pos_x, pos_y)
