extends Panel

var default_texture = preload("res://Assets/item_slot_default_background.png")
var empty_texture = preload("res://Assets/item_slot_empty_background.png")
var selected_texture = preload("res://Assets/item_slot_selected_background.png")

var default_style : StyleBoxTexture = null
var empty_style : StyleBoxTexture = null
var selected_style : StyleBoxTexture = null

var ItemClass = preload("res://Objects/Items/Item.tscn")
var item = null
var slot_index
var slot_type

enum SlotType{
	HOTBAR = 0,
	INVENTORY,
	HELMET,
	BODY,
	BOOTS,
	WEAPONS,
}

func _ready() -> void:
	default_style = StyleBoxTexture.new()
	empty_style = StyleBoxTexture.new()
	selected_style = StyleBoxTexture.new()
	default_style.texture = default_texture
	empty_style.texture = empty_texture
	selected_style.texture = selected_texture
	refresh_style()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func refresh_style():
	if SlotType.HOTBAR == slot_type and PlayerInventory.active_item_slot == slot_index:
		set('theme_override_styles/panel', selected_style);
	elif item == null:
		set('theme_override_styles/panel', empty_style);
	else:
		set('theme_override_styles/panel', default_style);

func pickFromSlot():
	remove_child(item)
	var inventoryNode = find_parent("UI")
	inventoryNode.add_child(item)
	item = null
	refresh_style()
	
func putIntoSlot(new_item):
	item = new_item
	item.position = Vector2(2.5, 2.5)
	var inventoryNode = find_parent("UI")
	inventoryNode.remove_child(item)
	add_child(item)
	refresh_style()

func getFromSlot():
	var inventoryNode = find_parent("UI")
	inventoryNode.add_child(item)
	refresh_style()

func initialize_item(item_name, item_quantity):
	if item == null:
		item = ItemClass.instantiate()
		add_child(item)
		item.position.x = 2.5
		item.position.y = 2.5
		item.set_item(item_name, item_quantity)
	else:
		item.position.x = 2.5
		item.position.y = 2.5
		item.set_item(item_name, item_quantity)
	refresh_style()
