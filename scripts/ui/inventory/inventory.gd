extends UserInterface

const SlotClass = preload("res://scripts/ui/inventory/slot.gd")
@onready var inventory_slots = $VBoxContainer2/PanelContainer2/HBoxContainer/GridContainer
@onready var equip_slots = $VBoxContainer2/PanelContainer2/HBoxContainer/VBoxContainer/EquipSlots.get_children()
@onready var tooltip = $Tooltip
@onready var ui = find_parent("UI")
var t = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var slots = get_tree().get_nodes_in_group("inv_slots")
	PlayerInventory.inventory_active_item_updated.connect(self.update_inventory_active_item_label)
	PlayerInventory.equip_active_item_updated.connect(self.update_equip_active_item_label)
	for i in range(slots.size()):
		slots[i].gui_input.connect(slot_gui_input.bind(slots[i]))
		slots[i].inventory_slot_index = i
		slots[i].slot_type = SlotClass.SlotType.INVENTORY
		PlayerInventory.inventory_active_item_updated.connect(slots[i].refresh_style)
	equip_slots[0].slot_type = SlotClass.SlotType.HELMET
	equip_slots[1].slot_type = SlotClass.SlotType.BODY
	equip_slots[2].slot_type = SlotClass.SlotType.BOOTS
	equip_slots[3].slot_type = SlotClass.SlotType.WEAPONS
	equip_slots[4].slot_type = SlotClass.SlotType.WEAPONS
	for i in range(equip_slots.size()):
		equip_slots[i].gui_input.connect(slot_gui_input.bind(equip_slots[i]))
		equip_slots[i].equip_slot_index = i
		PlayerInventory.equip_active_item_updated.connect(equip_slots[i].refresh_style)
	initialize_inventory()
	initialize_equip()
	update_inventory_active_item_label()
	update_equip_active_item_label()
		
func update_inventory_active_item_label():
	var slots = inventory_slots.get_children()
	tooltip.visible = true
	tooltip.set_position(Vector2(217,4))
	if slots[PlayerInventory.active_item_slot].item != null:
		tooltip.visible = true
		var info_slots = get_tree().get_nodes_in_group("Info_Slots")
		info_slots[0].text = str(ResourceData.item_data[slots[PlayerInventory.active_item_slot].item.item_name].item_category)
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
		elif ResourceData.item_data[slots[PlayerInventory.active_item_slot].item.item_name].super_category == "Clothes":
			info_slots[3].text = "Adds " + str(ResourceData.item_data[slots[PlayerInventory.active_item_slot].item.item_name].protection) + " Protection" 
			info_slots[4].text = "Adds " + str(ResourceData.item_data[slots[PlayerInventory.active_item_slot].item.item_name].insulation) + " Insulation"
		else:
			info_slots[3].text = ""
			info_slots[4].text = ""
	else:
		tooltip.visible = false
		
func update_equip_active_item_label():
	var slots = equip_slots
	tooltip.visible = true
	tooltip.set_position(Vector2(-140,4))
	if slots[PlayerInventory.active_item_slot].item != null:
		tooltip.visible = true
		var info_slots = get_tree().get_nodes_in_group("Info_Slots")
		info_slots[0].text = str(ResourceData.item_data[slots[PlayerInventory.active_item_slot].item.item_name].item_category)
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
		elif ResourceData.item_data[slots[PlayerInventory.active_item_slot].item.item_name].super_category == "Clothes":
			info_slots[3].text = "Protection: " + str(ResourceData.item_data[slots[PlayerInventory.active_item_slot].item.item_name].protection)
			info_slots[4].text = "Insulation: " + str(ResourceData.item_data[slots[PlayerInventory.active_item_slot].item.item_name].insulation)
		else:
			info_slots[3].text = ""
			info_slots[4].text = ""
	else:
		tooltip.visible = false
		
func initialize_inventory():
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		if i < len(PlayerInventory.inventory):
			if PlayerInventory.inventory[i]:
				slots[i].initialize_item(PlayerInventory.inventory[i][0], PlayerInventory.inventory[i][1])

func initialize_equip():
	var es = equip_slots
	for i in range(es.size()):
		if i < len(PlayerInventory.equips):
			if PlayerInventory.equips[i]:
				es[i].initialize_item(PlayerInventory.equips[i][0], PlayerInventory.equips[i][1])


func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if ui.holding_item != null:
				if !slot.item:
					if able_to_put_into_slot(slot):
						PlayerInventory.add_item_to_empty_slot(ui.holding_item, slot)
						slot.putIntoSlot(ui.holding_item)
						ui.holding_item = null
				else:
					if ui.holding_item.item_name != slot.item.item_name:
						if able_to_put_into_slot(slot):
							PlayerInventory.remove_item(slot)
							PlayerInventory.add_item_to_empty_slot(ui.holding_item, slot)
							var temp_item = slot.item
							slot.pickFromSlot()
							temp_item.global_position = event.global_position
							slot.putIntoSlot(ui.holding_item)
							ui.holding_item = temp_item
					else:
						if able_to_put_into_slot(slot):
							var stack_size = int(ResourceData.item_data[slot.item.item_name].stacksize)
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
			elif slot.item:
				PlayerInventory.remove_item(slot)
				ui.holding_item = slot.item
				slot.pickFromSlot()
				ui.holding_item.global_position = get_global_mouse_position()
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			if slot.item:
				var amount_to_remove = slot.item.item_quantity/2
				if amount_to_remove > 0:
					PlayerInventory.decrease_item_quantity(slot, amount_to_remove)
					slot.item.decrease_item_quantity(amount_to_remove)
					t = SlotClass.new()
					add_child(t)
					t.initialize_item(slot.item.item_name, amount_to_remove)
					ui.holding_item = t.item
					t.remove_child(t.item)
					t.getFromSlot()
					ui.holding_item.global_position = get_global_mouse_position()
				else:
					PlayerInventory.remove_item(slot)
					ui.holding_item = slot.item
					slot.pickFromSlot()
					ui.holding_item.global_position = get_global_mouse_position()

func _input(_event: InputEvent) -> void:
	if ui:
		if ui.holding_item:
			ui.holding_item.global_position = get_global_mouse_position()

func able_to_put_into_slot(slot):
	var holding_item = ui.holding_item
	if holding_item == null:
		return true
	var holding_item_category = ResourceData.item_data[holding_item.item_name].item_category
	if slot.slot_type == SlotClass.SlotType.HELMET:
		return holding_item_category == "Helmet"
	elif slot.slot_type == SlotClass.SlotType.BODY:
		return holding_item_category == "Vest"
	elif slot.slot_type == SlotClass.SlotType.BOOTS:
		return holding_item_category == "Boots"
	elif slot.slot_type == SlotClass.SlotType.WEAPONS:
		return holding_item_category == "Weapon"
	return true
