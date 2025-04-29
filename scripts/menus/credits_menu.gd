extends MenuBase




func _on_back_pressed() -> void:
	menu_manager.load_previous_menu()

func _richtextlabel_on_meta_clicked(meta):
	OS.shell_open(str(meta))
