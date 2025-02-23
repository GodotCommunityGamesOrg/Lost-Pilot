extends Node
class_name PlInventory

signal active_item_updated
signal inventory_active_item_updated
signal equip_active_item_updated

# Constants defining the number of inventory and hotbar slots
const NUM_INVENTORY_SLOTS : int = 20
const NUM_HOTBAR_SLOTS : int = 8

# Preloaded classes for Item and Slot
const ItemClass = preload("res://scripts/ui/inventory/item.gd")
const SlotClass = preload("res://scripts/ui/inventory/slot.gd")

# Player Inventory Dictionary
var inventory = [
	["Repair Kit", 5], 
	["Med Kit", 10], 
	["Bandage", 30], 
	["Repair Kit", 2], 
	["Med Kit", 10], 
	["Bandage", 30], 
	["Repair Kit", 5], 
	["Food 1", 12], 
	["Fuel", 2], 
	["Intermediate Helmet", 1]
]

# Player Hotbar Dictionary
var hotbar = [
		["Repair Kit", 5],
		["Med Kit", 10],
		["Bandage", 30],
		["Repair Kit", 2],
		["Med Kit", 10],
		["Bandage", 20],
]

# Player Equip Dictionary
var equips = [
	["Basic Helmet", 1],
	["Basic Vest", 1], 
	["Basic Boots", 1], 
	["Weapon 1", 1]
]

# Keeps track of index of selected slots
var active_item_slot : int = 0

# Adds items to the inventory.
func add_item(item_name, item_quantity):
	for item in inventory:
		if inventory[item][0] == item_name:
			var stack_size : int = int(ResourceData.item_data[item_name].stacksize)
			var able_to_add : int = stack_size - inventory[item][1]
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
	var slot = get_tree().get_nodes_in_group("inv_slots")[slot_index]
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
			hotbar.append([item.item_name, item.item_quantity])
		SlotClass.SlotType.INVENTORY:
			inventory.append([item.item_name, item.item_quantity])
		_:
			equips.append([item.item_name, item.item_quantity])

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
	active_item_updated.emit()

# Changes the active item slot in the inventory and emit a signal
func change_inventory_active_item_slot(active_slot):
	active_item_slot = active_slot
	inventory_active_item_updated.emit()

func change_equip_active_item_slot(active_slot):
	active_item_slot = active_slot
	equip_active_item_updated.emit()
	
func active_inventory_item_scroll_up():
	active_item_slot = (active_item_slot + 1) % NUM_INVENTORY_SLOTS
	inventory_active_item_updated.emit()
	
func active_inventory_item_scroll_down():
	if active_item_slot == 0:
		active_item_slot = NUM_INVENTORY_SLOTS - 1
	else:
		active_item_slot -= 1
	inventory_active_item_updated.emit()

func active_item_scroll_up():
	active_item_slot = (active_item_slot + 1) % NUM_HOTBAR_SLOTS
	active_item_updated.emit()

func active_item_scroll_down():
	if active_item_slot == 0:
		active_item_slot = NUM_HOTBAR_SLOTS - 1
	else:
		active_item_slot -= 1
	active_item_updated.emit()
