extends Node2D
@onready var floor = $RoomGenerator/Floor

func _ready() -> void:
	WorldPathfinder.reset(floor)
	WorldTurnBase.reset()
