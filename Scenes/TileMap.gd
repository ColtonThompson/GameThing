extends TileMap

@export_group("Tile Altitude Thresholds")
@export_subgroup("Water Values")
@export_range (0, 100) var deepwater_min_threshold: int
@export_range (0, 100) var deepwater_max_threshold: int

@export_range (0, 100) var water_min_threshold: int
@export_range (0, 100) var water_max_threshold: int

@export_subgroup("Sand Values")
@export_range (0, 100) var sand_min_threshold: int
@export_range (0, 100) var sand_max_threshold: int

@export_subgroup("Grass Values")
@export_range (0, 100) var grass_min_threshold: int
@export_range (0, 100) var grass_max_threshold: int

@export_group("Chunk Rendering")
@export var tile_mask_radius: int

var altitude = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var humidity = FastNoiseLite.new()

var seed = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Makes sure the thresholds are set properly (avoiding black tiles on the world map)
	configure_tile_thresholds()
		
	# Configure seed - Use player string or randomize
	var seed = randi()
	if World.map_seed.length() > 0:
		seed = World.map_seed.hash()
		
	altitude.seed = seed
	temperature.seed = seed
	humidity.seed = seed
	
	altitude.frequency = 0.005
	temperature.frequency = 0.005
	humidity.frequency = 0.005
	update_world()
	
func _input(event):
	if event.is_action_pressed("debug"):
		update_world()
		
func _on_map_update_timer_timeout():
	update_world()
	
func _process(delta):
	pass
	
func configure_tile_thresholds():
	if deepwater_max_threshold < deepwater_min_threshold:
		deepwater_max_threshold = deepwater_min_threshold + 1
	if water_max_threshold < water_min_threshold:
		water_max_threshold = water_min_threshold + 1
	if sand_max_threshold < sand_min_threshold:
		sand_max_threshold = sand_min_threshold + 1	
	if grass_max_threshold < grass_min_threshold:
		grass_max_threshold = grass_min_threshold + 1
	
# Loops through all the used tiles and checks the distance for tile_mask_radius
func get_faraway_tiles_for_cleanup() -> Array:
	var result = []
	var player_position = World.get_player_tile_position()
	var used_cells = get_used_cells(0)
	for cell in used_cells:
		var cleanup_mask_radius = tile_mask_radius + 16
		var tile_pos = cell as Vector2i
		var diff_x = abs(player_position.x - tile_pos.x)
		var diff_y = abs(player_position.y - tile_pos.y)
		if diff_x > cleanup_mask_radius or diff_y > cleanup_mask_radius:
			result.append(cell)
	return result

# Updates all cells that are visible to the player based on tile_mask_radius		
func update_world():
	var player_position = World.get_player_tile_position()
	var amount_of_screen_tiles_width = get_viewport_rect().size.x / World.tile_width
	var amount_of_screen_tiles_height = get_viewport_rect().size.y / World.tile_height
	var start_x = player_position.x - tile_mask_radius
	var start_y = player_position.y - tile_mask_radius
	var end_x = player_position.x + tile_mask_radius
	var end_y = player_position.y + tile_mask_radius
	
	# Set cells based on noise values
	for x in range(start_x, end_x):
		for y in range(start_y, end_y):
			var alt = abs(floor(altitude.get_noise_2d(x, y) * 100))
			var temp = abs(floor(temperature.get_noise_2d(x, y) * 100))
			var hum = abs(floor(humidity.get_noise_2d(x, y) * 100))
			set_cell_with_noise(alt, temp, hum, Vector2i(x,y))
	
	# Set all cells too far away to -1, -1
	for cell in get_faraway_tiles_for_cleanup():
		set_cell(0, Vector2i(cell.x, cell.y), 0, Vector2i(-1, -1))
							
# Determines the type of tile at the cell coordinates with noise values
func set_cell_with_noise(alt, temp, hum, tile: Vector2i):
	var biome_desert: bool = alt > water_max_threshold and alt <= grass_max_threshold and temp >= 50 and hum < 10
	var biome_tundra: bool = alt > water_max_threshold and alt <= grass_max_threshold and temp < 5 and hum < 10
	var biome_forest: bool = alt > sand_max_threshold and temp >= 5 and temp < 45 and hum >= 20 and hum < 50
	var biome_grassland: bool = alt > water_max_threshold and temp > 30 and hum > 50
	var biome_water: bool = alt >= water_min_threshold and alt < water_max_threshold
	var biome_deepwater: bool = alt >= deepwater_min_threshold and alt < deepwater_max_threshold
	var tile_grass = Vector2i(0,0)
	var tile_sand = Vector2i(1,0)
	var tile_water = Vector2i(2,0)
	var tile_deepwater = Vector2i(3,0)
	var tile_tundra = Vector2i(0,1)
	var tile_grassland = Vector2i(1,1)
	var object_tree = Vector2i(0,3)
	#print("Biome states:")
	#print("biome_desert: " + str(biome_desert) + ", biome_tundra: " + str(biome_tundra) + 
	#", biome_forest: " + str(biome_forest) + ", biome_grassland: " + str(biome_grassland) + 
	#", biome_water: " + str(biome_water) + ", biome_deepwater: " + str(biome_deepwater))
	if biome_forest:
		var tree_chance = randi_range(0, 100)
		if tree_chance < 70:
			set_cell(1, Vector2i(tile.x, tile.y), 0, object_tree)
	
	if biome_deepwater:
		set_cell(0, Vector2i(tile.x, tile.y), 0, tile_deepwater)
	elif biome_water:
		set_cell(0, Vector2i(tile.x, tile.y), 0, tile_water)
	elif biome_tundra:
		set_cell(0, Vector2i(tile.x, tile.y), 0, tile_tundra)
	elif biome_desert:
		set_cell(0, Vector2i(tile.x, tile.y), 0, tile_sand)
	elif biome_grassland:
		set_cell(0, Vector2i(tile.x, tile.y), 0, tile_grassland)
	else:
		set_cell(0, Vector2i(tile.x, tile.y), 0, tile_grass)
		
