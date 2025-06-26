extends ProceduralGenerator
class_name WalkerGenerator

@export var number_of_walkers: int = 1
@export var walker_steps: int = 100

@export var minimum_room_width: int = 20
@export var maximum_room_width: int = 100
@export var minimum_room_height: int = 20
@export var maximum_room_height: int = 100

var room_width: int
var room_height: int
var rng: RandomNumberGenerator

func generate(_rng: RandomNumberGenerator) -> void:
	rng = _rng
	room_height = rng.randi_range(minimum_room_height, maximum_room_height)
	room_width = rng.randi_range(minimum_room_width, maximum_room_width)
	clear()
	fill_the_room_with_walls()

	var threads = []
	var results = []
	var start_pos = Vector2i(room_width / 2, room_height / 2)

	# Start threads
	for n in range(number_of_walkers):
		var thread = Thread.new()
		var args = {
			"start_pos": start_pos,
			"room_width": room_width,
			"room_height": room_height,
			"steps": walker_steps,
			"seed": rng.randi()
		}
		thread.start(walker_thread_func.bind(args))
		threads.append(thread)

	# Wait for threads and collect results
	for thread in threads:
		var floor_positions_result = thread.wait_to_finish()
		results.append(floor_positions_result)

	# Merge all floor positions
	for floor_positions_result in results:
		for pos in floor_positions_result:
			if not floor_positions.has(pos):
				floor_positions.append(pos)

	place_entrance()
	place_exit()

### Fills in the wall positions to make up the whole room
func fill_the_room_with_walls() -> void:
	for x in range(room_width):
		for y in range(room_height):
			wall_positions.append(Vector2i(x, y))

### Starts a new walker at the center of the room
func run_walker() -> void:
	# Create walker at center of room
	var start_pos = Vector2i(room_width / 2, room_height / 2)
	var walker = Walker.new(start_pos, room_width, room_height, rng.randi())
	
	# Run walker
	for step in range(walker_steps):
		walker.update()
		# Add walker's floor positions to our floor positions
		for pos in walker.floor_positions:
			if not floor_positions.has(pos):
				floor_positions.append(pos)

## Places the entrance on the edge of the map
func place_entrance() -> void:
	var max_attempts = 1000  # Prevent infinite loops
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
	var max_attempts = 1000  # Prevent infinite loops
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

## Checks if a position is in the bounds of the room
func is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < room_width and pos.y >= 0 and pos.y < room_height

func walker_thread_func(args):
	var start_pos = args["start_pos"]
	var room_width = args["room_width"]
	var room_height = args["room_height"]
	var steps = args["steps"]
	var seed = args["seed"]
	
	var walker = Walker.new(start_pos, room_width, room_height, seed)
	for i in range(steps):
		walker.update()
	return walker.floor_positions
