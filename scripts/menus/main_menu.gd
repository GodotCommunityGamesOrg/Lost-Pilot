extends MenuBase


func _on_play_pressed() -> void:
	GameManager.spawn_scene(GameManager.Keys.SpaceStation)

func _on_settings_pressed() -> void:
	menu_manager.switch_menu(MainMenuSystem.MENUS.SETTINGS)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_github_button_pressed() -> void:
	OS.shell_open("https://github.com/GodotCommunityGamesOrg/Lost-Pilot/tree/main") 


func _on_credits_pressed() -> void:
	menu_manager.switch_menu(MainMenuSystem.MENUS.CREDITS)
