extends Node

@export var room: TileMapLayer
@export var object_layer: TileMapLayer
@export var room_height: int = 10
@export var room_width: int = 10
@export var seed: String = "Coding is hard"
@export var walker_count: int = 3
@export var walker_steps: int = 50
@export var walker_chance_to_change_direction: float = 0.3
@export var max_generation_attempts: int = 10
@export var player_scene: PackedScene
@export var door_scene: PackedScene

var floor: int = 0
var wall: int = 1

var rng: RandomNumberGenerator
var walkers: Array[Vector2i]
var walker_directions: Array[Vector2i]

# Track entrance and exit positions
var entrance_positions: Array[Vector2i]
var exit_positions: Array[Vector2i]

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	rng.seed = seed.hash()
	object_layer.clear()
	room.clear()
	generate_room()

func place_player(pos: Vector2i) -> void:
	var player_instance = player_scene.instantiate()
	object_layer.add_child(player_instance)
	player_instance.position = object_layer.map_to_local(pos)

func place_door(pos: Vector2i) -> void:
	var door_instance = door_scene.instantiate()
	object_layer.add_child(door_instance)
	door_instance.position = object_layer.map_to_local(pos)

func generate_room() -> void:
	var attempts = 0
	var valid_room = false
	
	while not valid_room and attempts < max_generation_attempts:
		attempts += 1
		
		# Initialize room with walls
		for x in range(room_width):
			for y in range(room_height):
				place_terrain_tile(Vector2i(x, y), 0, wall)
		
		# Place entrance and exit
		place_entrance_and_exit()
		
		# Initialize walkers
		walkers.clear()
		walker_directions.clear()
		
		# Start walkers from entrance
		for i in range(walker_count):
			var start_pos = entrance_positions[rng.randi() % entrance_positions.size()]
			walkers.append(start_pos)
			walker_directions.append(get_random_direction())
		
		# Run walkers
		for step in range(walker_steps):
			update_walkers()
		
		# Ensure borders are walls except for entrance and exit
		for x in range(room_width):
			if not entrance_positions.has(Vector2i(x, 0)) and not exit_positions.has(Vector2i(x, 0)):
				place_terrain_tile(Vector2i(x, 0), 0, wall)
			if not entrance_positions.has(Vector2i(x, room_height - 1)) and not exit_positions.has(Vector2i(x, room_height - 1)):
				place_terrain_tile(Vector2i(x, room_height - 1), 0, wall)
		for y in range(room_height):
			if not entrance_positions.has(Vector2i(0, y)) and not exit_positions.has(Vector2i(0, y)):
				place_terrain_tile(Vector2i(0, y), 0, wall)
			if not entrance_positions.has(Vector2i(room_width - 1, y)) and not exit_positions.has(Vector2i(room_width - 1, y)):
				place_terrain_tile(Vector2i(room_width - 1, y), 0, wall)
		
		# Check if entrance and exit are connected
		valid_room = check_connectivity()
		
		if not valid_room:
			print("Room generation attempt ", attempts, " failed - regenerating...")
			object_layer.clear()
	
	# Clean up isolated walls
	cleanup_isolated_walls()
	
	# Place player near entrance
	place_player_near_entrance()

func place_entrance_and_exit() -> void:
	entrance_positions.clear()
	exit_positions.clear()
	
	# Randomly choose which wall to place entrance and exit
	var entrance_wall = rng.randi() % 4  # 0: top, 1: right, 2: bottom, 3: left
	var exit_wall = (entrance_wall + 2) % 4  # Opposite wall
	
	# Place entrance
	var entrance_start = get_wall_position(entrance_wall)
	entrance_positions.append(entrance_start)
	entrance_positions.append(entrance_start + get_wall_direction(entrance_wall))
	place_terrain_tile(entrance_start, 0, floor)
	place_terrain_tile(entrance_start + get_wall_direction(entrance_wall), 0, floor)
	# Place entrance doors
	place_door(entrance_start)
	place_door(entrance_start + get_wall_direction(entrance_wall))
	
	# Place exit
	var exit_start = get_wall_position(exit_wall)
	exit_positions.append(exit_start)
	exit_positions.append(exit_start + get_wall_direction(exit_wall))
	place_terrain_tile(exit_start, 0, floor)
	place_terrain_tile(exit_start + get_wall_direction(exit_wall), 0, floor)
	# Place exit doors
	place_door(exit_start)
	place_door(exit_start + get_wall_direction(exit_wall))

func get_wall_position(wall_index: int) -> Vector2i:
	match wall_index:
		0:  # Top wall
			var x = rng.randi_range(1, room_width - 3)
			return Vector2i(x, 0)
		1:  # Right wall
			var y = rng.randi_range(1, room_height - 3)
			return Vector2i(room_width - 1, y)
		2:  # Bottom wall
			var x = rng.randi_range(1, room_width - 3)
			return Vector2i(x, room_height - 1)
		3:  # Left wall
			var y = rng.randi_range(1, room_height - 3)
			return Vector2i(0, y)
	return Vector2i.ZERO

func get_wall_direction(wall_index: int) -> Vector2i:
	match wall_index:
		0, 2:  # Top or bottom wall
			return Vector2i(1, 0)
		1, 3:  # Right or left wall
			return Vector2i(0, 1)
	return Vector2i.ZERO

func get_random_direction() -> Vector2i:
	var directions = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]
	return directions[rng.randi() % directions.size()]

func update_walkers() -> void:
	for i in range(walker_count):
		# Maybe change direction
		if rng.randf() < walker_chance_to_change_direction:
			walker_directions[i] = get_random_direction()
		
		# Move walker
		var new_pos = walkers[i] + walker_directions[i]
		
		# Keep walker in bounds
		if is_in_bounds(new_pos):
			walkers[i] = new_pos
			place_terrain_tile(new_pos, 0, floor)
			
			# Place floor tiles around the walker for wider paths
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					var surrounding_pos = new_pos + Vector2i(dx, dy)
					if is_in_bounds(surrounding_pos):
						place_terrain_tile(surrounding_pos, 0, floor)
			
			# Occasionally try to move towards exit
			if rng.randf() < 0.1:  # 10% chance to move towards exit
				var exit_pos = exit_positions[0]
				var direction_to_exit = (exit_pos - new_pos).sign()
				if direction_to_exit != Vector2i.ZERO:
					walker_directions[i] = direction_to_exit

func is_wall_at(pos: Vector2i) -> bool:
	var tile_data = room.get_cell_tile_data(pos)
	if not tile_data:
		return false
	var terrain = tile_data.terrain
	return terrain == wall
	
func is_floor_at(pos: Vector2i) -> bool:
	var tile_data = room.get_cell_tile_data(pos)
	if not tile_data:
		return false
	var terrain = tile_data.terrain
	return terrain == floor
	
func is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < room_width and pos.y >= 0 and pos.y < room_height

func remove_terrain_tile(pos: Vector2i):
	room.set_cells_terrain_connect(
		[pos],
		0,
		-1,
		false
	)
	pass

func place_terrain_tile(pos: Vector2i, terrain_set_id: int, terrain_id: int) -> void:
	room.set_cells_terrain_connect(
		[pos],
		terrain_set_id,
		terrain_id,
		true
	)

func check_connectivity() -> bool:
	var visited = {}
	var queue = []
	
	# Start flood fill from entrance
	for pos in entrance_positions:
		queue.append(pos)
		visited[pos] = true
	
	# Flood fill
	while queue.size() > 0:
		var current = queue.pop_front()
		
		# Check if we reached the exit
		if exit_positions.has(current):
			return true
		
		# Check adjacent tiles
		var directions = [
			Vector2i(1, 0),
			Vector2i(-1, 0),
			Vector2i(0, 1),
			Vector2i(0, -1)
		]
		
		for dir in directions:
			var next_pos = current + dir
			if is_in_bounds(next_pos) and is_floor_at(next_pos) and not visited.has(next_pos):
				queue.append(next_pos)
				visited[next_pos] = true
	
	return false

func cleanup_isolated_walls() -> void:
	var walls_to_remove = []
	
	# Check each tile in the room
	for x in range(room_width):
		for y in range(room_height):
			var pos = Vector2i(x, y)
			
			# Skip entrance and exit positions
			if entrance_positions.has(pos) or exit_positions.has(pos):
				continue
			
			# If it's a wall, check surrounding tiles
			if is_wall_at(pos):
				var has_adjacent_floor = false
				
				# Check all 8 surrounding tiles
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						if dx == 0 and dy == 0:
							continue
						
						var check_pos = pos + Vector2i(dx, dy)
						if is_in_bounds(check_pos) and is_floor_at(check_pos):
							has_adjacent_floor = true
							break
				
				# If no adjacent floors, mark for removal
				if not has_adjacent_floor:
					walls_to_remove.append(pos)
	
	# Remove all isolated walls
	for pos in walls_to_remove:
		remove_terrain_tile(pos)

func place_player_near_entrance() -> void:
	# Get the direction from the entrance to the center of the room
	var entrance_center = (entrance_positions[0] + entrance_positions[1]) / 2
	var room_center = Vector2i(room_width / 2, room_height / 2)
	var direction = (room_center - entrance_center).sign()
	
	# Try to place player one tile inside from the entrance
	var player_pos = entrance_center + direction
	
	# If that position is a wall, try adjacent positions
	if is_wall_at(player_pos):
		var directions = [
			Vector2i(1, 0),
			Vector2i(-1, 0),
			Vector2i(0, 1),
			Vector2i(0, -1)
		]
		for dir in directions:
			var test_pos = entrance_center + dir
			if is_in_bounds(test_pos) and is_floor_at(test_pos):
				player_pos = test_pos
				break
	
	place_player(player_pos)
