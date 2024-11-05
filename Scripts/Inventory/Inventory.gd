extends UserInterface

const SlotClass = preload("res://Scripts/Inventory/Slot.gd")
@onready var inventory_slots:GridContainer = $VBoxContainer/TextureRect/VBoxContainer/GridContainer
@onready var equip_slots: Array = $VBoxContainer/TextureRect/VBoxContainer/EquipSlots.get_children()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		slots[i].gui_input.connect(slot_gui_input.bind(slots[i]))
		slots[i].slot_index = i
		slots[i].slot_type = SlotClass.SlotType.INVENTORY
	for i in range(equip_slots.size()):
		equip_slots[i].gui_input.connect(slot_gui_input.bind(equip_slots[i]))
		equip_slots[i].slot_index = i
	equip_slots[0].slot_type = SlotClass.SlotType.HELMET
	equip_slots[1].slot_type = SlotClass.SlotType.BODY
	equip_slots[2].slot_type = SlotClass.SlotType.BOOTS
	equip_slots[3].slot_type = SlotClass.SlotType.WEAPONS
	equip_slots[4].slot_type = SlotClass.SlotType.WEAPONS
	initialize_inventory()
	initialize_equip()
		
func initialize_inventory():
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		if PlayerInventory.inventory.has(i):
			slots[i].initialize_item(PlayerInventory.inventory[i][0], PlayerInventory.inventory[i][1])

func initialize_equip():
	var es = equip_slots
	for i in range(es.size()):
		if PlayerInventory.equips.has(i):
			es[i].initialize_item(PlayerInventory.equips[i][0], PlayerInventory.equips[i][1])

func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if find_parent("UI").holding_item != null:
				if !slot.item:
					if able_to_put_into_slot(slot):
						PlayerInventory.add_item_to_empty_slot(find_parent("UI").holding_item, slot)
						slot.putIntoSlot(find_parent("UI").holding_item)
						find_parent("UI").holding_item = null
				else:
					if find_parent("UI").holding_item.item_name != slot.item.item_name:
						if able_to_put_into_slot(slot):
							PlayerInventory.remove_item(slot)
							PlayerInventory.add_item_to_empty_slot(find_parent("UI").holding_item, slot)
							var temp_item = slot.item
							slot.pickFromSlot()
							temp_item.global_position = event.global_position
							slot.putIntoSlot(find_parent("UI").holding_item)
							find_parent("UI").holding_item = temp_item
					else:
						if able_to_put_into_slot(slot):
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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if find_parent("UI").holding_item:
			find_parent("UI").holding_item.global_position = get_global_mouse_position()

func able_to_put_into_slot(slot):
	var holding_item = find_parent("UI").holding_item
	if holding_item == null:
		return true
	var holding_item_category = JsonData.item_data[holding_item.item_name]["ItemCategory"]
	if slot.slot_type == SlotClass.SlotType.HELMET:
		return holding_item_category == "Helmet"
	elif slot.slot_type == SlotClass.SlotType.BODY:
		return holding_item_category == "Vest"
	elif slot.slot_type == SlotClass.SlotType.BOOTS:
		return holding_item_category == "Boots"
	elif slot.slot_type == SlotClass.SlotType.WEAPONS:
		return holding_item_category == "Weapon"
	return true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
