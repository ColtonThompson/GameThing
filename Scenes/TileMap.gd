extends TileMap

var altitude = FastNoiseLite.new()
var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()

# Chunk management
var chunk_status = {
	1: false, 2: false, 3: false, 
	4: false, 5: false, 6: false, 
	7: false, 8: false, 9: false,
}
# Generates a X by Y grid of chunks (Currently 3x3)
# TODO: Determine if a chunk SHOULD be generated/unloaded
func generate_world():
	for x in range(World.world_width):
		for y in range(World.world_height):
			generate_chunk(x,y)

# Generates a 96 x 96 tile chunk of a map based on FastNoise
# This should cover the max resolution of the game window
func generate_chunk(chunk_x, chunk_y):
	var tile_position = local_to_map($"../Player".position)
	
	# Configure seed - Use player string or randomize
	var seed = randi()
	if World.map_seed.length() > 0:
		seed = World.map_seed.hash()
		
	altitude.seed = seed
	moisture.seed = seed
	temperature.seed = seed
		
	# Chunk tiles/layers
	for x in range(World.chunk_width):
		for y in range(World.chunk_height):
			for z in range(World.chunk_layer_count): # layers
				var chunk_offset_x = chunk_x * World.chunk_width
				var chunk_offset_y = chunk_y * World.chunk_height
				var offset_x = (tile_position.x - World.chunk_width/2) + chunk_offset_x
				var offset_y = (tile_position.y - World.chunk_height/2) + chunk_offset_y
				var alt = altitude.get_noise_2d(x + offset_x, y + offset_y)
				var moist = moisture.get_noise_2d(x + offset_x, y + offset_y)
				var temp = temperature.get_noise_2d(x + offset_x, y + offset_y)
					
				if alt < 0.1: # water
					set_cell(0, Vector2i(x + offset_x,y + offset_y), 0, Vector2i(2,0))
				elif alt >= 0.1 and alt < 0.25: # Sand
					set_cell(0, Vector2i(x + offset_x,y + offset_y), 0, Vector2i(1,0))
				else: # grass
					set_cell(0, Vector2i(x + offset_x,y + offset_y), 0, Vector2i(0,0))

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_world()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
