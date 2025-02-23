extends Panel

var default_texture = preload("res://assets/ui/inventory_ui/InventorySlotUsed64x64.png")
var empty_texture = preload("res://assets/ui/inventory_ui/InventorySlot64x64.png")
var selected_texture = preload("res://assets/ui/inventory_ui/InventorySlotSelected64x64.png")

var default_style : StyleBoxTexture = StyleBoxTexture.new()
var empty_style : StyleBoxTexture = StyleBoxTexture.new()
var selected_style : StyleBoxTexture = StyleBoxTexture.new()

var ItemClass = preload("res://scenes/inventory/item.tscn")
var item = null
var slot_index : int
var inventory_slot_index : int
var equip_slot_index : int
var slot_type 
var hover : bool
@onready var ui = find_parent("UI")

enum SlotType{
	HOTBAR,
	INVENTORY,
	HELMET,
	BODY,
	BOOTS,
	WEAPONS,
}

var equip_types = [SlotType.HELMET, 
					SlotType.BODY,
					SlotType.BOOTS, 
					SlotType.WEAPONS
				]

func _ready() -> void:
	default_style.texture = default_texture
	empty_style.texture = empty_texture
	selected_style.texture = selected_texture
	self.mouse_entered.connect(self.change_hover)
	self.mouse_exited.connect(self.change_hover)
	refresh_style()
			
func refresh_style():
	if slot_type == SlotType.INVENTORY and PlayerInventory.active_item_slot == inventory_slot_index:
		set('theme_override_styles/panel', selected_style);
	elif slot_type == SlotType.HOTBAR and PlayerInventory.active_item_slot == slot_index:
		set('theme_override_styles/panel', selected_style);
	elif slot_type in equip_types and PlayerInventory.active_item_slot == equip_slot_index:
			set('theme_override_styles/panel', selected_style);
	elif item == null:
		set('theme_override_styles/panel', empty_style);
	else:
		set('theme_override_styles/panel', default_style);

func pickFromSlot():
	remove_child(item)
	ui.add_child(item)
	item = null
	refresh_style()
	
func putIntoSlot(new_item):
	item = new_item
	item.position = Vector2(2.5, 2.5)
	ui.remove_child(item)
	add_child(item)
	tooltip_text = item.item_name
	refresh_style()

func getFromSlot():
	ui.add_child(item)
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
	tooltip_text = item.item_name
	refresh_style()

func change_hover():
	hover = !hover
	if hover:
		if slot_type == SlotType.HOTBAR:
			PlayerInventory.change_active_item_slot(slot_index)
		if slot_type == SlotType.INVENTORY:
			PlayerInventory.change_inventory_active_item_slot(inventory_slot_index)
		else:
			PlayerInventory.change_equip_active_item_slot(equip_slot_index)
