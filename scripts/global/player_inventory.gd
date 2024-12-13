extends Node

signal active_item_updated
signal inventory_active_item_updated

# Constants defining the number of inventory and hotbar slots
const NUM_INVENTORY_SLOTS = 20
const NUM_HOTBAR_SLOTS = 8

# Preloaded classes for Item and Slot
const ItemClass = preload("res://scripts/ui/inventory/item.gd")
const SlotClass = preload("res://scripts/ui/inventory/slot.gd")

# Player Inventory Dictionary
var inventory = {
	0 : ["Repair Kit", 5],
	1 : ["Med Kit", 10],
	2 : ["Bandage", 30],
	3 : ["Repair Kit", 2],
	4 : ["Med Kit", 10],
	5 : ["Bandage", 30],
	6 : ["Repair Kit", 5],
	7 : ["Food 1", 12],
	8 : ["Fuel", 2],
	9 : ["Intermediate Helmet", 1],
}

# Player Hotbar Dictionary
var hotbar = {
	0 : ["Repair Kit", 5],
	1 : ["Med Kit", 10],
	2 : ["Bandage", 30],
	3 : ["Repair Kit", 2],
	4 : ["Med Kit", 10],
	5 : ["Bandage", 20],
}

# Player Equip Dictionary
var equips = {
	0 : ["Basic Helmet", 1],
	1 : ["Basic Vest", 1],
	2 : ["Basic Boots", 1],
	3 : ["Weapon 1", 1],
}
# Keeps track of index of selected slots
var active_item_slot = 0

# Adds items to the inventory.
func add_item(item_name, item_quantity):
	for item in inventory:
		if inventory[item][0] == item_name:
			var stack_size = int(JsonData.item_data[item_name]["StackSize"])
			var able_to_add = stack_size - inventory[item][1]
			if able_to_add >= item_quantity:
				inventory[item][1] += item_quantity
				update_slot_visual(item, inventory[item][0], inventory[item][1])
				return
			else:
				inventory[item][1] += able_to_add
				update_slot_visual(item, inventory[item][0], inventory[item][1])
				item_quantity = item_quantity - able_to_add
	for i in range(NUM_INVENTORY_SLOTS):
		if inventory.has(i) == false:
			inventory[i] = [item_name, item_quantity]
			update_slot_visual(i, inventory[i][0], inventory[i][1])
			return
		
# Updates the visual inventory
func update_slot_visual(slot_index, item_name, new_quantity):
	var slot = get_tree().root.get_node("/root/World/UI/Inventory/GridContainer/Slot" + str(slot_index + 1))
	if slot.item != null:
		slot.item.set_item(item_name, new_quantity)
	else:
		slot.initialize_item(item_name, new_quantity)

# Removes items from the inventory.
func remove_item(slot : SlotClass):
	match slot.SlotType:
		SlotClass.SlotType.HOTBAR:
			hotbar.erase(slot.slot_index)
		SlotClass.SlotType.INVENTORY:
			inventory.erase(slot.slot_index)
		_:
			equips.erase(slot.slot_index)
			
# Adds items to empty slots in the inventory.
func add_item_to_empty_slot(item : ItemClass, slot : SlotClass):
	match slot.SlotType:
		SlotClass.SlotType.HOTBAR:
			hotbar[slot.slot_index] = [item.item_name, item.item_quantity]
		SlotClass.SlotType.INVENTORY:
			inventory[slot.slot_index] = [item.item_name, item.item_quantity]
		_:
			equips[slot.slot_index] = [item.item_name, item.item_quantity]

# Adds quantity to items in the inventory
func add_item_quantity(slot : SlotClass, quantity_to_add : int):
	match slot.SlotType:
		SlotClass.SlotType.HOTBAR:
			hotbar[slot.slot_index][1] += quantity_to_add
		SlotClass.SlotType.INVENTORY:
			inventory[slot.slot_index][1] += quantity_to_add

# Removes quantity from items in the inventory
func decrease_item_quantity(slot : SlotClass, quantity_to_remove : int):
	match slot.SlotType:
		SlotClass.SlotType.HOTBAR:
			hotbar[slot.slot_index][1] -= quantity_to_remove
		SlotClass.SlotType.INVENTORY:
			inventory[slot.slot_index][1] -= quantity_to_remove

# Changes the active item slot in the hotbar and emit a signal
func change_active_item_slot(active_slot):
	active_item_slot = active_slot
	emit_signal("active_item_updated")

# Changes the active item slot in the inventory and emit a signal
func change_inventory_active_item_slot(active_slot):
	active_item_slot = active_slot
	emit_signal("inventory_active_item_updated")
	
func active_inventory_item_scroll_up():
	active_item_slot = (active_item_slot + 1) % NUM_INVENTORY_SLOTS
	emit_signal("inventory_active_item_updated")
	
func active_inventory_item_scroll_down():
	if active_item_slot == 0:
		active_item_slot = NUM_INVENTORY_SLOTS - 1
	else:
		active_item_slot -= 1
	emit_signal("inventory_active_item_updated")

func active_item_scroll_up():
	active_item_slot = (active_item_slot + 1) % NUM_HOTBAR_SLOTS
	emit_signal("active_item_updated")
	
func active_item_scroll_down():
	if active_item_slot == 0:
		active_item_slot = NUM_HOTBAR_SLOTS - 1
	else:
		active_item_slot -= 1
	emit_signal("active_item_updated")
