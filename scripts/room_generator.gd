## A procedural room generator that creates rooms using random walkers.
## The generator ensures there is always a valid path between entrance and exit.
class_name RoomGenerator
extends Node2D

@export_category("Room Size")
## The height of the generated room in tiles
@export var room_height: int = 10

## The width of the generated room in tiles
@export var room_width: int = 10

@export_category("Floors & Walls")
## The Tileset that will be used for Floors & Walls
@export var floor_tileset: TileSet

## Terrain ID for the floor tiles
@export var floor_tile: int

## Terrain ID for the wall tiles
@export var wall_tile: int

@export_category("Objects")
## The TileSet that will be used for Objects
@export var object_tileset: TileSet

## The ID of the door in the Scene Collection
@export var door_id: int

## The ID of the player in the Scene Collection
@export var player_id: int

@export_category("Randomization")
## Seed used for random generation. Changing this will create different room layouts
@export var _seed: String = "Game dev is difficult"

## Number of steps the walker should take
@export var walker_steps: int = 100

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

var floor_layer: map_generator
var object_layer: TileMapLayer

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	rng.seed = _seed.hash()
	create_layers()
	generate_room()
	floor_layer.init_pathfinding()

## Creates the neccessary TileMapLayers
func create_layers() -> void:
	create_floor_layer()
	create_object_layer()

## Creates the floor layer
func create_floor_layer() -> void:
	floor_layer = map_generator.new()
	floor_layer.tile_set = floor_tileset
	add_child(floor_layer)

## Creates the object layer
func create_object_layer() -> void:
	object_layer = TileMapLayer.new()
	object_layer.tile_set = object_tileset
	add_child(object_layer)

## Generates a new room layout
func generate_room() -> void:
	clear_the_previous_room()
	fill_the_room_with_walls()
	run_walker()
	place_entrance()
	place_exit()
	apply_terrain_changes()

func clear_the_previous_room() -> void:
	floor_layer.clear()
	object_layer.clear()
	floor_positions.clear()
	wall_positions.clear()
	entrance_positions.clear()
	exit_positions.clear()

### Fills in the wall positions to make up the whole room
func fill_the_room_with_walls() -> void:
	for x in range(room_width):
		for y in range(room_height):
			wall_positions.append(Vector2i(x, y))

### Starts a new walker at the center of the room
func run_walker() -> void:
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
				entrance_pos = Vector2i(int(rng.randi_range(1, room_width - 3)), 0)
			1: # Right edge
				entrance_pos = Vector2i(room_width - 1, int(rng.randi_range(1, room_height - 3)))
			2: # Bottom edge
				entrance_pos = Vector2i(int(rng.randi_range(1, room_width - 3)), room_height - 1)
			3: # Left edge
				entrance_pos = Vector2i(0, int(rng.randi_range(1, room_height - 3)))
		
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
		
		# Calculate floor positions based on edge
		var floor_pos1: Vector2i
		var floor_pos2: Vector2i
		match edge:
			0: # Top edge
				floor_pos1 = entrance_pos + Vector2i(0, 1)
				floor_pos2 = entrance_pos2 + Vector2i(0, 1)
			1: # Right edge
				floor_pos1 = entrance_pos + Vector2i(-1, 0)
				floor_pos2 = entrance_pos2 + Vector2i(-1, 0)
			2: # Bottom edge
				floor_pos1 = entrance_pos + Vector2i(0, -1)
				floor_pos2 = entrance_pos2 + Vector2i(0, -1)
			3: # Left edge
				floor_pos1 = entrance_pos + Vector2i(1, 0)
				floor_pos2 = entrance_pos2 + Vector2i(1, 0)
		
		# Check if floor positions are valid
		if not is_in_bounds(floor_pos1) or not is_in_bounds(floor_pos2):
			attempts += 1
			continue
			
		# Check if floor positions connect to existing floor tiles
		var has_floor_connection = false
		var adjacent_positions = [
			floor_pos1 + Vector2i(0, 1),   # Below
			floor_pos1 + Vector2i(0, -1),  # Above
			floor_pos1 + Vector2i(1, 0),   # Right
			floor_pos1 + Vector2i(-1, 0),  # Left
			floor_pos2 + Vector2i(0, 1),   # Below
			floor_pos2 + Vector2i(0, -1),  # Above
			floor_pos2 + Vector2i(1, 0),   # Right
			floor_pos2 + Vector2i(-1, 0)   # Left
		]
		
		for pos in adjacent_positions:
			if floor_positions.has(pos):
				has_floor_connection = true
				break
		
		if not has_floor_connection:
			attempts += 1
			continue
		
		# If we get here, we found valid positions
		entrance_positions.append(entrance_pos)
		entrance_positions.append(entrance_pos2)
		floor_positions.append(floor_pos1)
		floor_positions.append(floor_pos2)
		player_start_position = floor_pos1
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
				exit_pos = Vector2i(int(rng.randi_range(1, room_width - 3)), 0)
			1: # Right edge
				exit_pos = Vector2i(room_width - 1, int(rng.randi_range(1, room_height - 3)))
			2: # Bottom edge
				exit_pos = Vector2i(int(rng.randi_range(1, room_width - 3)), room_height - 1)
			3: # Left edge
				exit_pos = Vector2i(0, int(rng.randi_range(1, room_height - 3)))
		
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
		
		# Calculate floor positions based on edge
		var floor_pos1: Vector2i
		var floor_pos2: Vector2i
		match edge:
			0: # Top edge
				floor_pos1 = exit_pos + Vector2i(0, 1)
				floor_pos2 = exit_pos2 + Vector2i(0, 1)
			1: # Right edge
				floor_pos1 = exit_pos + Vector2i(-1, 0)
				floor_pos2 = exit_pos2 + Vector2i(-1, 0)
			2: # Bottom edge
				floor_pos1 = exit_pos + Vector2i(0, -1)
				floor_pos2 = exit_pos2 + Vector2i(0, -1)
			3: # Left edge
				floor_pos1 = exit_pos + Vector2i(1, 0)
				floor_pos2 = exit_pos2 + Vector2i(1, 0)
		
		# Check if floor positions are valid
		if not is_in_bounds(floor_pos1) or not is_in_bounds(floor_pos2):
			attempts += 1
			continue
			
		# Check if floor positions connect to existing floor tiles
		var has_floor_connection = false
		var adjacent_positions = [
			floor_pos1 + Vector2i(0, 1),   # Below
			floor_pos1 + Vector2i(0, -1),  # Above
			floor_pos1 + Vector2i(1, 0),   # Right
			floor_pos1 + Vector2i(-1, 0),  # Left
			floor_pos2 + Vector2i(0, 1),   # Below
			floor_pos2 + Vector2i(0, -1),  # Above
			floor_pos2 + Vector2i(1, 0),   # Right
			floor_pos2 + Vector2i(-1, 0)   # Left
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
		floor_positions.append(floor_pos1)
		floor_positions.append(floor_pos2)
		return
	
	# If we get here, we couldn't find valid positions
	push_error("Failed to place exit after " + str(max_attempts) + " attempts")

## Applies all terrain changes at once
func apply_terrain_changes() -> void:
	apply_floors()
	apply_entrance()
	apply_exit()
	apply_walls()
	apply_player()
	
### Apply floors
func apply_floors() -> void:
	for pos in floor_positions:
		wall_positions.erase(pos)
	floor_layer.set_cells_terrain_connect(floor_positions, 0, floor_tile, true)
	
### Apply walls
func apply_walls() -> void:
	floor_layer.set_cells_terrain_connect(wall_positions, 0, wall_tile, true)

### Apply entrance
func apply_entrance() -> void:
	print("Entrance Positions:")
	print(entrance_positions)
	print("------------------")
	for pos in entrance_positions:
		wall_positions.erase(pos)
	floor_layer.set_cells_terrain_connect(entrance_positions, 0, floor_tile, true)
	object_layer.set_cell(entrance_positions[0], 1, Vector2i.ZERO, door_id)
	object_layer.set_cell(entrance_positions[1], 1, Vector2i.ZERO, door_id)

### Apply exit
func apply_exit() -> void:
	print("Exit Positions:")
	print(exit_positions)
	print("__________________")
	for pos in exit_positions:
		wall_positions.erase(pos)
	floor_layer.set_cells_terrain_connect(exit_positions, 0, floor_tile, true)
	object_layer.set_cell(exit_positions[0], 1, Vector2i.ZERO, door_id)
	object_layer.set_cell(exit_positions[1], 1, Vector2i.ZERO, door_id)

### Apply player
func apply_player() -> void:
	object_layer.set_cell(player_start_position, 1, Vector2i.ZERO, player_id)

## Checks if a position is in the bounds of the room
func is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < room_width and pos.y >= 0 and pos.y < room_height
