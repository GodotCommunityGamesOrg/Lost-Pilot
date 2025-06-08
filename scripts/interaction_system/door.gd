extends InteractableObject
class_name DoorObject

## DoorObject class:
## A specialized InteractableObject that represents a door. It can animate open and close states 
## based on user interaction, update the pathfinding system accordingly, and optionally sync 
## with a paired door on the opposite side.

# --- Exported Properties ---

## Reference to the CircleMenuButton used to prompt player interaction choices.
@export var gui: CircleMenuButton

## AnimatedSprite2D that visually represents the door’s open/close animation.
@export var anim: AnimatedSprite2D

# --- Private Properties ---

## The animation name to play based on the door's orientation (e.g., "open-up").
var anim_str: String

## A reference to the paired DoorObject on the opposite side, if any.
var door2: DoorObject

## Stores the most recent interaction choice made by the player.
var choice

# --- Built-in Callbacks ---

## Called when the node enters the scene tree. Determines door orientation, assigns animation,
## and attempts to find a matching door on the opposite side.
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

# --- Public Methods ---

## Handles interaction logic for the door, including choice selection via GUI,
## animation playback, and modifying pathfinding solidity.
func interact(player: PlayerNode, _choice: int = -10, p: Array[Vector2i] = []) -> Array[PlayerNode.Action]:
	choice = await gui.open() if _choice == -10 else _choice
	if WorldPathfinder.map.local_to_map(WorldTurnBase.players[0].position) == map_position or choice == -1:
		return []

	# Lock the door tiles if closing
	if choice == 0:
		WorldPathfinder.pathfinder.set_point_solid(map_position, true)
		if door2:
			WorldPathfinder.pathfinder.set_point_solid(door2.map_position, true)

	var actions = super(player, _choice, p)
	actions.append(PlayerNode.Press.new(
		func():
			match choice:
				-1:
					return
				0:
					if anim.frame != 0:
						anim.play_backwards(anim_str)
						if door2:
							door2.anim.play_backwards(door2.anim_str)
						await anim.animation_finished
				1:
					if anim.frame == 0:
						anim.play(anim_str)
						if door2:
							door2.anim.play(door2.anim_str)
						await anim.animation_finished
						WorldPathfinder.pathfinder.set_point_solid(map_position, false)
						if door2:
							WorldPathfinder.pathfinder.set_point_solid(door2.map_position, false)
	))
	return actions

## Returns the terrain type at a relative tile offset.
## Useful for determining door orientation at startup.
func get_terrain_at_tile(x: int = 0, y: int = 0) -> int:
	var pos = Vector2i(map_position.x + x, map_position.y + y)
	var cell = WorldPathfinder.map.get_cell_tile_data(pos)
	if cell == null:
		return 0
	return cell.terrain

## Retrieves the InteractableObject at a specific coordinate offset, if it is a DoorObject.
func get_object_in_coords(x: int = 0, y: int = 0) -> InteractableObject:
	var i = WorldPathfinder.position_to_object(map_position + Vector2i(x, y))
	if i is DoorObject:
		return i
	return null
