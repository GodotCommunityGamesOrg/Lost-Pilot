extends Node
class_name Manager
# GameManager that handles loading and spawning scenes
# e.g Player, world scene and more.

# This script will evolve as the game progresses.


# Add to the keys for specific scenes.
enum Keys {SpaceStation,ShipEditor,SpaceEnvironment}

# Store the scenes
var scenes : Dictionary

var current_scene : Node
var scene_container : Node2D
func _ready() -> void:
	create_container()
	add_scene("res://scenes/player/world.tscn",Keys.SpaceStation)

# Add scenes to the scene dict.
func add_scene(scene : String,key : Keys) -> void:
	scenes[key] = load(scene)

func delete_scene() -> void:
	if current_scene:
		current_scene.queue_free()

# Spawns the scene to the tree.
func spawn_scene(key : Keys) -> void:
	
	if current_scene:
		current_scene.queue_free()
		
	var next_scene : Node = scenes[key].instantiate()
	
	if not scene_container: return
	
	scene_container.add_child(next_scene)
	current_scene = next_scene

# Setup the container for the scenes.
func create_container() -> void:
	var node : Node2D = Node2D.new()
	get_tree().get_root().add_child.call_deferred(node)
	scene_container = node
