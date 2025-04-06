extends InteractableObject

# --- Exported Properties ---
@export var anim:AnimatedSprite2D 
var choice
# --- Built-in Callbacks ---
func _ready() -> void:
	super()
	gui_focus.closed.connect(end_interact)

func interact() -> void:
	super()

func end_interact() -> void:
	super()
	if WorldPathfinder.map.local_to_map(WorldTurnBase.players[0].position) == map_position:
		gui_focus.close()
		return
	choice = gui_focus.close()
	
	var p = WorldPathfinder.calculate_free_path(WorldTurnBase.players[0].position, position)
	WorldTurnBase.players[0].all_actions.append(PlayerNode.Move.new(p[p.size()-2], WorldTurnBase.players[0]))
	WorldTurnBase.players[0].all_actions.append(PlayerNode.Press.new(done))
	if choice == 1:
		WorldPathfinder.pathfinder.set_point_solid(map_position, false)
		WorldTurnBase.players[0].all_actions.append(PlayerNode.Move.new(Vector2((-1*(p[p.size()-2].x-map_position.x))+map_position.x, p[p.size()-2].y), WorldTurnBase.players[0]))
	elif choice == 0:
		WorldPathfinder.pathfinder.set_point_solid(map_position, true)
func done():
	match choice:
		-1:
			return
		0:
			if anim.frame != 0:
				anim.play_backwards("open")
				await anim.animation_finished
		1:
			if anim.frame == 0:
				anim.play("open")
				await anim.animation_finished
