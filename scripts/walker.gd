## A walker that moves around a room and places floor tiles
class_name Walker
extends RefCounted

## Current position of the walker
var position: Vector2i

## Current direction of movement
var direction: Vector2i

## Random number generator for movement
var rng: RandomNumberGenerator

## Probability of changing direction (0-1)
var direction_change_chance: float = 0.3

## Array of positions where floor tiles have been placed
var floor_positions: Array[Vector2i]

## Room bounds
var _room_width: int
var _room_height: int

## Creates a new walker at the specified position
## @param start_pos The starting position of the walker
## @param room_width The width of the room
## @param room_height The height of the room
## @param seed The seed for random number generation
func _init(start_pos: Vector2i, room_width: int, room_height: int, seed: int) -> void:
	position = start_pos
	_room_width = room_width
	_room_height = room_height
	
	rng = RandomNumberGenerator.new()
	rng.seed = seed
	
	# Start with a random direction
	direction = get_random_direction()
	
	# Add starting position to floor positions
	floor_positions.append(position)

## Updates the walker's position and places floor tiles
## @return true if the walker moved, false if it couldn't move
func update() -> bool:
	# Maybe change direction
	if rng.randf() < direction_change_chance:
		direction = get_random_direction()
	
	# Calculate new position
	var new_pos = position + direction
	
	# If new position is out of bounds, try to find a valid direction
	if not is_in_bounds(new_pos):
		# Get all possible directions
		var possible_directions = get_all_directions()
		# Filter out directions that would put us out of bounds
		var valid_directions = possible_directions.filter(func(dir: Vector2i) -> bool:
			return is_in_bounds(position + dir)
		)
		
		# If we have valid directions, choose one randomly
		if valid_directions.size() > 0:
			direction = valid_directions[rng.randi() % valid_directions.size()]
			new_pos = position + direction
		else:
			return false
	
	position = new_pos
	floor_positions.append(position)
	return true

## Gets all possible directions for movement
## @return Array of all possible direction vectors
func get_all_directions() -> Array[Vector2i]:
	return [
		Vector2i(1, 0),   # Right
		Vector2i(-1, 0),  # Left
		Vector2i(0, 1),   # Down
		Vector2i(0, -1)   # Up
	]

## Gets a random direction for movement
## @return A random direction vector
func get_random_direction() -> Vector2i:
	var directions = get_all_directions()
	return directions[rng.randi() % directions.size()]

## Checks if a position is within the room bounds
## @param pos The position to check
## @return true if the position is in bounds, false otherwise
func is_in_bounds(pos: Vector2i) -> bool:
	return pos.x > 0 and pos.x < _room_width - 1 and pos.y > 0 and pos.y < _room_height - 1 