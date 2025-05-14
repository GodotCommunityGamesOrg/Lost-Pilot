extends Node
## Inventory manager, handles storing the inventory in a global space

var inventories : Dictionary[int,InventoryContainer]
var next_id : int = -1

## Player related
var inventory_size : Vector2i = Vector2i(8,6)
var player_inv : InventoryContainer
# this might change in the future for a better way of storing items
var player_items : Array[Dictionary] = [
	# ID is the item id, Position is the slot index, can add stack size here as well
		{"ID" : 0, "Position" : Vector2i(0,0)},
		{"ID" : 3, "Position" : Vector2i(4,1)},
		{"ID" : 2, "Position" : Vector2i(5,0)},
		{"ID" : 1, "Position" : Vector2i(2,4)}
	]

func _ready() -> void:
	player_inv = InventoryContainer.new(inventory_size)
	player_inv.set_id(register_inventory(player_inv))
	

func register_inventory(inventory : InventoryContainer) -> int:
	next_id += 1
	
	inventories[next_id] = inventory
	
	return next_id

# maybe in the future save logic could be here when an inventory is not in use
func unregister_inventory(id : int) -> void:
	inventories.erase(id)

func get_inventory(id : int) -> InventoryContainer:
	return inventories.get(id)
