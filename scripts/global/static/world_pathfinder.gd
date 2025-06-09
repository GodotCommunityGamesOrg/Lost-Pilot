class_name WorldPathfinder
# --- Public Properties ---
static var pathfinder: AStarGrid2D ## Reference to the AStarGrid2D for pathfinding.
static var map: map_generator
static var objects: Dictionary[Vector2i, InteractableObject]

# --- Custom Methods  ---
## return A [PackedVector2Array] containing a path as a series of points from the start to the end position.
## [param start]: A [Vector2] representing the starting position in the world.
## [param end]: A [Vector2] representing the target position in the world.
## [param tf]: A [bool] (optional, defaults to true) that toggles whether the algorithm can retun partial paths.[br]
static func calculate_path(start: Vector2, end: Vector2, tf: bool = false) -> PackedVector2Array:
	return pathfinder.get_id_path(
		map.local_to_map(start), 
		map.local_to_map(end),
		tf
	)

static func reset():
	pathfinder = AStarGrid2D.new()
	map = map_generator.new()
	
static func position_to_object(position: Vector2i):
	if objects.has(position):
		return objects[position]
	else:
		return null
