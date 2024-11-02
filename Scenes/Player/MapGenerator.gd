extends TileMapLayer
## builds pathfinder for tilemap
# --- Exported Properties ---
func _ready() -> void:
	global.pathfinder = AStarGrid2D.new()
	global.map = self
	global.pathfinder.region = global.map.get_used_rect()
	global.pathfinder.cell_size = Vector2.ONE * 128
	global.pathfinder.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	global.pathfinder.update()
	for pos in get_used_cells():
		if get_cell_tile_data(pos).get_custom_data("Col") == 0:
			global.pathfinder.set_point_solid(pos)
