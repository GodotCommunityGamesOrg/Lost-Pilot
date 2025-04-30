extends Node
class_name Manager
# GameManager that handles loading and spawning scenes
# e.g Player, world scene and more.

# This script will evolve as the game progresses.


# Add to the keys for specific scenes.
enum Keys {SpaceStation,ShipEditor,SpaceEnvironment, main}

# Store the scenes
var scenes : Dictionary

var current_scene : Node
var scene_container : Node2D
func _ready() -> void:
	add_scene("res://scenes/player/world.tscn",Keys.SpaceStation)
	add_scene("res://scenes/main/main.tscn", Keys.main)

# Add scenes to the scene dict.
func add_scene(scene : String,key : Keys) -> void:
	scenes[key] = scene

func delete_scene() -> void:
	if current_scene:
		current_scene.queue_free()

# Spawns the scene to the tree.
func spawn_scene(key : Keys) -> void:
	
	get_tree().change_scene_to_file(scenes[key])
