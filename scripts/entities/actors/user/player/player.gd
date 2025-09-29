extends Actor
class_name PlayerNode

## PlayerNode class:
## Represents the controllable player in the game world. Handles input, movement, pathfinding, 
## camera behavior, and executing interaction logic in a turn-based system.

# --- Exported Properties ---

## Movement speed of the player.
@export var speed: float = 200.0

## The player's camera node.
@export var cam: Camera2D

## The camera container that controls camera offset for UI feedback.
@export var camcon: Node2D

# --- Public Properties ---

## The cell the player is currently occupying.
var current_cell: Vector2i

## The current path the player is following.
var path: Array = []

## Highlighted path displayed during selection.
var highlight_path: PackedVector2Array = []

## Whether the player is currently performing an action.
var action: bool = false:
	set(value):
		action = value
		queue_redraw()

## Highlighted target position.
var highlight_pos: Vector2i

## All queued actions for the player during their turn.
var all_actions: Array[Action] = []

## Whether the player has already used their move this turn.
var used: bool = false

## Signal emitted when the player has moved to a new position.
signal moved(position: Vector2i)

## Position selected by the player with the mouse.
var selection_position: Vector2

# --- Built-in Callbacks ---

## Called when the node enters the scene tree.
func _ready() -> void:
	super()
	moved.emit()
	_setup_camera_limits()
	WorldTurnBase.on = true

## Handles unhandled input during the player's turn for mouse-based interaction.
func _unhandled_input(event: InputEvent) -> void:
	super(event)
	if WorldTurnBase.state.state != turn_state:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = WorldPathfinder.map.local_to_map(get_global_mouse_position())
		var object = WorldPathfinder.position_to_object(mouse_pos)

		if object != null and object.interactable(self):
			all_actions = await object.interact(self)
		elif UtilityFunctions.in_map(get_global_mouse_position()) \
			and not WorldPathfinder.pathfinder.is_point_solid(mouse_pos) \
			and WorldPathfinder.calculate_path(position, get_global_mouse_position()) \
			and mouse_pos != map_position:
			
			if highlight_path.size() - 1 <= distence and not action:
				if !used:
					camcon.global_position = WorldPathfinder.map.map_to_local(mouse_pos)
					all_actions.append(Move.new(mouse_pos, self))
					get_tree().get_root().set_input_as_handled()
					highlight_path.clear()

		if all_actions.size() > 0:
			play()

## Called every frame to update highlight paths and handle input actions.
func _process(delta: float) -> void:
	super(delta)
	if WorldTurnBase.state.state != turn_state:
		return

	if UtilityFunctions.in_map(get_global_mouse_position()) and not action:
		var last_move := UtilityFunctions.find_last_occurrence(all_actions, Move)
		selection_position = WorldPathfinder.map.map_to_local(last_move.destination) if last_move else position

		highlight_path = WorldPathfinder.calculate_path(selection_position, get_global_mouse_position())
		queue_redraw()

	if Input.is_action_just_pressed("ui_accept") and not action:
		play()

## Draws the planned and highlighted paths for the player on the screen.
func _draw() -> void:
	if WorldTurnBase.state.state != turn_state or action:
		return
	
	var prev: Vector2 = position
	for move_action in all_actions:
		if move_action is Move:
			for pos in WorldPathfinder.calculate_path(prev, WorldPathfinder.map.map_to_local(move_action.destination)):
				draw_circle(WorldPathfinder.map.map_to_local(pos) - position, 10, Color(0.7, 0.7, 0.7, 1))
			prev = WorldPathfinder.map.map_to_local(move_action.destination)

	for pos in highlight_path:
		if pos != highlight_path[0]:
			var color := Color(1, 1, 0, 1) if highlight_path.find(pos) <= distence else Color(1, 0, 0, 1)
			draw_circle(WorldPathfinder.map.map_to_local(pos) - position, 10, color)

	if highlight_path.size() > 0:
		var last := highlight_path[highlight_path.size() - 1]
		var rect_color := Color(1, 1, 0, 1) if (highlight_path.size() - 1 <= distence) else Color(1, 0, 0, 1)
		draw_rect(Rect2(WorldPathfinder.map.map_to_local(last) - Vector2.ONE * 32 - position, Vector2(64, 64)), rect_color, false, 5)

# --- Public Methods ---

## Executes all actions queued by the player in sequence.
func play():
	action = true
	camcon.position = Vector2.ZERO
	for current_action in all_actions:
		await current_action.execute()
	all_actions.clear()
	action = false
	WorldTurnBase.state.remove_actor(self)

# --- Private Methods ---

## Sets camera movement bounds to match the map area.
func _setup_camera_limits():
	var map_rect = WorldPathfinder.map.get_used_rect()
	cam.limit_left = map_rect.position.x * 128
	cam.limit_top = map_rect.position.y * 128
	cam.limit_right = (map_rect.position.x + map_rect.size.x) * 128
	cam.limit_bottom = (map_rect.position.y + map_rect.size.y) * 128

# --- Action Classes ---

## Abstract base class for all player actions.
class Action:
	var used_actions: int = 0
	func execute():
		pass

## Represents a movement action for the player.
class Move extends Action:
	var destination: Vector2i = Vector2i.ZERO
	var path: Array = []
	var path_index: int = 0
	var player: PlayerNode

	func _init(dest, ply):
		destination = dest
		player = ply

	func execute() -> void:
		while true:
			await GameManager.get_tree().process_frame
			if path.is_empty():
				path = WorldPathfinder.calculate_path(player.position, WorldPathfinder.map.map_to_local(destination), false)
				path_index = 0

			if path.size() > path_index:
				var target_position = WorldPathfinder.map.map_to_local(path[path_index])
				player.position = player.position.move_toward(target_position, player.get_process_delta_time() * player.speed)

				if player.position.distance_to(target_position) < player.speed * player.get_process_delta_time():
					player.current_cell = WorldPathfinder.map.local_to_map(player.position)
					path_index += 1
					player.moved.emit(player.current_cell)
			else:
				if path_index > 0:
					player.position = WorldPathfinder.map.map_to_local(destination)
					player.map_position = path[path_index - 1]
				return

	func is_completed() -> bool:
		return path.size() == 0 or path_index >= path.size()

## Represents a callable action (e.g., pressing a button, toggling a door).
class Press extends Action:
	var caller: Callable

	func _init(_caller: Callable) -> void:
		caller = Callable(_caller)

	func execute():
		await caller.call()
