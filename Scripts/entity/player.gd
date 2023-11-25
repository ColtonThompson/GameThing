extends CharacterBody2D

signal chunk_update_required

@export var speed = 200

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed('right'):
		velocity.x += 1
	if Input.is_action_pressed('left'):
		velocity.x -= 1
	if Input.is_action_pressed('down'):
		velocity.y += 1
	if Input.is_action_pressed('up'):
		velocity.y -= 1
	velocity = velocity.normalized() * speed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _physics_process(delta):
	World.set_player_tile_position(get_tile_position().x, get_tile_position().y)
	
	get_input()
	move_and_slide()
	
# Gets what tile the player is standing on
func get_tile_position():
	var pos_x = position.x / World.tile_width
	var pos_y = position.y / World.tile_height
	return Vector2i(pos_x, pos_y)
