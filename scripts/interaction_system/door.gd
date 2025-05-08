extends InteractableObject
class_name DoorObject
# --- Exported Properties ---
## Container for GUI elements associated with the object.
@export var gui: CircleMenuButton
@export var anim:AnimatedSprite2D 
var anim_str: String
var door2: InteractableObject
var choice
# --- Built-in Callbacks ---
func _ready() -> void:
	super()
	await get_tree().process_frame
	if get_terrain_at_tile(0, -1):
		anim_str = "open-up"
		door2 = get_object_in_coords(0, 1)
	elif get_terrain_at_tile(0, 1): 
		anim_str = "open-down"
		door2 = get_object_in_coords(0, -1)
	elif get_terrain_at_tile(-1): 
		anim_str = "open-left"
		door2 = get_object_in_coords(1)
	elif get_terrain_at_tile(1): 
		anim_str = "open-right"
		door2 = get_object_in_coords(-1)
	anim.animation = anim_str
	

func interact(player: PlayerNode, _choice:int = -10, p: Array[Vector2i] = []) -> Array[PlayerNode.Action]:
	var actions = super(player, _choice, p)
	choice = await gui.open() if _choice == -10 else _choice
	if WorldPathfinder.map.local_to_map(WorldTurnBase.players[0].position) == map_position:
		return []
	
	
	actions.append(PlayerNode.Press.new(
	func():
		match choice:
			-1:
				return
			0:
				if anim.frame != 0:
					anim.play_backwards(anim_str)
					await anim.animation_finished
					WorldPathfinder.pathfinder.set_point_solid(map_position, true)
			1:
				if anim.frame == 0:
					anim.play(anim_str)
					await anim.animation_finished
					WorldPathfinder.pathfinder.set_point_solid(map_position, false)
	))
	return actions

func get_terrain_at_tile(x: int = 0, y: int = 0) -> int:
	var cell := WorldPathfinder.map.get_cell_tile_data(Vector2i(map_position.x+x, map_position.y+y))
	if cell == null:
		return 0
	return cell.terrain

func get_object_in_coords(x: int = 0, y: int = 0) -> InteractableObject:
	var i = WorldPathfinder.position_to_object(map_position+Vector2i(x,y))
	if i is DoorObject:
		return i
	return null
