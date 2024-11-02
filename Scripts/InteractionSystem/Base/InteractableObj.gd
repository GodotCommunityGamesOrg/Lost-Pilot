extends Node2D
class_name InteractableObj

# Used for checking if this interactable obj is blocking the grid cell.
@export var is_blocking: bool = true
@export var priority: int = 0
@export var GUI: Control
@export var detection_radius:int
func _ready() -> void:
	if global.pathfinder and global.map:
		global.pathfinder.set_point_solid(global.map.local_to_map(position), is_blocking)
	else:
		push_error("Pathfinder or map not initialized.")

# Override function
func interact() -> void:
	# Placeholder for interactable behavior
	pass

func _process(delta: float) -> void:
	if (global.player.position - position).length() < detection_radius*global.map.tile_set.tile_size.x:
		if global.player.selected_object and global.player.selected_object != self:
			if global.player.selected_object.priority >= priority:
				if GUI.visible:
					GUI.visible = false
				return

		GUI.grab_focus()
		global.player.selected_object = self
		if not GUI.visible:
			GUI.visible = true
	else:
		if global.player.selected_object == self:
			global.player.selected_object = null
		if GUI.visible:
			GUI.visible = false
