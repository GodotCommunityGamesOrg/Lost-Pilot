extends TileMapLayer
class_name map_generator
## builds pathfinder for tilemap
# --- Exported Properties ---
func _ready() -> void:
	init_pathfinding()
	
func init_pathfinding() -> void:
	WorldTurnBase.state.actors = []
	WorldPathfinder.map = self
	WorldPathfinder.pathfinder = AStarGrid2D.new()
	WorldPathfinder.pathfinder.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	WorldPathfinder.pathfinder.cell_size = Vector2.ONE * 128
	var _rect := get_used_rect()
	_rect.size += Vector2i.ONE * 2
	_rect.position -= Vector2i.ONE 
	WorldPathfinder.pathfinder.region = _rect
	WorldPathfinder.pathfinder.update()
	for pos in get_used_cells():
		if get_cell_tile_data(pos).get_custom_data("Col") == 0:
			WorldPathfinder.pathfinder.set_point_solid(pos)
