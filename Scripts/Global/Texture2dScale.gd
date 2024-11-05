extends Texture2D

@export var texture_scale: float = 1.0

func _init():
	texture_scale = 1.0  # Default scale to 1 (no scaling)

func set_texture_scale(scale: float):
	texture_scale = scale
	update_scale()

func update_scale():
	var size = get_size() * texture_scale
	
