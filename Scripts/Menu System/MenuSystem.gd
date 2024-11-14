extends Node
class_name MenuSystem

## To disable the menu system when working on other systems.
@export var disable : bool = false

## Add to the keys enum when adding a new menu.
enum Keys {InGame,MainMenu,Paused,Settings,Credits}
## Stores all the menus in memory and stored in a dict using the keys enum as input.
var menus : Dictionary = {}
## Current menu that is being shown.
var current_menu : Control
## Storing a single array of menus so we can go back a menu without the new menu knowing it.
var previous_menus : Array = []
## Where menus are instanced into the scene.
var menu_container : CanvasLayer

func _ready() -> void:
	
	if disable: return
	
	## Need to create the container first before we event start loading menus.
	set_up_menu_container()
	
	## Adding all the menus we want the game to have in the ready func.
	add_menu(Keys.InGame,"res://Scenes/Menus/in_game_menu.tscn")
	add_menu(Keys.Paused,"res://Scenes/Menus/pause_menu.tscn")
	add_menu(Keys.MainMenu,"res://Scenes/Menus/main_menu.tscn")
	add_menu(Keys.Settings,"res://Scenes/Menus/settings_menu.tscn")
	add_menu(Keys.Credits,"res://Scenes/Menus/credits_menu.tscn")
	## When all the menus are setup we now need to load the first menu. 
	load_menu(Keys.MainMenu)

## Adding the new menu into the dict and is loaded into memory.
func add_menu(key : Keys , menu_path : String) -> void:
	menus[key] = load(menu_path)

## Load the menu using the keys enum as input, we wait a frame to avoid timing issues.
func load_menu(key : Keys) -> void:
	## Should wait one frame before loading the next menu, to avoid any unwanted issue.
	call_deferred("deferred_menu_load",key)

## Load a previous menu using the previous_menus array we pop the current menu
## so we get the previous menu
func load_previous_menu() -> void:
	## Delete the last menu in the previous menu array and load it
	previous_menus.pop_back()
	call_deferred("deferred_menu_load",previous_menus[-1])

func deferred_menu_load(key : Keys) -> void:
	
	## Stop attempt if menu does not exist.
	if not menus.has(key): assert(true,"No menu found!")
	
	## If the previous menu array is empty we add the first menu,
	## elif the last menu isnt the same one as the current one we add it
	if previous_menus.size() == 0:
		previous_menus.append(key)
	elif previous_menus[-1] != key:
		previous_menus.append(key)
	
	## Queue free current menu if its not null.
	if current_menu:
		current_menu.queue_free()
	
	## Get the next menu from the menus dict
	var next_menu : PackedScene = menus[key]
	
	## Set the current menu by instancing the next menu
	current_menu = next_menu.instantiate()
	## Add it to the menus container
	menu_container.add_child(current_menu)
	## Set the menu manager to the menu so it can do menu changes
	current_menu.set_menu_manager(self)
	
	## Set the game to paused if a menu pauses the game
	get_tree().paused = current_menu.is_paused

## Function for creating a container for the menus.
func set_up_menu_container() -> void:
	if not menu_container:
		var canvas : CanvasLayer = CanvasLayer.new()
		canvas.name = "Menu Container"
		add_child(canvas)
		menu_container = canvas
