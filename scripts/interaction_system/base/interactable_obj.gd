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
var _li: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2(-1, 0),
	Vector2(0, 1),
	Vector2(0, -1),
]
# --- Signals ---

# --- Built-in Callbacks ---
# Initializes the object settings and connects signals.
func _ready() -> void:
	WorldPathfinder.objects[map_position] = self
	if WorldPathfinder.pathfinder:
		WorldPathfinder.pathfinder.set_point_solid(WorldPathfinder.map.local_to_map(position), is_blocking)
	else:
		push_error("Pathfinder or map not initialized.")
	
func interactable(player: PlayerNode):
	if player.map_position != map_position:
		if _return_side(player) != Vector2i.ZERO:
			return true
	return false

# --- Custom Methods ---
## Starts interaction with the object, making the GUI visible and focusing the object.
func interact(player: PlayerNode, _choice:int = -10, before_act: Array[Vector2i] = []) -> Array[PlayerNode.Action]:
	player.action = true
	before_act.append(_return_side(player))
	return [PlayerNode.Move.new(before_act[0]+map_position, player)]

func _return_side(player: PlayerNode):
	var dict: Dictionary[int, Vector2i] = {}
	for i in _li:
		if player.map_position == map_position+i:
			return i
		dict[WorldPathfinder.calculate_path(player.position, WorldPathfinder.map.map_to_local(map_position+i), false).size()] = i
	var max_key = INF

	for key in dict.keys():
		if key < max_key and key != 0:
			max_key = key
	if max_key != 0 and max_key <= player.distence:
		return dict[max_key]
	return Vector2i.ZERO
