extends TileMapLayer
class_name map_generator
## builds pathfinder for tilemap
# --- Exported Properties ---
func _ready() -> void:
	WorldTurnBase.state.actors = []
	WorldPathfinder.map = self
	WorldPathfinder.pathfinder = AStarGrid2D.new()
	WorldPathfinder.pathfinder.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	WorldPathfinder.pathfinder.cell_size = Vector2.ONE * 128
	WorldPathfinder.pathfinder.region = get_used_rect()
	WorldPathfinder.pathfinder.update()
	for pos in get_used_cells():
		if get_cell_tile_data(pos).get_custom_data("Col") == 0:
			WorldPathfinder.pathfinder.set_point_solid(pos)
			
	WorldPathfinder.free_pathfinder = AStarGrid2D.new()
	WorldPathfinder.free_pathfinder.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	WorldPathfinder.free_pathfinder.cell_size = Vector2.ONE * 128
	WorldPathfinder.free_pathfinder.region = get_used_rect()
	WorldPathfinder.free_pathfinder.update()
	for pos in get_used_cells():
		if get_cell_tile_data(pos).get_custom_data("Col") == 0:
			WorldPathfinder.free_pathfinder.set_point_solid(pos)
