extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass	

func _on_cancel_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# Sets the world map name to whatever the player typed into the map name field
func _on_world_name_field_text_changed(new_text):
	World.map_name = new_text
	print("Map name set to " + new_text)
	
# Sets the world seed to whatever the player typed into the map seed field
func _on_world_seed_field_text_changed(new_text):
	World.map_seed = new_text
	print("Seed set to " + new_text)

func _on_select_pressed():
	get_tree().change_scene_to_file("res://Scenes/game_world.tscn")
