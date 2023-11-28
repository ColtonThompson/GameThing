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

# Map variables
var map_seed = ""
var map_name = "Default"

# Procgen Variables
var procgen_min_threshold = -20
var procgen_max_threshold = 20

# Player variables
var player_tile_position = Vector2i(0,0)

func set_player_tile_position(x: float, y: float):
	player_tile_position = Vector2i(x,y)
	
func get_player_tile_position():
	return player_tile_position
