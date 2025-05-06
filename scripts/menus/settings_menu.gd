extends MenuBase
@export var _master: HSlider
@export var _music: HSlider
@export var _enviroment: HSlider
@export var _v_sync: CheckButton
var _disabled = true
func _init() -> void:
	_load_settings()

func ready() -> void:
	_setup()

func _on_back_pressed() -> void:
	menu_manager.switch_to_previous_menu()

func _on_master_slider_drag_ended(value_changed: bool, value: int = -1) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(_master.value if value == -1 else value))
	_save_settings()

func _on_muse_slider_drag_ended(value_changed: bool, value: int = -1) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(_music.value if value == -1 else value))
	_save_settings()

func _on_env_slider_drag_ended(value_changed: bool, value: int = -1) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(_enviroment.value if value == -1 else value))
	_save_settings()

func _on_v_sync_toggled(on: bool) -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if on else DisplayServer.VSYNC_DISABLED)
	_save_settings()

func _save_settings() -> void:
	if _disabled:
		return
	var config = ConfigFile.new()
	config.set_value("audio", "master-volume", _master.value)
	config.set_value("audio", "music-volume", _music.value)
	config.set_value("audio", "env-volume", _enviroment.value)
	config.set_value("graphics", "v_sync", _v_sync.button_pressed)
	config.save("user://settings.cfg")

func _load_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		_on_master_slider_drag_ended(true, config.get_value("audio", "master-volume", 1.0))
		_on_muse_slider_drag_ended(true, config.get_value("audio", "music-volume", 1.0))
		_on_env_slider_drag_ended(true, config.get_value("audio", "env-volume", 1.0))
		_on_v_sync_toggled(config.get_value("graphics", "v_sync", false))

func _setup() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		_master.value = config.get_value("audio", "master-volume", 1.0)
		_music.value = config.get_value("audio", "music-volume", 1.0)
		_master.value = config.get_value("audio", "env-volume", 1.0)
		_v_sync.button_pressed = config.get_value("graphics", "v_sync", false)
		
		
	
