extends MenuBase


func _on_play_pressed() -> void:
	GameManager.spawn_scene(GameManager.Keys.SpaceStation)
	menu_manager.load_menu(menu_manager.Keys.InGame)

func _on_settings_pressed() -> void:
	menu_manager.load_menu(menu_manager.Keys.Settings)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_github_button_pressed() -> void:
	OS.shell_open("https://github.com/GodotCommunityGamesOrg/Lost-Pilot/tree/main") 


func _on_credits_pressed() -> void:
	menu_manager.load_menu(menu_manager.Keys.Credits)
