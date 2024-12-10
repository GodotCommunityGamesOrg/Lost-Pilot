extends InteractableObject

# --- Exported Properties ---
@export var anim:AnimatedSprite2D 

# --- Built-in Callbacks ---
func _ready() -> void:
	super()
	gui_focus.closed.connect(end_interact)

func end_interact() -> void:
	super()
	if WorldPathfinder.map.local_to_map(WorldPathfinder.players[0].position) == map_position:
		print("ERR-1")
		gui_focus.close()
		return
	match gui_focus.close():
		-1:
			return
		0:
			if !WorldPathfinder.pathfinder.is_point_solid(map_position):
				WorldPathfinder.pathfinder.set_point_solid(map_position, true)
				anim.play_backwards("open")
				gui_interaction_priority = 2
		1:
			if WorldPathfinder.pathfinder.is_point_solid(map_position):
				WorldPathfinder.pathfinder.set_point_solid(map_position, false)
				anim.play("open")
				gui_interaction_priority = 1
