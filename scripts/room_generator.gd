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
	
	# Apply terrain changes
	apply_terrain_changes()

## Applies all terrain changes at once
func apply_terrain_changes() -> void:
	# Ensure no position is in both arrays
	for pos in floor_positions:
		wall_positions.erase(pos)
	
	# Apply all terrain changes
	set_cells_terrain_connect(floor_positions, 0, floor, true)
	set_cells_terrain_connect(wall_positions, 0, wall, true)

## Checks if a position is in the bounds of the room
func is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < room_width and pos.y >= 0 and pos.y < room_height
