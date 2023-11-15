extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_generate_pressed():
	# Set the "play" button to disabled until the map is finished generating
	$Select.set_disabled(true)
	# Set the "generate world" button to disabled until its finished generating
	$Generate.set_disabled(true)
	# Generate the world map first
	await World.generate_world_map()
	# Once the map is generated we can update the preview tilemap
	await update_map_preview()
	# Re-enable the "play" button now the map is generated
	$Select.set_disabled(false)
	# Re-enable the "generate world" button now that the map is generated
	$Generate.set_disabled(false)
	
func _on_select_spawnpoint_pressed():
	World.choose_world_spawn_point()
	# Get atlas_coords and figure out what the tile is and feed the atlas back into map generation

func _on_cancel_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# Sets the world map name to whatever the player typed into the map name field
func _on_world_name_field_text_changed(new_text):
	World.world_map_name = new_text
	get_node("%MapName").set_text(new_text)
	print("World map name set to " + new_text)
	
# Sets the world seed to whatever the player typed into the map seed field
func _on_world_seed_field_text_changed(new_text):
	World.world_map_seed = new_text
	print("World seed set to " + new_text)

# Sets the world size string to what the player selected into the size dropdown
func _on_world_size_option_item_selected(index):
	match index:
		0:
			World.world_map_size = "small"
			print("World map size set to " + World.world_map_size)
		1:
			World.world_map_size = "medium"
			print("World map size set to " + World.world_map_size)
		2:
			World.world_map_size = "large"
			print("World map size set to " + World.world_map_size)
		_:
			print("Error: World map size not supported - selection out of range")

# Updates the tilemap to show the player a preview of their world before they start playing		
func update_map_preview():
	var layer_count = World.world_tilemap.get_layers_count()
	for x in range(World.world_map_width):
		for y in range(World.world_map_height):
			for l in range(layer_count):
				var tile = World.world_tilemap.get_cell_atlas_coords(l, Vector2i(x,y))
				$HBoxContainer/Control/TileMap.set_cell(l, Vector2i(x,y), 1, tile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

