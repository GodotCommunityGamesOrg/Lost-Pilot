extends Node2D
class_name Entity
## Position of the object on the map grid.
@onready var map_position: Vector2i = WorldPathfinder.map.local_to_map(position)  
