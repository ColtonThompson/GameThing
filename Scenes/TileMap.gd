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

var rpg_normal_source = 0
var rpg_autumn_source = 1
var rpg_winter_source = 2

var seed = 0
var last_player_location: Vector2i

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
	
	last_player_location = World.get_player_tile_position()
	
func _input(event):
	if World.debug_mode:
		if event.is_action_pressed("debug"):
			update_world()
		
	# Called on the map update timer signal
	# Checks how far the player has moved, if the player has moved in any direction more than 
	# dist_required_for_update tiles then it calls update_world()
	#
	# TODO: I think this method can be improved
func _on_map_update_timer_timeout():
	var diffX = abs(World.get_player_tile_position().x - last_player_location.x)
	var diffY = abs(World.get_player_tile_position().y - last_player_location.y)
	var dist_required_for_update = 16
	var dist_traveled = diffX + diffY
	var needs_update = dist_traveled >= dist_required_for_update
	if needs_update:
		update_world()
		last_player_location = World.get_player_tile_position()

func _process(delta):
	World.player_standing_biome = get_biome_for_tile(World.get_player_tile_position())
	
func configure_tile_thresholds():
	if deepwater_max_threshold < deepwater_min_threshold:
		deepwater_max_threshold = deepwater_min_threshold + 1
	if water_max_threshold < water_min_threshold:
		water_max_threshold = water_min_threshold + 1
	if sand_max_threshold < sand_min_threshold:
		sand_max_threshold = sand_min_threshold + 1	
	if grass_max_threshold < grass_min_threshold:
		grass_max_threshold = grass_min_threshold + 1

# Handles the spawning of objects and overlays on the game world
func handle_object_spawns(alt, temp, hum, tile: Vector2i):
	var object_mushroom_single = Vector2i(3,0)
	var object_mushroom_group = Vector2i(3,1)
	var object_stone = Vector2i(2,1)
	var object_tree_fallen = Vector2i(4,0)
	var object_tree_stump = Vector2i(3,1)
	var object_tree = Vector2i(0,1)
	var overlay_tree = Vector2i(0,0)
	var object_dead_tree = Vector2i(2,1)
	var overlay_dead_tree = Vector2i(2,0)
	var biome_forest: bool = alt > sand_max_threshold and temp >= 5 and temp < 45 and hum >= 20 and hum < 50
	var roll = randi_range(0, 100)
	if biome_forest:
		var tree_type_roll = randi_range(0, 100)
		#Trees shouldn't spawn on every tile, so we do a random roll from 0-100
		if roll <= 30:
			# Dead tree
			if tree_type_roll >= 0 && tree_type_roll < 10:
				set_obj_and_data(World.layer_objects, Vector2i(tile.x, tile.y), rpg_autumn_source, object_dead_tree)
				set_obj_overlay_and_data(World.layer_objects_overlay, Vector2i(tile.x, tile.y - 1), rpg_autumn_source, overlay_dead_tree)	
			elif tree_type_roll >= 10 && tree_type_roll < 20:
				set_obj_and_data(World.layer_objects, Vector2i(tile.x, tile.y), rpg_autumn_source, object_tree_stump)
			else:
				set_obj_and_data(World.layer_objects, Vector2i(tile.x, tile.y), rpg_normal_source, object_tree)
				set_obj_overlay_and_data(World.layer_objects_overlay, Vector2i(tile.x, tile.y - 1), rpg_normal_source, overlay_tree)
		elif roll >= 35 && roll < 40: # Mushrooms
			var shroom_roll = randi_range(0, 100)
			if shroom_roll < 25:
				set_obj_and_data(World.layer_objects, Vector2i(tile.x, tile.y), rpg_normal_source, object_mushroom_group)
			else:
				set_obj_and_data(World.layer_objects, Vector2i(tile.x, tile.y), rpg_normal_source, object_mushroom_single)
		elif roll >= 40 && roll < 42: # Fallen tree/logs
			set_obj_and_data(World.layer_objects, Vector2i(tile.x, tile.y), rpg_normal_source, object_tree_fallen)
		elif roll > 42 && roll < 50: # Stones
			set_obj_and_data(World.layer_objects, Vector2i(tile.x, tile.y), rpg_normal_source, object_stone)
			
		
	
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
			var pos: Vector2i = Vector2i(x,y)
			
			# Set cells from memory otherwise we generate new tiles!
			if World.tile_is_set(pos):
				set_cell(World.layer_tiles, pos, get_source_id(World.layer_tiles, pos), World.get_tile_atlas_coords(pos))
			else:
				var alt = abs(floor(altitude.get_noise_2d(x, y) * 100))
				var temp = abs(floor(temperature.get_noise_2d(x, y) * 100))
				var hum = abs(floor(humidity.get_noise_2d(x, y) * 100))
				set_cell_with_noise(alt, temp, hum, pos)
			
			# After the tiles are set we can set objects and overlays
			if World.object_is_set(pos):
				set_cell(World.layer_objects, pos, get_source_id(World.layer_objects, pos), World.get_obj_atlas_coords(pos))
			if World.object_overlay_is_set(pos):
				set_cell(World.layer_objects_overlay, pos, get_source_id(World.layer_objects_overlay, pos), World.get_obj_overlay_atlas_coords(pos))
	
	# Set all cells too far away to -1, -1
	for cell in get_faraway_tiles_for_cleanup():
		set_cell(World.layer_tiles, Vector2i(cell.x, cell.y), 0, Vector2i(-1, -1))
	
							
# Determines the type of tile at the cell coordinates with noise values
func set_cell_with_noise(alt, temp, hum, tile: Vector2i):
	var biome_desert: bool = alt > water_max_threshold and alt <= grass_max_threshold and temp >= 50 and hum < 10
	var biome_tundra: bool = alt > water_max_threshold and alt <= grass_max_threshold and temp < 5 and hum < 10
	var biome_forest: bool = alt > sand_max_threshold and temp >= 5 and temp < 45 and hum >= 20 and hum < 50
	var biome_savanna: bool = alt > water_max_threshold and temp > 30 and hum > 50
	var biome_water: bool = alt >= water_min_threshold and alt < water_max_threshold
	var biome_deepwater: bool = alt >= deepwater_min_threshold and alt < deepwater_max_threshold
	# TODO: Find a better way to create codebased definitions of the tile atlas
	var tile_grass_long = Vector2i(0,2)
	var tile_grass_short = Vector2i(4,2)
	var tile_sand = Vector2i(4,1)
	var tile_water = Vector2i(1,2)
	var tile_deepwater = Vector2i(1,2)
	var tile_snow = Vector2i(0,2)

	var roll = randi_range(0, 100)
	
	handle_object_spawns(alt, temp, hum, tile)

	if biome_deepwater:
		set_cell_and_data(World.layer_tiles, Vector2i(tile.x, tile.y), rpg_normal_source, tile_deepwater)
	elif biome_water:
		set_cell_and_data(World.layer_tiles, Vector2i(tile.x, tile.y), rpg_normal_source, tile_water)
	elif biome_tundra:
		set_cell_and_data(World.layer_tiles, Vector2i(tile.x, tile.y), rpg_winter_source, tile_snow)
	elif biome_desert:
		set_cell_and_data(World.layer_tiles, Vector2i(tile.x, tile.y), rpg_normal_source, tile_sand)
	else:
		var roll_grass = randi_range(0, 100)
		if roll_grass >= 50:
			set_cell_and_data(World.layer_tiles, Vector2i(tile.x, tile.y), 0, tile_grass_short)
		else:
			set_cell_and_data(World.layer_tiles, Vector2i(tile.x, tile.y), 0, tile_grass_long)

# Sets the cell for the tile as well as stores the data into a dictionary
func set_cell_and_data(layer, tile_pos: Vector2i, source_id, atlas_coords: Vector2i):
	World.set_tile(tile_pos, atlas_coords)
	set_cell(layer, tile_pos, source_id, atlas_coords)
	
# Sets the cell for the object as well as stores the data into a dictionary	
func set_obj_and_data(layer, tile_pos: Vector2i, source_id, atlas_coords: Vector2i):
	World.set_object_tile(tile_pos, atlas_coords)
	set_cell(layer, tile_pos, source_id, atlas_coords)
	
# Sets the cell for the object_overlay as well as stores the data into a dictionary	
func set_obj_overlay_and_data(layer, tile_pos: Vector2i, source_id, atlas_coords: Vector2i):
	World.set_object_overlay_tile(tile_pos, atlas_coords)
	set_cell(layer, tile_pos, source_id, atlas_coords)
	
# Determines what the atlas coords/source id are at tile_position	
func get_biome_for_tile(tile_position: Vector2i):
	var cell_source_id = get_cell_source_id(0, tile_position)
	var cell_atlas_coords = get_cell_atlas_coords(0, tile_position)
	var tile_grass = Vector2i(0,0)
	var tile_sand = Vector2i(1,0)
	var tile_water = Vector2i(2,0)
	var tile_deepwater = Vector2i(3,0)
	var tile_tundra = Vector2i(0,1)
	var tile_grassland = Vector2i(1,1)
	match cell_atlas_coords:
		tile_grass:
			return "Forest/Fields"
		tile_sand:
			return "Desert/Beach"
		tile_water:
			return "River/Lake/Ocean"
		tile_deepwater:
			return "Deep Ocean"
		tile_tundra:
			return "Tundra"
		tile_grassland:
			return "Grassland/Savanna"
		_:
			return "Unknown Biome"

func get_atlas_for_tile(layer, tile_pos: Vector2i) -> Vector2i:
	var cell_atlas_coords = get_cell_atlas_coords(layer, tile_pos)
	return cell_atlas_coords	
	
	
func get_source_id(layer, tile_pos: Vector2i) -> int:
	var cell_source_id = get_cell_source_id(layer, tile_pos)
	return cell_source_id
