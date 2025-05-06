extends Node
class_name Manager
## GameManager that handles loading and spawning scenes
## e.g Player, world scene and more.

# temporary leaving inventory in a global script (I dont know if this is a good place or not)
var player_inventory : Array
const loading_scene: String = "res://scenes/loader.tscn" ## path to the loading screen

var loader: ProgressBar ## loading screen progress

## keys for each level that corrisponds with the scene path.
enum Keys {
	## SpaceStation level where most of the playing takes place.
	SpaceStation,
	## Space Ship (player home)
	ShipEditor, 
	## ship Navigation area
	SpaceEnvironment,
	## Main Menu 
	main 
	}

var scenes : Dictionary ## Scene path storage
var current_scene : Node ## the Main Scene currently loaded

var _load_key : int ## which scene loading (do not touch)

func _ready() -> void:
	add_scene("res://scenes/player/world.tscn", Keys.SpaceStation)
	add_scene("res://scenes/main/main.tscn", Keys.main)
	add_child(preload(loading_scene).instantiate())
	loader = get_child(0).get_child(0)
	# temporary disabled the menu to focus on working on the inventory system
	#spawn_scene(Keys.main)

## adds scene path to dictionary with assignes key
func add_scene(scene : String, key : Keys) -> void:
	scenes[key] = scene

## deletes primary scene
func delete_scene() -> void:
	if current_scene:
		current_scene.queue_free()
		current_scene = null

## replaces scene with new scene.
func spawn_scene(key : Keys, function_await: Callable = func() -> void: pass) -> void:
	if !scenes.has(key):
		return
	_load_key = key
	var path = scenes[key]
	ResourceLoader.load_threaded_request(path)
	while true:
		var total = []
		var stage = ResourceLoader.load_threaded_get_status(scenes[_load_key], total)
		loader.value = total[0] * 100.0

		if stage == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED and total[0] == 1.0:
			var res = ResourceLoader.load_threaded_get(scenes[_load_key])
			if res:
				delete_scene()
				current_scene = res.instantiate()
				add_child(current_scene)
			await function_await.call()
			loader.get_parent().visible = false
			break
		await get_tree().process_frame
