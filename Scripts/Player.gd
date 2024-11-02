extends Node2D

@export var Actions: int = 2
@export var speed: float = 200.0 # Speed of the player
var path = [] # Array to hold the calculated path
var path_index: int = 0 # Current index in the path
var moving: bool = false # Movement flag
var highlight_path: PackedVector2Array

func _ready() -> void:
	global.pathfinder = AStarGrid2D.new()
	global.map = get_parent().get_parent().get_child(0) # Adjust this as needed for clarity
	global.pathfinder.region = global.map.get_used_rect()
	global.pathfinder.cell_size = Vector2.ONE*128
	global.pathfinder.diagonal_mode = 1
	global.pathfinder.update()
	
	# Populate solid points based on tile data
	for I: Vector2i in global.map.get_used_cells():
		if global.map.get_cell_tile_data(I).get_custom_data("Col") == 0:
			global.pathfinder.set_point_solid(I)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var cell_position = global.map.local_to_map(get_global_mouse_position())
			if cell_position in global.map.get_used_cells():
				if global.map.get_cell_tile_data(cell_position).get_custom_data("Col") == 1:
					if highlight_path.size()-1 <= Actions:
						path = global.calculate_path(position, get_global_mouse_position())

func _process(delta: float) -> void:
	if path.size() > path_index:
		var target_position = global.map.map_to_local(path[path_index])
		global_position = global_position.move_toward(target_position, delta * speed)
		
		# Check if the player has reached the target position
		if position.distance_to(target_position) < speed * delta:
			position = target_position
			path_index += 1
	else:
		path.clear()
		path_index = 0
		var cell_position = global.map.local_to_map(get_global_mouse_position())
		if cell_position in global.map.get_used_cells():
			if global.map.get_cell_tile_data(cell_position).get_custom_data("Col") == 1:
				highlight_path = global.calculate_path(position, get_global_mouse_position())
	queue_redraw()

func _draw() -> void:
	if highlight_path.size() > 0:
		for i in highlight_path:
			if highlight_path.find(i) <= Actions:
				draw_circle(global.map.map_to_local(i)-position, 20, Color(1, 1, 0, 1))
			else:
				draw_circle(global.map.map_to_local(i)-position, 20, Color(1, 0, 0, 1))
		if highlight_path.size()-1 <= Actions:
			draw_rect(Rect2(global.map.map_to_local(highlight_path[highlight_path.size()-1])-(Vector2.ONE*62.5)-position, Vector2(128, 128)), Color(1, 1, 0, 1), false, 10)
		else:
			draw_rect(Rect2(global.map.map_to_local(highlight_path[highlight_path.size()-1])-(Vector2.ONE*62.5)-position, Vector2(128, 128)), Color(1, 0, 0, 1), false, 10)
