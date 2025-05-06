extends MenuBase

@export_group("Settings")
@export var database : ItemDatabase
@export var grid_container : GridContainer
@export var inventory_size : Vector2i = Vector2i(8,6)

var inventory : InventoryContainer

func _ready() -> void:
	inventory = InventoryContainer.new(grid_container,inventory_size)
	# This setting of id should be dynamic to include other external inventories e.g chests, lockers
	# currently its not.
	inventory.set_id(0)
	inventory.generate_cells()
	
	# Temp for testing items in the inventory, should be a global thing
	var items : Array[Dictionary] = [
		{"ID" : 0, "Position" : Vector2i(0,0)},
		{"ID" : 3, "Position" : Vector2i(4,1)},
		{"ID" : 2, "Position" : Vector2i(5,0)},
		{"ID" : 1, "Position" : Vector2i(2,4)}
	]
	
	inventory.load_data(items,database)
	inventory.slot_pressed.connect(on_slot_pressed)

func on_slot_pressed(id : int,index : Vector2i) -> void:
	print("Inventory (%s) was pressed at (%s)" % [id, index])

func _on_exit_button_pressed() -> void:
	menu_manager.switch_to_previous_menu()
