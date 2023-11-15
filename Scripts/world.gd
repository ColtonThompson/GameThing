extends Node

##
# Global world script to handle all map related variables needed to pass between
# scenes.
##

var world_map_name = "DefaultWorld"
var world_map_seed = ""
var world_map_size = "small"
var world_map_width = 64
var world_map_height = 64
var world_spawn_point = Vector2(0,0)
var viable_spawn_points = []

var world_tilemap = TileMap.new() as TileMap
var world_tileset = load("res://Tilesets/world_tileset.tres")

func choose_world_spawn_point():
	if viable_spawn_points.size() == 0:
		print("Error: No viable spawn points available!")
		return
	var ran_choice_index = randi_range(0, viable_spawn_points.size() - 1)
	var random_point = viable_spawn_points[ran_choice_index] as Vector2
	set_world_spawn_point(random_point.x, random_point.y)

# Sets the spawn point for the overworld
func set_world_spawn_point(pos_x, pos_y):
	world_spawn_point = Vector2(pos_x, pos_y)
	print("World spawn point set to [X=" + str(pos_x) + ", Y=" + str(pos_y) + "]")
	
func get_world_spawn_point():
	return world_spawn_point

# Sets the width/height dimensions of a tilemap in tiles
func set_world_map_dimensions():
	if world_map_size == "small":
		world_map_width = 64
		world_map_height = 64
	elif world_map_size == "medium":
		world_map_width = 128
		world_map_height = 128
	elif world_map_size == "large":
		world_map_width = 256
		world_map_height = 256
		
# Clear all the used layers for our world map	
func clear_world_map_layers():
	if world_tilemap: 
		world_tilemap.clear_layer(0)
		world_tilemap.clear_layer(1)
		world_tilemap.clear_layer(2)

# Generates the world map (or overworld) 
func generate_world_map():
	var time_before = Time.get_ticks_msec()
	clear_world_map_layers()
		
	world_tilemap.tile_set = world_tileset
	
	# Create the noise variables
	var altitude = FastNoiseLite.new()
	var temperature = FastNoiseLite.new()
	var moisture = FastNoiseLite.new()
	
	altitude.frequency = 0.01
	temperature.frequency = 0.01
	moisture.frequency = 0.01
	
	# Set the seed values for each noise variable
	if world_map_seed.length() > 0:
		altitude.seed = world_map_seed.hash()
		temperature.seed = world_map_seed.hash()
		moisture.seed = world_map_seed.hash()
	else:
		altitude.seed = randi()
		temperature.seed = randi()
		moisture.seed = randi()
	
	# Set the dimensions again just incase the player changed the size
	set_world_map_dimensions()
	
	# Does this fix layer 1?
	world_tilemap.add_layer(1)
	world_tilemap.set_layer_name(0, "ground")
	world_tilemap.set_layer_name(1, "node")
	world_tilemap.set_layer_enabled(1, true)
	
	# Set the cell data based on noise values
	for x in range(world_map_width):
		for y in range(world_map_height):
			var alt = altitude.get_noise_2d(x,y)
			var temp = temperature.get_noise_2d(x,y)
			var moist = moisture.get_noise_2d(x,y)
			
			if alt < 0.15: # Deep ocean
				world_tilemap.set_cell(0, Vector2i(x, y), 1, Vector2i(2,2))
			elif alt >= 0.15 && alt < 0.2: # Shallow Water tiles
				world_tilemap.set_cell(0, Vector2i(x, y), 1, Vector2i(2,0))
			elif alt >= 0.2 && alt < 0.25: # Sand/deserts
				viable_spawn_points.append(Vector2(x,y))
				world_tilemap.set_cell(0, Vector2i(x, y), 1, Vector2i(0,0))	
			elif alt >= 0.25 && alt < 0.55: # Others/grassland
				viable_spawn_points.append(Vector2(x,y))
				world_tilemap.set_cell(0, Vector2i(x, y), 1, Vector2i(3,0))	
				if moist >= 0.5: # Forest node
					world_tilemap.set_cell(1, Vector2i(x, y), 1, Vector2i(0,9))	
			elif alt >= 0.55 && alt < 0.6: # mountains
				world_tilemap.set_cell(0, Vector2i(x, y), 1, Vector2i(4,1))	
			elif alt >= 0.6: # ice/peaks of mountains
				world_tilemap.set_cell(0, Vector2i(x, y), 1, Vector2i(4,0))	
	var total_time = Time.get_ticks_msec() - time_before
	print("World " + world_map_name + " generated in " + str(total_time) + " ms")
			

# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup the basic variables for map generation
	set_world_map_dimensions()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
