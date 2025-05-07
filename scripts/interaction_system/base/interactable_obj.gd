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


# --- Public Properties ---

# --- Private Properties ---

# --- Signals ---

# --- Built-in Callbacks ---
# Initializes the object settings and connects signals.
func _ready() -> void:
	if WorldPathfinder.pathfinder:
		WorldPathfinder.pathfinder.set_point_solid(WorldPathfinder.map.local_to_map(position), is_blocking)
	else:
		push_error("Pathfinder or map not initialized.")
	
func interactable(player: PlayerNode):
	if player.map_pos == map_position:
		var p = WorldPathfinder.calculate_path(position, player.position, true)
		if WorldPathfinder.calculate_path(player.position, WorldPathfinder.map.map_to_local(p[p.size()-2]), false).size() > 0:
			return true

# --- Custom Methods ---
## Starts interaction with the object, making the GUI visible and focusing the object.
func interact(player: PlayerNode) -> void:
	player.action = true
