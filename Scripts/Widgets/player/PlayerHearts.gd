extends Node2D

@onready var heart_full = load("res://Sprites/player/heart_full_32.png")
@onready var heart_half = load("res://Sprites/player/heart_half_32.png")
@onready var heart_empty = load("res://Sprites/player/heart_empty_32.png")

@export var hearts: Array[Sprite2D] = []

var heart_value = 50
var heart_offset = 34

func setup_hearts():
	var remainder = World.player_current_health % heart_value
	var total_empty_hearts = (World.player_max_health - World.player_current_health) / heart_value
	var total_full_hearts = World.player_max_health / heart_value
	var total_half_hearts = remainder / (heart_value / 2)
	print("Hearts array size = " + str(hearts.size()))
	print("Empty hearts: " + str(total_empty_hearts) + ", Full hearts: " + str(total_full_hearts) + ", Half hearts: " + str(total_half_hearts))
	var empty_count = total_empty_hearts
	var full_count = total_full_hearts
	var half_count = total_half_hearts
	var total_hearts = full_count + half_count + empty_count
	for i in range(hearts.size()):
		if full_count > 0:	
			hearts[i].texture = heart_full
			hearts[i].position = Vector2i(10 + (i * heart_offset), 55)
			full_count -= 1
		elif half_count > 0:
			hearts[i].texture = heart_half
			hearts[i].position = Vector2i(10 + (i * heart_offset), 55)
			half_count -= 1
		elif empty_count > 0:
			hearts[i].texture = heart_empty
			hearts[i].position = Vector2i(10 + (i * heart_offset), 55)
			empty_count -= 1	
		print("New Heart[" + str(i) + "]: Pos(X:" + str(hearts[i].position.x) + ", Y: " + str(hearts[i].position.y) + ")")
		
func _ready():
	setup_hearts()

func _process(delta):
	pass 

