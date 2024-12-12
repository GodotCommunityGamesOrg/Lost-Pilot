extends TileMapLayer
class_name map_generator
## builds pathfinder for tilemap
# --- Exported Properties ---
func _ready() -> void:
	WorldTurnBase.state.actors = []
	WorldPathfinder.pathfinder = AStarGrid2D.new()
	WorldPathfinder.map = self
	WorldPathfinder.pathfinder.region = get_used_rect()
	WorldPathfinder.pathfinder.cell_size = Vector2.ONE * 128
	WorldPathfinder.pathfinder.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	WorldPathfinder.pathfinder.update()
	for pos in get_used_cells():
		if get_cell_tile_data(pos).get_custom_data("Col") == 0:
			WorldPathfinder.pathfinder.set_point_solid(pos)
