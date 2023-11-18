extends TileMap

var altitude = FastNoiseLite.new()
var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()

# Generates a 64 x 64 tile chunk of a map based on FastNoise
func generate_chunk():
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
				var offset_x = tile_position.x - World.chunk_width/2
				var offset_y = tile_position.y - World.chunk_height/2
				var alt = altitude.get_noise_2d(x + offset_x, y + offset_y)
				var moist = moisture.get_noise_2d(x + offset_x, y + offset_y)
				var temp = temperature.get_noise_2d(x + offset_x, y + offset_y)
				
				if alt <= 0.3: # water
					set_cell(0, Vector2i(x + offset_x,y + offset_y), 0, Vector2i(2,0))
				else: # grass
					set_cell(0, Vector2i(x + offset_x,y + offset_y), 0, Vector2i(0,0))


# Called when the node enters the scene tree for the first time.
func _ready():
	generate_chunk()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
