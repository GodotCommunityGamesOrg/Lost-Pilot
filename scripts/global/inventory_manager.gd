extends Node
## Inventory manager, handles storing the inventory in a global space
## each time a new inventory is added it gets a new id
## potentional issue is if the player opens to many inventories and the next id 
## somehow becomes to big which I dont think will ever happen but we never know...

#var inventories : Dictionary[int,InventoryContainer]
var inventories : Array[InventoryContainer]
var next_id : int = 0

## Player related
var inventory_size : Vector2i = Vector2i(8,6)
var player_inv : InventoryContainer = InventoryContainer.new(inventory_size)
# this might change in the future for a better way of storing items
var player_items : ItemInventory = preload("res://scripts/inventory_system/temp folder/player_inventory.tres")


func _ready() -> void:
	#player_inv = 
	register_inventory(player_inv)

func register_inventory(inv : InventoryContainer) -> void:
	
	## if the id is -1, it means the inventory has not been set
	match inv.get_id():
		-1:
			inventories.append(inv)
			inv.set_id(next_id)
			## this might not be needed if we just use the array size, leaving it for now.
			next_id += 1
		_:
			inventories[inv.get_id()] = inv
	
func unregister_inventory(id : int) -> void:
	## when we want to not use an inventory it is better to set it to null
	## this is because we dont want to shuffle the array and also cause mismatch inventory IDs.
	inventories[id] = null

func get_inventory(id : int) -> InventoryContainer:
	return inventories.get(id)
