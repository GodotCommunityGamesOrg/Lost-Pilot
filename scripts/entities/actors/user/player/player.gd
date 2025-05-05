extends UserActor
class_name PlayerNode

@export var speed: float = 200.0
@export var cam: Camera2D
@export var camcon: Node2D
var current_cell: Vector2i
var path: Array = []
var highlight_path: PackedVector2Array = []
var action: bool = false:
	set(value):
		action = value
		queue_redraw()
var highlight_pos: Vector2i
var all_actions: Array[Action] = []
var used: bool = false
signal moved(position: Vector2i)
var select: CallableList = CallableList.new()
var selection_position: Vector2
func _ready() -> void:
	super()
	moved.emit()
	_setup_camera_limits()
	get_tree().get_root().size_changed.connect(_cam_resize)
	WorldTurnBase.on = true

func _unhandled_input(event: InputEvent) -> void:
	super(event)
	if WorldTurnBase.state.state == turn_state and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = WorldPathfinder.map.local_to_map(get_global_mouse_position())
		await select.emit(mouse_pos)
		if UtilityFunctions.in_map(get_global_mouse_position()) and not WorldPathfinder.pathfinder.is_point_solid(mouse_pos):
			if highlight_path.size() - 1 <= _actions and not action:
				if !used:
					camcon.global_position = WorldPathfinder.map.map_to_local(mouse_pos)
					all_actions.append(Move.new(mouse_pos, self))
					get_tree().get_root().set_input_as_handled()
					_actions -= (highlight_path.size() - 1)
					highlight_path.clear()

func _process(delta: float) -> void:
	super(delta)
	if WorldTurnBase.state.state != turn_state: return

	if UtilityFunctions.in_map(get_global_mouse_position()) and not action:
		selection_position = WorldPathfinder.map.map_to_local(UtilityFunctions.find_last_occurrence(all_actions, Move).destination) if all_actions.size() > 0 and UtilityFunctions.find_last_occurrence(all_actions, Move) != null else position
		highlight_path = WorldPathfinder.calculate_path(
			selection_position, 
			get_global_mouse_position()
		)
		queue_redraw()

	if Input.is_action_just_pressed("ui_accept") and not action:
		play()

func _draw() -> void:
	if WorldTurnBase.state.state != turn_state or action:
		return
	
	var prev: Vector2 = position
	for move_action in all_actions:
		if move_action is Move:
			for pos in WorldPathfinder.calculate_path(prev, WorldPathfinder.map.map_to_local(move_action.destination)):
				draw_circle(WorldPathfinder.map.map_to_local(pos) - position, 20, Color(0.7, 0.7, 0.7, 1))
			prev = WorldPathfinder.map.map_to_local(move_action.destination)

	for pos in highlight_path:
		if pos != highlight_path[0]:
			draw_circle(WorldPathfinder.map.map_to_local(pos) - position, 20, Color(1, 1, 0, 1) if (highlight_path.find(pos) <= _actions) else Color(1, 0, 0, 1))

	if highlight_path.size() > 0:
		draw_rect(Rect2(WorldPathfinder.map.map_to_local(highlight_path[highlight_path.size() - 1]) - (Vector2.ONE * 62.5) - position, Vector2(128, 128)), Color(1, 1, 0, 1) if (highlight_path.size() - 1 <= _actions) else Color(1, 0, 0, 1), false, 10)

func play():
	action = true
	camcon.position = Vector2.ZERO
	for current_action in all_actions:
		if current_action is Move:
			await current_action.move(0.05)
		elif current_action is Press:
			await current_action.execute()
	all_actions.clear()
	action = false
	WorldTurnBase.state.remove_actor(self)

func _setup_camera_limits():
	var map_rect = WorldPathfinder.map.get_used_rect()
	cam.limit_left = map_rect.position.x * 128
	cam.limit_top = map_rect.position.y * 128
	cam.limit_right = (map_rect.position.x + map_rect.size.x) * 128
	cam.limit_bottom = (map_rect.position.y + map_rect.size.y) * 128

func _cam_resize():
	var viewport_size = get_viewport().size
	cam.zoom = (Vector2.ONE * 0.8) * (viewport_size.x / UserInterface._base_size.x + viewport_size.y / UserInterface._base_size.y) / 2.0

class Action:
	var used_actions: int = 0

class Move extends Action:
	var destination: Vector2i = Vector2i.ZERO
	var path: Array = []
	var path_index: int = 0
	var player: PlayerNode
	
	func _init(dest, ply):
		destination = dest
		player = ply

	func move(delta: float) -> void:
		while true:
			await GameManager.get_tree().process_frame
			if path.is_empty():
				path = WorldPathfinder.calculate_path(player.position, WorldPathfinder.map.map_to_local(destination))
				path_index = 0
			
			if path.size() > path_index:
				var target_position = WorldPathfinder.map.map_to_local(path[path_index])
				player.position = player.position.move_toward(target_position, delta * player.speed)

				if player.position.distance_to(target_position) < player.speed * delta:
					player.current_cell = WorldPathfinder.map.local_to_map(player.position)
					path_index += 1
					player.moved.emit(player.current_cell)
			else: 
				player.position = WorldPathfinder.map.map_to_local(destination)
				return

	func is_completed() -> bool:
		return path.size() == 0 or path_index >= path.size()

class Press extends Action:
	var caller: Callable
	func _init(_caller:Callable) -> void:
		caller = Callable(_caller)
	func execute():
		await caller.call()
