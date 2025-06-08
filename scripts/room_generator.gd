## A procedural room generator that creates rooms using random walkers.
## The generator ensures there is always a valid path between entrance and exit.
class_name RoomGenerator
extends map_generator

## The tilemap layer used for objects (doors and player)
@export var object_layer: TileMapLayer

## The height of the generated room in tiles
@export var room_height: int = 10

## The width of the generated room in tiles
@export var room_width: int = 10

## Seed used for random generation. Changing this will create different room layouts
@export var seed: String = "Game dev is difficult"

## Number of steps the walker should take
@export var walker_steps: int = 100

## Terrain ID for floor tiles
var floor: int = 0

## Terrain ID for wall tiles
var wall: int = 1

## Random number generator for procedural generation
var rng: RandomNumberGenerator

## Array of floor tile positions to be placed
var floor_positions: Array[Vector2i]

## Array of wall tile positions to be placed
var wall_positions: Array[Vector2i]

## The active walker
var walker: Walker

## Array of entrance tile positions
var entrance_positions: Array[Vector2i]

### Player's starting position near the entrance
var player_start_position: Vector2i

## Array of exit tile positions
var exit_positions: Array[Vector2i]

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	rng.seed = seed.hash()
	
	generate_room()

## Generates a new room layout
func generate_room() -> void:
	# Clear previous room
	clear()
	object_layer.clear()
	
	# Initialize arrays
	floor_positions.clear()
	wall_positions.clear()
	entrance_positions.clear()
	exit_positions.clear()
	
	# Fill room with walls
	for x in range(room_width):
		for y in range(room_height):
			wall_positions.append(Vector2i(x, y))
	
	# Create walker at center of room
	var start_pos = Vector2i(room_width / 2, room_height / 2)
	walker = Walker.new(start_pos, room_width, room_height, rng.randi())
	
	# Run walker
	for step in range(walker_steps):
		walker.update()
		# Add walker's floor positions to our floor positions
		for pos in walker.floor_positions:
			if not floor_positions.has(pos):
				floor_positions.append(pos)
	
	# Place entrance and exit
	place_entrance()
	place_exit()
	
	# Apply terrain changes
	apply_terrain_changes()

## Places the entrance on the edge of the map
func place_entrance() -> void:
	var max_attempts = 100  # Prevent infinite loops
	var attempts = 0
	
	while attempts < max_attempts:
		# Choose a random edge (0: top, 1: right, 2: bottom, 3: left)
		var edge = rng.randi() % 4
		
		# Choose a random position on that edge (avoiding corners)
		var entrance_pos: Vector2i
		match edge:
			0: # Top edge
				entrance_pos = Vector2i(rng.randi_range(1, room_width - 3), 0)
			1: # Right edge
				entrance_pos = Vector2i(room_width - 1, rng.randi_range(1, room_height - 3))
			2: # Bottom edge
				entrance_pos = Vector2i(rng.randi_range(1, room_width - 3), room_height - 1)
			3: # Left edge
				entrance_pos = Vector2i(0, rng.randi_range(1, room_height - 3))
		
		# Calculate second entrance position
		var entrance_pos2: Vector2i
		match edge:
			0: # Top edge - place tile to the right
				entrance_pos2 = entrance_pos + Vector2i(1, 0)
			1: # Right edge - place tile below
				entrance_pos2 = entrance_pos + Vector2i(0, 1)
			2: # Bottom edge - place tile to the right
				entrance_pos2 = entrance_pos + Vector2i(1, 0)
			3: # Left edge - place tile below
				entrance_pos2 = entrance_pos + Vector2i(0, 1)
		
		# Check if positions connect to a floor tile
		var has_floor_connection = false
		var adjacent_positions = [
			entrance_pos + Vector2i(0, 1),   # Below
			entrance_pos + Vector2i(0, -1),  # Above
			entrance_pos + Vector2i(1, 0),   # Right
			entrance_pos + Vector2i(-1, 0),  # Left
			entrance_pos2 + Vector2i(0, 1),  # Below
			entrance_pos2 + Vector2i(0, -1), # Above
			entrance_pos2 + Vector2i(1, 0),  # Right
			entrance_pos2 + Vector2i(-1, 0)  # Left
		]
		
		for pos in adjacent_positions:
			if floor_positions.has(pos):
				player_start_position = pos
				has_floor_connection = true
				break
		
		if not has_floor_connection:
			attempts += 1
			continue
		
		# If we get here, we found valid positions
		entrance_positions.append(entrance_pos)
		entrance_positions.append(entrance_pos2)
		return
	
	# If we get here, we couldn't find valid positions
	push_error("Failed to place entrance after " + str(max_attempts) + " attempts")

## Places the exit on the edge of the map
func place_exit() -> void:
	var max_attempts = 100  # Prevent infinite loops
	var attempts = 0
	
	while attempts < max_attempts:
		# Choose a random edge (0: top, 1: right, 2: bottom, 3: left)
		var edge = rng.randi() % 4
		
		# Choose a random position on that edge (avoiding corners)
		var exit_pos: Vector2i
		match edge:
			0: # Top edge
				exit_pos = Vector2i(rng.randi_range(1, room_width - 3), 0)
			1: # Right edge
				exit_pos = Vector2i(room_width - 1, rng.randi_range(1, room_height - 3))
			2: # Bottom edge
				exit_pos = Vector2i(rng.randi_range(1, room_width - 3), room_height - 1)
			3: # Left edge
				exit_pos = Vector2i(0, rng.randi_range(1, room_height - 3))
		
		# Calculate second exit position
		var exit_pos2: Vector2i
		match edge:
			0: # Top edge - place tile to the right
				exit_pos2 = exit_pos + Vector2i(1, 0)
			1: # Right edge - place tile below
				exit_pos2 = exit_pos + Vector2i(0, 1)
			2: # Bottom edge - place tile to the right
				exit_pos2 = exit_pos + Vector2i(1, 0)
			3: # Left edge - place tile below
				exit_pos2 = exit_pos + Vector2i(0, 1)
		
		# Check if positions overlap with entrance
		if entrance_positions.has(exit_pos) or entrance_positions.has(exit_pos2):
			attempts += 1
			continue
		
		# Check if positions connect to a floor tile
		var has_floor_connection = false
		var adjacent_positions = [
			exit_pos + Vector2i(0, 1),   # Below
			exit_pos + Vector2i(0, -1),  # Above
			exit_pos + Vector2i(1, 0),   # Right
			exit_pos + Vector2i(-1, 0),  # Left
			exit_pos2 + Vector2i(0, 1),  # Below
			exit_pos2 + Vector2i(0, -1), # Above
			exit_pos2 + Vector2i(1, 0),  # Right
			exit_pos2 + Vector2i(-1, 0)  # Left
		]
		
		for pos in adjacent_positions:
			if floor_positions.has(pos):
				has_floor_connection = true
				break
		
		if not has_floor_connection:
			attempts += 1
			continue
		
		# If we get here, we found valid positions
		exit_positions.append(exit_pos)
		exit_positions.append(exit_pos2)
		return
	
	# If we get here, we couldn't find valid positions
	push_error("Failed to place exit after " + str(max_attempts) + " attempts")

## Applies all terrain changes at once
func apply_terrain_changes() -> void:
	# Ensure no position is in both arrays
	for pos in floor_positions:
		wall_positions.erase(pos)
	
	# Remove entrance and exit positions from wall positions
	for pos in entrance_positions:
		wall_positions.erase(pos)
	for pos in exit_positions:
		wall_positions.erase(pos)
		
	apply_floors()
	apply_walls()
	apply_entrance()
	apply_exit()
	
### Apply floors
func apply_floors() -> void:
	set_cells_terrain_connect(floor_positions, 0, floor, true)
	
### Apply walls
func apply_walls() -> void:
	set_cells_terrain_connect(wall_positions, 0, wall, true)

### Apply entrance
func apply_entrance() -> void:
	set_cells_terrain_connect(entrance_positions, 0, floor, true)
	object_layer.set_cell(entrance_positions[0], 1, Vector2i.ZERO, 2)
	object_layer.set_cell(entrance_positions[1], 1, Vector2i.ZERO, 2)

### Apply exit
func apply_exit() -> void:
	set_cells_terrain_connect(exit_positions, 0, floor, true)
	object_layer.set_cell(exit_positions[0], 1, Vector2i.ZERO, 2)
	object_layer.set_cell(exit_positions[1], 1, Vector2i.ZERO, 2)

func apply_player() -> void:
	object_layer.set_cell(player_start_position, 1, Vector2i.ZERO, 1)

## Checks if a position is in the bounds of the room
func is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < room_width and pos.y >= 0 and pos.y < room_height
