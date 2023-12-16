extends Node

# Tile dimensions
var tile_width = 32
var tile_height = 32

# Chunk dimension variables
var chunk_width = 32
var chunk_height = 32
var chunk_layer_count = 3

# World row/columns (each index is a chunk map)
var world_width = 3
var world_height = 3
var world_cell_count = world_width * world_height
var world_needs_update = false

# Layer data
var world_tile_data = {}
var world_object_data = {}
var world_object_overlay_data = {}

var layer_tiles = 0
var layer_objects = 1
var layer_objects_overlay = 2

# Enables printing of various info to the console
var debug_mode = true

# Sets the tile_pos to the tileset atlas_coords and stores it in a dictionary
func set_tile(tile_pos: Vector2i, atlas_coords: Vector2i):
	var tile_is_set = world_tile_data.has(tile_pos)
	if !tile_is_set:
		world_tile_data[tile_pos] = atlas_coords
		
# Sets the tile_pos to the tileset atlas_coords and stores it in a dictionary
func set_object_tile(tile_pos: Vector2i, atlas_coords: Vector2i):
	var object_is_set = world_object_data.has(tile_pos)
	if !object_is_set:
		world_object_data[tile_pos] = atlas_coords

# Sets the tile_pos to the tileset atlas_coords and stores it in a dictionary
func set_object_overlay_tile(tile_pos: Vector2i, atlas_coords: Vector2i):
	var overlay_is_set = world_object_overlay_data.has(tile_pos)
	if !overlay_is_set:
		world_object_overlay_data[tile_pos] = atlas_coords
		
# Returns true if world_tile_data contains tile_pos as a key		
func tile_is_set(tile_pos: Vector2i) -> bool:
	return world_tile_data.has(tile_pos)
	
# Returns true if world_object_data contains tile_pos as a key		
func object_is_set(tile_pos: Vector2i) -> bool:
	return world_object_data.has(tile_pos)
	
# Returns true if world_object_overlay_data contains tile_pos as a key		
func object_overlay_is_set(tile_pos: Vector2i) -> bool:
	return world_object_overlay_data.has(tile_pos)	
	
# Gets the tile atlas coords from the world_tile_data dictionary	
func get_tile_atlas_coords(tile_pos: Vector2i) -> Vector2i:
	var atlas_coords = world_tile_data[tile_pos]
	return atlas_coords

# Gets the tile atlas coords from the world_object_data dictionary	
func get_obj_atlas_coords(tile_pos: Vector2i) -> Vector2i:
	var atlas_coords = world_object_data[tile_pos]
	return atlas_coords
	
# Gets the tile atlas coords from the world_object_data dictionary	
func get_obj_overlay_atlas_coords(tile_pos: Vector2i) -> Vector2i:
	var atlas_coords = world_object_overlay_data[tile_pos]
	return atlas_coords	

# Map variables
var map_seed = ""
var map_name = "Default"

# Procgen Variables
var procgen_min_threshold = -20
var procgen_max_threshold = 20

# Player variables
var player_tile_position = Vector2i(0,0)
var player_standing_biome = "UNKNOWN"

func set_player_standing_biome(biome):
	player_standing_biome = biome

func set_player_tile_position(x: float, y: float):
	player_tile_position = Vector2i(x,y)
	
func get_player_tile_position():
	return player_tile_position

func get_player_standing_biome():
	return player_standing_biome
