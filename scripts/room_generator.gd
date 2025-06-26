## A procedural room generator that creates rooms using random walkers.
## The generator ensures there is always a valid path between entrance and exit.
class_name RoomGenerator
extends Node2D

@export_category("Floors & Walls")
## The Tileset that will be used for Floors & Walls
@export var floor_tileset: TileSet

## Terrain ID for the floor tiles
@export var floor_tile: int

## Terrain ID for the wall tiles
@export var wall_tile: int

@export_category("Objects")
## The TileSet that will be used for Objects
@export var object_tileset: TileSet

## The ID of the door in the Scene Collection
@export var door_id: int

## The ID of the player in the Scene Collection
@export var player_id: int

@export_category("Randomization")
## Seed used for random generation. Changing this will create different room layouts
@export var _seed: String = "Game dev is difficult"

## Random number generator for procedural generation
var rng: RandomNumberGenerator

var floor_layer: map_generator
var object_layer: TileMapLayer

@export var procedural_generator: ProceduralGenerator

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	rng.seed = _seed.hash()
	create_layers()
	generate_room()
	floor_layer.init_pathfinding()

## Creates the neccessary TileMapLayers
func create_layers() -> void:
	create_floor_layer()
	create_object_layer()

## Creates the floor layer
func create_floor_layer() -> void:
	floor_layer = map_generator.new()
	floor_layer.tile_set = floor_tileset
	add_child(floor_layer)

## Creates the object layer
func create_object_layer() -> void:
	object_layer = TileMapLayer.new()
	object_layer.tile_set = object_tileset
	add_child(object_layer)

## Generates a new room layout
func generate_room() -> void:
	clear_the_previous_room()
	procedural_generator.generate(rng)
	apply_terrain_changes()

func clear_the_previous_room() -> void:
	floor_layer.clear()
	object_layer.clear()
	procedural_generator.clear()

## Applies all terrain changes at once
func apply_terrain_changes() -> void:
	apply_floors()
	apply_entrance()
	apply_exit()
	apply_walls()
	apply_player()
	
### Apply floors
func apply_floors() -> void:
	for pos in procedural_generator.floor_positions:
		procedural_generator.wall_positions.erase(pos)
	floor_layer.set_cells_terrain_connect(procedural_generator.floor_positions, 0, floor_tile, true)
	
### Apply walls
func apply_walls() -> void:
	floor_layer.set_cells_terrain_connect(procedural_generator.wall_positions, 0, wall_tile, true)

### Apply entrance
func apply_entrance() -> void:
	for pos in procedural_generator.entrance_positions:
		procedural_generator.wall_positions.erase(pos)
	floor_layer.set_cells_terrain_connect(procedural_generator.entrance_positions, 0, floor_tile, true)
	object_layer.set_cell(procedural_generator.entrance_positions[0], 1, Vector2i.ZERO, door_id)
	object_layer.set_cell(procedural_generator.entrance_positions[1], 1, Vector2i.ZERO, door_id)

### Apply exit
func apply_exit() -> void:
	for pos in procedural_generator.exit_positions:
		procedural_generator.wall_positions.erase(pos)
	floor_layer.set_cells_terrain_connect(procedural_generator.exit_positions, 0, floor_tile, true)
	object_layer.set_cell(procedural_generator.exit_positions[0], 1, Vector2i.ZERO, door_id)
	object_layer.set_cell(procedural_generator.exit_positions[1], 1, Vector2i.ZERO, door_id)

### Apply player
func apply_player() -> void:
	object_layer.set_cell(procedural_generator.player_start_position, 1, Vector2i.ZERO, player_id)
