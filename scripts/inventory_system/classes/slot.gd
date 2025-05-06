extends PanelContainer
class_name Slot

var index :Vector2i

@onready var icon : TextureRect = get_node("Icon")
@onready var button : TextureButton = get_node("Button")

func set_icon(texture : Texture2D) -> void:
	if not icon:
		return
	
	icon.texture = texture
