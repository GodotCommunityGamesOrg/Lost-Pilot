extends PanelContainer
class_name Slot
## Slot is simply a custom texture button that sets information about the set item.

var index :Vector2i

@onready var icon : TextureRect = get_node("Icon")
@onready var button : TextureButton = get_node("Button")
@onready var stack : Label = get_node("Stack")

func set_icon(texture : Texture2D) -> void:
	if not icon:
		return
	
	icon.texture = texture

func set_stack(amount : int) -> void:
	
	stack.visible = true
	
	if not stack or amount == 0:
		stack.visible = false
		return
	
	stack.text = str(amount)
