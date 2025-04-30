extends TabContainer
class_name MenuSystem



## Add to the keys enum when adding a new menu.
## Stores all the menus in memory and stored in a dict using the keys enum as input.
var menus : Dictionary = {}
## Current menu that is being shown.
var current_menu: MenuBase
## Storing a single array of menus so we can go back a menu without the new menu knowing it.
var previous_menus: Array[int] = []
## Where menus are instanced into the scene.

func _ready() -> void:
	tabs_visible = false
	for i: MenuBase in get_children():
		i.set_menu_manager(self) 
## Load a previous menu using the previous_menus array we pop the current menu
## so we get the previous menu
func switch_to_previous_menu() -> void:
	## Delete the last menu in the previous menu array and load it
	switch_menu(previous_menus.pop_back())
func switch_menu(id: int):
	previous_menus.append(current_tab)
	current_tab = id;
	current_menu = get_child(id)
	
