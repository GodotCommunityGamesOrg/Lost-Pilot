extends TabContainer
class_name MenuSystem




## Current menu that is being shown.
var current_menu: MenuBase

## Storing a single array of menus so we can go back a menu without the new menu knowing it.
var previous_menus: Array[int] = []

func _ready() -> void:
	tabs_visible = false
	for i: MenuBase in get_children():
		i.set_menu_manager(self) 

## switch to the previous menu using the previous_menus array we pop the current menu
## so we get the previous menu
func switch_to_previous_menu() -> void:
	## Delete the last menu in the previous menu array and load it
	switch_menu(previous_menus.pop_back())

## switch to the menu with the given id
func switch_menu(id: int):
	previous_menus.append(current_tab)
	current_tab = id;
	current_menu = get_child(id)
	
