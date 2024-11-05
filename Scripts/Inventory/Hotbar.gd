extends Node2D

const SlotClass = preload("res://Scripts/Inventory/Slot.gd")
@onready var hotbar = $HotbarSlots 
@onready var slots = $HotbarSlots.get_children()
@onready var active_item_label = $ActiveItemLabel
@onready var tooltip = $ActiveItemLabel/Tooltip
var t

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerInventory.active_item_updated.connect(self.update_active_item_label)
	for i in range(slots.size()):
		slots[i].gui_input.connect(slot_gui_input.bind(slots[i]))
		PlayerInventory.active_item_updated.connect(slots[i].refresh_style)
		slots[i].slot_index = i
		slots[i].slot_type = SlotClass.SlotType.HOTBAR
	initialize_hotbar()
	update_active_item_label()
	
func update_active_item_label():
	tooltip.visible = true
	if slots[PlayerInventory.active_item_slot].item != null:
		active_item_label.text = slots[PlayerInventory.active_item_slot].item.item_name
		tooltip.visible = true
		var tips = tooltip.get_children()
		tips[0].text = JsonData.item_data[active_item_label.text]["ItemCategory"]
		tips[1].text = slots[PlayerInventory.active_item_slot].item.item_name
		tips[2].text = JsonData.item_data[active_item_label.text]["Description"]
	else:
		active_item_label.text = "Empty Slot"
		tooltip.visible = false
		
func initialize_hotbar():
	for i in range(slots.size()):
		if PlayerInventory.hotbar.has(i):
			slots[i].initialize_item(PlayerInventory.hotbar[i][0], PlayerInventory.hotbar[i][1])

func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if find_parent("UI").holding_item != null:
				if !slot.item:
					PlayerInventory.add_item_to_empty_slot(find_parent("UI").holding_item, slot)
					slot.putIntoSlot(find_parent("UI").holding_item)
					find_parent("UI").holding_item = null
				else:
					if find_parent("UI").holding_item.item_name != slot.item.item_name:
						PlayerInventory.remove_item(slot)
						PlayerInventory.add_item_to_empty_slot(find_parent("UI").holding_item, slot)
						var temp_item = slot.item
						slot.pickFromSlot()
						temp_item.global_position = event.global_position
						slot.putIntoSlot(find_parent("UI").holding_item)
						find_parent("UI").holding_item = temp_item
					else:
						var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
						var able_to_add = stack_size - slot.item.item_quantity
						if able_to_add >= find_parent("UI").holding_item.item_quantity:
							PlayerInventory.add_item_quantity(slot, find_parent("UI").holding_item.item_quantity)
							slot.item.add_item_quantity(find_parent("UI").holding_item.item_quantity)
							find_parent("UI").holding_item.queue_free()
							find_parent("UI").holding_item = null
						else:
							PlayerInventory.add_item_quantity(slot, able_to_add)
							slot.item.add_item_quantity(able_to_add)
							find_parent("UI").holding_item.decrease_item_quantity(able_to_add)
			elif slot.item:
				PlayerInventory.remove_item(slot)
				find_parent("UI").holding_item = slot.item
				slot.pickFromSlot()
				find_parent("UI").holding_item.global_position = get_global_mouse_position()
			update_active_item_label()
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			if slot.item:
				var amount_to_remove = slot.item.item_quantity/2
				PlayerInventory.decrease_item_quantity(slot, amount_to_remove)
				slot.item.decrease_item_quantity(amount_to_remove)
				t = SlotClass.new()
				add_child(t)
				t.initialize_item(slot.item.item_name, amount_to_remove)
				find_parent("UI").holding_item = t.item
				t.remove_child(t.item)
				t.getFromSlot()
				find_parent("UI").holding_item.global_position = get_global_mouse_position()
