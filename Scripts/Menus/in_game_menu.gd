extends MenuBase

# In this menu it would be blank because we are in game
# so instead of having buttons in this script to change menu
# we should check for conditions for example when the player presses the pause
# key then we should open the pause menu in this script
# also we should call the GameManager script to delete the current scene if we 
# are going back to the main menu.

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.is_pressed():
			# load the pause menu.
			menu_manager.load_menu(menu_manager.Keys.Paused)
