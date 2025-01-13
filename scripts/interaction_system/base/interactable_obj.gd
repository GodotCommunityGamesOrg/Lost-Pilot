extends Entity
class_name InteractableObject

## Represents an interactive object within the game world, designed for objects that 
## the player can interact with when within a certain range. This class manages interaction 
## priorities, GUI visibility, and detection radius, allowing for flexible and layered 
## interactions with multiple objects.

# --- Exported Properties ---
@export var is_blocking: bool = true           ## Determines if this object blocks grid cell movement.
@export var hover_texture: Texture             ## Texture shown when the object is hovered over.
@export_group("GUI", "gui")
@export var gui_container: Control             ## Container for GUI elements associated with the object.
@export var gui_focus: BaseButton              ## Primary focusable GUI element for the object.

# --- Public Properties ---
@onready var map_position = WorldPathfinder.map.local_to_map(position)  ## Position of the object on the map grid.

# --- Private Properties ---

# --- Signals ---

# --- Built-in Callbacks ---
# Initializes the object settings and connects signals.
func _ready() -> void:
	if WorldPathfinder.pathfinder:
		WorldPathfinder.pathfinder.set_point_solid(WorldPathfinder.map.local_to_map(position), is_blocking)
	else:
		push_error("Pathfinder or map not initialized.")
	
	WorldTurnBase.players[0].select.callables.append(
		func(pos: Vector2i):
			if pos == map_position:
				var p = WorldPathfinder.calculate_free_path(WorldTurnBase.players[0].position, position)
				if WorldPathfinder.calculate_path(WorldTurnBase.players[0].selection_position, WorldPathfinder.map.map_to_local(p[p.size()-2]), false).size() > 0:
					print(WorldPathfinder.calculate_path(WorldTurnBase.players[0].selection_position, WorldPathfinder.map.map_to_local(p[p.size()-2]), false).size())
					interact()
	)

# --- Custom Methods ---
## Starts interaction with the object, making the GUI visible and focusing the object.
func interact() -> void:
	gui_container.visible = true
	WorldTurnBase.players[0].action = true

## Ends the interaction, hiding the GUI and releasing focus.
func end_interact() -> void:
	gui_container.visible = false
	WorldTurnBase.players[0].action = false
