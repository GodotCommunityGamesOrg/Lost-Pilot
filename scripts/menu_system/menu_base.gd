extends Control
class_name MenuBase

## Use dependecy injection to the menus so it can communicate back to the system.
var menu_manager : MenuSystem

## Private function used by the menu system when adding this menu to the scene.
func set_menu_manager(_menu_manager : MenuSystem) -> void:
	menu_manager = _menu_manager
