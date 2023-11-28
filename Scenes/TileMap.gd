extends TileMap

@export_group("Tile Thresholds")
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

@export_group("Chunks")
@export var tile_mask_radius: int

var altitude = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var humidity = FastNoiseLite.new()

var seed = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if deepwater_max_threshold < deepwater_min_threshold:
		deepwater_max_threshold = deepwater_min_threshold + 1
	if water_max_threshold < water_min_threshold:
		water_max_threshold = water_min_threshold + 1
	if sand_max_threshold < sand_min_threshold:
		sand_max_threshold = sand_min_threshold + 1	
	if grass_max_threshold < grass_min_threshold:
		grass_max_threshold = grass_min_threshold + 1
		
	# Configure seed - Use player string or randomize
	var seed = randi()
	if World.map_seed.length() > 0:
		seed = World.map_seed.hash()
		
	altitude.seed = seed
	temperature.seed = seed
	humidity.seed = seed
	
	altitude.frequency = 0.02
	temperature.frequency = 0.02
	humidity.frequency = 0.02
	update_world()
	
func _input(event):
	if event.is_action_pressed("debug"):
		update_world()
		
func _on_map_update_timer_timeout():
	update_world()
	
func _process(delta):
	pass
	
# Maybe shorten this?
func get_faraway_tiles_for_cleanup() -> Array:
	var result = []
	var player_position = World.get_player_tile_position()
	var used_cells = get_used_cells(0)
	for cell in used_cells:
		var tile_pos = cell as Vector2i
		var diff_x = abs(player_position.x - tile_pos.x)
		var diff_y = abs(player_position.y - tile_pos.y)
		if diff_x > tile_mask_radius or diff_y > tile_mask_radius:
			result.append(cell)
	return result
		
func update_world():
	var player_position = World.get_player_tile_position()
	var amount_of_screen_tiles_width = get_viewport_rect().size.x / World.tile_width
	var amount_of_screen_tiles_height = get_viewport_rect().size.y / World.tile_height
	var start_x = player_position.x - tile_mask_radius
	var start_y = player_position.y - tile_mask_radius
	var end_x = player_position.x + tile_mask_radius
	var end_y = player_position.y + tile_mask_radius
	
	for x in range(start_x, end_x):
		for y in range(start_y, end_y):
			var alt = abs(floor(altitude.get_noise_2d(x, y) * 100))
			var temp = abs(floor(temperature.get_noise_2d(x, y) * 100))
			var hum = abs(floor(humidity.get_noise_2d(x, y) * 100))
			
			#print("ALT: " + str(alt))
			
			set_cell_with_noise(alt, temp, hum, Vector2i(x,y))
	
	# Set all cells too far away to -1, -1
	for cell in get_faraway_tiles_for_cleanup():
		set_cell(0, Vector2i(cell.x, cell.y), 0, Vector2i(-1, -1))
							
# Determines the type of tile at the cell coordinates with noise values
func set_cell_with_noise(alt, temp, hum, tile: Vector2i):
	if alt >= deepwater_min_threshold and alt < deepwater_max_threshold: # deepwater
		set_cell(0, Vector2i(tile.x, tile.y), 0, Vector2i(3,0))
	elif alt >= water_min_threshold and alt < water_max_threshold: # water
		set_cell(0, Vector2i(tile.x, tile.y), 0, Vector2i(2,0))
	elif alt >= sand_min_threshold and alt < sand_max_threshold: # Sand
		set_cell(0, Vector2i(tile.x, tile.y), 0, Vector2i(1,0))
	elif alt >= grass_min_threshold: # grass
		set_cell(0, Vector2i(tile.x, tile.y), 0, Vector2i(0,0))
		
func is_cell_empty(x: int, y: int) -> bool:
	return get_cell_source_id(0, Vector2i(x,y)) == -1



