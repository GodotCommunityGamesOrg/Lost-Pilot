extends MenuBase

@export_group("Settings")
@export var database : ItemDatabase
@export var grid_container : GridContainer
@export var inventory_size : Vector2i = Vector2i(8,6)
@export var held_icon : Sprite2D

enum states {Empty,Held,Drop,PickUp,Swap,Add,Remove}
var current_state : states = states.Empty

var inventories : Dictionary[int,InventoryContainer]

var inventory : InventoryContainer
var held_item : InvItem
var current_id : int
var current_index : Vector2i
var swap_id : int
var swap_index : Vector2i


func _ready() -> void:
	var player_inv : InventoryContainer = _get_inventory(0) # 0 is the players inv
	player_inv.generate_cells(grid_container)
	# we need to generate the cells before we can load data, might not be the right way...
	player_inv.load_data(InventoryManager.player_items,database)
	# connect the slot pressed signal to a function in this script
	player_inv.slot_pressed.connect(on_slot_pressed)
	player_inv.slot_hovered.connect(handle_hover_tooltip)

func _process(delta: float) -> void:
	handle_state_update()

func on_slot_pressed(id : int,index : Vector2i) -> void:
	handle_state_transition(id,index)
	#print("Inventory (%s) was pressed at (%s)" % [id, index])

func _on_exit_button_pressed() -> void:
	menu_manager.switch_to_previous_menu()

## Handles logic that needs to be run constantly like moving a held item or checking if a pop up should show up
func handle_state_update() -> void:
	match current_state:
		states.Empty:
			pass
		states.Held:
			held_icon.global_position = get_global_mouse_position()
			
		states.Drop:
			drop()
			current_state = states.Empty
			
		states.PickUp:
			pickup()
			current_state = states.Held
			
		states.Add:
			pass
		states.Remove:
			pass
		states.Swap:
			swap_items()
			current_state = states.Held

## Handles the logic in each state e.g empty state you can pick up an item
func handle_state_transition(id:  int, index : Vector2i) -> void:
	match current_state:
		states.Empty:
			var inv : InventoryContainer = _get_inventory(id)
			if not inv.is_cell_free(index): # Check if we should pick up the item
				current_id = id
				current_index = index
				current_state = states.PickUp
		states.Held:
			var inv : InventoryContainer = _get_inventory(id)
			if inv.is_cell_free(index): # Check if the cell is empty
				current_id = id
				current_index = index
				current_state = states.Drop
			else:
				var cur_item : InvItem = inv.get_item(index)
				if held_item.id != cur_item.id:
					print("Items are not the same so swap them!")
					swap_id = id
					swap_index = index
					current_state = states.Swap
				
		states.Drop:
			pass
		states.PickUp:
			pass
		states.Add:
			pass
		states.Remove:
			pass
		states.Swap:
			pass

func handle_hover_tooltip(id : int, index : Vector2i) -> void:
	var inv : InventoryContainer = InventoryManager.get_inventory(id)
	## the hovered slot is empty
	if inv.is_cell_free(index):
		return
	
	## show a tooltip for the item, maybe we can also add options like consumbe,drop, etc
	var item : InvItem = inv.get_item(index)
	var item_data : Item = database.database[item.id]
	print("Item (%s) , Stack (%s)" % [item_data.item_name,item.stack])
	
func drop() -> void:
	# grab the inventory
	var inv : InventoryContainer = _get_inventory(current_id)
	# empty the held_icon and reset position
	held_icon.global_position = Vector2(-100,-100)
	held_icon.texture = null
	# update the held items origin index if we dont it returns to the previous index
	held_item.origin = current_index
	# add the item from the previous inventory
	inv.add_item(held_item)

func pickup() -> void:
	# grab the inventory
	var inv : InventoryContainer = _get_inventory(current_id)
	# set the item to the held_item
	held_item = inv.get_item(current_index)
	# set the texture from the held item
	held_icon.texture = held_item.icon
	# remove the item from the previous inventory
	inv.remove_item(held_item)

func swap_items() -> void:
	
	var to_inv : InventoryContainer = InventoryManager.get_inventory(swap_id)
	var to_item : InvItem = to_inv.get_item(swap_index)
	
	held_item.origin = swap_index
	to_inv.add_item(held_item)
	
	held_item = to_item
	held_icon.texture = held_item.icon

## Helper function to make it less painful to write
func _get_inventory(id : int) -> InventoryContainer:
	return InventoryManager.get_inventory(id)
