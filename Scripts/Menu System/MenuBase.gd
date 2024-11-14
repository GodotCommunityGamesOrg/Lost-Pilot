extends UserInterface
class_name MenuBase

## Use dependecy injection to the menus so it can communicate back to the system.
var menu_manager : MenuSystem
## if a menu should pause the game then this should be enabled e.g a pause menu.
@export var is_paused : bool = false

## Private function used by the menu system when adding this menu to the scene.
func set_menu_manager(_menu_manager : MenuSystem) -> void:
	menu_manager = _menu_manager
