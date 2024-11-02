extends Control
class_name InteractableObject

## Represents an interactive object within the game world, designed for objects that 
## the player can interact with when within a certain range. This class manages interaction 
## priorities, GUI visibility, and detection radius, allowing for flexible and layered 
## interactions with multiple objects.

# --- Exported Properties ---
@export var is_blocking: bool = true           ## Determines if this object blocks grid cell movement.
@export var hover_texture: Texture             ## Texture shown when the object is hovered over.
@export_group("GUI", "gui")
@export var gui_interaction_priority: int = 0  ## Priority level for object selection in the GUI.
@export var gui_detection_radius: int = 2      ## Radius within which the player can interact with the object.
@export var gui_container: Control             ## Container for GUI elements associated with the object.
@export var gui_focus: BaseButton              ## Primary focusable GUI element for the object.

# --- Public Properties ---
@onready var map_position = global.map.local_to_map(position)  ## Position of the object on the map grid.

# --- Private Properties ---
var in_object: bool = false                    ## Tracks if the player is within the object’s space.
var disabled: bool = false                     ## Disables interaction when true.
var hover: bool = false                        ## Tracks if the object is being hovered over.

# --- Signals ---
signal interacting(active: bool)               ## Emitted when interaction starts or ends.

# --- Built-in Callbacks ---

# Handles right-click input to trigger interaction with the object.
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			interact()
			get_tree().get_root().set_input_as_handled()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and has_focus():
		interact()

# Initializes the object settings and connects signals.
func _ready() -> void:
	focus_mode = FocusMode.FOCUS_CLICK
	mouse_entered.connect(func(): hover = true; queue_redraw())
	mouse_exited.connect(func(): hover = false; queue_redraw())

	if global.pathfinder and global.map:
		global.pathfinder.set_point_solid(global.map.local_to_map(position), is_blocking)
	else:
		push_error("Pathfinder or map not initialized.")
	
	global.player.moved.connect(_player_moved)

func _player_moved(player_position: Vector2i) -> void:
	if player_position == map_position:
		in_object = true
	else:
		in_object = false
	
	var is_within_radius := (player_position - map_position).length() < gui_detection_radius
	var should_hide_gui := global.player.selected_object and global.player.selected_object != self and global.player.selected_object.gui_interaction_priority >= gui_interaction_priority
	
	if is_within_radius:
		if should_hide_gui:
			disabled = true
			return
		grab_focus()
		global.player.selected_object = self
		disabled = false
	else:
		if global.player.selected_object == self:
			global.player.selected_object = null
		disabled = true

# Draws the object with hover and focus effects.
func _draw() -> void:
	if hover:
		draw_texture(hover_texture, Vector2.ZERO)
	elif has_focus():
		draw_texture(hover_texture, Vector2.ZERO, Color(0.5, 0.5, 0.5))

# --- Custom Methods ---

## Starts interaction with the object, making the GUI visible and focusing the object.
func interact() -> void:
	if global.map.local_to_map(global.player.position) == map_position:
		return
	if disabled:
		return
	interacting.emit(true)
	gui_container.visible = true
	gui_focus.grab_focus()
	global.player.action = true

## Ends the interaction, hiding the GUI and releasing focus.
func end_interact() -> void:
	if disabled:
		return
	interacting.emit(false)
	gui_container.visible = false
	grab_focus()
	global.player.action = false
