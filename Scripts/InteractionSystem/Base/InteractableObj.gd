extends Button
class_name InteractableObject
## Represents an interactive object within the game world, designed for objects that 
## the player can interact with when within a certain range. This class manages interaction 
## priorities, GUI visibility, and detection radius, allowing for flexible and layered 
## interactions with multiple objects.

# --- Exported Properties ---
@export var is_blocking: bool = true            ## Determines if this object blocks grid cell movement

@export_group("GUI", "gui")
@export var gui_interaction_priority: int = 0   ## Priority level for object selection
@export var gui_detection_radius: int = 2       ## Radius within which player can interact
@export var gui_container: Control
@export var gui_focus: BaseButton

@onready var map_position = global.map.local_to_map(position)

# --- Signals ---
signal interacting(TF:bool)

# --- Built-in Callbacks ---
func _ready() -> void:
	pressed.connect(interact)
	if global.pathfinder and global.map:
		global.pathfinder.set_point_solid(global.map.local_to_map(position), is_blocking)
	else:
		push_error("Pathfinder or map not initialized.")
	global.player.moved.connect(_player_moved)

func _player_moved(player_position:Vector2i):
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

# --- Custom Methods ---
func interact() -> void:
	if disabled:
		return
	interacting.emit(true)
	gui_container.visible = true
	gui_focus.grab_focus()
	global.player.action = true

func end_interact() -> void:
	if disabled:
		return
	interacting.emit(true)
	gui_container.visible = false
	grab_focus()
	global.player.action = false
