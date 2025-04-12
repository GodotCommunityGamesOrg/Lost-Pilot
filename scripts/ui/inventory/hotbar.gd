extends UserInterface

const SlotClass = preload("res://scripts/ui/inventory/slot.gd") ## Preload the Slot script
@onready var hotbar = $HotbarSlots ## Reference to the HotbarSlots node
@onready var slots = $HotbarSlots.get_children() ##List of all child nodes of HotbarSlots
@onready var active_item_label = $ActiveItemLabel ## Reference to the ActiveItemLabel node
@onready var tooltip = $ActiveItemLabel/Tooltip ## Reference to the Tooltip node
@onready var ui = find_parent("UI")
var temporary_slot
func _ready() -> void:##Set up the Hotbar and its slots
	PlayerInventory.active_item_updated.connect(self.update_active_item_label)
	for i in range(slots.size()):
		slots[i].gui_input.connect(slot_gui_input.bind(slots[i]))
		slots[i].slot_index = i
		slots[i].slot_type = SlotClass.SlotType.HOTBAR
		PlayerInventory.active_item_updated.connect(slots[i].refresh_style)
	initialize_hotbar()
	update_active_item_label()
	
func tooltip_change():##Toggles the visibility of the tooltip
	active_item_label.visible = !active_item_label.visible

func update_active_item_label():##Gives data to tooltip
	tooltip.visible = true
	if PlayerInventory.active_item_slot == null or PlayerInventory.active_item_slot > 7:
		return
	if slots[PlayerInventory.active_item_slot].item != null:
		active_item_label.text = slots[PlayerInventory.active_item_slot].item.item_name
		tooltip.visible = true
		var info_slots = get_tree().get_nodes_in_group("hotbar_info_slots")
		info_slots[0].text = ResourceData.item_data[slots[PlayerInventory.active_item_slot].item.item_name].item_category
		info_slots[1].text = slots[PlayerInventory.active_item_slot].item.item_name
		info_slots[2].text = ResourceData.item_data[slots[PlayerInventory.active_item_slot].item.item_name].description
		if ResourceData.item_data[slots[PlayerInventory.active_item_slot].item.item_name].item_category == "Consumable":
			info_slots[3].text = "Adds " + str(ResourceData.item_data[slots[PlayerInventory.active_item_slot].item.item_name].add_health) + " Health"
			info_slots[4].text = "Adds " + str(ResourceData.item_data[slots[PlayerInventory.active_item_slot].item.item_name].add_energy) + " Energy"
		elif ResourceData.item_data[slots[PlayerInventory.active_item_slot].item.item_name].item_category == "Tool":
			info_slots[3].text = "Adds " + str(ResourceData.item_data[slots[PlayerInventory.active_item_slot].item.item_name].add_repair) + " Repair"
			info_slots[4].text = "Adds " + str(ResourceData.item_data[slots[PlayerInventory.active_item_slot].item.item_name].add_energy) + " Energy"
		elif ResourceData.item_data[slots[PlayerInventory.active_item_slot].item.item_name].item_category == "Weapon":
			info_slots[3].text = "Damage: " + str(ResourceData.item_data[slots[PlayerInventory.active_item_slot].item.item_name].item_attack)
			info_slots[4].text = "Reload: " + str(ResourceData.item_data[slots[PlayerInventory.active_item_slot].item.item_name].item_reload) + "s"
		else:
			info_slots[3].text = ""
			info_slots[4].text = ""
	else:
		active_item_label.text = "Empty Slot"
		tooltip.visible = false
		
func initialize_hotbar(): ##Goes through the slots and inializes the item that are there
	for i in range(slots.size()):
		if i < len(PlayerInventory.hotbar):
			if PlayerInventory.hotbar[i]:
				slots[i].initialize_item(PlayerInventory.hotbar[i][0], PlayerInventory.hotbar[i][1])

func slot_gui_input(event: InputEvent, slot: SlotClass): ## Handles how the user interacts with the items in the hotbar.
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed: 
			if ui.holding_item != null:
				if !slot.item:  ## If user left-clicks on an empty slot and is dragging a item. The item is placed in the slot.
					PlayerInventory.add_item_to_empty_slot(ui.holding_item, slot)
					slot.putIntoSlot(ui.holding_item)
					ui.holding_item = null
				else:
					if ui.holding_item.item_name != slot.item.item_name:  ## If user left-clicks on an occupied slot and is dragging a item different from the one in the slot. The item being dragged is placed in the slot and the item that was previously in the slot is now being dragged by player.
						PlayerInventory.remove_item(slot)
						PlayerInventory.add_item_to_empty_slot(ui.holding_item, slot)
						var temp_item = slot.item
						slot.pickFromSlot()
						temp_item.global_position = event.global_position
						slot.putIntoSlot(ui.holding_item)
						ui.holding_item = temp_item
					else:
						var stack_size = int(ResourceData.item_data[slot.item.item_name].stacksize)  ## If user left-clicks on an occupied slot and is dragging a item that is the the same as the item in the slot. The item is added to the slot if it can be without exceeding the item maximum stacksize.
						var able_to_add = stack_size - slot.item.item_quantity
						if able_to_add >= ui.holding_item.item_quantity:
							PlayerInventory.add_item_quantity(slot, ui.holding_item.item_quantity)
							slot.item.add_item_quantity(ui.holding_item.item_quantity)
							ui.holding_item.queue_free()
							ui.holding_item = null
						else:
							PlayerInventory.add_item_quantity(slot, able_to_add)
							slot.item.add_item_quantity(able_to_add)
							ui.holding_item.decrease_item_quantity(able_to_add)
			elif slot.item: ## If User left-clicks on a slot while not dragging anything. The item in the slot is dragged by the user and the slot becomes empty
				PlayerInventory.remove_item(slot)
				ui.holding_item = slot.item
				slot.pickFromSlot()
				ui.holding_item.global_position = get_global_mouse_position()
			update_active_item_label()
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			if slot.item: ## If a user right-clicks on a slot with an item in it. The item in the slot is split in two 
				var amount_to_remove = slot.item.item_quantity/2
				PlayerInventory.decrease_item_quantity(slot, amount_to_remove)
				slot.item.decrease_item_quantity(amount_to_remove)
				temporary_slot = SlotClass.new()
				add_child(temporary_slot)
				temporary_slot.initialize_item(slot.item.item_name, amount_to_remove)
				ui.holding_item = temporary_slot.item
				temporary_slot.remove_child(temporary_slot.item)
				temporary_slot.getFromSlot()
				ui.holding_item.global_position = get_global_mouse_position()
