extends Node2D
class_name PlayerNode
## Represents the player character in the game world, handling movement, pathfinding,
## and interactions with objects. The class manages the player's action turns, speed, 
## and cell-based positioning within the game grid.

# --- Exported Properties ---
@export var Actions: int = 2                ## Number of actions the player can take in a single turn.
@export var speed: float = 200.0            ## Movement speed of the player.

# --- Public Properties ---
var current_cell: Vector2i                  ## Current cell position of the player in the grid.
var target_cell: Vector2                    ## Target cell position for movement.
var path: Array = []                        ## Array to hold the calculated path for movement.
var path_index: int = 0                     ## Current index in the path array.
var highlight_path: PackedVector2Array = [] ## Array to hold the positions to highlight on the path.
var selected_object: InteractableObject     ## Reference to the interactable object currently selected by the player.
var action: bool = false:                   ## Flag indicating if the player is currently performing an action.
	set(value):
		action = value
		queue_redraw()

# --- Signals ---
signal moved(position: Vector2i)            ## Signal emitted when the player’s position is updated.

# --- Built-in Callbacks ---
# Called when the node is added to the scene. Sets up camera limits and connects the resize signal.
func _ready() -> void:
	
	global.player = self
	$Camera2D.limit_left = global.map.get_used_rect().position.x * 128
	$Camera2D.limit_top = global.map.get_used_rect().position.y * 128
	$Camera2D.limit_right = (global.map.get_used_rect().position.x + global.map.get_used_rect().size.x) * 128
	$Camera2D.limit_bottom = (global.map.get_used_rect().position.y + global.map.get_used_rect().size.y) * 128
	get_tree().get_root().size_changed.connect(_cam_resize)

# Processes unhandled input events, allowing the player to set a movement path with the left mouse button.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = global.map.local_to_map(get_global_mouse_position())
		if UtilityFunctions.in_map(get_global_mouse_position()) and !global.pathfinder.is_point_solid(mouse_pos):
			if highlight_path.size() - 1 <= Actions and action == false:
				path = highlight_path
				action = true
				get_tree().get_root().set_input_as_handled()

# Called every frame. Updates path highlights and moves the player along the defined path.
func _process(delta: float) -> void:
	if UtilityFunctions.in_map(get_global_mouse_position()) and !action:
		highlight_path = global.calculate_path(position, get_global_mouse_position())
	
	if path.size() > path_index:
		var target_position = global.map.map_to_local(path[path_index])
		global_position = global_position.move_toward(target_position, delta * speed)
		if position.distance_to(target_position) < speed * delta:
			current_cell = global.map.local_to_map(position)
			path_index += 1
			moved.emit(current_cell)
	elif path.size() != 0:
		position = global.map.map_to_local(path[path.size() - 1])
		path.clear()
		path_index = 0
		action = false
	else:
		if highlight_path.size() > 0:
			queue_redraw()

# Handles visual feedback for the player's path. Highlights the path to the target cell.
func _draw() -> void:
	if highlight_path.size() > 0 and !action:
		for pos in highlight_path:
			var draw_color = Color(1, 1, 0, 1) if (highlight_path.find(pos) <= Actions) else Color(1, 0, 0, 1)
			draw_circle(global.map.map_to_local(pos) - position, 20, draw_color)
		
		var final_color = Color(1, 1, 0, 1) if (highlight_path.size() - 1 <= Actions) else Color(1, 0, 0, 1)
		draw_rect(Rect2(global.map.map_to_local(highlight_path[highlight_path.size() - 1]) - (Vector2.ONE * 62.5) - position, Vector2(128, 128)), final_color, false, 10)

# --- Custom Methods ---
## Adjusts the camera zoom based on the viewport size.
func _cam_resize():
	
	var viewport_size = get_viewport().size
	print(viewport_size, UserInterface._base_size, Vector2.ONE * (viewport_size.x / UserInterface._base_size.x + viewport_size.y / UserInterface._base_size.y) / 2.0)
	$Camera2D.zoom = (Vector2.ONE * 0.8) * (viewport_size.x / UserInterface._base_size.x + viewport_size.y / UserInterface._base_size.y) / 2.0
