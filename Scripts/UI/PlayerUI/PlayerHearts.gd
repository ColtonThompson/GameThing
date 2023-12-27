extends Node2D

@onready var heart_full = load("res://Sprites/player/heart_full_32.png")
@onready var heart_half = load("res://Sprites/player/heart_half_32.png")
@onready var heart_empty = load("res://Sprites/player/heart_empty_32.png")

@export var hearts: Array[Sprite2D] = []

var heart_value = 20
var half_heart_value = heart_value / 2

# TODO: Break down the various parts of code into their own methods to simplify this process.
func setup_hearts():
	print("Hearts array size = " + str(hearts.size()))
	# The total count of heart containers is equal to the players max health divided by heart_value 
	# We then divide it by two to get the full heart container number
	# Any remaining health is then consider a half heart
	var total_hearts = PlayerManager.player_max_health / heart_value
	var current_half_hearts = PlayerManager.player_current_health / half_heart_value
	var max_half_hearts = PlayerManager.player_max_health / half_heart_value
	
	var full_hearts = current_half_hearts / 2
	var remaining_health_value = PlayerManager.player_current_health - (full_hearts * heart_value)
	var remaining_half_hearts = 0
	if remaining_health_value > 0:
		remaining_half_hearts = remaining_health_value / half_heart_value
	var empty_hearts = total_hearts - full_hearts - remaining_half_hearts
	
	if (World.debug_mode):
		print("Total Heart Containers = " + str(total_hearts))
		print("Current Half Hearts = " + str(current_half_hearts))
		print("Max Half Hearts = " + str(max_half_hearts))
		print("Full Hearts = " + str(full_hearts))
		print("Empty Hearts = " + str(empty_hearts))
	
	# offsets for drawing
	var heart_offset_x = 34
	var heart_offset_y = 0
	
	# The count for each type of heart so we can track how many are left to display
	var full_count = full_hearts
	var half_count = remaining_half_hearts
	var empty_count = empty_hearts
	
	# The total count that we have drawn thus far to handle rows
	var count = 0
	for i in range(hearts.size()):
		if count >= 10:
			heart_offset_y = 34
			count = 0
		if full_count > 0:	
			hearts[i].texture = heart_full
			hearts[i].position = Vector2i(5 + (count * heart_offset_x), 55 + heart_offset_y)
			full_count -= 1
		elif half_count > 0:
			hearts[i].texture = heart_half
			hearts[i].position = Vector2i(5 + (count * heart_offset_x), 55 + heart_offset_y)
			half_count -= 1
		elif empty_count > 0:
			hearts[i].texture = heart_empty
			hearts[i].position = Vector2i(5 + (count * heart_offset_x), 55 + heart_offset_y)
			empty_count -= 1	
		count += 1
		
func reset_hearts():
	for i in range(hearts.size()):
		hearts[i].texture = null
		hearts[i].position = Vector2i(0, 0)
		
# TODO: Create a signal to signify a health update is required then call these methods.	
func update_hearts():
	reset_hearts()
	setup_hearts()
	
func _ready():
	setup_hearts()
	
func _process(delta):
	if Input.is_action_just_pressed("adjust_health"):
		PlayerManager.player_current_health = randi_range(10,150)
		PlayerManager.player_max_health = PlayerManager.player_current_health + randi_range(0, 40)
	
func _on_ui_update_timer_timeout():
	update_hearts()
