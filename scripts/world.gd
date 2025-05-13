extends Node2D

@export var _floor: TileMapLayer
@export var objects: TileMapLayer
@export var wall_tile_coords := Vector2i(0, 0)
@export var wall_tile_id := 1

const TILE_ID = 0
const TILE_COORDS = Vector2i(6, 5)

const MAX_STEPS = 200
const TURN_CHANCE = 0.3
const ROOM_CHANCE = 0.15
const ROOM_MIN_SIZE = Vector2i(3, 3)
const ROOM_MAX_SIZE = Vector2i(6, 6)

const DIRECTIONS = [
	Vector2i(1, 0),
	Vector2i(0, -1),
	Vector2i(-1, 0),
	Vector2i(0, 1)
]

var current_direction = Vector2i(1, 0)
var visited = {} # Keep track of placed _floor tiles

func _init() -> void:
	WorldPathfinder.reset()
	WorldTurnBase.reset()

func load_function(ar: Array) -> void:
	match ar.size():
		1:
			push_error("no arguments given")
	generate_world()

func generate_world():
	for x in range(-10, 10, 1):
		for y in range(-10, 10, 1):
			if Vector2(x,y).distance_to(Vector2.ZERO) < 10:
				_floor.set_cell(Vector2i(x,y), TILE_ID, TILE_COORDS)
	var room_width = 10
	var wall: Array[Vector2i]
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	#for i in 4:
	var pos: Vector2i = Vector2i.ZERO
	for i in MAX_STEPS:
		if i > room_width and rng.randi_range(1, 6) == 6:
			_floor.set_cell(Vector2i(-1, i), TILE_ID, TILE_COORDS)
			objects.set_cell(Vector2i(-1, i), 1, Vector2i(0, 0), 2 )
			room_width = rng.randi_range(3, 8)+i
		_floor.set_cell(Vector2i(0, i), TILE_ID, TILE_COORDS)
		if _floor.get_cell_tile_data(Vector2i(-1, i)) == null: wall.append(Vector2i(-1, i))
		if _floor.get_cell_tile_data(Vector2i(1, i)) == null: wall.append(Vector2i(1, i))
		#if _floor.get_cell_tile_data(Vector2i(-1, i)) == null:
		#if _floor.get_cell_tile_data(Vector2i(-1, i)) == null:
		pos.x += 1
	_floor.set_cells_terrain_connect(wall, 0, 1)
	
