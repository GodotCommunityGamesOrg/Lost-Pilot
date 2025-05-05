extends MenuBase


func _visiblity_changed():
	get_tree().paused = visible

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	GameManager.spawn_scene(GameManager.Keys.main)


func _on_resume_pressed() -> void:
	menu_manager.switch_menu(GameMenuSystem.MENUS.InGame)


func _on_settings_pressed() -> void:
	get_tree().paused = false
	menu_manager.switch_menu(GameMenuSystem.MENUS.Settings)
