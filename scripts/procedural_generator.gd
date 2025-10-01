extends Resource
class_name ProceduralGenerator

var floor_positions: Array[Vector2i] = []
var wall_positions: Array[Vector2i] = []
var entrance_positions: Array[Vector2i] = []
var exit_positions: Array[Vector2i] = []
var player_start_position: Vector2i = Vector2i.ZERO
var seed: String

func _init():
	if self.get_script() == ProceduralGenerator:
		push_error("ProceduralGenerator is abstract and cannot be instantiated directly.")
		assert(false)

func generate(rng: RandomNumberGenerator) -> void:
	assert(false, "generate() must be implemented by a subclass.")

func clear() -> void:
	floor_positions.clear()
	wall_positions.clear()
	entrance_positions.clear()
	exit_positions.clear()
