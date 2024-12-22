extends UserInterface

const SlotClass = preload("res://scripts/ui/inventory/slot.gd") # Preload the Slot script
@onready var hotbar = $HotbarSlots # Reference to the HotbarSlots node
@onready var slots = $HotbarSlots.get_children() #List of all child nodes of HotbarSlots
@onready var active_item_label = $ActiveItemLabel # Reference to the ActiveItemLabel node
@onready var tooltip = $ActiveItemLabel/Tooltip # Reference to the Tooltip node
var temporary_slot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Sets up the Hotbar
	PlayerInventory.active_item_updated.connect(self.update_active_item_label)
	for i in range(slots.size()):
		slots[i].gui_input.connect(slot_gui_input.bind(slots[i]))
		PlayerInventory.active_item_updated.connect(slots[i].refresh_style)
		slots[i].slot_index = i
		slots[i].slot_type = SlotClass.SlotType.HOTBAR
	initialize_hotbar()
	update_active_item_label()
	
func tooltip_change():
	# Toggle the visibility of the tooltip
	active_item_label.visible = !active_item_label.visible

func update_active_item_label():
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
		
func initialize_hotbar():
	for i in range(slots.size()):
		if i < len(PlayerInventory.hotbar):
			if PlayerInventory.hotbar[i]:
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
						var stack_size = int(ResourceData.item_data[slot.item.item_name].stacksize)
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
				temporary_slot = SlotClass.new()
				add_child(temporary_slot)
				temporary_slot.initialize_item(slot.item.item_name, amount_to_remove)
				find_parent("UI").holding_item = temporary_slot.item
				temporary_slot.remove_child(temporary_slot.item)
				temporary_slot.getFromSlot()
				find_parent("UI").holding_item.global_position = get_global_mouse_position()
