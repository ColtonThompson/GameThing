extends Node2D

@onready var heart_full = load("res://Sprites/player/heart_full_32.png")
@onready var heart_half = load("res://Sprites/player/heart_half_32.png")
@onready var heart_empty = load("res://Sprites/player/heart_empty_32.png")

@export var hearts: Array[Sprite2D] = []

var heart_value = 20
var half_heart_value = heart_value / 2

func setup_hearts():
	var heart_containers = PlayerManager.player_max_health / heart_value
	var full_heart_containers = PlayerManager.player_current_health / heart_value
	var health_remaining_after: float = round((PlayerManager.player_current_health / heart_value) % heart_value)
	var half_heart_containers = 0
	if health_remaining_after > 0:
		half_heart_containers = health_remaining_after / half_heart_value
	var empty_heart_containers = heart_containers - full_heart_containers - half_heart_containers
	if empty_heart_containers < 0:
		empty_heart_containers = 0
	print("Hearts array size = " + str(hearts.size()))
	print("Heart Containers: " + str(heart_containers))
	print("Health remaining after: " + str(health_remaining_after))
	print("Full hearts: " + str(full_heart_containers) + ", Half hearts: " + str(half_heart_containers) + ", Empty hearts: " + str(empty_heart_containers))
	var empty_count = empty_heart_containers
	var full_count = full_heart_containers
	var half_count = half_heart_containers
	var total_hearts = full_count + half_count + empty_count
	var heart_offset_x = 34
	var heart_offset_y = 0
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
		#print("New Heart[" + str(i) + "]: Pos(X:" + str(hearts[i].position.x) + ", Y: " + str(hearts[i].position.y) + ") - Count: " + str(count))
		count += 1
		
func _ready():
	setup_hearts()

func _process(delta):
	pass 

